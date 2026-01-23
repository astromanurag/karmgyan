const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/consultant', require('./routes/consultant'));
app.use('/api/computation', require('./routes/computation'));
app.use('/api/payment', require('./routes/payment'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/matching', require('./routes/matching'));
app.use('/api/panchang', require('./routes/panchang'));
app.use('/api/numerology', require('./routes/numerology'));
app.use('/api/ai', require('./routes/ai_predictions'));
app.use('/api/horoscope', require('./routes/horoscope'));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Check for mock mode
const useMockMode = !process.env.SUPABASE_URL || !process.env.RAZORPAY_KEY_ID;
if (useMockMode) {
  console.warn('⚠️  Running in MOCK MODE - Supabase/Razorpay credentials not configured');
}

app.listen(PORT, () => {
  console.log(`🚀 karmgyan backend server running on port ${PORT}`);
  console.log(`📊 Mode: ${useMockMode ? 'MOCK' : 'LIVE'}`);
});

