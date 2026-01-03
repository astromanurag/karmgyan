const express = require('express');
const { PythonShell } = require('python-shell');
const path = require('path');
const router = express.Router();

const PYTHON_SCRIPT_PATH = path.join(__dirname, '../python/compute_chart.py');
const TIMEOUT = 30000;

router.post('/compatibility', async (req, res) => {
  try {
    const { person1, person2 } = req.body;

    if (!person1 || !person2) {
      return res.status(400).json({ 
        success: false, 
        error: 'Both person1 and person2 are required' 
      });
    }

    console.log('[Matching] Computing compatibility');

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--type', 'compatibility',
        '--person1', JSON.stringify(person1),
        '--person2', JSON.stringify(person2),
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
              error: 'Failed to compute compatibility: ' + err.message 
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

