const express = require('express');
const { PythonShell } = require('python-shell');
const path = require('path');
const router = express.Router();

const PYTHON_SCRIPT_PATH = path.join(__dirname, '../python/compute_chart.py');
const TIMEOUT = 30000;

// Analyze name (Life Path, Destiny, Soul Urge, Personality numbers)
router.post('/analyze', async (req, res) => {
  try {
    const { name, birthDate, system } = req.body;

    if (!name) {
      return res.status(400).json({ 
        success: false, 
        error: 'Name is required' 
      });
    }

    console.log(`[Numerology] Analyzing name: ${name}`);

    const args = [
      '--type', 'numerology',
      '--numerology-action', 'analyze',
      '--name', name,
      '--system', system || 'pythagorean',
    ];

    if (birthDate) {
      args.push('--date', birthDate);
    }

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: args,
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
              error: 'Failed to compute numerology: ' + err.message 
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

// Check compatibility between two numbers
router.get('/compatibility', async (req, res) => {
  try {
    const { number1, number2, system } = req.query;

    if (!number1 || !number2) {
      return res.status(400).json({ 
        success: false, 
        error: 'Both number1 and number2 are required' 
      });
    }

    console.log(`[Numerology] Checking compatibility: ${number1} & ${number2}`);

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--type', 'numerology',
        '--numerology-action', 'compatibility',
        '--number1', number1,
        '--number2', number2,
        '--system', system || 'pythagorean',
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

// Suggest name spellings for a target number
router.post('/suggest-names', async (req, res) => {
  try {
    const { name, targetNumber, system } = req.body;

    if (!name || !targetNumber) {
      return res.status(400).json({ 
        success: false, 
        error: 'Name and targetNumber are required' 
      });
    }

    console.log(`[Numerology] Suggesting names for: ${name}, target: ${targetNumber}`);

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--type', 'numerology',
        '--numerology-action', 'suggest',
        '--name', name,
        '--target-number', targetNumber.toString(),
        '--system', system || 'pythagorean',
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
              error: 'Failed to suggest names: ' + err.message 
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

// Calculate number for a name
router.post('/calculate-name-number', async (req, res) => {
  try {
    const { name, system } = req.body;

    if (!name) {
      return res.status(400).json({ 
        success: false, 
        error: 'Name is required' 
      });
    }

    console.log(`[Numerology] Calculating number for name: ${name}`);

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--type', 'numerology',
        '--numerology-action', 'calculate-name-number',
        '--name', name,
        '--system', system || 'pythagorean',
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
              error: 'Failed to calculate name number: ' + err.message 
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

// Get Loshu grid
router.post('/loshu-grid', async (req, res) => {
  try {
    const { birthDate } = req.body;

    if (!birthDate) {
      return res.status(400).json({ 
        success: false, 
        error: 'Birth date is required' 
      });
    }

    console.log(`[Numerology] Calculating Loshu grid for date: ${birthDate}`);

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--type', 'numerology',
        '--numerology-action', 'loshu-grid',
        '--date', birthDate,
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
              error: 'Failed to calculate Loshu grid: ' + err.message 
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

// Suggest names by number (without base name)
router.post('/suggest-names-by-number', async (req, res) => {
  try {
    const { targetNumber, system, nameLength, language, religion, gender, excludeNames } = req.body;

    if (!targetNumber) {
      return res.status(400).json({ 
        success: false, 
        error: 'Target number is required' 
      });
    }

    console.log(`[Numerology] Suggesting names for number: ${targetNumber}`);

    const options = {
      mode: 'text',
      pythonPath: 'python3',
      scriptPath: path.dirname(PYTHON_SCRIPT_PATH),
      args: [
        '--type', 'numerology',
        '--numerology-action', 'suggest-by-number',
        '--target-number', targetNumber.toString(),
        '--system', system || 'pythagorean',
      ],
      timeout: TIMEOUT,
    };

    if (nameLength) {
      options.args.push('--name-length', nameLength.toString());
    }
    if (language) {
      options.args.push('--language', language);
    }
    if (religion) {
      options.args.push('--religion', religion);
    }
    if (gender) {
      options.args.push('--gender', gender);
    }
    if (excludeNames && Array.isArray(excludeNames) && excludeNames.length > 0) {
      options.args.push('--exclude-names', JSON.stringify(excludeNames));
    }

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
              error: 'Failed to suggest names: ' + err.message 
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

