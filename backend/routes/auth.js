const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');

// Mock user storage (in production, use database)
const mockUsers = [];
const otpStore = new Map(); // phone -> { otp, expiresAt }
const resetCodes = new Map(); // email/phone -> { code, expiresAt }

// Helper: Generate OTP
function generateOTP() {
  return '123456'; // Mock OTP - in production, generate random 6-digit
}

// Helper: Generate reset code
function generateResetCode() {
  return '123456'; // Mock code - in production, generate random 6-digit
}

// Email/Password Sign Up
router.post('/signup', async (req, res) => {
  try {
    const { email, password, name } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Check if user exists
    const existingUser = mockUsers.find(u => u.email === email);
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Create user
    const user = {
      id: uuidv4(),
      email,
      password, // In production, hash this
      name: name || email.split('@')[0],
      role: 'client',
      auth_provider: 'email',
      email_verified: false,
      phone_verified: false,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    mockUsers.push(user);

    // Generate token (in production, use JWT)
    const token = `token_${user.id}_${Date.now()}`;

    res.json({
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        auth_provider: user.auth_provider,
        email_verified: user.email_verified,
        phone_verified: user.phone_verified,
        created_at: user.created_at,
        updated_at: user.updated_at,
      },
      token,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Email/Password Sign In
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user
    const user = mockUsers.find(u => u.email === email && u.password === password);
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate token
    const token = `token_${user.id}_${Date.now()}`;

    res.json({
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        auth_provider: user.auth_provider,
        email_verified: user.email_verified,
        phone_verified: user.phone_verified,
        created_at: user.created_at,
        updated_at: user.updated_at,
      },
      token,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Phone OTP - Send OTP
router.post('/phone/send-otp', async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).json({ error: 'Phone number is required' });
    }

    const otp = generateOTP();
    const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes

    otpStore.set(phone, { otp, expiresAt });

    // In production, send SMS via Twilio/Firebase
    console.log(`OTP for ${phone}: ${otp}`);

    res.json({ message: 'OTP sent successfully', otp: otp }); // Remove otp in production
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Phone OTP - Verify and Sign In/Up
router.post('/phone/verify-otp', async (req, res) => {
  try {
    const { phone, otp } = req.body;

    if (!phone || !otp) {
      return res.status(400).json({ error: 'Phone and OTP are required' });
    }

    const stored = otpStore.get(phone);
    if (!stored || stored.expiresAt < Date.now()) {
      return res.status(400).json({ error: 'OTP expired or invalid' });
    }

    if (stored.otp !== otp) {
      return res.status(401).json({ error: 'Invalid OTP' });
    }

    // Find or create user
    let user = mockUsers.find(u => u.phone === phone);
    if (!user) {
      user = {
        id: uuidv4(),
        phone,
        role: 'client',
        auth_provider: 'phone',
        email_verified: false,
        phone_verified: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };
      mockUsers.push(user);
    } else {
      user.phone_verified = true;
      user.updated_at = new Date().toISOString();
    }

    // Clear OTP
    otpStore.delete(phone);

    // Generate token
    const token = `token_${user.id}_${Date.now()}`;

    res.json({
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        name: user.name,
        role: user.role,
        auth_provider: user.auth_provider,
        email_verified: user.email_verified,
        phone_verified: user.phone_verified,
        created_at: user.created_at,
        updated_at: user.updated_at,
      },
      token,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Google Sign In
router.post('/google', async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({ error: 'Google token is required' });
    }

    // In production, verify token with Google
    // For mock, extract user info from token or use mock data
    const email = 'google_user@example.com';
    const name = 'Google User';
    const googleId = `google_${Date.now()}`;

    // Find or create user
    let user = mockUsers.find(u => u.google_id === googleId || u.email === email);
    if (!user) {
      user = {
        id: uuidv4(),
        email,
        name,
        google_id: googleId,
        role: 'client',
        auth_provider: 'google',
        email_verified: true,
        phone_verified: false,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };
      mockUsers.push(user);
    } else {
      user.updated_at = new Date().toISOString();
    }

    // Generate auth token
    const authToken = `token_${user.id}_${Date.now()}`;

    res.json({
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        auth_provider: user.auth_provider,
        google_id: user.google_id,
        email_verified: user.email_verified,
        phone_verified: user.phone_verified,
        created_at: user.created_at,
        updated_at: user.updated_at,
      },
      token: authToken,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Forgot Password - Send Reset Code
router.post('/forgot-password', async (req, res) => {
  try {
    const { email_or_phone } = req.body;

    if (!email_or_phone) {
      return res.status(400).json({ error: 'Email or phone is required' });
    }

    // Check if user exists
    const user = mockUsers.find(
      u => u.email === email_or_phone || u.phone === email_or_phone
    );

    if (!user) {
      // Don't reveal if user exists (security)
      return res.json({ message: 'If user exists, reset code sent' });
    }

    const code = generateResetCode();
    const expiresAt = Date.now() + 15 * 60 * 1000; // 15 minutes

    resetCodes.set(email_or_phone, { code, expiresAt });

    // In production, send email/SMS
    console.log(`Reset code for ${email_or_phone}: ${code}`);

    res.json({ message: 'Reset code sent', code: code }); // Remove code in production
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Reset Password
router.post('/reset-password', async (req, res) => {
  try {
    const { email_or_phone, code, new_password } = req.body;

    if (!email_or_phone || !code || !new_password) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    const stored = resetCodes.get(email_or_phone);
    if (!stored || stored.expiresAt < Date.now()) {
      return res.status(400).json({ error: 'Reset code expired or invalid' });
    }

    if (stored.code !== code) {
      return res.status(401).json({ error: 'Invalid reset code' });
    }

    // Find user
    const user = mockUsers.find(
      u => u.email === email_or_phone || u.phone === email_or_phone
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Update password
    user.password = new_password; // In production, hash this
    user.updated_at = new Date().toISOString();

    // Clear reset code
    resetCodes.delete(email_or_phone);

    res.json({ message: 'Password reset successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

