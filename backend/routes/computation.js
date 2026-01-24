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
    console.log(`[Birth Chart] Location: lat=${latitude}, lon=${longitude}, tz=${timezone || 'Asia/Kolkata'}`);
    console.log(`[Birth Chart] Python script path: ${PYTHON_SCRIPT_PATH}`);
    console.log(`[Birth Chart] Python script directory: ${path.dirname(PYTHON_SCRIPT_PATH)}`);

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

    console.log(`[Birth Chart] Python command: python3 ${options.scriptPath}/compute_chart.py ${options.args.join(' ')}`);

    return new Promise((resolve, reject) => {
      const shell = new PythonShell('compute_chart.py', options);
      let output = '';
      let errorOutput = '';

      shell.on('message', (message) => {
        console.log(`[Python Output] ${message}`);
        output += message + '\n';
      });

      shell.on('stderr', (stderr) => {
        console.error('[Python Stderr]', stderr);
        errorOutput += stderr + '\n';
      });

      shell.end((err) => {
        if (err) {
          console.error('[Computation Error] Full error object:', JSON.stringify(err, null, 2));
          console.error('[Computation Error] Error message:', err.message);
          console.error('[Computation Error] Error traceback:', err.traceback);
          console.error('[Computation Error] Python stderr output:', errorOutput);
          console.error('[Computation Error] Python stdout output:', output);
          console.error('[Computation Error] Exit code:', err.exitCode);
          
          if (!res.headersSent) {
            res.status(500).json({ 
              success: false, 
              error: 'Failed to compute chart: ' + err.message,
              details: {
                traceback: err.traceback,
                stderr: errorOutput,
                stdout: output,
                exitCode: err.exitCode,
              }
            });
          }
          reject(err);
          return;
        }

        console.log(`[Birth Chart] Python script completed. Output length: ${output.length} chars`);
        console.log(`[Birth Chart] Output preview: ${output.substring(0, 200)}...`);

        try {
          const result = JSON.parse(output.trim());
          console.log(`[Birth Chart] ✅ Successfully parsed JSON result`);
          console.log(`[Birth Chart] Result keys: ${Object.keys(result).join(', ')}`);
          
          if (result.error) {
            console.error(`[Birth Chart] ❌ Python script returned error: ${result.error}`);
            if (result.traceback) {
              console.error(`[Birth Chart] Python traceback: ${result.traceback}`);
            }
          }
          
          if (!res.headersSent) {
            res.json({ success: true, ...result });
          }
          resolve(result);
        } catch (parseError) {
          console.error('[Parse Error] Failed to parse JSON output');
          console.error('[Parse Error] Parse error:', parseError);
          console.error('[Parse Error] Output length:', output.length);
          console.error('[Parse Error] Output (first 500 chars):', output.substring(0, 500));
          console.error('[Parse Error] Output (last 500 chars):', output.substring(Math.max(0, output.length - 500)));
          console.error('[Parse Error] Python stderr:', errorOutput);
          
          if (!res.headersSent) {
            res.status(500).json({ 
              success: false, 
              error: 'Failed to parse computation result',
              details: {
                parseError: parseError.message,
                outputLength: output.length,
                outputPreview: output.substring(0, 500),
                stderr: errorOutput,
              },
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

