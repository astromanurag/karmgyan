const express = require('express');
const { PythonShell } = require('python-shell');
const path = require('path');
const router = express.Router();

const PYTHON_SCRIPT_PATH = path.join(__dirname, '../python/compute_chart.py');
const TIMEOUT = 30000; // 30 seconds

router.post('/birth-chart', async (req, res) => {
  try {
    const { name, date, time, latitude, longitude, timezone } = req.body;

    if (!date || !time || latitude === undefined || longitude === undefined) {
      return res.status(400).json({ 
        success: false, 
        error: 'Missing required fields: date, time, latitude, longitude' 
      });
    }

    console.log(`[Birth Chart] Computing chart for ${name || 'Unknown'} at ${date} ${time}`);

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--type', 'birth-chart',
        '--date', date,
        '--time', time,
        '--latitude', latitude.toString(),
        '--longitude', longitude.toString(),
        '--timezone', timezone || 'Asia/Kolkata',
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
              error: 'Failed to compute chart: ' + err.message 
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
          console.error('[Parse Error]', parseError, 'Output:', output);
          if (!res.headersSent) {
            res.status(500).json({ 
              success: false, 
              error: 'Failed to parse computation result',
              raw: output 
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

router.post('/dasha', async (req, res) => {
  try {
    const { date, time, latitude, longitude, timezone } = req.body;

    if (!date || !time || latitude === undefined || longitude === undefined) {
      return res.status(400).json({ 
        success: false, 
        error: 'Missing required fields: date, time, latitude, longitude' 
      });
    }

    console.log(`[Dasha] Computing dasha for ${date} ${time}`);

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--type', 'dasha',
        '--date', date,
        '--time', time,
        '--latitude', latitude.toString(),
        '--longitude', longitude.toString(),
        '--timezone', timezone || 'Asia/Kolkata',
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
              error: 'Failed to compute dasha: ' + err.message 
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
          console.error('[Parse Error]', parseError, 'Output:', output);
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

router.post('/divisional', async (req, res) => {
  try {
    const { date, time, latitude, longitude, timezone, chartType } = req.body;

    if (!date || !time || latitude === undefined || longitude === undefined) {
      return res.status(400).json({ 
        success: false, 
        error: 'Missing required fields: date, time, latitude, longitude' 
      });
    }

    console.log(`[Divisional] Computing ${chartType || 'D9'} chart for ${date} ${time}`);

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--type', 'divisional',
        '--date', date,
        '--time', time,
        '--latitude', latitude.toString(),
        '--longitude', longitude.toString(),
        '--timezone', timezone || 'Asia/Kolkata',
        '--chart-type', chartType || 'D9',
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
              error: 'Failed to compute divisional chart: ' + err.message 
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
          console.error('[Parse Error]', parseError, 'Output:', output);
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

