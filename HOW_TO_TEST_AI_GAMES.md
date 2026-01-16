# 🧪 Paano i-Test ang AI-Generated Games

## Step 1: I-check kung Running ang Backend Server

### Sa Terminal/Command Prompt:
```bash
cd backend
node server.js
```

### Dapat makita mo:
```
✅ Gemini AI service initialized successfully
🚀 Inside Qoutes Backend Server running on http://localhost:3000
📡 API endpoints available at http://localhost:3000/api
```

**⚠️ Important:** Kung walang "✅ Gemini AI service initialized", ibig sabihin walang Gemini API key!

---

## Step 2: I-verify ang Gemini API Key

### I-check ang `.env` file sa `backend` folder:
```
GEMINI_API_KEY=AIzaSy... (dapat may value)
PORT=3000
```

### Kung walang `.env` file:
1. Gumawa ng `.env` file sa `backend` folder
2. I-add ang Gemini API key:
   ```
   GEMINI_API_KEY=your_api_key_here
   PORT=3000
   ```
3. I-restart ang backend server

### Paano kumuha ng Gemini API Key:
1. Pumunta sa: https://aistudio.google.com/app/apikey
2. Sign in gamit ang Google account
3. Click "Create API Key"
4. Copy ang API key
5. I-paste sa `.env` file

---

## Step 3: I-test ang Games sa App

### Sa Flutter App:
1. **Open ang app**
2. **Pumunta sa "Games" tab** (bottom navigation)
3. **Pumili ng game:**
   - Emotions Quiz
   - Bible Verse Quiz
4. **Pumili ng difficulty:**
   - Easy (5 questions)
   - Medium (7 questions)
   - Hard (10 questions)

### Dapat makita mo:
- ✅ Loading screen na may "Generating questions with AI..."
- ✅ Questions na lumalabas pagkatapos ng ilang segundo
- ✅ Unique questions bawat beses na maglaro ka

---

## Step 4: I-check ang Backend Logs

### Habang naglo-load ang quiz, tignan ang backend console:

### ✅ **Kung gumagana ang AI:**
```
😊 Generating Emotions quiz: difficulty=easy, count=5, language=en
   ✅ Using gemini-1.5-flash (fast model)
   ⏱️  Calling Gemini API for Emotions quiz...
   ⏱️  Gemini API responded in 8.45 seconds
✅ Validated 5 Emotions quiz questions from Gemini AI
✅ Generated 5 Emotions quiz questions
```

### ❌ **Kung may problema:**
```
⚠️  GEMINI_API_KEY not found in environment variables
❌ Quiz generation unavailable
```

---

## Step 5: I-test gamit ang Browser/Postman

### Health Check:
```
http://localhost:3000/api/health
```

**Dapat makita:**
```json
{
  "status": "ok",
  "message": "Inside Qoutes API is running",
  "timestamp": "2024-..."
}
```

### Test Emotions Quiz (gamit ang Postman o curl):
```bash
curl -X POST http://localhost:3000/api/quiz/emotions \
  -H "Content-Type: application/json" \
  -d '{"difficulty": "easy", "count": 5, "language": "en"}'
```

**Dapat makita:**
```json
{
  "questions": [
    {
      "question": "...",
      "options": ["...", "...", "...", "..."],
      "correct": 0
    }
  ],
  "difficulty": "easy",
  "count": 5,
  "source": "gemini"
}
```

---

## Step 6: I-verify na AI-Generated

### Signs na AI-generated:
1. ✅ **Different questions bawat beses** - maglaro ka ulit, iba ang questions
2. ✅ **Loading time** - 5-30 seconds depende sa bilang ng questions
3. ✅ **Backend logs** - may "Gemini API responded" message
4. ✅ **Source field** - `"source": "gemini"` sa response

### Kung hindi AI-generated:
- ❌ Same questions lagi
- ❌ Walang loading time
- ❌ Error message: "Quiz generation unavailable"

---

## Troubleshooting

### Problem: "Loading lang ng loading"
**Solution:**
1. I-check kung running ang backend server
2. I-check kung may Gemini API key sa `.env`
3. I-check ang network connection
4. I-check ang IP address sa `RestApiService`

### Problem: "Unable to load AI-generated questions"
**Solution:**
1. I-verify ang Gemini API key sa `.env` file
2. I-restart ang backend server
3. I-check ang backend logs para sa error messages

### Problem: "Request timed out"
**Solution:**
1. I-check ang internet connection
2. I-check kung mabagal ang Gemini API (peak hours)
3. I-try ulit pagkatapos ng ilang segundo

---

## Quick Test Checklist

- [ ] Backend server ay running
- [ ] Gemini API key ay naka-configure
- [ ] Health check endpoint ay nagre-respond
- [ ] Games page ay naglo-load
- [ ] Quiz questions ay lumalabas
- [ ] Questions ay unique bawat beses
- [ ] Backend logs ay nagpapakita ng "Gemini API responded"

---

## Expected Behavior

### ✅ **Working:**
- Loading screen → Questions appear → Quiz starts
- Backend logs show "Gemini API responded"
- Different questions each time
- Takes 5-30 seconds to generate

### ❌ **Not Working:**
- Stuck sa loading
- Error message appears
- Same questions every time
- Backend logs show "GEMINI_API_KEY not found"

---

**💡 Tip:** I-check ang backend console logs habang nagte-test para makita kung ano ang nangyayari!

