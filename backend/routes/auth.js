const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const axios = require('axios');

// Mock user storage (in production, use database)
const mockUsers = [];
const otpStore = new Map(); // phone -> { otp, expiresAt }
const resetCodes = new Map(); // email/phone -> { code, expiresAt }

// Clerk configuration
const CLERK_SECRET_KEY = process.env.CLERK_SECRET_KEY;
const CLERK_API_URL = 'https://api.clerk.com/v1';

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

    // Create new user
    const user = {
      id: uuidv4(),
      email,
      name: name || email.split('@')[0],
      role: 'client',
      auth_provider: 'email',
      email_verified: false,
      phone_verified: false,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    mockUsers.push(user);

    // Generate auth token
    const authToken = `token_${user.id}_${Date.now()}`;

    res.status(201).json({
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
      token: authToken,
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
    let user = mockUsers.find(u => u.email === email);
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    user.updated_at = new Date().toISOString();

    // Generate auth token
    const authToken = `token_${user.id}_${Date.now()}`;

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
      token: authToken,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Phone OTP - Send OTP (Legacy - will be replaced by Clerk)
router.post('/phone/send-otp', async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).json({ error: 'Phone number is required' });
    }

    // Generate and store OTP
    const otp = generateOTP();
    otpStore.set(phone, {
      otp,
      expiresAt: Date.now() + 10 * 60 * 1000, // 10 minutes
    });

    // In production, send OTP via SMS service
    console.log(`OTP for ${phone}: ${otp}`);

    res.json({ success: true, message: 'OTP sent' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Phone OTP - Verify OTP (Legacy - will be replaced by Clerk)
router.post('/phone/verify-otp', async (req, res) => {
  try {
    const { phone, otp } = req.body;

    if (!phone || !otp) {
      return res.status(400).json({ error: 'Phone and OTP are required' });
    }

    const stored = otpStore.get(phone);
    if (!stored || stored.otp !== otp || Date.now() > stored.expiresAt) {
      return res.status(401).json({ error: 'Invalid or expired OTP' });
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

    // Generate auth token
    const authToken = `token_${user.id}_${Date.now()}`;

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
      token: authToken,
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

    let email, name, googleId, picture;

    // Verify token with Google
    try {
      const https = require('https');
      const url = `https://oauth2.googleapis.com/tokeninfo?id_token=${token}`;
      
      const response = await new Promise((resolve, reject) => {
        https.get(url, (res) => {
          let data = '';
          res.on('data', (chunk) => { data += chunk; });
          res.on('end', () => {
            try {
              resolve(JSON.parse(data));
            } catch (e) {
              reject(e);
            }
          });
        }).on('error', reject);
      });

      if (response.error) {
        throw new Error(response.error_description || 'Token verification failed');
      }

      email = response.email;
      name = response.name || response.given_name || 'Google User';
      googleId = response.sub;
      picture = response.picture;
    } catch (verifyError) {
      // Fallback to mock if verification fails (for development)
      console.warn('Google token verification failed, using mock:', verifyError.message);
      email = 'google_user@example.com';
      name = 'Google User';
      googleId = `google_${Date.now()}`;
    }

    // Find or create user
    let user = mockUsers.find(u => u.google_id === googleId || u.email === email);
    if (!user) {
      user = {
        id: uuidv4(),
        email,
        name,
        google_id: googleId,
        avatar_url: picture,
        role: 'client',
        auth_provider: 'google',
        email_verified: true,
        phone_verified: false,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };
      mockUsers.push(user);
    } else {
      user.google_id = googleId;
      user.name = name;
      user.avatar_url = picture;
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
        avatar_url: user.avatar_url,
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

// Clerk Phone Auth - Send OTP
router.post('/clerk/send-otp', async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).json({ error: 'Phone number is required' });
    }

    if (!CLERK_SECRET_KEY) {
      // Mock mode
      const sessionId = `session_${Date.now()}`;
      otpStore.set(sessionId, {
        phone,
        expiresAt: Date.now() + 10 * 60 * 1000,
      });
      return res.json({ session_id: sessionId, message: 'OTP sent (mock)' });
    }

    // Use Clerk API to send OTP
    try {
      const response = await axios.post(
        `${CLERK_API_URL}/sign_ins`,
        {
          identifier: phone,
          strategy: 'phone_code',
        },
        {
          headers: {
            'Authorization': `Bearer ${CLERK_SECRET_KEY}`,
            'Content-Type': 'application/json',
          },
        }
      );

      res.json({
        session_id: response.data.id,
        message: 'OTP sent successfully',
      });
    } catch (clerkError) {
      console.error('Clerk API error:', clerkError.response?.data || clerkError.message);
      res.status(500).json({ error: 'Failed to send OTP via Clerk' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Clerk Phone Auth - Verify OTP
router.post('/clerk/verify-otp', async (req, res) => {
  try {
    const { phone, code, session_id } = req.body;

    if (!phone || !code) {
      return res.status(400).json({ error: 'Phone and code are required' });
    }

    if (!CLERK_SECRET_KEY) {
      // Mock mode
      const stored = otpStore.get(session_id);
      if (!stored || stored.phone !== phone || code !== '123456') {
        return res.status(401).json({ error: 'Invalid OTP' });
      }

      // Find or create user
      let user = mockUsers.find(u => u.phone === phone);
      if (!user) {
        user = {
          id: uuidv4(),
          phone,
          role: 'client',
          auth_provider: 'clerk',
          clerk_id: `clerk_${Date.now()}`,
          email_verified: false,
          phone_verified: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        };
        mockUsers.push(user);
      }

      const authToken = `token_${user.id}_${Date.now()}`;
      otpStore.delete(session_id);

      return res.json({
        user: {
          id: user.id,
          phone: user.phone,
          role: user.role,
          auth_provider: user.auth_provider,
          clerk_id: user.clerk_id,
          phone_verified: user.phone_verified,
          created_at: user.created_at,
          updated_at: user.updated_at,
        },
        token: authToken,
      });
    }

    // Use Clerk API to verify OTP
    try {
      const response = await axios.post(
        `${CLERK_API_URL}/sign_ins/${session_id}/attempt_first_factor`,
        {
          strategy: 'phone_code',
          code: code,
        },
        {
          headers: {
            'Authorization': `Bearer ${CLERK_SECRET_KEY}`,
            'Content-Type': 'application/json',
          },
        }
      );

      const clerkUserId = response.data.user_id;
      
      // Get user details from Clerk
      const userResponse = await axios.get(
        `${CLERK_API_URL}/users/${clerkUserId}`,
        {
          headers: {
            'Authorization': `Bearer ${CLERK_SECRET_KEY}`,
          },
        }
      );

      const clerkUser = userResponse.data;
      const phoneNumber = clerkUser.phone_numbers?.[0]?.phone_number || phone;
      const email = clerkUser.email_addresses?.[0]?.email_address;
      const name = clerkUser.first_name || clerkUser.username || 'User';

      // Find or create user in our system
      let user = mockUsers.find(u => u.clerk_id === clerkUserId || u.phone === phoneNumber);
      if (!user) {
        user = {
          id: uuidv4(),
          phone: phoneNumber,
          email: email,
          name: name,
          role: 'client',
          auth_provider: 'clerk',
          clerk_id: clerkUserId,
          email_verified: !!email,
          phone_verified: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        };
        mockUsers.push(user);
      } else {
        user.clerk_id = clerkUserId;
        user.phone = phoneNumber;
        user.email = email || user.email;
        user.name = name || user.name;
        user.phone_verified = true;
        user.updated_at = new Date().toISOString();
      }

      const authToken = `token_${user.id}_${Date.now()}`;

      res.json({
        user: {
          id: user.id,
          email: user.email,
          phone: user.phone,
          name: user.name,
          role: user.role,
          auth_provider: user.auth_provider,
          clerk_id: user.clerk_id,
          email_verified: user.email_verified,
          phone_verified: user.phone_verified,
          created_at: user.created_at,
          updated_at: user.updated_at,
        },
        token: authToken,
      });
    } catch (clerkError) {
      console.error('Clerk API error:', clerkError.response?.data || clerkError.message);
      res.status(401).json({ error: 'Invalid OTP or verification failed' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Clerk Verify (for webhook or direct verification)
router.post('/clerk/verify', async (req, res) => {
  try {
    const { clerk_id, phone, email, name } = req.body;

    if (!clerk_id) {
      return res.status(400).json({ error: 'Clerk ID is required' });
    }

    // Find or create user
    let user = mockUsers.find(u => u.clerk_id === clerk_id);
    if (!user) {
      user = {
        id: uuidv4(),
        phone: phone,
        email: email,
        name: name || 'User',
        role: 'client',
        auth_provider: 'clerk',
        clerk_id: clerk_id,
        email_verified: !!email,
        phone_verified: !!phone,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      };
      mockUsers.push(user);
    } else {
      user.updated_at = new Date().toISOString();
    }

    const authToken = `token_${user.id}_${Date.now()}`;

    res.json({
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        name: user.name,
        role: user.role,
        auth_provider: user.auth_provider,
        clerk_id: user.clerk_id,
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

    // Generate reset code
    const code = generateResetCode();
    resetCodes.set(email_or_phone, {
      code,
      expiresAt: Date.now() + 30 * 60 * 1000, // 30 minutes
    });

    // In production, send code via email/SMS
    console.log(`Reset code for ${email_or_phone}: ${code}`);

    res.json({ success: true, message: 'Reset code sent' });
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
    if (!stored || stored.code !== code || Date.now() > stored.expiresAt) {
      return res.status(401).json({ error: 'Invalid or expired code' });
    }

    // Find user and update password (in production, hash password)
    const user = mockUsers.find(u => u.email === email_or_phone || u.phone === email_or_phone);
    if (user) {
      user.updated_at = new Date().toISOString();
    }

    // Clear reset code
    resetCodes.delete(email_or_phone);

    res.json({ success: true, message: 'Password reset successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
