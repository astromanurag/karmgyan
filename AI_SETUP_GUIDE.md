# 🤖 AI Predictions - Setup & Usage Guide

## ✅ Implementation Complete

The AI-powered astrological predictions feature has been fully implemented:

### Backend Components

1. **Python AI Service** (`backend/python/ai_astrology.py`)
   - GPT-4 / Claude integration
   - Chart context preparation
   - Expert astrologer prompts
   - Mock responses for testing

2. **Node.js API Routes** (`backend/routes/ai_predictions.js`)
   - `POST /api/ai/ask` - Ask questions
   - `POST /api/ai/generate-report` - Generate reports
   - `GET /api/ai/credits` - Get user credits
   - `POST /api/ai/credits/purchase` - Buy credits
   - `GET /api/ai/credit-packages` - Get pricing
   - `GET /api/ai/conversations` - Get history
   - `GET /api/ai/reports` - Get saved reports

### Flutter Components

1. **AI Service** (`lib/services/ai_service.dart`)
2. **AI Hub Screen** (`lib/presentation/screens/ai/ai_hub_screen.dart`)
3. **AI Chat Screen** (`lib/presentation/screens/ai/ai_chat_screen.dart`)
4. **AI Reports Screen** (`lib/presentation/screens/ai/ai_reports_screen.dart`)

### Routes Added

- `/ai` - AI Hub (main landing page)
- `/ai-chat` - Chat with AI astrologer
- `/ai-reports` - Generate detailed reports

---

## 🔧 Setup Instructions

### Step 1: Install Python Dependencies

```bash
cd backend/python
pip install openai anthropic
```

### Step 2: Configure API Key

Create a `.env` file in the `backend` folder:

```env
# OpenAI (recommended)
OPENAI_API_KEY=sk-your-openai-key-here

# OR Anthropic Claude
ANTHROPIC_API_KEY=your-anthropic-key-here

# Choose provider
AI_PROVIDER=openai  # or 'anthropic'
```

### Step 3: Get Your API Key

#### OpenAI (GPT-4)
1. Go to https://platform.openai.com/signup
2. Create an account or sign in
3. Navigate to API Keys section
4. Create a new secret key
5. Copy and paste into `.env`

**Pricing (GPT-4 Turbo):**
- Input: $0.01 / 1K tokens (~$0.01-0.02 per question)
- Output: $0.03 / 1K tokens

#### Anthropic (Claude)
1. Go to https://console.anthropic.com
2. Create an account
3. Get API key from dashboard

**Pricing (Claude 3 Opus):**
- Input: $0.015 / 1K tokens
- Output: $0.075 / 1K tokens

### Step 4: Restart Backend

```bash
cd backend
npm start
```

---

## 🎮 Testing the API

### Check Credits
```bash
curl -X GET "http://localhost:3000/api/ai/credits" \
  -H "X-User-Id: test123"
```

### Ask a Question
```bash
curl -X POST "http://localhost:3000/api/ai/ask" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: test123" \
  -d '{
    "chartData": {
      "name": "Test User",
      "date": "1987-10-31",
      "time": "06:35:00",
      "ascendant": {"sign": "Libra"},
      "planets": {"Sun": {"sign": "Libra", "house": 1}},
      "current_dasha": {"mahadasha": "Moon"}
    },
    "question": "When will I get married?"
  }'
```

### Generate Report
```bash
curl -X POST "http://localhost:3000/api/ai/generate-report" \
  -H "Content-Type: application/json" \
  -H "X-User-Id: test123" \
  -d '{
    "chartData": {...},
    "reportType": "comprehensive"
  }'
```

---

## 💰 Monetization

### Credit System

| Action | Credits |
|--------|---------|
| Ask Question | 1 |
| Basic Report (Career/Marriage) | 5 |
| Comprehensive Life Reading | 10 |
| Yearly Forecast | 15 |

### Credit Packages

| Package | Price (INR) | Price (USD) | Savings |
|---------|-------------|-------------|---------|
| 10 Credits | ₹99 | $1.50 | - |
| 50 Credits | ₹399 | $6.00 | 20% |
| 100 Credits | ₹699 | $10.00 | 30% |

### Profit Margins

- **Your Revenue per Question:** ₹10 (~$0.12)
- **AI Cost per Question:** ₹2-3 (~$0.03)
- **Your Profit:** 70-80% margin

---

## 🚀 Flutter App Usage

### Navigate to AI Features

From Home Screen:
1. Click the purple "AI Predictions" banner
2. Or use the "AI Chat" quick access button

### AI Hub Features

1. **View Credits** - See remaining credits
2. **Buy Credits** - Purchase credit packs
3. **AI Chat** - Ask questions
4. **AI Reports** - Generate detailed reports

### Chat Interface

- Type any question about your chart
- Get instant AI-powered predictions
- Copy/share responses
- Conversation history saved

### Report Types

- **Comprehensive** - Complete life reading (10 credits)
- **Career** - Professional guidance (5 credits)
- **Marriage** - Relationship analysis (5 credits)
- **Yearly** - 12-month forecast (15 credits)

---

## 🔒 Security Notes

1. **API Keys:** Never commit API keys to git
2. **Rate Limiting:** Built-in to prevent abuse
3. **Credits System:** Prevents unlimited usage
4. **User ID:** Track usage per user

---

## 📊 Monitoring

The backend logs:
- Questions asked
- Credits used
- API response times
- Error rates

---

## 🎯 Next Steps

1. **Production Deployment**
   - Set up proper database for credits
   - Integrate payment gateway (Razorpay/Stripe)
   - Add user authentication

2. **Enhancements**
   - Voice input/output
   - Multi-language support
   - Image generation for charts
   - Push notifications for daily insights

3. **Marketing**
   - Free credits for new users (already implemented!)
   - Referral program
   - Social sharing

---

## 🐛 Troubleshooting

### Mock Responses Only

If you're only getting mock responses:
1. Check `.env` file has correct API key
2. Verify `AI_PROVIDER` is set correctly
3. Check Python has `openai` package installed

### Connection Errors

If API calls fail:
1. Verify backend is running: `curl http://localhost:3000/health`
2. Check network connectivity
3. Verify API key is valid

### Rate Limits

OpenAI has rate limits. If hitting limits:
1. Implement request queuing
2. Consider upgrading OpenAI tier
3. Add caching for common questions

---

## 📝 Files Created/Modified

### New Files
- `backend/python/ai_astrology.py`
- `backend/routes/ai_predictions.js`
- `lib/services/ai_service.dart`
- `lib/presentation/screens/ai/ai_hub_screen.dart`
- `lib/presentation/screens/ai/ai_chat_screen.dart`
- `lib/presentation/screens/ai/ai_reports_screen.dart`

### Modified Files
- `backend/server.js` - Added AI routes
- `lib/core/router/app_router.dart` - Added AI routes
- `lib/presentation/screens/home/home_screen.dart` - Added AI banner

---

**🎉 AI Predictions feature is now ready to use!**

