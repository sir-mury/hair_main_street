/* eslint-disable */

const { firestore, pubsub, https } = require('firebase-functions')
const admin = require('firebase-admin')
const { createTransport } = require('nodemailer')
require('dotenv').config()
const { FieldValue, Timestamp } = require('firebase-admin/firestore')
admin.initializeApp()
const messaging = admin.messaging()
const t = Timestamp.now()
const db = admin.firestore()
const express = require('express')
const { get, post, default: axios } = require('axios')
const cors = require('cors')
const { json } = require('body-parser')

const app = express()

const ADMIN_EMAIL = process.env.ADMIN_EMAIL
const paystackSecretKey = process.env.PAYSTACK_SECRET_KEY

//middle ware
app.use(json())
app.use(cors({ origin: true }))

app.post('/refund', async (req, res) => {
  const { transactionId, refundAmount, customerEmail } = req.body
  const paystackSecretKey = process.env.PAYSTACK_SECRET_KEY

  try {
    const response = await post(
      'https://api.paystack.co/refund',
      {
        transaction: transactionId,
        amount: refundAmount, // Optional: Specify the refund amount
        customerEmail: customerEmail
      },
      {
        headers: {
          Authorization: `Bearer ${paystackSecretKey}`,
          'Content-Type': 'application/json'
        }
      }
    )

    if (response.status === 200) {
      res
        .status(200)
        .send({ message: 'Refund initiated successfully', data: response.data })
    } else {
      res
        .status(response.status)
        .send({ message: 'Failed to initiate refund', error: response.data })
    }
  } catch (error) {
    console.error('Error initiating refund:', error)
    res
      .status(500)
      .send({ message: 'Internal server error', error: error.message })
  }
})

async function sendFcmNotification(topic, body, title, data) {
  const message = {
    notification: {
      title: title,
      body: body
    },
    data: {
      orderID: data
    },
    topic: topic
  }

  try {
    await messaging.send(message)
    console.log('FCM notification sent successfully')
  } catch (error) {
    console.error('Error sending FCM notification:', error)
  }
}

async function sendEmail(email, subject, body) {
  const transporter = createTransport({
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
    console.log('Email sent successfully')
  } catch (error) {
    console.error('Error sending email:', error)
  }
}

exports.notifyBuyerOnOrderStatusChange = firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const newOrderData = change.after.data()
    const oldOrderData = change.before.data()

    if (
      newOrderData['order status'] !== oldOrderData['order status'] &&
      newOrderData['order status'] !== 'expired'
    ) {
      const buyerId = newOrderData['buyerID']
      const buyerDoc = await db.collection('userProfile').doc(buyerId).get()
      const buyerData = buyerDoc.data()
      const orderID = context.params.orderId
      const fcmTitle = 'Order Status Update'
      const fcmBody = `Your order has been ${newOrderData['order status']},\nKindly Confirm`

      await db
        .collection('notifications')
        .doc(buyerId)
        .collection('notifications')
        .add({
          userID: buyerId,
          'extra data': orderID,
          title: fcmTitle,
          body: fcmBody,
          'time stamp': t
        })

      if (buyerId && buyerData['token']) {
        await sendFcmNotification(
          `buyer_${buyerId}`,
          fcmBody,
          fcmTitle,
          orderID
        )
      }

      if (buyerData && buyerData['email']) {
        const emailSubject = 'Order Status Update'
        const emailBody = `
          <p>Dear ${buyerData['fullname']},</p>
          <p>Your order with ID: ${orderID} has been ${newOrderData['order status']}, Kindly Confirm.</p>
        `
        await sendEmail(buyerData['email'], emailSubject, emailBody)
      }
    }

    return null
  })

exports.notifyOnOrderCreation = firestore
  .document('orders/{orderId}')
  .onCreate(async (snapshot, context) => {
    const orderData = snapshot.data()
    const buyerId = orderData.buyerID
    const buyerDoc = await db.collection('userProfile').doc(buyerId).get()
    const buyerData = buyerDoc.data()
    const vendorID = orderData.vendorID
    const vendorDoc = await db.collection('userProfile').doc(vendorID).get()
    const vendorData = vendorDoc.data()
    const orderID = context.params.orderId
    const fcmTitle = 'New Order Created'
    const vendorFcmBody = 'You have a new order for your product'
    const buyerFcmBody = 'Your order has been created'
    const emailSubject = 'New Order Created'
    const buyerEmailBody = `
      <p>Dear ${buyerData['fullname']},</p>
      <p>Your order with ID: ${orderID} has been successfully created.</p>
    `
    const vendorEmailBody = `
      <p>Dear ${vendorData['fullname']},</p>
      <p>You have a new order for your product with ID: ${orderID}.</p>
    `

    await db
      .collection('notifications')
      .doc(buyerId)
      .collection('notifications')
      .add({
        userID: buyerId,
        'extra data': orderID,
        title: fcmTitle,
        body: buyerFcmBody,
        'time stamp': t
      })

    await db
      .collection('notifications')
      .doc(vendorID)
      .collection('notifications')
      .add({
        userID: vendorID,
        'extra data': orderID,
        title: fcmTitle,
        body: vendorFcmBody,
        'time stamp': t
      })

    await sendFcmNotification(
      `buyer_${buyerId}`,
      buyerFcmBody,
      fcmTitle,
      orderID
    )
    await sendEmail(buyerData['email'], emailSubject, buyerEmailBody)

    await sendFcmNotification(
      `vendor_${vendorID}`,
      vendorFcmBody,
      fcmTitle,
      orderID
    )
    await sendEmail(vendorData['email'], emailSubject, vendorEmailBody)

    return null
  })

exports.updateWalletAfterOrderPlacement = firestore
  .document('orders/{orderId}')
  .onCreate(async (snapshot, context) => {
    const order = snapshot.data()
    const vendorId = order.vendorID
    const paymentPrice = order['payment price']
    const orderId = context.params.orderId

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
      timestamp: _firestore.FieldValue.serverTimestamp(),
      amount: paymentPrice
    })

    console.log('Wallet updated successfully')
    return null
  })

exports.processConfirmedOrder = firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const orderId = context.params.orderId
    const orderData = change.after.data()
    const previousOrderData = change.before.data()

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
        //console.log(`current amount: ${currentAmount}`);
        //console.log(`updated amount: ${updatedAmount}`);
        // Update the wallet with the new amount
        await walletRef.update({
          'withdrawable balance': updatedAmount
        })

        //console.log(`Amount remitted to vendor (${vendorId}): ${amountToRemit}`);
        return null
      } else {
        console.error(`Wallet not found for vendor (${vendorId})`)
        return null
      }
    }

    return null
  })

exports.processExpiredOrder = firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const orderId = context.params.orderId
    const orderData = change.after.data()
    const previousOrderData = change.before.data()

    // Check if the order status changed to "confirmed"
    if (
      orderData['order status'] === 'expired' &&
      previousOrderData['order status'] !== 'expired'
    ) {
      const vendorId = orderData.vendorID // Assuming there's a field called "vendorId" in your order document
      const transactionIDs = orderData['transactionID']
      const installments = transactionIDs.length
      const paymentPrice = orderData['payment price'] // Adjust this based on your data model
      const refundAmount = (paymentPrice - paymentPrice * 0.1) / installments
      const orderRef = db.collection('orders').doc(orderId)
      await orderRef.update({
        'refund operations': 0
      })
      const metadata = {
        orderId: orderId
      }
      for (const transactionID in transactionIDs) {
        try {
          const transactionResponse = await axios.get(
            `https://api.paystack.co/transaction/verify/${transactionID}`,
            {
              headers: {
                Authorization: `Bearer ${paystackSecretKey}`
              }
            }
          )
          if (transactionResponse.status === 200) {
            if (transactionResponse.data.data.amount >= refundAmount) {
              await initiateRefund(transactionID, refundAmount, metadata)
              orderRef.update({
                'refund operations': FieldValue.increment(1)
              })
            } else {
              console.log(
                'cannot complete the refund because amount less than refund'
              )
            }
          } else {
            console.log(transactionResponse.status)
          }
        } catch (error) {
          console.error('Cannot verify transaction:', error)
        }
      }
    }

    return null
  })

exports.checkInstallmentPayments = pubsub
  .schedule('every 10 minutes')
  .onRun(async context => {
    const currentTime = Date.now()

    // Query orders with "installment" payment method
    const installmentOrdersSnapshot = await db
      .collection('orders')
      .where('payment method', '==', 'installment')
      .get()

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
      const installmentDuration = vendorRef.data()['installment duration'] || 0 // Default to 3 days if not specified
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
        const reminderDoc = await db.collection('reminders').doc(orderID).get()
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

          await sendFcmNotification(
            `buyer_${order['buyerID']}`,
            fcmBody,
            fcmTitle,
            orderID
          )
          await db
            .collection('notifications')
            .doc(order['buyerID'])
            .collection('notifications')
            .add({
              body: fcmBody,
              'extra data': orderID,
              'time stamp': t,
              title: fcmTitle,
              userID: order['buyerID']
            })
          await sendEmail(buyerRef.data()['email'], 'Order Expired', fcmBody)

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
              orderID
            )
            await db
              .collection('notifications')
              .doc(order['buyerID'])
              .collection('notifications')
              .add({
                body: buyerFcmBody,
                'extra data': orderID,
                'time stamp': t,
                title: fcmTitle,
                userID: order['buyerID']
              })
            await sendEmail(
              buyerRef.data()['email'],
              'Payment Reminder',
              'Please remember to pay your installment payment before the deadline runs out'
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
              orderID
            )
            await db
              .collection('notifications')
              .doc(order['buyerID'])
              .collection('notifications')
              .add({
                body: buyerFcmBody,
                'extra data': orderID,
                'time stamp': t,
                title: fcmTitle,
                userID: order['buyerID']
              })
            await sendEmail(
              buyerRef.data()['email'],
              'Payment Reminder',
              'Please remember to pay your installment payment before the deadline runs out'
            )

            await db
              .collection('reminders')
              .doc(orderID)
              .set({ oneDayPaymentReminderSent: true }, { merge: true })
          }
        }
      }
    })
    //console.log('this ran')
    return null
  })

exports.api = https.onRequest(app)

exports.handleRefundRequestCreation = firestore
  .document('refunds/{requestId}')
  .onCreate(async (snapshot, context) => {
    try {
      // Get the refund request data
      const refundRequestData = snapshot.data()
      if (!refundRequestData) {
        throw new Error('Refund request data is missing')
      }

      // Get the order associated with the refund request
      const orderId = refundRequestData['orderID']
      const orderSnapshot = await db.collection('orders').doc(orderId).get()
      const orderData = orderSnapshot.data()
      if (!orderData) {
        throw new Error('Order data is missing')
      }

      // Get user and vendor data
      const buyerId = orderData['buyerID']
      const vendorId = orderData['vendorID']
      const buyerSnapshot = await db
        .collection('userProfile')
        .doc(buyerId)
        .get()
      const vendorSnapshot = await db
        .collection('userProfile')
        .doc(vendorId)
        .get()
      const buyerData = buyerSnapshot.data()
      const vendorData = vendorSnapshot.data()
      if (!buyerData || !vendorData) {
        throw new Error('Buyer or vendor data is missing')
      }

      // Send email notifications
      await sendEmail(
        buyerData['email'],
        'Refund Request Submitted',
        'Your refund request has been submitted successfully.'
      )
      await sendEmail(
        vendorData['email'],
        'New Refund Request',
        'A new refund request has been submitted by a buyer.'
      )
      await sendEmail(
        ADMIN_EMAIL,
        'New Refund Request',
        'A new refund request has been submitted.'
      )

      //send FCM notifications
      await sendFcmNotification(
        `buyer_${buyerId}`,
        'Your refund request has been submitted successfully.',
        'Refund Request Submitted',
        orderId
      )

      await sendFcmNotification(
        `vendor_${vendorId}`,
        'A new refund request has been submitted by a buyer.',
        'New Refund Request',
        orderId
      )

      //update notifications in db
      await db
        .collection('notifications')
        .doc(buyerId)
        .collection('notifications')
        .add({
          userID: buyerId,
          'extra data': orderId,
          title: 'Refund Request Submitted',
          body: 'Your refund request has been submitted successfully.',
          'time stamp': t
        })

      await db
        .collection('notifications')
        .doc(vendorId)
        .collection('notifications')
        .add({
          userID: vendorId,
          'extra data': orderId,
          title: 'New Refund Request',
          body: 'A new refund request has been submitted by a buyer.',
          'time stamp': t
        })

      return null
    } catch (error) {
      console.error('Error handling refund request creation:', error)
      return null
    }
  })

exports.handleOrderCancelRequestCreation = firestore
  .document('cancellations/{requestID}')
  .onCreate(async (snapshot, context) => {
    try {
      // Get the cancel request data
      const cancelRequestData = snapshot.data()
      if (!cancelRequestData) {
        throw new Error('Cancel request data is missing')
      }

      // Get the order associated with the cancel request
      const orderId = cancelRequestData['orderID']
      const orderSnapshot = await db.collection('orders').doc(orderId).get()
      const orderData = orderSnapshot.data()
      if (!orderData) {
        throw new Error('Order data is missing')
      }

      // Get user and vendor data
      const buyerId = orderData['buyerID']
      const vendorId = orderData['vendorID']
      const buyerSnapshot = await db
        .collection('userProfile')
        .doc(buyerId)
        .get()
      const vendorSnapshot = await db
        .collection('userProfile')
        .doc(vendorId)
        .get()
      const buyerData = buyerSnapshot.data()
      const vendorData = vendorSnapshot.data()
      if (!buyerData || !vendorData) {
        throw new Error('Buyer or vendor data is missing')
      }

      // Send email notifications
      await sendEmail(
        buyerData['email'],
        'Order Cancel Request Submitted',
        'Your order cancel request has been submitted successfully.'
      )
      await sendEmail(
        vendorData['email'],
        'New Order Cancel Request',
        'A new order cancel request has been submitted by a buyer.'
      )
      await sendEmail(
        ADMIN_EMAIL,
        'New Order Cancel Request',
        'A new order cancel request has been submitted.'
      )

      //send fcm notification to buyer and vendor
      await sendFcmNotification(
        `buyer_${buyerId}`,
        'Your order cancel request has been submitted successfully.',
        'Order Cancel Request Submitted',
        orderId
      )

      await sendFcmNotification(
        `vendor_${vendorId}`,
        'A new order cancel request has been submitted by a buyer.',
        'New Order Cancel Request',
        orderId
      )

      await db
        .collection('notifications')
        .doc(buyerId)
        .collection('notifications')
        .add({
          userID: buyerId,
          'extra data': orderId,
          title: 'Order Cancel Request Submitted',
          body: 'Your order cancel request has been submitted successfully.',
          'time stamp': t
        })

      await db
        .collection('notifications')
        .doc(vendorId)
        .collection('notifications')
        .add({
          userID: vendorId,
          'extra data': orderId,
          title: 'New Order Cancel Request',
          body: 'A new order cancel request has been submitted by a buyer.',
          'time stamp': t
        })

      return null
    } catch (error) {
      console.error('Error handling order cancel request creation:', error)
      return null
    }
  })

async function initiateRefund(transactionId, refundAmount, metadata = {}) {
  try {
    const response = await axios.post(
      'https://api.paystack.co/refund',
      {
        transaction: transactionId,
        amount: refundAmount,
        metadata: metadata
      },
      {
        headers: {
          Authorization: `Bearer ${paystackSecretKey}`
        }
      }
    )
    return response.data
  } catch (error) {
    console.error('Error initiating refund:', error.response.data)
    throw error
  }
}

exports.handleRefunds = firestore
  .document('refunds/{refundId}')
  .onUpdate(async (change, context) => {
    const refundId = context.params.refundId
    const newValue = change.after.data()
    const oldValue = change.before.data()

    if (
      newValue['refund status'] === 'approved' &&
      oldValue['refund status'] !== 'approved'
    ) {
      try {
        // ... (Retrieve order data, calculate refund amount, get user and vendor data)
        const orderId = newValue['orderID']
        const orderSnapshot = await db.collection('orders').doc(orderId).get()
        const orderData = orderSnapshot.data()
        if (!orderData) {
          throw new Error('Order data is missing')
        }

        // Get user and vendor data
        const buyerId = orderData['buyerID']
        const vendorId = orderData['vendorID']
        const buyerSnapshot = await db
          .collection('userProfile')
          .doc(buyerId)
          .get()
        const vendorSnapshot = await db
          .collection('userProfile')
          .doc(vendorId)
          .get()
        const buyerData = buyerSnapshot.data()
        const vendorData = vendorSnapshot.data()
        if (!buyerData || !vendorData) {
          throw new Error('Buyer or vendor data is missing')
        }

        // Send email notifications
        await Promise.all([
          sendEmail(
            buyerData['email'],
            'Refund Approved',
            'Your refund has been approved.'
          ),
          sendEmail(
            vendorData['email'],
            'Refund Approved',
            'A refund has been approved.'
          ),
          sendEmail(
            ADMIN_EMAIL,
            'Refund Approved',
            'A refund has been approved.'
          )
        ])

        //send notification to both vendor and buyer
        const buyerFcmBody = 'Refund has been approved.'
        const fcmTitle = 'Refund Approved'

        await Promise.all([
          sendFcmNotification(
            `buyer_${buyerId}`,
            buyerFcmBody,
            fcmTitle,
            orderId
          ),
          db
            .collection('notifications')
            .doc(buyerId)
            .collection('notifications')
            .add({
              body: buyerFcmBody,
              'extra data': orderId,
              'time stamp': t,
              title: fcmTitle,
              userID: buyerId
            }),

          sendFcmNotification(
            `vendor_${vendorId}`,
            buyerFcmBody,
            fcmTitle,
            orderId
          ),
          db
            .collection('notifications')
            .doc(vendorId)
            .collection('notifications')
            .add({
              body: buyerFcmBody,
              'extra data': orderId,
              'time stamp': t,
              title: fcmTitle,
              userID: vendorId
            })
        ])

        // Get payment amount and calculate refund amount based on the reason
        const paymentAmount = orderData['payment price']
        const transactionIDs = orderData['transactionID']
        const installments = transactionIDs.length
        console.log('transactionID:', transactionIDs)
        const refundRef = db.collection('refunds').doc(refundId)
        await refundRef.update({
          'refund operations': 0
        })
        let refundAmount
        const metadata = {
          refundId: refundId,
          orderId: orderId
        }
        if (
          newValue['reason'] === 'Defective Product' ||
          newValue['reason'] === 'Received Wrong Item'
        ) {
          for (const transactionID in transactionIDs) {
            try {
              const transactionResponse = await axios.get(
                `https://api.paystack.co/transaction/verify/${transactionID}`,
                {
                  headers: {
                    Authorization: `Bearer ${paystackSecretKey}`
                  }
                }
              )
              if (transactionResponse.status === 200) {
                refundAmount = paymentAmount / installments
                if (transactionResponse.data.data.amount >= refundAmount) {
                  await initiateRefund(transactionID, refundAmount, metadata)
                  refundRef.update({
                    'refund operations': FieldValue.increment(1)
                  })
                } else {
                  console.log(
                    'cannot complete the refund because amount less than refund'
                  )
                }
              } else {
                console.log(transactionResponse.status)
              }
            } catch (error) {
              console.error('Cannot verify transaction:', error)
            }
          }
        } else {
          for (const transactionID in transactionIDs) {
            try {
              const transactionResponse = await axios.get(
                `https://api.paystack.co/transaction/verify/${transactionID}`,
                {
                  headers: {
                    Authorization: `Bearer ${paystackSecretKey}`
                  }
                }
              )
              if (transactionResponse.status === 200) {
                refundAmount =
                  (paymentAmount - paymentPrice * 0.1) / installments
                if (transactionResponse.data.data.amount >= refundAmount) {
                  await initiateRefund(transactionID, refundAmount, metadata)
                  refundRef.update({
                    'refund operations': FieldValue.increment(1)
                  })
                } else {
                  console.log(
                    'cannot complete the refund because amount less than refund'
                  )
                }
              } else {
                console.log(transactionResponse.status)
              }
            } catch (error) {
              console.error('Cannot verify payment:', error)
            }
          }
        }
      } catch (error) {
        console.error('Error processing refund:', error)
      }
    }
  })

exports.handleOrderCancellations = firestore
  .document('cancellations/{cancellationId}')
  .onUpdate(async (change, context) => {
    const cancellationId = context.params.cancellationId
    const newValue = change.after.data()
    const oldValue = change.before.data()

    if (
      newValue['cancellation status'] === 'approved' &&
      oldValue['cancellation status'] !== 'approved'
    ) {
      try {
        // ... (Retrieve order data, calculate refund amount, get user and vendor data)
        const orderId = newValue['orderID']
        const orderSnapshot = await db.collection('orders').doc(orderId).get()
        const orderData = orderSnapshot.data()
        if (!orderData) {
          throw new Error('Order data is missing')
        }

        // Get user and vendor data
        const buyerId = orderData['buyerID']
        const vendorId = orderData['vendorID']
        const buyerSnapshot = await db
          .collection('userProfile')
          .doc(buyerId)
          .get()
        const vendorSnapshot = await db
          .collection('userProfile')
          .doc(vendorId)
          .get()
        const buyerData = buyerSnapshot.data()
        const vendorData = vendorSnapshot.data()
        if (!buyerData || !vendorData) {
          throw new Error('Buyer or vendor data is missing')
        }

        // Send email notifications
        await Promise.all([
          sendEmail(
            buyerData['email'],
            'Order Cancellation Approved',
            'Your Order Cancellation Request has been approved.'
          ),
          sendEmail(
            vendorData['email'],
            'Order Cancellation Approved',
            'An Order Cancellation Request has been approved by Admin.'
          ),
          sendEmail(
            ADMIN_EMAIL,
            'Order Cancellation Approved',
            'A Order Cancellation has been approved.'
          )
        ])

        //send notification to both vendor and buyer
        const buyerFcmBody = 'Order Cancellation has been approved.'
        const fcmTitle = 'Order Cancellattion Approved'

        await Promise.all([
          sendFcmNotification(
            `buyer_${buyerId}`,
            buyerFcmBody,
            fcmTitle,
            orderId
          ),
          db
            .collection('notifications')
            .doc(buyerId)
            .collection('notifications')
            .add({
              body: buyerFcmBody,
              'extra data': orderId,
              'time stamp': t,
              title: fcmTitle,
              userID: buyerId
            }),

          sendFcmNotification(
            `vendor_${vendorId}`,
            buyerFcmBody,
            fcmTitle,
            orderId
          ),
          db
            .collection('notifications')
            .doc(vendorId)
            .collection('notifications')
            .add({
              body: buyerFcmBody,
              'extra data': orderId,
              'time stamp': t,
              title: fcmTitle,
              userID: vendorId
            })
        ])

        const paymentAmount = orderData['payment price']
        const transactionIDs = orderData['transactionID']
        const installments = transactionIDs.length
        console.log('transactionID:', transactionIDs)
        const cancellationRef = db
          .collection('cancellations')
          .doc(cancellationId)
        await cancellationRef.update({
          'cancellation operations': 0
        })
        let refundAmount
        const metadata = {
          cancellationId: cancellationId,
          orderId: orderId
        }
        for (const transactionID in transactionIDs) {
          try {
            const transactionResponse = await axios.get(
              `https://api.paystack.co/transaction/verify/${transactionID}`,
              {
                headers: {
                  Authorization: `Bearer ${paystackSecretKey}`
                }
              }
            )
            if (transactionResponse.status === 200) {
              refundAmount =
                (paymentAmount - paymentAmount * 0.1) / installments
              if (transactionResponse.data.data.amount >= refundAmount) {
                await initiateRefund(transactionID, refundAmount, metadata)
                cancellationRef.update({
                  'cancellation operations': FieldValue.increment(1)
                })
              } else {
                console.log(
                  'cannot complete the refund because amount less than refund'
                )
              }
            } else {
              console.log(transactionResponse.status)
            }
          } catch (error) {
            console.error('Cannot verify transaction:', error)
          }
        }
      } catch (error) {
        console.error('Error processing refund:', error)
      }
    }
  })

exports.paystackRefundWebhook = https.onRequest(async (req, res) => {
  // Verify the Paystack webhook signature
  const signature = req.headers['x-paystack-signature']
  if (!signature || !validateSignature(req.rawBody, signature)) {
    console.error('Invalid signature:', signature)
    res.status(400).send('Invalid signature')
    return
  }

  const event = req.body
  let inRefunds
  let inCancellations

  if (event.event === 'refund.processed') {
    const orderId = event.data.metadata['orderId']

    try {
      //get order
      const orderSnapshot = await db.collection('orders').doc(orderId).get()
      const orderData = orderSnapshot.data()

      // Get buyer and vendor data from the order document
      const buyerId = orderData['buyerID']
      const vendorId = orderData['vendorID']
      const buyerSnapshot = await db
        .collection('userProfile')
        .doc(buyerId)
        .get()
      const vendorSnapshot = await db
        .collection('userProfile')
        .doc(vendorId)
        .get()
      const buyerData = buyerSnapshot.data()
      const vendorData = vendorSnapshot.data()

      //get refund details
      const refundSnapshot = await db
        .collection('refunds')
        .where('orderID', '==', orderData['orderID'])
        .get()
      if (refundSnapshot.size > 1) {
        console.error('Multiple refunds found for the same orderID')
        res.status(400).send('Multiple refunds found for the same orderID')
        return
      } else if (refundSnapshot.empty) {
        inRefunds = false
      } else {
        inRefunds = true
      }

      //get cancellation details
      const cancellationSnapshot = await db
        .collection('cancellations')
        .where('orderID', '==', orderData['orderID'])
        .get()
      if (cancellationSnapshot.size > 1) {
        console.error('Multiple cancellations found for the same orderID')
        res
          .status(400)
          .send('Multiple cancellations found for the same orderID')
        return
      } else if (cancellationSnapshot.empty) {
        inCancellations = false
      } else {
        inCancellations = true
      }

      //do the conditional checks
      if (orderData['order status'] === 'expired') {
        //update the vendors wallet
        const orderRef = db.collection('orders').doc(orderId)
        await orderRef.update({
          'refund operations': FieldValue.increment(-1)
        })
        if (orderSnapshot.exists && orderData['refund operations'] === 0) {
          const installments = orderData['transactionID'].length
          const paymentAmount = orderData['payment price']
          const refundAmount =
            paymentAmount - (paymentAmount * 0.1) / installments
          await processExpiredOrder(
            refundAmount,
            vendorId,
            orderData['orderID']
          )
        } else {
          console.log('Refund Process not yet complete or it failed')
        }
      } else if (inRefunds) {
        //update refunds to complete
        const refundData = refundSnapshot.docs[0].data()
        const refundId = refundData['requestID']
        const refundDocRef = db.collection('refunds').doc(refundId)
        await refundDocRef.update({
          'refund operations': FieldValue.increment(-1) // Decrement the counter
        })
        if (refundSnapshot.exists && refundData['refund operations'] === 0) {
          const installments = orderData['transactionID'].length
          const paymentAmount = orderData['payment price']
          let refundAmount
          if (
            refundData['reason'] === 'Defective Product' ||
            refundData['reason'] === 'Received Wrong Item'
          ) {
            refundAmount = paymentAmount / installments
          }else{
            refundAmount = paymentAmount - (paymentAmount * 0.1) / installments
          }
          await processRefunds(refundData, buyerData, vendorData, refundAmount)
        } else {
          console.log('Refund Process not yet complete or it failed')
        }
      } else if (inCancellations) {
        //update cancellations to complete
        const cancellationData = cancellationSnapshot.docs[0].data()
        const cancellationId = cancellationData['requestID']
        const cancellationRef = db
          .collection('cancellations')
          .doc(cancellationId)
        await cancellationRef.update({
          'cancellation operations': FieldValue.increment(-1)
        })
        if (
          cancellationSnapshot.exists &&
          cancellationData['cancellation operations'] === 0
        ) {
          const installments = orderData['transactionID'].length
          const paymentAmount = orderData['payment price']
          const refundAmount =
            paymentAmount - (paymentAmount * 0.1) / installments
          await processCancellations(
            cancellationData,
            buyerData,
            vendorData,
            refundAmount
          )
        } else {
          console.log('Refund Process not yet complete or it failed')
        }
      }

      res.status(200).send('Webhook received and processed successfully.')
    } catch (error) {
      console.error('Error processing refund webhook:', error)
      res.status(500).send('Error processing webhook')
    }
  } else {
    res.status(200).send('Webhook received but not processed.')
  }
})

// Helper function to validate Paystack webhook signature
function validateSignature(body, signature) {
  const crypto = require('crypto')
  const bodyString = body.toString('utf8')
  const hash = crypto
    .createHmac('sha512', process.env.PAYSTACK_SECRET_KEY)
    .update(bodyString)
    .digest('hex')

  return hash === signature
}

async function processExpiredOrder(refundAmount, vendorId, orderID) {
  const transaction = db.runTransaction(async t => {
    const vendorWalletRef = db.collection('wallet').doc(vendorId)
    const vendorWalletSnapshot = await t.get(vendorWalletRef)

    if (!vendorWalletSnapshot.exists) {
      throw new Error('Vendor wallet not found')
    }

    t.update(vendorWalletRef, {
      balance: db.FieldValue.increment(-refundAmount)
    })
  })

  try {
    await transaction
    console.log('Transaction successfully committed!')

    //add a transaction for vendor
    await db.collection('wallet').doc(vendorId).collection('transactions').add({
      type: 'debit',
      timestamp: FieldValue.serverTimestamp(),
      orderId: orderID,
      amount: refundAmount
    })
  } catch (error) {
    console.error('Transaction failed:', error)
  }
}

async function processRefunds(refundData, buyerData, vendorData, refundAmount) {
  const buyerFcmBody = 'Refund has been completed.'
  const fcmTitle = 'Refund Completed'
  const buyerId = buyerData['uid']
  const vendorId = vendorData['uid']
  await db
    .collection('refunds')
    .doc(refundData['requestID'])
    .update({ 'refund status': 'completed' })

  await Promise.all([
    sendEmail(ADMIN_EMAIL, 'Refund Completed', 'A refund has been completed.'),
    sendEmail(
      vendorData['email'],
      'Refund Completed',
      'A refund has been completed.'
    ),
    sendEmail(
      buyerData['email'],
      'Refund Completed',
      'Your refund has been completed.'
    ),
    //send notification to both vendor and buyer

    sendFcmNotification(
      `buyer_${buyerId}`,
      buyerFcmBody,
      fcmTitle,
      refundData['orderID']
    ),
    db
      .collection('notifications')
      .doc(buyerId)
      .collection('notifications')
      .add({
        body: buyerFcmBody,
        'extra data': refundData['orderID'],
        'time stamp': t,
        title: fcmTitle,
        userID: buyerId
      }),

    sendFcmNotification(
      `vendor_${vendorId}`,
      buyerFcmBody,
      fcmTitle,
      refundData['orderID']
    ),
    db
      .collection('notifications')
      .doc(vendorId)
      .collection('notifications')
      .add({
        body: buyerFcmBody,
        'extra data': refundData['orderID'],
        'time stamp': t,
        title: fcmTitle,
        userID: vendorId
      })
  ])
  //update vendor wallet
  const transaction = db.runTransaction(async t => {
    const vendorWalletRef = db.collection('wallet').doc(vendorId)
    const vendorWalletSnapshot = await t.get(vendorWalletRef)

    if (!vendorWalletSnapshot.exists) {
      throw new Error('Vendor wallet not found')
    }

    t.update(vendorWalletRef, {
      balance: db.FieldValue.increment(-refundAmount),
      'withdrawable balance': db.FieldValue.increment(-refundAmount)
    })
  })
  try {
    await transaction
    console.log('Transaction successfully committed!')

    //add a transaction for vendor
    await db.collection('wallet').doc(vendorId).collection('transactions').add({
      type: 'debit',
      timestamp: FieldValue.serverTimestamp(),
      orderId: orderID,
      amount: refundAmount
    })
  } catch (error) {
    console.error('Transaction failed:', error)
  }
}

async function processCancellations(
  cancellationData,
  buyerData,
  vendorData,
  refundAmount
) {
  const buyerFcmBody = 'Order Cancellation has been completed.'
  const fcmTitle = 'Order Cancellation Completed'
  const buyerId = buyerData['uid']
  const vendorId = vendorData['uid']
  await db
    .collection('cancellations')
    .doc(cancellationData['requestID'])
    .update({ 'cancellation status': 'completed' })

  await Promise.all([
    sendEmail(
      ADMIN_EMAIL,
      'Order Cancellation Completed',
      'An Order Cancellation has been completed.'
    ),
    sendEmail(
      vendorData['email'],
      'Order Cancellation Completed',
      'An Order Cancellation has been completed.'
    ),
    sendEmail(
      buyerData['email'],
      'Order Cancellation Completed',
      'Your Order Cancellation has been completed.'
    ),
    //send notification to both vendor and buyer

    sendFcmNotification(
      `buyer_${buyerId}`,
      buyerFcmBody,
      fcmTitle,
      refundData['orderID']
    ),
    db
      .collection('notifications')
      .doc(buyerId)
      .collection('notifications')
      .add({
        body: buyerFcmBody,
        'extra data': refundData['orderID'],
        'time stamp': t,
        title: fcmTitle,
        userID: buyerId
      }),

    sendFcmNotification(
      `vendor_${vendorId}`,
      buyerFcmBody,
      fcmTitle,
      refundData['orderID']
    ),
    db
      .collection('notifications')
      .doc(vendorId)
      .collection('notifications')
      .add({
        body: buyerFcmBody,
        'extra data': refundData['orderID'],
        'time stamp': t,
        title: fcmTitle,
        userID: vendorId
      })
  ])
  //update vendor wallet
  const transaction = db.runTransaction(async t => {
    const vendorWalletRef = db.collection('wallet').doc(vendorId)
    const vendorWalletSnapshot = await t.get(vendorWalletRef)

    if (!vendorWalletSnapshot.exists) {
      throw new Error('Vendor wallet not found')
    }

    t.update(vendorWalletRef, {
      balance: db.FieldValue.increment(-refundAmount)
    })
  })
  try {
    await transaction
    console.log('Transaction successfully committed!')
    //add a transaction for vendor
    await db.collection('wallet').doc(vendorId).collection('transactions').add({
      type: 'debit',
      timestamp: FieldValue.serverTimestamp(),
      orderId: orderID,
      amount: refundAmount
    })
  } catch (error) {
    console.error('Transaction failed:', error)
  }
}

//send admin email on become a seller request
exports.sendEmailToAdminOnVendorCreation = firestore
  .document('vendors/{vendorId}')
  .onCreate(async (snapshot, context) => {
    try {
      // Get the newly created vendor data
      const vendorData = snapshot.data()

      // Send email notification to admin
      const adminEmail = 'admin@example.com' // Replace with your admin email
      const subject = 'Someone Wants to Become A Seller With Us'
      const message = `Become a seller form has been Submitted\n\nDetails:\nShop Name: ${vendorData['shop name']}`

      await sendEmail(ADMIN_EMAIL, subject, message)

      console.log('Email notification sent to admin successfully')
    } catch (error) {
      console.error('Error sending email notification:', error)
    }
  })

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