# Chart Demo Guide

## Overview

Since you're having issues with the backend/npm setup, I've created a **Chart Demo Screen** that displays astrological charts using sample data. This allows you to see how charts are rendered in the UI without needing the backend server.

## How to Access

### Option 1: From Home Screen
1. Launch the app
2. Navigate to the Home screen
3. Tap on the **"Chart Demo"** card in the Quick Actions grid
4. The chart will load immediately with sample data

### Option 2: Direct Navigation
You can navigate directly to `/chart-demo` route in your app.

## What You'll See

The Chart Demo Screen displays:

1. **Sample Birth Chart Information**
   - Name, Date, Time, and Location of the sample chart

2. **Visual Birth Chart (D1 - Rashi)**
   - A diamond-shaped astrological chart
   - Shows all 9 planets (Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Rahu, Ketu)
   - Displays all 12 houses
   - Shows the ascendant position

3. **Planet Positions Table**
   - Lists all planets with their:
     - Sign (Zodiac sign)
     - House number
     - Longitude (degrees)

4. **House Positions Table**
   - Shows all 12 houses with their longitude positions

## Sample Data

The demo uses sample data from:
- `assets/mock_data/charts.json` (if available)
- Or hardcoded fallback data with realistic astrological positions

## Features

- ✅ **No Backend Required** - Works completely offline
- ✅ **Instant Loading** - Charts appear immediately
- ✅ **Visual Chart Rendering** - See the diamond chart visualization
- ✅ **Detailed Tables** - View planet and house positions
- ✅ **Refresh Button** - Reload the chart data

## Regular Birth Chart Screen

The regular `/birth-chart` screen has also been updated to:
- Use mock data when backend is unavailable
- Automatically fallback to sample data on network errors
- Still allow you to input your own birth details

## Technical Details

### Files Created/Modified

1. **`lib/presentation/screens/charts/chart_demo_screen.dart`**
   - New demo screen with sample data
   - Displays chart visualization and tables

2. **`lib/services/computation_service.dart`**
   - Updated to use mock data when backend unavailable
   - Automatic fallback to sample data

3. **`lib/core/router/app_router.dart`**
   - Added route for `/chart-demo`

4. **`lib/presentation/screens/home/home_screen.dart`**
   - Added "Chart Demo" quick action card

## Next Steps

Once your backend is set up:
1. The regular birth chart screen will automatically use the real backend
2. The chart demo will continue to work with sample data
3. You can compare real vs sample charts

## Chart Widget

The chart is rendered using `DiamondChartWidget` which:
- Creates a diamond-shaped (rectangular) chart layout
- Positions planets based on their house and sign
- Shows house cusps and divisions
- Uses color coding for different planets
- Displays planet symbols and labels

Enjoy exploring the chart visualization! 🎯

