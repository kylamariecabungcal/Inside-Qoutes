# ⚡ Quick Setup - Get Bible Verses Working in 2 Minutes!

## Step 1: Get Your Free Gemini API Key (1 minute)

1. **Open this link:** https://aistudio.google.com/app/apikey
2. **Sign in** with your Google account
3. **Click "Create API Key"**
4. **Copy the key** (looks like: `AIzaSyAbc123xyz789...`)

## Step 2: Add API Key to .env File (30 seconds)

1. Open `backend/.env` file
2. Find this line:
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   ```
3. Replace `your_gemini_api_key_here` with your actual API key:
   ```
   GEMINI_API_KEY=AIzaSyAbc123xyz789...
   ```
4. Save the file

## Step 3: Restart Backend (30 seconds)

```bash
cd backend
node server.js
```

You should see:
```
✅ Gemini AI service initialized successfully
```

## ✅ Done!

Now when you use the app:
- ✅ You'll get AI-generated advice
- ✅ You'll get AI-generated Bible verses (relevant to your feelings)
- ✅ Everything is unique and personalized!

## Need Help?

If you see "⚠️ GEMINI_API_KEY not found":
- Make sure `.env` file is in the `backend` folder
- Make sure there are no spaces around the `=` sign
- Make sure you saved the file

---

**That's it! Bible verses will now appear with your advice! 🎉**

