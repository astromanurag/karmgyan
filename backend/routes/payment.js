const express = require('express');
const router = express.Router();
const crypto = require('crypto');

// Cashfree configuration
const CASHFREE_APP_ID = process.env.CASHFREE_APP_ID;
const CASHFREE_SECRET_KEY = process.env.CASHFREE_SECRET_KEY;
const CASHFREE_MODE = process.env.CASHFREE_MODE || 'sandbox';
const CASHFREE_BASE_URL = CASHFREE_MODE === 'production' 
  ? 'https://api.cashfree.com' 
  : 'https://sandbox.cashfree.com';

// Helper: Generate signature for Cashfree
function generateSignature(orderId, orderAmount, orderCurrency = 'INR') {
  const data = `${orderId}${orderAmount}${orderCurrency}`;
  return crypto
    .createHmac('sha256', CASHFREE_SECRET_KEY || '')
    .update(data)
    .digest('hex');
}

// Create Cashfree order
router.post('/create-order', async (req, res) => {
  try {
    const { amount, orderId, customerName, customerEmail, customerPhone, description } = req.body;

    if (!amount || !orderId) {
      return res.status(400).json({ error: 'Amount and orderId are required' });
    }

    if (!CASHFREE_APP_ID || !CASHFREE_SECRET_KEY) {
      // Mock response for development
      return res.json({
        orderId: orderId,
        amount: amount,
        payment_session_id: `mock_session_${Date.now()}`,
        payment_url: 'https://mock-payment-url.com',
      });
    }

    // Create payment session with Cashfree
    const axios = require('axios');
    const paymentSessionData = {
      order_id: orderId,
      order_amount: amount,
      order_currency: 'INR',
      customer_details: {
        customer_id: customerEmail,
        customer_name: customerName,
        customer_email: customerEmail,
        customer_phone: customerPhone,
      },
      order_meta: {
        return_url: `${process.env.BACKEND_URL || 'http://localhost:3000'}/api/payment/callback?order_id=${orderId}`,
        notify_url: `${process.env.BACKEND_URL || 'http://localhost:3000'}/api/payment/webhook`,
      },
    };

    const response = await axios.post(
      `${CASHFREE_BASE_URL}/pg/orders/session`,
      paymentSessionData,
      {
        headers: {
          'x-client-id': CASHFREE_APP_ID,
          'x-client-secret': CASHFREE_SECRET_KEY,
          'x-api-version': '2022-09-01',
          'Content-Type': 'application/json',
        },
      }
    );

    res.json({
      orderId: orderId,
      amount: amount,
      payment_session_id: response.data.payment_session_id,
      payment_url: response.data.payment_url,
    });
  } catch (error) {
    console.error('Payment error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Payment callback (return URL)
router.get('/callback', async (req, res) => {
  try {
    const { order_id, payment_status } = req.query;
    
    // Redirect to frontend with payment status
    const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:8080';
    res.redirect(`${frontendUrl}/payment/callback?order_id=${order_id}&status=${payment_status}`);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Payment webhook
router.post('/webhook', async (req, res) => {
  try {
    const signature = req.headers['x-cashfree-signature'];
    const payload = JSON.stringify(req.body);

    // Verify signature
    const expectedSignature = crypto
      .createHmac('sha256', CASHFREE_SECRET_KEY || '')
      .update(payload)
      .digest('hex');

    if (signature !== expectedSignature) {
      return res.status(401).json({ error: 'Invalid signature' });
    }

    const { orderId, orderAmount, paymentStatus, paymentMessage, paymentTime } = req.body;

    // Update order status in database
    // TODO: Update order in Supabase/database

    console.log('Payment webhook received:', {
      orderId,
      orderAmount,
      paymentStatus,
      paymentMessage,
    });

    res.json({ success: true });
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get payment status
router.get('/status/:orderId', async (req, res) => {
  try {
    const { orderId } = req.params;

    if (!CASHFREE_APP_ID || !CASHFREE_SECRET_KEY) {
      // Mock response
      return res.json({
        status: 'success',
        order_id: orderId,
      });
    }

    const axios = require('axios');
    const response = await axios.get(
      `${CASHFREE_BASE_URL}/pg/orders/${orderId}/payments`,
      {
        headers: {
          'x-client-id': CASHFREE_APP_ID,
          'x-client-secret': CASHFREE_SECRET_KEY,
          'x-api-version': '2022-09-01',
        },
      }
    );

    res.json(response.data);
  } catch (error) {
    console.error('Status check error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
