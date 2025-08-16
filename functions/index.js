/* eslint-disable */

const {
  onDocumentUpdated,
  onDocumentCreated
} = require('firebase-functions/v2/firestore')
const { logger } = require('firebase-functions')
const { onSchedule } = require('firebase-functions/v2/scheduler')
const admin = require('firebase-admin')
const nodemailer = require('nodemailer')
const axios = require('axios')
const express = require('express')
const cors = require('cors')
const { json } = require('body-parser')

admin.initializeApp()
const messaging = admin.messaging()
const db = admin.firestore()
const auth = admin.auth()
const { event } = require('firebase-functions/v1/analytics')
const { onCall, onRequest } = require('firebase-functions/v2/https')
const app = express()
app.use(json())
app.use(cors({ origin: true }))
app.use(express.json())

const PAYSTACK_SECRET_KEY = process.env.PAYSTACK_SECRET_KEY
const PAYSTACK_LIVE_SECRET_KEY = process.env.PAYSTACK_LIVE_SECRET_KEY
const paystackApi = axios.create({
  baseURL: 'https://api.paystack.co',
  headers: {
    Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`,
    'Content-Type': 'application/json'
  }
})

async function getAdminVariables() {
  try {
    const data = await db.collection('admin variables').doc('admin').get()
    const adminVariables = data.data()
    return adminVariables
  } catch (error) {
    logger.error(`An error occured ${error}`)
  }
}

/**
 * Send an FCM notification and log the result.
 */
async function sendFcmNotification(topic, body, title, data, receiver) {
  const message = {
    notification: { title, body },
    data: { orderID: data, receiver },
    topic
  }
  try {
    await messaging.send(message)
    logger.info('FCM notification sent successfully')
  } catch (error) {
    logger.error(`Error sending FCM notification: ${error}`)
  }
}

/**
 * Send an email and log the result.
 */
async function sendEmail(email, subject, body) {
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL,
      pass: process.env.APPPASSWORD
    }
  })

  const mailOptions = {
    from: 'hairmainstreetofficial01@gmail.com',
    to: email,
    subject,
    html: body
  }

  try {
    await transporter.sendMail(mailOptions)
    logger.info('Email sent successfully')
  } catch (error) {
    logger.error(`Error sending email: ${error}`)
  }
}

/**
 * Send notification and email to a user.
 */
async function notifyUser({
  userID,
  orderID,
  receiver,
  fcmTitle,
  fcmBody,
  email,
  emailSubject,
  emailBody
}) {
  // Store notification in Firestore
  await db
    .collection('notifications')
    .doc(userID)
    .collection('notifications')
    .add({
      userID,
      'extra data': { orderID, receiver },
      title: fcmTitle,
      body: fcmBody,
      'time stamp': admin.firestore.FieldValue.serverTimestamp()
    })

  // Send FCM notification
  await sendFcmNotification(
    `${receiver}_${userID}`,
    fcmBody,
    fcmTitle,
    orderID,
    receiver
  )

  // Send email if email is provided
  if (email) {
    await sendEmail(email, emailSubject, emailBody)
  }

  return 'success'
}

exports.notifyBuyerOnOrderStatusChange = onDocumentUpdated(
  'orders/{orderId}',
  async event => {
    const newOrderData = event.data.after.data()
    const oldOrderData = event.data.before.data()

    if (
      newOrderData['order status'] !== oldOrderData['order status'] &&
      newOrderData['order status'] !== 'expired'
    ) {
      const buyerId = newOrderData['buyerID']
      const orderID = event.params.orderId
      const fcmTitle = 'Order Status Update'
      const fcmBody = `Your order has been ${newOrderData['order status']},\nKindly Confirm`

      try {
        await db.runTransaction(async transaction => {
          // Get buyer data within the transaction
          const buyerDocRef = db.collection('userProfile').doc(buyerId)
          const buyerDoc = await transaction.get(buyerDocRef)
          if (!buyerDoc.exists) {
            throw new Error(`Buyer with ID ${buyerId} not found`)
          }
          const buyerData = buyerDoc.data()

          // Add notification to Firestore within the transaction
          const notificationRef = db
            .collection('notifications')
            .doc(buyerId)
            .collection('notifications')
            .doc()
          transaction.set(notificationRef, {
            userID: buyerId,
            'extra data': { orderID: orderID, receiver: 'buyer' },
            title: fcmTitle,
            body: fcmBody,
            'time stamp': admin.firestore.FieldValue.serverTimestamp()
          })

          // Attach email and token to transaction result for use outside transaction
          transaction.set(db.collection('temp_notify_results').doc(orderID), {
            email: buyerData['email'] || null,
            token: buyerData['token'] || null,
            fullname: buyerData['fullname'] || ''
          })
        })

        // Fetch email and token from temp_notify_results (not strictly necessary, but ensures atomicity)
        const tempDoc = await db
          .collection('temp_notify_results')
          .doc(orderID)
          .get()
        const tempData = tempDoc.data() || {}
        const email = tempData.email
        const fullname = tempData.fullname

        // Use notifyUser helper for FCM and email (outside transaction)
        await notifyUser({
          userID: buyerId,
          orderID,
          receiver: 'buyer',
          fcmTitle,
          fcmBody,
          email,
          emailSubject: 'Order Status Update',
          emailBody: `
            <h2 style="font-size: 24px; color:#673AB7">Hair Main Street</h2>
            <p style="font-size: 18px">Dear ${fullname},</p>
            <p style="font-size: 18px">Your order with ID: ${orderID} has been ${newOrderData['order status']}, Kindly Confirm.</p>
          `
        })

        // Clean up temp doc
        await db.collection('temp_notify_results').doc(orderID).delete()
      } catch (error) {
        logger.error('Error notifying buyer on order status change:', error)
      }
    }

    return null
  }
)

exports.notifyOnOrderCreation = onDocumentCreated(
  'orders/{orderId}',
  async event => {
    const orderData = event.data.data()
    const buyerId = orderData.buyerID
    const buyerDoc = await db.collection('userProfile').doc(buyerId).get()
    const buyerData = buyerDoc.data()
    const vendorID = orderData.vendorID
    const vendorDoc = await db.collection('userProfile').doc(vendorID).get()
    const vendorData = vendorDoc.data()
    const orderID = event.params.orderId
    const fcmTitle = 'New Order Created'
    const vendorFcmBody = 'You have a new order for your product'
    const buyerFcmBody = 'Your order has been created'
    const emailSubject = 'New Order Created'
    const buyerEmailBody = `
    <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
    <p style="font-size: 18px">Dear ${buyerData['fullname']},</p>
    <p style="font-size: 18px">Your order with ID: ${orderID} has been successfully created.</p>
    `
    const vendorEmailBody = `
    <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
    <p style="font-size: 18px">Dear ${vendorData['fullname']},</p>
    <p style="font-size: 18px">You have a new order for your product with ID: ${orderID}.</p>
  `
    await Promise.all([
      notifyUser({
        userID: buyerId,
        orderID: orderID,
        receiver: 'buyer',
        fcmTitle: fcmTitle,
        fcmBody: buyerFcmBody,
        email: buyerData['email'],
        emailSubject: emailSubject,
        emailBody: buyerEmailBody
      }),
      notifyUser({
        userID: vendorID,
        orderID: orderID,
        receiver: 'vendor',
        fcmTitle: fcmTitle,
        fcmBody: vendorFcmBody,
        email: vendorData['email'],
        emailSubject: emailSubject,
        emailBody: vendorEmailBody
      })
    ])

    return null
  }
)

exports.updateWalletAfterOrderPlacement = onDocumentCreated(
  'orders/{orderId}',
  async event => {
    const order = event.data.data()
    const vendorId = order.vendorID
    const paymentPrice = order['payment price']
    const orderId = event.params.orderId

    // Check if wallet exists for the vendor
    const walletRef = db.collection('wallet').doc(vendorId)
    const walletSnapshot = await walletRef.get()

    if (walletSnapshot.exists) {
      // Wallet exists, update balance
      const walletData = walletSnapshot.data()

      // Update balance
      await walletRef.update({
        balance: admin.firestore.FieldValue.increment(paymentPrice)
      })
    } else {
      // Wallet does not exist, create new wallet document
      await walletRef.set({
        balance: paymentPrice
      })
    }

    const transactionRef = db
      .collection('wallet')
      .doc(vendorId)
      .collection('transactions')
      .doc(orderId)
    await transactionRef.set({
      orderId: orderId,
      type: 'credit',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      amount: paymentPrice
    })

    logger.info('Wallet updated successfully')
    return null
  }
)

exports.updateWalletAfterInstallmentPayment = onDocumentUpdated(
  'orders/{orderID}',
  async event => {
    try {
      const orderID = event.params.orderID
      const previousData = event.data.before.data()
      const newData = event.data.after.data()

      const previousAmountPaid = previousData['payment price']
      const newAmountPaid = newData['payment price']
      const difference = newAmountPaid - previousAmountPaid

      // Only proceed if payment price increased (installment payment made)
      if (!previousAmountPaid || !newAmountPaid || difference <= 0) {
        // No payment made, or payment price did not increase
        return null
      }

      const walletRef = db.collection('wallet').doc(newData.vendorID)
      const vendorID = newData.vendorID
      const walletSnapshot = await walletRef.get()

      if (walletSnapshot.exists) {
        //update wallet balance
        await walletRef.update({
          balance: admin.firestore.FieldValue.increment(difference)
        })

        logger.info('Wallet updated successfully')
      } else {
        logger.info('Wallet does not exist,hence creating a wallet')
        // Wallet does not exist, create new wallet document
        await walletRef.set({
          balance: admin.firestore.FieldValue.increment(difference)
        })
        logger.info('Wallet created successfully')
      }

      // Create a transaction record for the installment payment
      const transactionRef = db
        .collection('wallet')
        .doc(vendorID)
        .collection('transactions')
        .doc(orderID)
      await transactionRef.set({
        orderId: orderID,
        type: 'credit',
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        amount: difference
      })

      // If the total payment is now complete, send notifications
      if (newData['payment price'] === newData['total price']) {
        const buyerId = newData.buyerID
        const buyerDoc = await db.collection('userProfile').doc(buyerId).get()
        const buyerData = buyerDoc.data()
        const vendorDoc = await db.collection('userProfile').doc(vendorID).get()
        const vendorData = vendorDoc.data()
        const fcmTitle = 'Installment Payment Complete'
        const vendorFcmBody =
          'The buyer has completed his installment payment for your product'
        const buyerFcmBody = 'You have completed your installment payment'
        const emailSubject = 'Installment Payment Complete'
        const buyerEmailBody = `
        <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
        <p style="font-size: 18px">Dear ${buyerData['fullname']},</p>
        <p style="font-size: 18px">You have successfully completed your installment payment for the order with ID: ${orderID}. Open the app to review.</p>
      `
        const vendorEmailBody = `
        <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
        <p style="font-size: 18px">Dear ${vendorData['fullname']},</p>
        <p style="font-size: 18px">The buyer has completed the installment payment for the order with ID: ${orderID}. Open the app to review</p>
      `

        await Promise.all([
          notifyUser({
            userID: buyerId,
            orderID: orderID,
            receiver: 'buyer',
            fcmTitle: fcmTitle,
            fcmBody: buyerFcmBody,
            email: buyerData['email'],
            emailSubject: emailSubject,
            emailBody: buyerEmailBody
          }),
          notifyUser({
            userID: vendorID,
            orderID: orderID,
            receiver: 'vendor',
            fcmTitle: fcmTitle,
            fcmBody: vendorFcmBody,
            email: vendorData['email'],
            emailSubject: emailSubject,
            emailBody: vendorEmailBody
          })
        ])
      }
    } catch (error) {
      logger.error('Entire function failed in its implementation')
    }
  }
)

exports.updateProductStockOnOrderPlacement = onDocumentCreated(
  'orders/{orderId}',
  async event => {
    const orderId = event.params.orderId

    try {
      await db.runTransaction(async transaction => {
        const orderItemDoc = await db
          .collection('orders')
          .doc(orderId)
          .collection('order items')
          .doc(orderId)
          .get()
        const orderItemData = orderItemDoc.data()
        const productRef = db
          .collection('products')
          .doc(orderItemData['productID'])
        const snapshot = transaction.get(productRef)
        const quantityOrdered = Number(orderItemData['quantity'])
        const previousQuantity = (await snapshot).data().quantity
        const newQuantity = previousQuantity - quantityOrdered
        if (newQuantity < 0) {
          throw new Error(
            `Insufficient stock for product ${orderItemData['productID']}`
          )
        }
        //send notification to vendor if stock quantity is < 5
        if (newQuantity < 5) {
          const orderRef = db.collection('orders').doc(orderId)
          const orderData = (await orderRef.get()).data()
          const vendorID = orderData.vendorID
          const productDoc = await db
            .collection('products')
            .doc(orderItemData['productID'])
            .get()
          const vendorDoc = await db
            .collection('userProfile')
            .doc(vendorID)
            .get()
          const vendorData = vendorDoc.data()
          const productData = productDoc.data()
          await notifyUser({
            userID: vendorID,
            orderID: orderId,
            receiver: 'vendor',
            fcmTitle: 'Low Stock Alert',
            fcmBody: `The stock for product "${productData['name']}" is running low. Only ${newQuantity} left.`,
            email: vendorData['email'],
            emailSubject: 'Low Stock Alert',
            emailBody: `
        <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
        <p style="font-size: 16px">Dear ${vendorData['fullname']},</p>
        <p style="font-size: 16px">The stock for product ${productData['name']} is running low. Only ${newQuantity} left.</p>
      `
          })
        }
        transaction.update(productRef, { quantity: newQuantity })
      })
      logger.info('Stock quantity updated successfully')
    } catch (error) {
      logger.error(`Stock update failed ${error}`)
    }
  }
)

exports.processConfirmedOrder = onDocumentUpdated(
  'orders/{orderId}',
  async event => {
    const orderData = event.data.after.data()
    const previousOrderData = event.data.before.data()

    // Check if the order status changed to "confirmed"
    if (
      orderData['order status'] === 'confirmed' &&
      previousOrderData['order status'] !== 'confirmed'
    ) {
      const vendorId = orderData.vendorID // Assuming there's a field called "vendorId" in your order document
      const amountToRemit = orderData['payment price'] // Adjust this based on your data model

      // Update the vendor's wallet collection
      const walletRef = db.collection('wallet').doc(vendorId)
      const walletDoc = await walletRef.get()

      if (walletDoc.exists) {
        const data = walletDoc.data()
        // ensure the wallet has a 'withdrawable balance' field
        if (!data.hasOwnProperty('withdrawable balance')) {
          await walletRef.set({ 'withdrawable balance': 0 }, { merge: true })
        }
        // Update the wallet with the new amount
        await walletRef.update({
          'withdrawable balance':
            admin.firestore.FieldValue.increment(amountToRemit)
        })

        logger.info(`Amount remitted to vendor (${vendorId}): ${amountToRemit}`)

        const orderData = event.data.data()
        const buyerId = orderData.buyerID
        const buyerDoc = await db.collection('userProfile').doc(buyerId).get()
        const buyerData = buyerDoc.data()
        const vendorID = orderData.vendorID
        const vendorDoc = await db.collection('userProfile').doc(vendorID).get()
        const vendorData = vendorDoc.data()
        const orderID = event.params.orderId
        const fcmTitle = 'Order Confirmed'
        const vendorFcmBody =
          'The buyer has confirmed receipt of the order for your product'
        const buyerFcmBody =
          'Your order has been confirmed, kindly leave a review'
        const emailSubject = 'Order Confirmed'
        const buyerEmailBody = `
        <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
        <p style="font-size: 18px">Dear ${buyerData['fullname']},</p>
        <p style="font-size: 18px">Your order with ID: ${orderID} has been successfully confirmed. Kindly visit the app to leave a review</p>
      `
        const vendorEmailBody = `
        <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
        <p style="font-size: 18px">Dear ${vendorData['fullname']},</p>
        <p style="font-size: 18px">The buyer has confirmed the receipt of the order for your product with ID: ${orderID}.</p>
      `
        await Promise.all([
          notifyUser({
            userID: buyerId,
            orderID: orderID,
            receiver: 'buyer',
            fcmTitle: fcmTitle,
            fcmBody: buyerFcmBody,
            email: buyerData['email'],
            emailSubject: emailSubject,
            emailBody: buyerEmailBody
          }),
          notifyUser({
            userID: vendorID,
            orderID: orderID,
            receiver: 'vendor',
            fcmTitle: fcmTitle,
            fcmBody: vendorFcmBody,
            email: vendorData['email'],
            emailSubject: emailSubject,
            emailBody: vendorEmailBody
          })
        ])
        return null
      } else {
        logger.error(`Wallet not found for vendor (${vendorId})`)
        return null
      }
    }

    return null
  }
)

exports.processExpiredOrder = onDocumentUpdated(
  'orders/{orderId}',
  async event => {
    const orderId = event.params.orderId
    const orderData = event.data.after.data()
    const previousOrderData = event.data.before.data()

    // Check if the order status changed to "expired"
    if (
      orderData['order status'] === 'expired' &&
      previousOrderData['order status'] !== 'expired'
    ) {
      const adminVariables = await getAdminVariables()
      const buyerId = orderData.buyerID
      const buyerDoc = await db.collection('userProfile').doc(buyerId).get()
      const buyerData = buyerDoc.data()
      const vendorID = orderData.vendorID
      const vendorDoc = await db.collection('userProfile').doc(vendorID).get()
      const vendorData = vendorDoc.data()
      const fcmTitle = 'Order Expired'
      const vendorFcmBody = `The order for your product with ID: ${orderId} has expired.  Amount paid already would be refunded back to the buyers account `
      const buyerFcmBody = `Your order with ID: ${orderId} has expired, The amount paid for the order will be refunded according to terms and conditions.`
      const emailSubject = 'Order Expired'
      const buyerEmailBody = `
      <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
    <p style="font-size: 16px">Dear ${buyerData['fullname']},</p>
    <p style="font-size: 16px">Your order with ID: ${orderId} has expired.</p>
    <p style="font-size: 16px">The amount paid for the order will be refunded according to terms and conditions.</p>
    <p style="font-size: 16px">Visit the app to add your account details for a refund.</p>
  `
      const vendorEmailBody = `
      <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
    <p style="font-size: 16px">Dear ${vendorData['fullname']},</p>
    <p style="font-size: 16px">The order for your product with ID: ${orderId} has expired. Amount paid already would be refunded back to the buyers account </p>
    
  `

      const adminEmail = process.env.ADMIN_EMAIL
      const adminBody = `<p style="font-size: 18px">An order with ID : ${orderId} from the vendor ${vendorData['shop name']} has expired</p>`
      const adminSubject = `Order Expired`

      //also return the stock back to the product
      try {
        await db.runTransaction(async transaction => {
          const orderItemDoc = await db
            .collection('orders')
            .doc(orderId)
            .collection('order items')
            .doc(orderId)
            .get()
          const orderItemData = orderItemDoc.data()
          const productRef = db
            .collection('products')
            .doc(orderItemData['productID'])
          const snapshot = transaction.get(productRef)
          const quantityOrdered = Number(orderItemData['quantity'])
          const previousQuantity = (await snapshot).data().quantity
          const newQuantity = previousQuantity + quantityOrdered
          transaction.update(productRef, { quantity: newQuantity })
        })
        logger.info('Stock quantity updated successfully')
      } catch (error) {
        logger.error(`Stock update failed ${error}`)
      }

      await Promise.all([
        notifyUser({
          userID: buyerId,
          orderID: orderId,
          receiver: 'buyer',
          fcmTitle: fcmTitle,
          fcmBody: buyerFcmBody,
          email: buyerData['email'],
          emailSubject: emailSubject,
          emailBody: buyerEmailBody
        }),
        notifyUser({
          userID: vendorID,
          orderID: orderId,
          receiver: 'vendor',
          fcmTitle: fcmTitle,
          fcmBody: vendorFcmBody,
          email: vendorData['email'],
          emailSubject: emailSubject,
          emailBody: vendorEmailBody
        }),
        sendEmail(adminEmail, adminSubject, adminBody)
      ])

      return null
    }
  }
)

exports.dailyInstallmentCheck = onSchedule('every 24 hours', async () => {
  const now = Date.now()
  const threeDays = 3 * 24 * 60 * 60 * 1000
  const oneDay = 24 * 60 * 60 * 1000

  try {
    // Get all active installment orders
    const orders = await db
      .collection('orders')
      .where('payment method', '==', 'installment')
      .where('order status', '!=', 'expired')
      .get()

    const [adminVars, vendors, buyers] = await Promise.all([
      getAdminVariables(),
      getVendorsMap(),
      getBuyersMap()
    ])

    for (const doc of orders.docs) {
      const order = doc.data()
      const orderId = doc.id

      // Calculate payment status on-the-fly
      const paymentInfo = calculatePaymentStatus(order, adminVars, vendors)

      if (!paymentInfo.needsNextPayment) continue

      const timeUntilDue = paymentInfo.nextDueDate - now
      const reminderKey = `${orderId}_${paymentInfo.nextInstallment}`

      if (timeUntilDue < 0) {
        // Expired
        await expireOrder(orderId)
        await notify(order.buyerID, buyers, 'expired', orderId)
      } else if (
        timeUntilDue <= oneDay &&
        !(await reminderSent(reminderKey, '1day'))
      ) {
        await sendReminder(order.buyerID, buyers, '1 day', orderId)
        await markReminderSent(reminderKey, '1day')
      } else if (
        timeUntilDue <= threeDays &&
        !(await reminderSent(reminderKey, '3day'))
      ) {
        await sendReminder(order.buyerID, buyers, '3 days', orderId)
        await markReminderSent(reminderKey, '3day')
      }
    }

    return null
  } catch (error) {
    console.error('Error in daily check:', error)
    return null
  }
})

// =============================================================================
// CALCULATION FUNCTIONS
// =============================================================================

function calculatePaymentStatus(order, adminVars, vendors) {
  const installmentsPaid = order['installment paid'] || 1
  const totalInstallments = order['installment number'] || 1

  // All payments done
  if (installmentsPaid >= totalInstallments) {
    return { needsNextPayment: false }
  }

  // Get duration
  const vendor = vendors[order.vendorID]
  const duration =
    vendor?.['installment duration'] || adminVars['installment duration']

  // Calculate next due date
  const createdAt = order['created at'].seconds * 1000
  const nextDueDate = createdAt + installmentsPaid * duration

  return {
    needsNextPayment: true,
    nextInstallment: installmentsPaid + 1,
    nextDueDate: nextDueDate
  }
}

// =============================================================================
// SIMPLE REMINDER TRACKING (using a single document)
// =============================================================================

async function reminderSent(reminderKey, type) {
  const doc = await db.collection('reminders').doc('daily').get()
  const data = doc.data() || {}
  return data[`${reminderKey}_${type}`] === true
}

async function markReminderSent(reminderKey, type) {
  await admin
    .firestore()
    .collection('reminders')
    .doc('daily')
    .set(
      {
        [`${reminderKey}_${type}`]: true
      },
      { merge: true }
    )
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

async function getVendorsMap() {
  const vendors = await db.collection('vendors').get()
  const map = {}
  vendors.forEach(doc => (map[doc.id] = doc.data()))
  return map
}

async function getBuyersMap() {
  const buyers = await db.collection('userProfile').get()
  const map = {}
  buyers.forEach(doc => (map[doc.id] = doc.data()))
  return map
}

async function expireOrder(orderId) {
  await db.collection('orders').doc(orderId).update({
    'order status': 'expired'
  })
}

async function sendReminder(buyerId, buyers, timeframe, orderId) {
  const buyer = buyers[buyerId]
  if (!buyer) return

  const message = `Payment due in ${timeframe}`
  await notify(buyerId, buyers, 'reminder', orderId, message)
}

async function notify(buyerId, buyers, type, orderId, customMessage = '') {
  const buyer = buyers[buyerId]
  if (!buyer) return

  const messages = {
    expired: `Order #${orderId} has expired. Please place a new order.`,
    reminder: customMessage || `Payment reminder for Order #${orderId}`
  }

  const title = type === 'expired' ? 'Order Expired' : 'Payment Reminder'
  const body = messages[type]

  await Promise.all([
    notifyUser({
      userID: buyerId,
      orderID: orderId,
      receiver: 'buyer',
      fcmTitle: title,
      fcmBody: body,
      email: buyer['email'],
      emailSubject: title,
      emailBody: `
        <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
        <p style="font-size: 16px">Dear ${buyer['fullname']},</p>
        <p style="font-size: 16px">${body}</p>
      `
    })
  ])
}

exports.sendEmailToAdminOnVendorCreation = onDocumentCreated(
  'vendors/{vendorId}',
  async event => {
    try {
      // Get the newly created vendor data
      const vendorData = event.data.data()

      // Send email notification to admin
      const adminEmail = process.env.ADMIN_EMAIL // Replace with your admin email
      const subject = 'Vendor Request Submitted'
      const message = `<h2 style="font-size: 24px">Vendor request form has been Submitted</h2>
      <h4 style="font-size: 20px">Details:</h4>
      <p style="font-size: 16px">Shop Name: ${vendorData['shop name']}</p>
      <p style="font-size: 16px">Shop Link: ${vendorData['shop link']}</p>
      <p style="font-size: 16px">Account Information: ${vendorData['account info']}</p>
      <p style="font-size: 16px">Contact Information: ${vendorData['contact info']}</p>
      `

      await sendEmail(adminEmail, subject, message)

      logger.info('Email notification sent to admin successfully')
    } catch (error) {
      logger.error('Error sending email notification:', error)
    }
  }
)

exports.sendEmailToUserOnAccountCreation = onDocumentCreated(
  'userProfile/{userID}',
  async event => {
    try {
      // Get the newly created user data
      const userData = event.data.data()

      // Send email notification to admin
      const userEmail = userData['email']
      const subject = 'Welcome to HAIR MAIN STREET'
      const message = `<h2 style="font-size: 20px">Welcome to <span style="color: #673AB7" "font-size: 22px" >Hair Main Street</span></h2>
            <p style="font-size: 16px">Your account creation was successful. Enjoy using our application and witness the best we have to offer.</p>
            <p style="font-size: 16px">We are excited to have you on board.</p>
            <p style="font-size: 16px">Have Fun.</p>
    `

      await sendEmail(userEmail, subject, message)

      logger.info('Email notification sent to admin successfully')
    } catch (error) {
      logger.error('Error sending email notification:', error)
    }
  }
)

exports.processRefundRequest = onDocumentUpdated(
  'refunds/{refundID}',
  async event => {
    const beforeData = event.data.before.data()
    const afterData = event.data.after.data()

    // Only proceed if status just changed to 'approved'
    if (
      afterData['refund status'] === 'approved' &&
      beforeData['refund status'] !== 'approved'
    ) {
      const orderID = afterData.orderID
      const refundAmount = afterData['refund amount']

      try {
        // 1. Get all necessary documents
        const orderRef = db.collection('orders').doc(orderID)
        const orderDoc = await orderRef.get()

        if (!orderDoc.exists) {
          throw new Error(`Order ${orderID} not found`)
        }

        const orderData = orderDoc.data()
        const vendorID = orderData.vendorID
        const buyerID = orderData.buyerID
        const walletRef = db.collection('wallet').doc(vendorID)
        const walletDoc = await walletRef.get()

        if (!walletDoc.exists) {
          throw new Error(`Wallet for vendor ${vendorID} not found`)
        }

        // 2. Validate vendor balance
        const currentBalance = walletDoc.data().balance
        if (currentBalance < refundAmount) {
          throw new Error(
            `Insufficient balance. Vendor has ${currentBalance} but needs ${refundAmount}`
          )
        }

        // 3. Prepare all updates
        const batch = db.batch()

        //only update the order status if the refund reason is not 'expired'
        if (afterData['reason'] !== 'expired') {
          // Update order status
          batch.update(orderRef, {
            'order status': 'refunded'
          })
        } else {
          // If the refund reason is 'expired', we don't update the order status
          logger.info(
            `Order ${orderID} not updated to refunded due to refund reason being 'expired'`
          )
        }
        batch.update(walletRef, {
          balance: admin.firestore.FieldValue.increment(-refundAmount)
        })
        const transactionRef = db
          .collection('wallet')
          .doc(vendorID)
          .collection('transactions')
          .doc()
        batch.set(transactionRef, {
          type: 'debit',
          amount: refundAmount,
          orderID: orderID,
          timestamp: admin.firestore.FieldValue.serverTimestamp()
        })

        // 4. Execute all updates atomically
        await batch.commit()

        // 5. Notify parties (outside transaction)
        const [vendorDoc, buyerDoc] = await Promise.all([
          db.collection('userProfile').doc(vendorID).get(),
          db.collection('userProfile').doc(buyerID).get()
        ])
        const vendorData = vendorDoc.data()
        const buyerData = buyerDoc.data()

        await Promise.all([
          notifyUser({
            userID: vendorID,
            orderID,
            receiver: 'vendor',
            fcmTitle: 'Order Refunded',
            fcmBody: `Order ${orderID} Refunded. ${refundAmount} deducted from your balance`,
            email: vendorData?.email,
            emailSubject: 'Order Refund',
            emailBody: `Amount deducted: ₦${refundAmount}`
          }),
          notifyUser({
            userID: buyerID,
            orderID,
            receiver: 'buyer',
            fcmTitle: 'Refund Complete',
            fcmBody: `Refund Request for order ${orderID} approved`,
            email: buyerData?.email,
            emailSubject: 'Refund Approved',
            emailBody: 'Your request was processed and approved'
          })
        ])
      } catch (error) {
        logger.error(`Refund failed: ${error}`)
        await db.collection('refunds').doc(event.params.refundID).update({
          'refund status': 'failed',
          error: error.message
        })
        throw error
      }
    }
    return null
  }
)

exports.processCancellationRequest = onDocumentUpdated(
  'cancellations/{cancellationID}',
  async event => {
    const beforeData = event.data.before.data()
    const afterData = event.data.after.data()

    // Only proceed if status just changed to 'approved'
    if (
      afterData['cancellation status'] === 'approved' &&
      beforeData['cancellation status'] !== 'approved'
    ) {
      const db = admin.firestore()
      const batch = db.batch()
      const orderID = afterData.orderID
      const cancellationAmount = afterData['cancellation amount']

      try {
        // 1. Get all necessary documents
        const orderRef = db.collection('orders').doc(orderID)
        const orderDoc = await orderRef.get()

        if (!orderDoc.exists) {
          throw new Error(`Order ${orderID} not found`)
        }

        const orderData = orderDoc.data()
        const vendorID = orderData.vendorID
        const buyerID = orderData.buyerID
        const walletRef = db.collection('wallet').doc(vendorID)
        const walletDoc = await walletRef.get()

        if (!walletDoc.exists) {
          throw new Error(`Wallet for vendor ${vendorID} not found`)
        }

        // 2. Validate vendor balance
        const currentBalance = walletDoc.data().balance
        if (currentBalance < cancellationAmount) {
          throw new Error(
            `Insufficient balance. Vendor has ${currentBalance} but needs ${cancellationAmount}`
          )
        }

        // 3. Prepare all updates
        // Update order status
        batch.update(orderRef, {
          'order status': 'cancelled'
        })

        // Deduct from vendor wallet
        batch.update(walletRef, {
          balance: admin.firestore.FieldValue.increment(-cancellationAmount)
        })

        // Create transaction record
        const transactionRef = db
          .collection('wallet')
          .doc(vendorID)
          .collection('transactions')
          .doc()
        batch.set(transactionRef, {
          type: 'debit',
          amount: cancellationAmount,
          orderID: orderID,
          timestamp: admin.firestore.FieldValue.serverTimestamp()
        })

        // 4. Execute all updates atomically
        await batch.commit()

        // 5. Notify parties (outside transaction)
        const [vendorDoc, buyerDoc] = await Promise.all([
          db.collection('userProfile').doc(vendorID).get(),
          db.collection('userProfile').doc(buyerID).get()
        ])
        const vendorData = vendorDoc.data()
        const buyerData = buyerDoc.data()

        await Promise.all([
          notifyUser({
            userID: vendorID,
            orderID,
            receiver: 'vendor',
            fcmTitle: 'Order Cancelled',
            fcmBody: `Order ${orderID} cancelled. ${cancellationAmount} deducted from your balance`,
            email: vendorData?.email,
            emailSubject: 'Order Cancellation',
            emailBody: `Amount deducted: ₦${cancellationAmount}`
          }),
          notifyUser({
            userID: buyerID,
            orderID,
            receiver: 'buyer',
            fcmTitle: 'Cancellation Approved',
            fcmBody: `Cancellation Request for order ${orderID} approved`,
            email: buyerData?.email,
            emailSubject: 'Cancellation Approved',
            emailBody: 'Your cancellation request was processed and approved'
          })
        ])
        logger.info(`Cancellation processed successfully for order ${orderID}`)
      } catch (error) {
        logger.error('Cancellation failed:', error)

        // Revert the cancellation status if needed
        await db
          .collection('cancellations')
          .doc(event.params.cancellationID)
          .update({
            'cancellation status': 'failed',
            error: error.message
          })

        throw error // Ensures Firebase logs the error
      }
    }
  }
)

exports.processWithdrawalRequest = onDocumentUpdated(
  'withdrawals/{withdrawalID}',
  async event => {
    const beforeData = event.data.before.data()
    const afterData = event.data.after.data()
    const withdrawalID = event.params.withdrawalID

    // Only process if status just changed to 'approved'
    if (
      beforeData['status'] !== 'approved' &&
      afterData['status'] === 'approved'
    ) {
      const withdrawalAmount = afterData['withdrawal amount']
      const vendorID = afterData['vendorID']

      if (!withdrawalAmount || !vendorID || !withdrawalID) {
        logger.error(
          `Missing required fields: withdrawalAmount=${withdrawalAmount}, vendorID=${vendorID}, withdrawalID=${withdrawalID}`
        )
        return null
      }

      const walletRef = db.collection('wallets').doc(vendorID)
      const transactionRef = db
        .collection('wallet')
        .doc(vendorID)
        .collection('transactions')
        .doc()

      try {
        await db.runTransaction(async transaction => {
          const walletDoc = await transaction.get(walletRef)
          if (!walletDoc.exists) {
            throw new Error(`Wallet for vendor ${vendorID} not found`)
          }

          const currentBalance = walletDoc.data()['withdrawable balance'] || 0
          if (currentBalance < withdrawalAmount) {
            throw new Error(
              `Insufficient balance. Vendor has ${currentBalance} but needs ${withdrawalAmount}`
            )
          }

          // Deduct balance
          transaction.update(walletRef, {
            'withdrawable balance': admin.firestore.FieldValue.increment(
              -withdrawalAmount
            )
          })

          // Record transaction
          transaction.set(transactionRef, {
            type: 'debit',
            amount: withdrawalAmount,
            orderID: 'withdrawal',
            timestamp: admin.firestore.FieldValue.serverTimestamp()
          })
        })

        // Notify vendor (outside transaction)
        await sendFcmNotification(
          `vendor_${vendorID}`,
          `Withdrawal of ${withdrawalAmount} processed successfully`,
          'Withdrawal Successful',
          withdrawalID,
          'vendor'
        )
        logger.info(
          `Withdrawal processed: vendor=${vendorID}, amount=${withdrawalAmount}`
        )
      } catch (error) {
        logger.error(
          `Failed to process withdrawal for vendor=${vendorID}, withdrawalID=${withdrawalID}: ${error.message}`
        )
        // // Optionally, update withdrawal status to 'failed'
        // await db
        //   .collection('withdrawals')
        //   .doc(withdrawalID)
        //   .update({
        //     status: 'failed',
        //     error: error.message
        //   })
      }
    }
    return null
  }
)

async function getOrCreateTransferRecipient(accountNumber, bankCode) {
  // Fetch existing recipients from Paystack
  let page = 1
  let recipientCode = null
  let hasMore = true

  while (hasMore) {
    const response = await paystackApi.get('/transferrecipient', {
      params: {
        perPage: 50,
        page: page
      }
    })

    const recipients = response.data.data

    for (const recipient of recipients) {
      if (
        recipient.details.account_number === accountNumber &&
        recipient.details.bank_code === bankCode
      ) {
        recipientCode = recipient.recipient_code
        break
      }
    }

    if (recipientCode) break
    hasMore = response.data.meta.next
    page++
  }

  // If recipient doesn't exist, create one
  if (!recipientCode) {
    const response = await paystackApi.post('/transferrecipient', {
      type: 'nuban',
      name: 'Refund Recipient',
      account_number: accountNumber,
      bank_code: bankCode,
      currency: 'NGN'
    })

    recipientCode = response.data.data.recipient_code
  }

  return recipientCode
}

//function to pay a customer
exports.makeTransfer = onCall(async request => {
  const { bank_code, account_number, amount, reason } = request.data

  // Input validation
  if (!bank_code || !account_number || !amount) {
    logger.error('The request failed due to missing body parameters')
    return {
      success: false,
      message: 'Missing required parameters'
    }
  }

  try {
    const recipientCode = await getOrCreateTransferRecipient(
      account_number,
      bank_code
    )

    // Make transfer
    const response = await paystackApi.post('/transfer', {
      reason: reason,
      amount: amount * 100,
      recipient: recipientCode,
      source: 'balance'
    })

    return {
      success: true,
      message: 'Transfer successful',
      transfer: response.data.data
    }
  } catch (error) {
    logger.error(`An error occurred in making the transfer: ${error}`)
    return {
      success: false,
      message: 'Transfer failed',
      error: error.message
    }
  }
})

// make transfers locally
async function makeTransfersLocallyForExpiredOrders({
  recipientCode,
  amount,
  reason
}) {
  try {
    //make transfer
    const response = paystackApi.post('/transfer', {
      reason: reason,
      amount: amount * 100,
      recipient: recipientCode,
      source: 'balance'
    })

    return {
      success: true,
      message: 'transfer successful',
      transfer: response.data.data
    }
  } catch (error) {
    logger.error(`An error occured in making the transfer ${error}`)
  }
}

//function to initialize transaction and send access code
exports.initiateTransaction = onCall(async request => {
  const { amount, email, callbackUrl, reference, isLive } = request.data

  try {
    const response = await axios.post(
      'https://api.paystack.co/transaction/initialize',
      {
        amount: amount * 100, // amount in kobo
        email: email,
        callback_url: callbackUrl,
        reference: reference
      },
      {
        headers: {
          Authorization: `Bearer ${
            isLive ? PAYSTACK_LIVE_SECRET_KEY : PAYSTACK_SECRET_KEY
          }`,
          'Content-Type': 'application/json'
        }
      }
    )

    if (!response.data.status) {
      throw new Error(
        `Paystack transaction initialization failed: ${response.data.message}`
      )
    }

    return { accessCode: response.data.data.access_code }
  } catch (error) {
    logger.error('Error initiating transaction:', error)
    throw new Error('Failed to initiate transaction')
  }
})

// Express route to handle Paystack callback
app.post('/paystack/callback', async (req, res) => {
  const transactionDetails = req.body

  logger.log('Transaction callback received:', transactionDetails)

  if (transactionDetails.event === 'charge.success') {
    const transactionId = transactionDetails.data.id
    const amount = transactionDetails.data.amount
    const email = transactionDetails.data.customer.email
    const status = transactionDetails.data.status

    // Handle successful transaction
    logger.log(
      `Transaction ${transactionId} of amount ${amount} for email ${email} was successful.`
    )

    // Update the database or perform necessary actions

    res.status(200).send('Transaction processed successfully')
  } else {
    logger.log(`Transaction event received: ${transactionDetails.event}`)
    res.status(200).send('Event received')
  }
})

app.post('/makeTransfer', async (req, res) => {
  const { bank_code, account_number, amount, reason } = req.body

  logger.info(`Body: ${JSON.stringify(req.body)}`)

  // Input validation
  if (!bank_code || !account_number || !amount) {
    logger.error('The request failed due to missing body parameters')
    return res.status(400).json({
      success: false,
      message: 'Missing required parameters'
    })
  }

  try {
    const recipientCode = await getOrCreateTransferRecipient(
      account_number,
      bank_code
    )

    // Make transfer
    const response = await paystackApi.post('/transfer', {
      reason: reason,
      amount: parseInt(amount) * 100,
      recipient: recipientCode,
      source: 'balance'
    })

    return res.status(200).json({
      success: true,
      message: 'Transfer successful',
      transfer: response.data.data
    })
  } catch (error) {
    logger.error(`An error occurred in making the transfer: ${error}`)
    return res.status(500).json({
      success: false,
      message: 'Transfer failed',
      error: error.message
    })
  }
})

app.post('/notifyUser', async (req, res) => {
  const {
    userID,
    orderID,
    receiver,
    fcmTitle,
    fcmBody,
    email,
    emailSubject,
    emailBody
  } = req.body

  try {
    const notificationResult = await notifyUser({
      userID,
      orderID,
      receiver,
      fcmTitle,
      fcmBody,
      email,
      emailSubject,
      emailBody
    })

    if (notificationResult === 'success') {
      return res.status(200).json({
        message: 'User notified successfully',
        success: true
      })
    } else {
      throw new Error('error notifying user')
    }
  } catch (error) {
    logger.error('Error notifying user:', error)
    return res.status(500).json({
      message: 'Error notifying user',
      error: error.message,
      success: false
    })
  }
})

//helper function to delete all subcollections of the user
const deleteAllUserSubcollections = async userID => {
  const docRef = db.collection('userProfile').doc(userID)
  const collections = await docRef.listCollections()

  for (const subcollection of collections) {
    const snapshot = await subcollection.get()
    const batch = db.batch()
    snapshot.docs.forEach(doc => batch.delete(doc.ref))
    await batch.commit()
  }
  logger.log('All subcollections deleted successfully')
  return true
}

//helper function to delete all subcollections of the product
const deleteAllProductSubcollections = async productID => {
  const docRef = db.collection('products').doc(productID)
  const collections = await docRef.listCollections()

  for (const subcollection of collections) {
    const snapshot = await subcollection.get()
    const batch = db.batch()
    snapshot.docs.forEach(doc => batch.delete(doc.ref))
    await batch.commit()
  }
  logger.log('All subcollections deleted successfully')
  return true
}

//http function to delete a user based on userID
app.delete('/delete-user', async (req, res) => {
  const { userID } = req.body
  try {
    await admin.auth().deleteUser(userID)
    await deleteAllUserSubcollections(userID)
    await db.collection('userProfile').doc(userID).set(
      {
        email: 'deleted',
        fullname: 'deleted',
        token: null,
        phonenumber: 'deleted',
        'referral code': 'deleted',
        'referral link': 'deleted',
        isAdmin: false,
        isVendor: false,
        isBuyer: false,
        'profile photo': null
      },
      { merge: true }
    )
    res.status(200).send({ success: 'User deleted successfully' })
  } catch (error) {
    logger.error('Error deleting user:', error)
    res.status(500).send({ error: 'Error deleting user' })
  }
})

//http function to delete a user based on userID
app.delete('/delete-order', async (req, res) => {
  const { orderID } = req.body
  try {
    // await deleteAllOrderSubcollections(orderID)
    await db
      .collection('orders')
      .doc(orderID)
      .set({ isDeleted: true }, { merge: true })
    res.status(200).send({ success: 'Order deleted successfully' })
  } catch (error) {
    logger.error('Error deleting order:', error)
    res.status(500).send({ error: 'Error deleting order' })
  }
})

//http function to delete a product based on productID
app.delete('/delete-product', async (req, res) => {
  const { productID } = req.body
  try {
    await deleteAllProductSubcollections(productID)
    await db.collection('products').doc(productID).delete()
    res.status(200).send({ success: 'Product deleted successfully' })
  } catch (error) {
    logger.error('Error deleting Product:', error)
    res.status(500).send({ error: 'Error deleting Product' })
  }
})

app.post('/change-password', async (req, res) => {
  const { newPassword, userID } = req.body
  try {
    await auth.updateUser(userID, { password: newPassword })
    res.status(200).send({ success: 'Password changed' })
  } catch (error) {
    logger.error('Error changing password:', error)
    res.status(500).send({ error: 'Error changing password' })
  }
})

// Cloud Function to deploy Express app
exports.api = onRequest(app)
