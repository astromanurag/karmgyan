const express = require('express');
const router = express.Router();

let razorpay;
try {
  const Razorpay = require('razorpay');
  if (process.env.RAZORPAY_KEY_ID && process.env.RAZORPAY_KEY_SECRET) {
    razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });
  }
} catch (error) {
  console.warn('Razorpay not configured, using mock mode');
}

router.post('/create-order', async (req, res) => {
  try {
    const { amount, currency = 'INR', receipt } = req.body;

    if (!amount) {
      return res.status(400).json({ error: 'Amount is required' });
    }

    if (razorpay) {
      const order = await razorpay.orders.create({
        amount: amount * 100, // Convert to paise
        currency,
        receipt: receipt || `receipt_${Date.now()}`,
      });
      res.json({ orderId: order.id, amount, currency });
    } else {
      // Mock response
      res.json({
        orderId: `order_mock_${Date.now()}`,
        amount,
        currency,
      });
    }
  } catch (error) {
    console.error('Payment error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.post('/verify-payment', async (req, res) => {
  try {
    const { orderId, paymentId, signature } = req.body;

    if (!razorpay) {
      // Mock verification
      res.json({ verified: true, paymentId });
      return;
    }

    const crypto = require('crypto');
    const hmac = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET);
    hmac.update(`${orderId}|${paymentId}`);
    const generatedSignature = hmac.digest('hex');

    if (generatedSignature === signature) {
      res.json({ verified: true, paymentId });
    } else {
      res.status(400).json({ verified: false, error: 'Invalid signature' });
    }
  } catch (error) {
    console.error('Verification error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

