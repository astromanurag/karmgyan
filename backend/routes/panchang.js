const express = require('express');
const { PythonShell } = require('python-shell');
const path = require('path');
const router = express.Router();

const PYTHON_SCRIPT_PATH = path.join(__dirname, '../python/compute_chart.py');
const TIMEOUT = 30000;

router.get('/daily', async (req, res) => {
  try {
    const { date, latitude, longitude, timezone } = req.query;

    if (!date) {
      return res.status(400).json({ 
        success: false, 
        error: 'Date is required' 
      });
    }

    console.log(`[Panchang] Computing daily panchang for ${date}`);

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--type', 'panchang',
        '--date', date,
        '--latitude', (latitude || '28.6139').toString(),
        '--longitude', (longitude || '77.2090').toString(),
        '--timezone', timezone || 'Asia/Kolkata',
      ].filter(arg => arg !== null && arg !== undefined),
      timeout: TIMEOUT,
    };

    return new Promise((resolve, reject) => {
      const shell = new PythonShell('compute_chart.py', options);
      let output = '';

      shell.on('message', (message) => {
        output += message + '\n';
      });

      shell.on('stderr', (stderr) => {
        console.error('[Python Error]', stderr);
      });

      shell.end((err) => {
        if (err) {
          console.error('[Computation Error]', err);
          if (!res.headersSent) {
            res.status(500).json({ 
              success: false, 
              error: 'Failed to compute panchang: ' + err.message 
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
              error: 'Failed to parse computation result' 
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

router.get('/muhurat', async (req, res) => {
  try {
    const { date, latitude, longitude, timezone, eventType } = req.query;

    if (!date) {
      return res.status(400).json({ 
        success: false, 
        error: 'Date is required' 
      });
    }

    console.log(`[Muhurat] Computing muhurat for ${eventType || 'general'} on ${date}`);

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--type', 'muhurat',
        '--date', date,
        '--latitude', (latitude || '28.6139').toString(),
        '--longitude', (longitude || '77.2090').toString(),
        '--timezone', timezone || 'Asia/Kolkata',
        '--event-type', eventType || 'general',
      ],
      timeout: TIMEOUT,
    };

    return new Promise((resolve, reject) => {
      const shell = new PythonShell('compute_chart.py', options);
      let output = '';

      shell.on('message', (message) => {
        output += message + '\n';
      });

      shell.on('stderr', (stderr) => {
        console.error('[Python Error]', stderr);
      });

      shell.end((err) => {
        if (err) {
          console.error('[Computation Error]', err);
          if (!res.headersSent) {
            res.status(500).json({ 
              success: false, 
              error: 'Failed to compute muhurat: ' + err.message 
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
              error: 'Failed to parse computation result' 
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

