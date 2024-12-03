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
const { event } = require('firebase-functions/v1/analytics')
const { onCall, onRequest } = require('firebase-functions/v2/https')
const app = express()
app.use(json())
app.use(cors({ origin: true }))
app.use(express.json())

const PAYSTACK_SECRET_KEY = process.env.PAYSTACK_SECRET_KEY
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
    const adminVaribles = data.data()
    return adminVaribles
  } catch (error) {
    logger.error(`An error occured ${error}`)
  }
}

async function sendFcmNotification(topic, body, title, data, receiver) {
  const message = {
    notification: {
      title: title,
      body: body
    },
    data: {
      orderID: data,
      receiver: receiver
    },
    topic: topic
  }

  try {
    await messaging.send(message)
    logger.info('FCM notification sent successfully')
  } catch (error) {
    logger.error('Error sending FCM notification:', error)
  }
}

async function sendEmail(email, subject, body) {
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL,
      pass: process.env.APPPASSWORD // Replace with your app password
    }
  })

  const mailOptions = {
    from: 'hairmainstreetofficial01@gmail.com',
    to: email,
    subject: subject,
    html: body
  }

  try {
    await transporter.sendMail(mailOptions)
    logger.info('Email sent successfully')
  } catch (error) {
    logger.error('Error sending email:', error)
  }
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
      const buyerDoc = await db.collection('userProfile').doc(buyerId).get()
      const buyerData = buyerDoc.data()
      const orderID = event.params.orderId
      const fcmTitle = 'Order Status Update'
      const fcmBody = `Your order has been ${newOrderData['order status']},\nKindly Confirm`

      await db
        .collection('notifications')
        .doc(buyerId)
        .collection('notifications')
        .add({
          userID: buyerId,
          'extra data': { orderID: orderID, receiver: 'buyer' },
          title: fcmTitle,
          body: fcmBody,
          'time stamp': admin.firestore.FieldValue.serverTimestamp()
        })

      if (buyerId && buyerData['token']) {
        await sendFcmNotification(
          `buyer_${buyerId}`,
          fcmBody,
          fcmTitle,
          orderID,
          'buyer'
        )
      }

      if (buyerData && buyerData['email']) {
        const emailSubject = 'Order Status Update'
        const emailBody = `
        <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
        <p style="font-size: 18px">Dear ${buyerData['fullname']},</p>
        <p style="font-size: 18px">Your order with ID: ${orderID} has been ${newOrderData['order status']}, Kindly Confirm.</p>
      `
        await sendEmail(buyerData['email'], emailSubject, emailBody)
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

    await db
      .collection('notifications')
      .doc(buyerId)
      .collection('notifications')
      .add({
        userID: buyerId,
        'extra data': { orderID: orderID, receiver: 'buyer' },
        title: fcmTitle,
        body: buyerFcmBody,
        'time stamp': admin.firestore.FieldValue.serverTimestamp()
      })

    await db
      .collection('notifications')
      .doc(vendorID)
      .collection('notifications')
      .add({
        userID: vendorID,
        'extra data': { orderID: orderID, receiver: 'vendor' },
        title: fcmTitle,
        body: vendorFcmBody,
        'time stamp': admin.firestore.FieldValue.serverTimestamp()
      })

    await sendFcmNotification(
      `buyer_${buyerId}`,
      buyerFcmBody,
      fcmTitle,
      orderID,
      'buyer'
    )
    await sendEmail(buyerData['email'], emailSubject, buyerEmailBody)

    await sendFcmNotification(
      `vendor_${vendorID}`,
      vendorFcmBody,
      fcmTitle,
      orderID,
      'vendor'
    )
    await sendEmail(vendorData['email'], emailSubject, vendorEmailBody)

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
      const currentBalance = walletData.balance || 0

      // Update balance
      await walletRef.update({
        balance: currentBalance + paymentPrice
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

      const walletRef = db.collection('wallet').doc(newData.vendorID)
      const vendorID = newData.vendorID
      const walletSnapshot = await walletRef.get()

      if (walletSnapshot.exists) {
        const walletData = walletSnapshot.data()
        const currentBalance = walletData['balance']

        //update wallet balance
        await walletRef.update({
          balance: currentBalance + difference
        })

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

        if (difference === 0) {
          const buyerId = newData.buyerID
          const buyerDoc = await db.collection('userProfile').doc(buyerId).get()
          const buyerData = buyerDoc.data()
          const vendorDoc = await db
            .collection('userProfile')
            .doc(vendorID)
            .get()
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

          await db
            .collection('notifications')
            .doc(vendorID)
            .collection('notifications')
            .add({
              userID: vendorID,
              'extra data': { orderID: orderID, receiver: 'vendor' },
              title: fcmTitle,
              body: vendorFcmBody,
              'time stamp': admin.firestore.FieldValue.serverTimestamp()
            })
          await db
            .collection('notifications')
            .doc(buyerId)
            .collection('notifications')
            .add({
              userID: buyerId,
              'extra data': { orderID: orderID, receiver: 'buyer' },
              title: fcmTitle,
              body: buyerFcmBody,
              'time stamp': admin.firestore.FieldValue.serverTimestamp()
            })
          await sendFcmNotification(
            `vendor_${vendorID}`,
            vendorFcmBody,
            fcmTitle,
            orderID,
            'vendor'
          )
          await sendEmail(vendorData['email'], emailSubject, vendorEmailBody)
          await sendFcmNotification(
            `buyer_${buyerId}`,
            buyerFcmBody,
            fcmTitle,
            orderID,
            'buyer'
          )
          await sendEmail(buyerData['email'], emailSubject, buyerEmailBody)
        }

        logger.info('Wallet updated successfully')
      } else {
        logger.error('Wallet does not exist')
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
        const currentAmount = data['withdrawable balance'] || 0
        const updatedAmount = Number(currentAmount) + Number(amountToRemit)

        // Update the wallet with the new amount
        await walletRef.update({
          'withdrawable balance': updatedAmount
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
        <p style="font-size: 18px">Your order with ID: ${orderID} has been successfully confirmed. Kindly the app to leave a review</p>
      `
        const vendorEmailBody = `
        <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
        <p style="font-size: 18px">Dear ${vendorData['fullname']},</p>
        <p style="font-size: 18px">The buyer has confirmed the receipt of the order for your product with ID: ${orderID}.</p>
      `

        await db
          .collection('notifications')
          .doc(buyerId)
          .collection('notifications')
          .add({
            userID: buyerId,
            'extra data': { orderID: orderID, receiver: 'buyer' },
            title: fcmTitle,
            body: buyerFcmBody,
            'time stamp': admin.firestore.FieldValue.serverTimestamp()
          })

        await db
          .collection('notifications')
          .doc(vendorID)
          .collection('notifications')
          .add({
            userID: vendorID,
            'extra data': { orderID: orderID, receiver: 'vendor' },
            title: fcmTitle,
            body: vendorFcmBody,
            'time stamp': admin.firestore.FieldValue.serverTimestamp()
          })

        await sendFcmNotification(
          `buyer_${buyerId}`,
          buyerFcmBody,
          fcmTitle,
          orderID,
          'buyer'
        )
        await sendEmail(buyerData['email'], emailSubject, buyerEmailBody)

        await sendFcmNotification(
          `vendor_${vendorID}`,
          vendorFcmBody,
          fcmTitle,
          orderID,
          'vendor'
        )
        await sendEmail(vendorData['email'], emailSubject, vendorEmailBody)
        return null
      } else {
        logger.error(`Wallet not found for vendor (${vendorId})`)
        return null
      }
    }

    return null
  }
)

exports.processRefundApproval = onDocumentUpdated(
  'refunds/{refundId}',
  async event => {
    const oldData = event.data.before.data()
    const newData = event.data.after.data()
    const refundId = event.params.refundId

    //check if refund status has been approved
    if (
      newData['refund status'] === 'approved' &&
      oldData['refund status'] !== 'approved'
    ) {
      const refundAccountNumber = newData['refund account']
      const refundBankCode = newData['refund bank_code']
      const refundAmount = newData['refund amount']
      const refundReason = newData['reason']

      try {
        const transfer = makeTransfersLocally(
          refundBankCode,
          refundAccountNumber,
          refundAmount,
          refundReason
        )
        if (transfer['success'] == true) {
          await db.collection('refunds').doc(refundId).update({
            'refund status': 'confirmed',
            'refund transactionID': transfer['transfer'],
            'refund timestamp': admin.FieldValue.serverTimestamp()
          })

          logger.info(
            'Refund successful and the status has been updated to confirmed'
          )
        } else {
          logger.info('Transaction failed to refund amount to user')
        }
      } catch (error) {
        logger.error(
          `An error occured in trying to make refund transfer ${error}`
        )
      }
    }
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
      const adminVaribles = await getAdminVariables()
      const buyerId = orderData.buyerID
      const buyerDoc = await db.collection('userProfile').doc(buyerId).get()
      const buyerData = buyerDoc.data()
      const vendorID = orderData.vendorID
      const vendorDoc = await db.collection('userProfile').doc(vendorID).get()
      const vendorData = vendorDoc.data()
      const paymentPrice = orderData['payment price'] // Adjust this based on your data model
      const refundAmount =
        paymentPrice - paymentPrice * (adminVaribles['expired fee'] / 100)
      const orderRef = db.collection('orders').doc(orderId)
      const recipientCode = orderData['recipient code']
      const fcmTitle = 'Order Expired'
      const vendorFcmBody = `The order for your product with ID: ${orderId} has expired.  Amount paid already would be refunded back to the buyers account `
      const buyerFcmBody = `Your order with ID: ${orderId} has expired, The amount paid for the order will be refunded according to terms and conditions.`
      const emailSubject = 'Order Expired'
      const buyerEmailBody = `
      <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
    <p style="font-size: 18px">Dear ${buyerData['fullname']},</p>
    <p style="font-size: 18px">Your order with ID: ${orderId} has expired.</p>
    <p style="font-size: 18px">The amount paid for the order will be refunded according to terms and conditions.</p>
  `
      const vendorEmailBody = `
      <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
    <p style="font-size: 18px">Dear ${vendorData['fullname']},</p>
    <p style="font-size: 18px">The order for your product with ID: ${orderId} has expired. Amount paid already would be refunded back to the buyers account </p>
    
  `

      const adminEmail = process.env.ADMIN_EMAIL
      const adminBody = `<p style="font-size: 18px">An order with ID : ${orderId} from the vendor ${vendorData['shop name']} has expired</p>`
      const adminSubject = `Order Expired`

      await db
        .collection('notifications')
        .doc(buyerId)
        .collection('notifications')
        .add({
          userID: buyerId,
          'extra data': { orderID: orderId, receiver: 'buyer' },
          title: fcmTitle,
          body: buyerFcmBody,
          'time stamp': admin.firestore.FieldValue.serverTimestamp()
        })

      await db
        .collection('notifications')
        .doc(vendorID)
        .collection('notifications')
        .add({
          userID: vendorID,
          'extra data': { orderID: orderId, receiver: 'vendor' },
          title: fcmTitle,
          body: vendorFcmBody,
          'time stamp': admin.firestore.FieldValue.serverTimestamp()
        })

      await sendFcmNotification(
        `buyer_${buyerId}`,
        buyerFcmBody,
        fcmTitle,
        orderId,
        'buyer'
      )
      await sendEmail(buyerData['email'], emailSubject, buyerEmailBody)

      await sendFcmNotification(
        `vendor_${vendorID}`,
        vendorFcmBody,
        fcmTitle,
        orderId,
        'vendor'
      )
      await sendEmail(vendorData['email'], emailSubject, vendorEmailBody)

      await sendEmail(adminEmail, adminSubject, adminBody)

      return null
    }
  }
)

exports.checkInstallmentPayments = onSchedule(
  'every 10 minutes',
  async event => {
    const currentTime = Date.now()

    // Query orders with "installment" payment method
    const installmentOrdersSnapshot = await db
      .collection('orders')
      .where('payment method', '==', 'installment')
      .get()

    if (installmentOrdersSnapshot.exists) {
      installmentOrdersSnapshot.forEach(async doc => {
        const order = doc.data()
        const orderID = doc.id
        const vendorRef = await db
          .collection('vendors')
          .doc(order['vendorID'])
          .get()
        const buyerRef = await db
          .collection('userProfile')
          .doc(order['buyerID'])
          .get()
        const totalInstallments = order['installment number'] || 1 // Default to 1 if not specified
        const installmentDuration =
          vendorRef.data()['installment duration'] || 0 // Default to 0 days if not specified
        const installmentsMade = order['installment paid'] || 1
        const firstInstallmentTime =
          order['created at'].seconds * 1000 +
          order['created at'].nanoseconds / 1000000

        // Calculate the deadline for the next installment
        const nextInstallmentDeadline =
          firstInstallmentTime + installmentsMade * installmentDuration

        // If the current time exceeds the deadline for the next installment, update order status to "expired"
        if (
          currentTime > nextInstallmentDeadline &&
          installmentsMade < totalInstallments
        ) {
          const reminderDoc = await db
            .collection('reminders')
            .doc(orderID)
            .get()
          const reminderData = reminderDoc.data()

          if (!reminderData || !reminderData['expirationReminderSent']) {
            await db
              .collection('orders')
              .doc(orderID)
              .update({ 'order status': 'expired' })

            // Optionally, send notification to buyer about order expiration
            // sendExpirationNotification(order.buyerID, orderID);
            const fcmTitle = 'Order Expired'
            const fcmBody = `Your Order with ID: ${orderID} has expired, Kindly Order Again`
            const emailBody = `
            <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
            <p style="font-size: 18px">Dear ${buyerRef.data()['full name']}</p>
            <p style="font-size: 18px">Your Order with ID: ${orderID} has expired, Kindly Order Again</p>
            `

            await sendFcmNotification(
              `buyer_${order['buyerID']}`,
              fcmBody,
              fcmTitle,
              orderID,
              'buyer'
            )
            await db
              .collection('notifications')
              .doc(order['buyerID'])
              .collection('notifications')
              .add({
                body: fcmBody,
                'extra data': { orderID: orderID, receiver: 'buyer' },
                'time stamp': admin.firestore.FieldValue.serverTimestamp(),
                title: fcmTitle,
                userID: order['buyerID']
              })
            await sendEmail(
              buyerRef.data()['email'],
              'Order Expired',
              emailBody
            )

            await db
              .collection('reminders')
              .doc(orderID)
              .set({ expirationReminderSent: true }, { merge: true })
          }
        } else {
          // Optionally, send payment reminders if needed
          if (currentTime + 3 * 24 * 60 * 60 * 1000 > nextInstallmentDeadline) {
            const reminderDoc = await db
              .collection('reminders')
              .doc(orderID)
              .get()
            const reminderData = reminderDoc.data()
            if (!reminderData || !reminderData['threeDayPaymentReminderSent']) {
              const buyerFcmBody =
                'Please remember to pay your installment payment before the deadline runs out'
              const fcmTitle = 'Payment Reminder'
              // Send reminder 3 days before the deadline
              // sendPaymentReminder(order.buyerID, orderID);
              await sendFcmNotification(
                `buyer_${order['buyerID']}`,
                buyerFcmBody,
                fcmTitle,
                orderID,
                'buyer'
              )
              await db
                .collection('notifications')
                .doc(order['buyerID'])
                .collection('notifications')
                .add({
                  body: buyerFcmBody,
                  'extra data': { orderID: orderID, receiver: 'buyer' },
                  'time stamp': admin.firestore.FieldValue.serverTimestamp(),
                  title: fcmTitle,
                  userID: order['buyerID']
                })
              await sendEmail(
                buyerRef.data()['email'],
                'Payment Reminder',
                `
                <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
                <p style="font-size: 18px">Dear ${
                  buyerRef.data()['full name']
                }</p>
                <p style="font-size: 18px">Please remember to pay your installment payment before the deadline runs out</p>
                `
              )
            }

            await db
              .collection('reminders')
              .doc(orderID)
              .set({ threeDayPaymentReminderSent: true }, { merge: true })
          }

          // Send reminder 1 day before the deadline
          if (currentTime + 24 * 60 * 60 * 1000 > nextInstallmentDeadline) {
            const reminderDoc = await db
              .collection('reminders')
              .doc(orderID)
              .get()
            const reminderData = reminderDoc.data()
            if (!reminderData || !reminderData['oneDayPaymentReminderSent']) {
              // Send reminder 1 day before the deadline
              // sendOneDayReminder(order.buyerID, orderID);
              const buyerFcmBody =
                'Please remember to pay your installment payment before the deadline runs out'
              const fcmTitle = 'Payment Reminder'
              await sendFcmNotification(
                `buyer_${order['buyerID']}`,
                buyerFcmBody,
                fcmTitle,
                orderID,
                'buyer'
              )
              await db
                .collection('notifications')
                .doc(order['buyerID'])
                .collection('notifications')
                .add({
                  body: buyerFcmBody,
                  'extra data': { orderID: orderID, receiver: 'buyer' },
                  'time stamp': admin.firestore.FieldValue.serverTimestamp(),
                  title: fcmTitle,
                  userID: order['buyerID']
                })
              await sendEmail(
                buyerRef.data()['email'],
                'Payment Reminder',
                `
                 <h2 style="font-size: 24px color:#673AB7">Hair Main Street</h2>
                 <p style="font-size: 18px">Dear ${
                   buyerRef.data()['full name']
                 }</p>
                <p style="font-size: 18px">Please remember to pay your installment payment before the deadline runs out'</p>
                `
              )

              await db
                .collection('reminders')
                .doc(orderID)
                .set({ oneDayPaymentReminderSent: true }, { merge: true })
            }
          }
        }
      })

      logger.info('Installment payment check completed')
      return null
    } else {
      logger.error('document does not exist')
    }
  }
)

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
      const message = `<h2 style="font-size: 24px">Welcome to <span style="color: #673AB7">Hair Main Street</span></h2>
    <p style="font-size: 18px">Your account creation was successful. Enjoy using our application and witness the best we have to offer.</p>
            <p style="font-size: 18px">We are excited to have you on board.</p>
            <p style="font-size: 18px">Have Fun.</p>
    `

      await sendEmail(userEmail, subject, message)

      logger.info('Email notification sent to admin successfully')
    } catch (error) {
      logger.error('Error sending email notification:', error)
    }
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

//make transfers locally
async function makeTransfersLocally({
  bank_code,
  account_number,
  amount,
  reason
}) {
  const recipientCode = await getOrCreateTransferRecipient(
    account_number,
    bank_code
  )

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
  const { amount, email, callbackUrl, reference } = request.data

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
          Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`,
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
    console.error('Error initiating transaction:', error)
    throw new Error('Failed to initiate transaction')
  }
})

// Express route to handle Paystack callback
app.post('/paystack/callback', async (req, res) => {
  const transactionDetails = req.body

  console.log('Transaction callback received:', transactionDetails)

  if (transactionDetails.event === 'charge.success') {
    const transactionId = transactionDetails.data.id
    const amount = transactionDetails.data.amount
    const email = transactionDetails.data.customer.email
    const status = transactionDetails.data.status

    // Handle successful transaction
    console.log(
      `Transaction ${transactionId} of amount ${amount} for email ${email} was successful.`
    )

    // Update the database or perform necessary actions

    res.status(200).send('Transaction processed successfully')
  } else {
    console.log(`Transaction event received: ${transactionDetails.event}`)
    res.status(200).send('Event received')
  }
})

app.post('/makeTransfer', async (req, res) => {
  const { bank_code, account_number, amount, reason } = req.body

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
      amount: amount * 100,
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

// Cloud Function to deploy Express app
exports.api = onRequest(app)
