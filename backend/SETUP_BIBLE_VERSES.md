# How to Get Bible Verses in Advice

## ⚠️ Important: Bible Verses Require Gemini AI

Bible verses are **100% AI-generated** (not hardcoded). To get Bible verses with your advice, you need to set up Google Gemini AI.

## Quick Setup (5 minutes)

### Step 1: Get Free Gemini API Key

1. Visit: https://aistudio.google.com/app/apikey
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your API key

### Step 2: Create `.env` File

1. Go to the `backend` folder
2. Create a file named `.env` (no extension)
3. Add this line:
   ```
   GEMINI_API_KEY=your_actual_api_key_here
   ```
4. Replace `your_actual_api_key_here` with your actual API key

### Step 3: Restart Backend Server

```bash
cd backend
node server.js
```

You should see:
```
✅ Gemini AI service initialized successfully
```

## How It Works

**With Gemini API Key:**
- ✅ AI-generated personalized advice
- ✅ AI-generated relevant Bible verse
- ✅ Different verse every time (based on user's feelings)

**Without Gemini API Key:**
- ✅ Local AI-generated advice
- ❌ No Bible verse (returns null)

## Example Response

**Input:** "I am feeling sad today"

**Output:**
```
Advice: I understand you're going through a difficult time. Remember, it's okay to feel this way. Reach out to someone you trust, and know that this feeling will pass.

Bible Verse: Psalm 34:18 - "The Lord is close to the brokenhearted and saves those who are crushed in spirit."
```

## Troubleshooting

**Problem:** Still no Bible verse after setup
- **Solution:** Check backend console logs - you should see "✅ Using Gemini AI for advice generation"
- **Solution:** Make sure `.env` file is in the `backend` folder (not root folder)
- **Solution:** Restart the backend server after creating `.env`

**Problem:** "GEMINI_API_KEY not found" warning
- **Solution:** Make sure `.env` file exists in `backend` folder
- **Solution:** Check that the API key is correct (no extra spaces)

## Free Tier

Google Gemini API has a generous free tier:
- **60 requests per minute**
- **1,500 requests per day**

This is more than enough for personal use!

