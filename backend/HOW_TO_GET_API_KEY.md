# 📖 Step-by-Step: How to Get Gemini API Key

## 🎯 What You Need

You need a **Google Gemini API Key** - it's FREE and takes 2 minutes to get!

## 📝 Step-by-Step Instructions

### Step 1: Go to Google AI Studio
**Open this link in your browser:**
```
https://aistudio.google.com/app/apikey
```

Or search: "Google AI Studio API key"

### Step 2: Sign In
- Click "Sign in" button
- Use your Google account (Gmail account)
- Allow permissions if asked

### Step 3: Create API Key
1. You'll see a page with "Get API key" or "Create API key" button
2. Click **"Create API Key"** button
3. A popup will appear asking:
   - "Create API key in new project" - Click this
   - OR "Create API key in existing project" - Choose a project if you have one
4. Click **"Create API key in new project"**

### Step 4: Copy Your API Key
- A new API key will be generated
- It looks like this: `AIzaSyAbc123xyz789DEF456ghi012jkl345mno`
- **Click the copy button** (or select all and copy)
- ⚠️ **IMPORTANT:** Copy it now! You might not see it again

### Step 5: Add to .env File
1. Open the file: `backend/.env`
2. Find this line:
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   ```
3. Replace `your_gemini_api_key_here` with your actual key:
   ```
   GEMINI_API_KEY=AIzaSyAbc123xyz789DEF456ghi012jkl345mno
   ```
4. **Save the file** (Ctrl+S)

### Step 6: Restart Backend
```bash
cd backend
node server.js
```

You should see:
```
✅ Gemini AI service initialized successfully
```

## ✅ That's It!

Now Bible verses will appear with your advice! 🎉

## 🔍 What the API Key Looks Like

- Starts with: `AIzaSy`
- Length: About 39 characters
- Format: Mix of letters and numbers
- Example: `AIzaSyAbc123xyz789DEF456ghi012jkl345mno`

## ❓ Common Questions

**Q: Is it free?**
A: Yes! Free tier: 60 requests/minute, 1,500 requests/day

**Q: Do I need to pay?**
A: No, the free tier is enough for personal use

**Q: What if I can't find the API key page?**
A: Try this direct link: https://aistudio.google.com/app/apikey

**Q: Can I use someone else's API key?**
A: No, each person needs their own (it's free to get one)

## 🆘 Need Help?

If you see errors:
- Make sure you copied the ENTIRE key (no spaces)
- Make sure `.env` file is in `backend` folder
- Make sure you saved the file after editing

