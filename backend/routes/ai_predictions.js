const express = require('express');
const { PythonShell } = require('python-shell');
const path = require('path');
const router = express.Router();

const PYTHON_SCRIPT_PATH = path.join(__dirname, '../python/ai_astrology.py');
const TIMEOUT = 60000; // 60 seconds for AI responses

// In-memory credit storage (replace with database in production)
const userCredits = new Map();
const conversationHistory = new Map();
const generatedReports = new Map();

// Credit costs
const CREDIT_COSTS = {
  question: 1,
  report_basic: 5,
  report_comprehensive: 10,
  report_yearly: 15
};

// Initialize user credits (for demo, give new users 10 free credits)
const getOrCreateCredits = (userId) => {
  if (!userCredits.has(userId)) {
    userCredits.set(userId, 10); // Free credits for new users
  }
  return userCredits.get(userId);
};

// Deduct credits
const deductCredits = (userId, amount) => {
  const current = getOrCreateCredits(userId);
  userCredits.set(userId, Math.max(0, current - amount));
  return userCredits.get(userId);
};

// Add credits (for purchases)
const addCredits = (userId, amount) => {
  const current = getOrCreateCredits(userId);
  userCredits.set(userId, current + amount);
  return userCredits.get(userId);
};

// Get user ID from request (simplified - use proper auth in production)
const getUserId = (req) => {
  return req.headers['x-user-id'] || req.body.userId || 'anonymous';
};

// Ask AI a question
router.post('/ask', async (req, res) => {
  try {
    const { chartData, question, conversationId } = req.body;
    const userId = getUserId(req);

    if (!chartData) {
      return res.status(400).json({ 
        success: false, 
        error: 'Chart data is required' 
      });
    }

    if (!question) {
      return res.status(400).json({ 
        success: false, 
        error: 'Question is required' 
      });
    }

    // Check credits
    const credits = getOrCreateCredits(userId);
    if (credits < CREDIT_COSTS.question) {
      return res.status(402).json({
        success: false,
        error: 'Insufficient credits',
        credits_required: CREDIT_COSTS.question,
        credits_available: credits
      });
    }

    console.log(`[AI] Question from ${userId}: "${question.substring(0, 50)}..."`);

    // Get conversation history if exists
    const convKey = conversationId || `${userId}_default`;
    const history = conversationHistory.get(convKey) || [];

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--action', 'ask',
        '--chart-data', JSON.stringify(chartData),
        '--question', question,
        '--history', JSON.stringify(history)
      ],
      timeout: TIMEOUT,
    };

    return new Promise((resolve, reject) => {
      const shell = new PythonShell('ai_astrology.py', options);
      let output = '';

      shell.on('message', (message) => {
        output += message + '\n';
      });

      shell.on('stderr', (stderr) => {
        console.error('[AI Python Error]', stderr);
      });

      shell.end((err) => {
        if (err) {
          console.error('[AI Error]', err);
          if (!res.headersSent) {
            res.status(500).json({ 
              success: false, 
              error: 'AI service error: ' + err.message 
            });
          }
          reject(err);
          return;
        }

        try {
          const result = JSON.parse(output.trim());
          
          if (result.success) {
            // Deduct credits
            const remainingCredits = deductCredits(userId, CREDIT_COSTS.question);
            
            // Save to conversation history
            const newHistory = [
              ...history,
              { role: 'user', content: question },
              { role: 'assistant', content: result.answer }
            ];
            conversationHistory.set(convKey, newHistory.slice(-10)); // Keep last 10 exchanges
            
            if (!res.headersSent) {
              res.json({
                success: true,
                answer: result.answer,
                usage: result.usage,
                model: result.model,
                is_mock: result.is_mock || false,
                credits_used: CREDIT_COSTS.question,
                credits_remaining: remainingCredits,
                conversation_id: convKey,
                timestamp: result.timestamp
              });
            }
          } else {
            if (!res.headersSent) {
              res.status(500).json({
                success: false,
                error: result.error || 'Unknown error'
              });
            }
          }
          resolve(result);
        } catch (parseError) {
          console.error('[AI Parse Error]', parseError);
          if (!res.headersSent) {
            res.status(500).json({ 
              success: false, 
              error: 'Failed to parse AI response' 
            });
          }
          reject(parseError);
        }
      });
    });
  } catch (error) {
    console.error('[AI Route Error]', error);
    if (!res.headersSent) {
      res.status(500).json({ 
        success: false, 
        error: error.message 
      });
    }
  }
});

// Generate AI report
router.post('/generate-report', async (req, res) => {
  try {
    const { chartData, reportType = 'comprehensive' } = req.body;
    const userId = getUserId(req);

    if (!chartData) {
      return res.status(400).json({ 
        success: false, 
        error: 'Chart data is required' 
      });
    }

    // Determine credit cost
    let creditCost = CREDIT_COSTS.report_comprehensive;
    if (reportType === 'career' || reportType === 'marriage') {
      creditCost = CREDIT_COSTS.report_basic;
    } else if (reportType === 'yearly') {
      creditCost = CREDIT_COSTS.report_yearly;
    }

    // Check credits
    const credits = getOrCreateCredits(userId);
    if (credits < creditCost) {
      return res.status(402).json({
        success: false,
        error: 'Insufficient credits',
        credits_required: creditCost,
        credits_available: credits
      });
    }

    console.log(`[AI] Generating ${reportType} report for ${userId}`);

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--action', 'report',
        '--chart-data', JSON.stringify(chartData),
        '--report-type', reportType
      ],
      timeout: TIMEOUT * 2, // Reports may take longer
    };

    return new Promise((resolve, reject) => {
      const shell = new PythonShell('ai_astrology.py', options);
      let output = '';

      shell.on('message', (message) => {
        output += message + '\n';
      });

      shell.on('stderr', (stderr) => {
        console.error('[AI Python Error]', stderr);
      });

      shell.end((err) => {
        if (err) {
          console.error('[AI Report Error]', err);
          if (!res.headersSent) {
            res.status(500).json({ 
              success: false, 
              error: 'AI service error: ' + err.message 
            });
          }
          reject(err);
          return;
        }

        try {
          const result = JSON.parse(output.trim());
          
          if (result.success) {
            // Deduct credits
            const remainingCredits = deductCredits(userId, creditCost);
            
            // Save report
            const reportId = `report_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
            generatedReports.set(reportId, {
              userId,
              reportType,
              content: result.answer,
              chartData,
              createdAt: new Date().toISOString(),
              usage: result.usage
            });
            
            if (!res.headersSent) {
              res.json({
                success: true,
                report_id: reportId,
                report_type: reportType,
                content: result.answer,
                usage: result.usage,
                model: result.model,
                is_mock: result.is_mock || false,
                credits_used: creditCost,
                credits_remaining: remainingCredits,
                timestamp: result.timestamp
              });
            }
          } else {
            if (!res.headersSent) {
              res.status(500).json({
                success: false,
                error: result.error || 'Unknown error'
              });
            }
          }
          resolve(result);
        } catch (parseError) {
          console.error('[AI Parse Error]', parseError);
          if (!res.headersSent) {
            res.status(500).json({ 
              success: false, 
              error: 'Failed to parse AI response' 
            });
          }
          reject(parseError);
        }
      });
    });
  } catch (error) {
    console.error('[AI Route Error]', error);
    if (!res.headersSent) {
      res.status(500).json({ 
        success: false, 
        error: error.message 
      });
    }
  }
});

// Get user credits
router.get('/credits', (req, res) => {
  const userId = getUserId(req);
  const credits = getOrCreateCredits(userId);
  
  res.json({
    success: true,
    credits: credits,
    pricing: {
      question: CREDIT_COSTS.question,
      report_basic: CREDIT_COSTS.report_basic,
      report_comprehensive: CREDIT_COSTS.report_comprehensive,
      report_yearly: CREDIT_COSTS.report_yearly
    }
  });
});

// Add credits (simulated purchase - integrate with payment gateway in production)
router.post('/credits/purchase', (req, res) => {
  const { amount, paymentId } = req.body;
  const userId = getUserId(req);
  
  // In production, verify payment with payment gateway
  // For now, just add credits
  
  if (!amount || amount < 1) {
    return res.status(400).json({
      success: false,
      error: 'Invalid amount'
    });
  }
  
  const newBalance = addCredits(userId, amount);
  
  res.json({
    success: true,
    credits_added: amount,
    new_balance: newBalance,
    payment_id: paymentId || 'demo_' + Date.now()
  });
});

// Get conversation history
router.get('/conversations', (req, res) => {
  const userId = getUserId(req);
  const { conversationId } = req.query;
  
  const convKey = conversationId || `${userId}_default`;
  const history = conversationHistory.get(convKey) || [];
  
  res.json({
    success: true,
    conversation_id: convKey,
    messages: history
  });
});

// Clear conversation history
router.delete('/conversations/:id', (req, res) => {
  const { id } = req.params;
  conversationHistory.delete(id);
  
  res.json({
    success: true,
    message: 'Conversation cleared'
  });
});

// Get saved reports
router.get('/reports', (req, res) => {
  const userId = getUserId(req);
  
  const userReports = [];
  generatedReports.forEach((report, id) => {
    if (report.userId === userId) {
      userReports.push({
        id,
        report_type: report.reportType,
        created_at: report.createdAt,
        preview: report.content.substring(0, 200) + '...'
      });
    }
  });
  
  res.json({
    success: true,
    reports: userReports.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
  });
});

// Get specific report
router.get('/reports/:id', (req, res) => {
  const { id } = req.params;
  const report = generatedReports.get(id);
  
  if (!report) {
    return res.status(404).json({
      success: false,
      error: 'Report not found'
    });
  }
  
  res.json({
    success: true,
    report: {
      id,
      report_type: report.reportType,
      content: report.content,
      created_at: report.createdAt,
      usage: report.usage
    }
  });
});

// Credit packages (pricing)
router.get('/credit-packages', (req, res) => {
  res.json({
    success: true,
    packages: [
      {
        id: 'pack_10',
        credits: 10,
        price_inr: 99,
        price_usd: 1.50,
        savings: null,
        popular: false
      },
      {
        id: 'pack_50',
        credits: 50,
        price_inr: 399,
        price_usd: 6.00,
        savings: '20%',
        popular: true
      },
      {
        id: 'pack_100',
        credits: 100,
        price_inr: 699,
        price_usd: 10.00,
        savings: '30%',
        popular: false
      }
    ],
    usage_costs: {
      question: {
        credits: 1,
        description: 'Ask any question about your chart'
      },
      report_basic: {
        credits: 5,
        description: 'Career or Marriage focused report'
      },
      report_comprehensive: {
        credits: 10,
        description: 'Complete life reading'
      },
      report_yearly: {
        credits: 15,
        description: '12-month detailed forecast'
      }
    }
  });
});

module.exports = router;

