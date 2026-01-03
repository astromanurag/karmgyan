const express = require('express');
const router = express.Router();
const { requireAuth, requireRole } = require('../middleware/role_check');

// Get dashboard data
router.get('/dashboard', requireAuth, requireRole('consultant'), (req, res) => {
  try {
    res.json({
      upcoming_consultations: 3,
      today_schedule: [
        {
          id: 'consultation_001',
          client_name: 'John Doe',
          time: '10:00 AM',
          type: 'video',
        },
      ],
      earnings_summary: {
        this_month: 25000.0,
        total: 125000.0,
      },
      pending_requests: 2,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get earnings
router.get('/earnings', requireAuth, requireRole('consultant'), (req, res) => {
  try {
    res.json({
      earnings: [
        {
          id: 'earning_001',
          date: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
          amount: 1998.0,
          consultation_id: 'consultation_001',
          client_name: 'John Doe',
        },
      ],
      total: 125000.0,
      pending_payout: 15000.0,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update availability
router.post('/availability', requireAuth, requireRole('consultant'), (req, res) => {
  try {
    const { availability } = req.body;
    // In production, save to database
    res.json({ message: 'Availability updated successfully', availability });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get consultations
router.get('/consultations', requireAuth, requireRole('consultant'), (req, res) => {
  try {
    const { status } = req.query;
    const consultations = [
      {
        id: 'consultation_001',
        client_name: 'John Doe',
        date: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        time: '10:00 AM',
        type: 'video',
        status: 'scheduled',
      },
    ];
    
    const filtered = status
      ? consultations.filter(c => c.status === status)
      : consultations;
    
    res.json({ consultations: filtered });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Respond to consultation request
router.post('/consultations/:id/respond', requireAuth, requireRole('consultant'), (req, res) => {
  try {
    const { accept } = req.body;
    // In production, update consultation status
    res.json({
      message: accept ? 'Consultation accepted' : 'Consultation rejected',
      consultation_id: req.params.id,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

