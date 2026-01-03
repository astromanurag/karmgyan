# Backend Troubleshooting Guide

## Issue: Chart Generation Button Stuck Loading

If the "Generate Chart" button is stuck in loading state, check the following:

### 1. Check if Backend Server is Running

```bash
# Navigate to backend directory
cd backend

# Install dependencies (if not done)
npm install

# Start the server
npm start
```

The server should start on `http://localhost:3000` and you should see:
```
karmgyan backend server running on port 3000
```

### 2. Check if Python Dependencies are Installed

```bash
# Install pyswisseph
pip3 install pyswisseph

# Or if using virtual environment
python3 -m pip install pyswisseph
```

### 3. Test Backend Health

Open in browser or use curl:
```bash
curl http://localhost:3000/health
```

Should return: `{"status":"ok","message":"karmgyan API is running"}`

### 4. Test Chart Generation Endpoint

```bash
curl -X POST http://localhost:3000/api/computation/birth-chart \
  -H "Content-Type: application/json" \
  -d '{
    "date": "1990-01-01",
    "time": "12:00:00",
    "latitude": 28.6139,
    "longitude": 77.2090,
    "timezone": "Asia/Kolkata"
  }'
```

### 5. Check Backend Logs

When you click "Generate Chart", check the backend terminal for:
- Any Python errors
- Any computation errors
- Connection issues

### 6. Common Issues

#### Issue: "Cannot connect to backend server"
**Solution**: Make sure backend is running on port 3000

#### Issue: "Request timed out"
**Solution**: 
- Check if Python script is taking too long
- Verify pyswisseph is installed correctly
- Check Python path in `backend/routes/computation.js` (should be `python3`)

#### Issue: "Computation failed"
**Solution**:
- Check Python script syntax: `python3 backend/python/compute_chart.py`
- Verify pyswisseph installation: `python3 -c "import swisseph as swe; print('OK')"`
- Check backend logs for detailed error messages

### 7. Verify Python Script Works

Test the Python script directly:
```bash
cd backend/python
python3 compute_chart.py '{"date":"1990-01-01","time":"12:00:00","latitude":28.6139,"longitude":77.2090,"timezone":"Asia/Kolkata","chartType":"birth"}'
```

Should return JSON with chart data.

### 8. Network Issues

If running Flutter on a device/emulator:
- **iOS Simulator**: `localhost` should work
- **Android Emulator**: Use `10.0.2.2` instead of `localhost`
- **Physical Device**: Use your computer's IP address (e.g., `192.168.1.100:3000`)

Update `lib/config/app_config.dart`:
```dart
static const String backendUrl = 'http://10.0.2.2:3000/api'; // For Android
// or
static const String backendUrl = 'http://YOUR_IP:3000/api'; // For physical device
```

### 9. Quick Fixes

1. **Restart Backend**: Stop (Ctrl+C) and restart the backend server
2. **Clear Flutter Cache**: `flutter clean && flutter pub get`
3. **Check Port**: Make sure port 3000 is not used by another application
4. **Check Firewall**: Ensure firewall allows connections on port 3000

### 10. Debug Mode

Enable verbose logging in Flutter by checking the console output when clicking "Generate Chart". The error message should now be more descriptive.

