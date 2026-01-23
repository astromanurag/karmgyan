const express = require('express');
const router = express.Router();
const { spawn } = require('child_process');
const path = require('path');

const PYTHON_SCRIPT_PATH = path.join(__dirname, '../python/generate_horoscope.py');
const PERPLEXITY_API_KEY = process.env.PERPLEXITY_API_KEY;
const TIMEOUT = 120000; // 2 minutes

// Get daily horoscope for a zodiac sign
router.get('/daily/:sign', async (req, res) => {
  try {
    const { sign } = req.params;
    const { date } = req.query; // Optional date parameter

    if (!PERPLEXITY_API_KEY) {
      return res.status(500).json({ 
        success: false, 
        error: 'Perplexity API key not configured' 
      });
    }

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--api-key', PERPLEXITY_API_KEY,
        '--sign', sign,
      ],
      timeout: TIMEOUT,
    };

    if (date) {
      options.args.push('--date', date);
    }

    return new Promise((resolve, reject) => {
      const { PythonShell } = require('python-shell');
      const shell = new PythonShell('generate_horoscope.py', options);
      let output = '';

      shell.on('message', (message) => {
        output += message + '\n';
      });

      shell.on('stderr', (stderr) => {
        console.error('[Python Error]', stderr);
      });

      shell.end((err) => {
        if (err) {
          console.error('[Horoscope Error]', err);
          if (!res.headersSent) {
            res.status(500).json({ 
              success: false, 
              error: 'Failed to generate horoscope: ' + err.message 
            });
          }
          reject(err);
          return;
        }

        try {
          const result = JSON.parse(output.trim());
          if (!res.headersSent) {
            res.json({ success: true, ...result });
          }
          resolve(result);
        } catch (parseError) {
          console.error('[Parse Error]', parseError);
          if (!res.headersSent) {
            res.status(500).json({ 
              success: false, 
              error: 'Failed to parse horoscope result' 
            });
          }
          reject(parseError);
        }
      });
    });
  } catch (error) {
    console.error('[Route Error]', error);
    if (!res.headersSent) {
      res.status(500).json({ 
        success: false, 
        error: error.message 
      });
    }
  }
});

// Generate daily horoscopes for all signs (for cron job)
router.post('/generate-daily', async (req, res) => {
  try {
    const { date } = req.body; // Optional date, defaults to today

    if (!PERPLEXITY_API_KEY) {
      return res.status(500).json({ 
        success: false, 
        error: 'Perplexity API key not configured' 
      });
    }

    console.log(`[Horoscope] Generating daily horoscopes for ${date || 'today'}`);

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--api-key', PERPLEXITY_API_KEY,
      ],
      timeout: TIMEOUT * 12, // Longer timeout for all signs
    };

    if (date) {
      options.args.push('--date', date);
    }

    return new Promise((resolve, reject) => {
      const { PythonShell } = require('python-shell');
      const shell = new PythonShell('generate_horoscope.py', options);
      let output = '';

      shell.on('message', (message) => {
        output += message + '\n';
      });

      shell.on('stderr', (stderr) => {
        console.error('[Python Error]', stderr);
      });

      shell.end((err) => {
        if (err) {
          console.error('[Horoscope Generation Error]', err);
          if (!res.headersSent) {
            res.status(500).json({ 
              success: false, 
              error: 'Failed to generate horoscopes: ' + err.message 
            });
          }
          reject(err);
          return;
        }

        try {
          const result = JSON.parse(output.trim());
          
          // Store in Supabase (if configured)
          if (result.horoscopes && process.env.SUPABASE_URL) {
            // TODO: Store each horoscope in Supabase daily_horoscopes table
            console.log('[Horoscope] Generated horoscopes for all signs');
          }
          
          if (!res.headersSent) {
            res.json({ 
              success: true, 
              message: 'Horoscopes generated successfully',
              count: Object.keys(result.horoscopes || {}).length,
            });
          }
          resolve(result);
        } catch (parseError) {
          console.error('[Parse Error]', parseError);
          if (!res.headersSent) {
            res.status(500).json({ 
              success: false, 
              error: 'Failed to parse horoscope results' 
            });
          }
          reject(parseError);
        }
      });
    });
  } catch (error) {
    console.error('[Route Error]', error);
    if (!res.headersSent) {
      res.status(500).json({ 
        success: false, 
        error: error.message 
      });
    }
  }
});

module.exports = router;

