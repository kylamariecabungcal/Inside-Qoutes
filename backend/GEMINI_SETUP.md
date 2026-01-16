# Google Gemini AI Setup Guide

## Why Gemini AI?

The app now uses **Google Gemini AI** to generate more personalized, varied, and intelligent advice responses. Instead of hardcoded responses, Gemini understands natural language and provides unique advice for each user input.

## How to Get Your Free API Key

1. **Visit Google AI Studio:**
   - Go to: https://aistudio.google.com/app/apikey
   - Or: https://makersuite.google.com/app/apikey

2. **Sign in with your Google account**

3. **Create a new API key:**
   - Click "Create API Key"
   - Select "Create API key in new project" (or use existing project)
   - Copy your API key

4. **Add to your backend:**
   - Create a file named `.env` in the `backend` folder
   - Add this line:
     ```
     GEMINI_API_KEY=your_actual_api_key_here
     ```
   - Replace `your_actual_api_key_here` with your actual API key

## Example `.env` file:

```
GEMINI_API_KEY=AIzaSyAbc123xyz789...
PORT=3000
```

## How It Works

1. **With Gemini API Key:**
   - User types their feelings → Gemini AI generates personalized advice
   - More varied, intelligent, and contextual responses
   - High confidence (0.9)

2. **Without Gemini API Key (Fallback):**
   - Uses local AI engine with keyword-based detection
   - Still provides good advice, but less varied
   - Lower confidence (0.5-0.7)

## Testing

After setting up your API key, restart the backend server:

```bash
cd backend
npm start
# or
npm run dev
```

Then test the advice endpoint:
```bash
curl -X POST http://localhost:3000/api/advice \
  -H "Content-Type: application/json" \
  -d '{"text": "I am happy today", "language": "en"}'
```

You should see `"source": "gemini"` in the response if Gemini is working.

## Free Tier Limits

Google Gemini API has a generous free tier:
- **60 requests per minute**
- **1,500 requests per day**

This is more than enough for personal use and development!

## Security

- The `.env` file is already in `.gitignore`
- Never commit your API key to git
- Keep your API key private

## Troubleshooting

**Problem:** "GEMINI_API_KEY not found" warning
- **Solution:** Make sure you created the `.env` file in the `backend` folder with the correct key

**Problem:** "Error generating advice with Gemini"
- **Solution:** Check if your API key is valid and you haven't exceeded rate limits

**Problem:** Still using local AI engine
- **Solution:** Check server logs - if Gemini fails, it automatically falls back to local AI

