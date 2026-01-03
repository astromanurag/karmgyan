const express = require('express');
const router = express.Router();
const { requireAuth, requireRole } = require('../middleware/role_check');
const fs = require('fs');
const path = require('path');

// Mock data - load from assets
let mockConsultants = [];
try {
  const consultantsPath = path.join(__dirname, '../../assets/mock_data/consultants.json');
  if (fs.existsSync(consultantsPath)) {
    mockConsultants = JSON.parse(fs.readFileSync(consultantsPath, 'utf8'));
  }
} catch (e) {
  // Fallback mock data
  mockConsultants = [
    {
      id: 'consultant_001',
      user_id: 'user_002',
      name: 'Dr. Priya Sharma',
      specialization: 'Vedic Astrology',
      status: 'approved',
    },
  ];
}

// Get all consultants
router.get('/consultants', requireAuth, requireRole('admin'), (req, res) => {
  try {
    const { status } = req.query;
    let consultants = mockConsultants;
    
    if (status) {
      consultants = consultants.filter(c => c.status === status);
    }
    
    res.json({ consultants });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get consultant by ID
router.get('/consultants/:id', requireAuth, requireRole('admin'), (req, res) => {
  try {
    const consultant = mockConsultants.find(c => c.id === req.params.id);
    if (!consultant) {
      return res.status(404).json({ error: 'Consultant not found' });
    }
    res.json({ consultant });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Approve consultant
router.post('/consultants/:id/approve', requireAuth, requireRole('admin'), (req, res) => {
  try {
    const consultant = mockConsultants.find(c => c.id === req.params.id);
    if (!consultant) {
      return res.status(404).json({ error: 'Consultant not found' });
    }
    
    consultant.status = 'approved';
    consultant.approved_at = new Date().toISOString();
    consultant.approved_by = req.user.id;
    
    res.json({ consultant });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Reject consultant
router.post('/consultants/:id/reject', requireAuth, requireRole('admin'), (req, res) => {
  try {
    const consultant = mockConsultants.find(c => c.id === req.params.id);
    if (!consultant) {
      return res.status(404).json({ error: 'Consultant not found' });
    }
    
    consultant.status = 'rejected';
    
    res.json({ consultant });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get analytics
router.get('/analytics', requireAuth, requireRole('admin'), (req, res) => {
  try {
    res.json({
      total_users: 1250,
      total_consultants: mockConsultants.length,
      total_orders: 320,
      total_revenue: 125000.0,
      pending_consultants: mockConsultants.filter(c => c.status === 'pending').length,
      active_consultations: 12,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Data management routes
router.post('/data/services', requireAuth, requireRole('admin'), (req, res) => {
  try {
    const { services } = req.body;
    // In production, save to database
    res.json({ message: 'Services uploaded successfully', count: services?.length || 0 });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/data/reports', requireAuth, requireRole('admin'), (req, res) => {
  try {
    const { reports } = req.body;
    // In production, save to database
    res.json({ message: 'Reports uploaded successfully', count: reports?.length || 0 });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

