// Node.js/Express Backend for Inside Qoutes App
// Run with: node server.js
// Or with nodemon: nodemon server.js

// Load environment variables
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs').promises;
const path = require('path');
const AdviceEngine = require('./ai_advice_engine');
const geminiService = require('./gemini_service');
const groqService = require('./groq_service');
const quizService = require('./quiz_service');
const db = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Data storage (in production, use a database like MongoDB, PostgreSQL, etc.)
const dataDir = path.join(__dirname, 'data');
const usersFile = path.join(dataDir, 'users.json');

// Initialize AI Advice Engine
const adviceEngine = new AdviceEngine();

// Initialize data directory (fallback storage)
async function initDataDir() {
  try {
    await fs.mkdir(dataDir, { recursive: true });
    try {
      await fs.access(usersFile);
    } catch {
      await fs.writeFile(usersFile, JSON.stringify({}));
    }
  } catch (error) {
    console.error('Error initializing data directory:', error);
  }
}

// Load users data. If MongoDB is connected, use it; otherwise fall back to file storage.
async function loadUsers() {
  if (db && db.isConnected && db.isConnected()) {
    try {
      return await db.loadUsers();
    } catch (err) {
      console.error('Error loading users from MongoDB, falling back to file:', err.message);
    }
  }

  try {
    const data = await fs.readFile(usersFile, 'utf8');
    return JSON.parse(data);
  } catch {
    return {};
  }
}

// Save users data. If MongoDB is connected, use it; otherwise fall back to file storage.
async function saveUsers(users) {
  if (db && db.isConnected && db.isConnected()) {
    try {
      await db.saveUsers(users);
      return;
    } catch (err) {
      console.error('Error saving users to MongoDB, falling back to file:', err.message);
    }
  }

  try {
    await fs.writeFile(usersFile, JSON.stringify(users, null, 2));
  } catch (error) {
    console.error('Error saving users:', error);
  }
}

// Simple token storage (in production, use JWT or similar)
const tokens = new Map();

// Initialize
initDataDir();
// Try to connect to MongoDB if MONGODB_URI is provided. If connection fails, app will continue using file storage.
db.connect(process.env.MONGODB_URI).catch((err) => {
  console.warn('MongoDB connection not available; using file-based storage.');
});

// ==================== AUTHENTICATION ====================

// Anonymous sign-in
app.post('/api/auth/anonymous', async (req, res) => {
  try {
    const userId = uuidv4();
    const token = uuidv4();

    tokens.set(token, userId);

    const users = await loadUsers();
    if (!users[userId]) {
      users[userId] = {
        id: userId,
        createdAt: new Date().toISOString(),
        settings: {},
        quizScores: [],
        favorites: [],
        profile: {},
      };
      await saveUsers(users);
    }

    res.json({
      userId,
      token,
      message: 'Anonymous sign-in successful',
    });
  } catch (error) {
    console.error('Error in anonymous sign-in:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Logout
app.post('/api/auth/logout', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (token) {
    tokens.delete(token);
  }
  res.json({ message: 'Logged out successfully' });
});

// Middleware to verify token
function verifyToken(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token || !tokens.has(token)) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  req.userId = tokens.get(token);
  next();
}

// ==================== USER SETTINGS ====================

// Get user settings
app.get('/api/users/:userId/settings', verifyToken, async (req, res) => {
  try {
    if (req.userId !== req.params.userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const users = await loadUsers();
    const user = users[req.params.userId];

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user.settings || {});
  } catch (error) {
    console.error('Error getting settings:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update user settings
app.put('/api/users/:userId/settings', verifyToken, async (req, res) => {
  try {
    if (req.userId !== req.params.userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const users = await loadUsers();
    const user = users[req.params.userId];

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    user.settings = {
      ...user.settings,
      ...req.body,
      updatedAt: new Date().toISOString(),
    };

    await saveUsers(users);
    res.json({ message: 'Settings updated successfully', settings: user.settings });
  } catch (error) {
    console.error('Error updating settings:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ==================== QUIZ SCORES ====================

// Get quiz scores
app.get('/api/users/:userId/quiz-scores', verifyToken, async (req, res) => {
  try {
    if (req.userId !== req.params.userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const users = await loadUsers();
    const user = users[req.params.userId];

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Sort by createdAt descending
    const scores = (user.quizScores || []).sort((a, b) =>
      new Date(b.createdAt) - new Date(a.createdAt)
    );

    res.json(scores);
  } catch (error) {
    console.error('Error getting quiz scores:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Save quiz score
app.post('/api/users/:userId/quiz-scores', verifyToken, async (req, res) => {
  try {
    if (req.userId !== req.params.userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const users = await loadUsers();
    const user = users[req.params.userId];

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const score = {
      id: uuidv4(),
      ...req.body,
      createdAt: new Date().toISOString(),
    };

    if (!user.quizScores) {
      user.quizScores = [];
    }
    user.quizScores.push(score);

    await saveUsers(users);
    res.json({ message: 'Quiz score saved successfully', score });
  } catch (error) {
    console.error('Error saving quiz score:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ==================== FAVORITES ====================

// Get favorites (no auth to keep mobile/web simple)
app.get('/api/users/:userId/favorites', async (req, res) => {
  try {
    const users = await loadUsers();
    const user = users[req.params.userId];

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const favorites = (user.favorites || []).sort(
      (a, b) => new Date(b.createdAt) - new Date(a.createdAt)
    );

    res.json(favorites);
  } catch (error) {
    console.error('Error getting favorites:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Add favorite (no auth)
app.post('/api/users/:userId/favorites', async (req, res) => {
  try {
    const users = await loadUsers();
    const user = users[req.params.userId];

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const favorite = {
      id: uuidv4(),
      ...req.body,
      createdAt: new Date().toISOString(),
    };

    if (!user.favorites) {
      user.favorites = [];
    }
    user.favorites.push(favorite);

    await saveUsers(users);
    res.json({ message: 'Favorite added successfully', favorite });
  } catch (error) {
    console.error('Error adding favorite:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Remove favorite (no auth)
app.delete('/api/users/:userId/favorites/:favoriteId', async (req, res) => {
  try {
    const users = await loadUsers();
    const user = users[req.params.userId];

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (!user.favorites) {
      user.favorites = [];
    }

    user.favorites = user.favorites.filter(
      (f) => f.id !== req.params.favoriteId
    );
    await saveUsers(users);

    res.json({ message: 'Favorite removed successfully' });
  } catch (error) {
    console.error('Error removing favorite:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ==================== USER PROFILE ====================

// Get profile
app.get('/api/users/:userId/profile', verifyToken, async (req, res) => {
  try {
    if (req.userId !== req.params.userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const users = await loadUsers();
    const user = users[req.params.userId];

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user.profile || {});
  } catch (error) {
    console.error('Error getting profile:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update profile
app.put('/api/users/:userId/profile', verifyToken, async (req, res) => {
  try {
    if (req.userId !== req.params.userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const users = await loadUsers();
    const user = users[req.params.userId];

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    user.profile = {
      ...user.profile,
      ...req.body,
      updatedAt: new Date().toISOString(),
    };

    await saveUsers(users);
    res.json({ message: 'Profile updated successfully', profile: user.profile });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ==================== ADVICE SERVICE (AI-like) ====================

// Get advice based on emotion/feeling text - 100% AI-powered (Gemini AI)
// No hardcoded advice - everything is generated by AI
app.post('/api/advice', async (req, res) => {
  try {
    const { text, language = 'en' } = req.body;

    // Normalize text (allow empty strings - AI will handle it)
    const normalizedText = (text && typeof text === 'string') ? text : '';

    // Try Groq AI first (if available) - handles all cases including empty text
    let result = null;
    if (groqService.isAvailable) {
      try {
        result = await groqService.generateAdvice(normalizedText, language);
        if (result && result.advice) {
          console.log('✅ Using Groq AI for advice generation');
          console.log(`   Bible Verse: ${result.bibleVerse || 'Not provided'}`);
          return res.json({
            advice: result.advice,
            bibleVerse: result.bibleVerse || null,
            detectedEmotion: result.detectedEmotion,
            confidence: result.confidence,
            timestamp: new Date().toISOString(),
            source: 'groq',
          });
        }
      } catch (groqError) {
        console.warn('⚠️  Groq AI failed, falling back to local AI engine:', groqError.message);
      }
    }

    // Fallback to local AI engine if Groq is not available or failed
    // Try Groq one more time (in case it was a temporary issue)
    if (groqService.isAvailable && normalizedText.trim().length > 0) {
      try {
        console.log('🔄 Retrying Groq AI...');
        result = await groqService.generateAdvice(normalizedText, language);
        if (result && result.advice) {
          console.log('✅ Groq AI retry successful');
          console.log(`   Bible Verse: ${result.bibleVerse || 'Not provided'}`);
          return res.json({
            advice: result.advice,
            bibleVerse: result.bibleVerse || null,
            detectedEmotion: result.detectedEmotion,
            confidence: result.confidence,
            timestamp: new Date().toISOString(),
            source: 'groq-retry',
          });
        }
      } catch (retryError) {
        console.warn('⚠️  Groq AI retry also failed:', retryError.message);
      }
    }

    // Last resort: Use local AI engine (pattern-based, not hardcoded single responses)
    // This only happens if Gemini is completely unavailable
    console.log('📝 Using local AI engine as last resort');
    result = adviceEngine.generateAdvice(normalizedText, language);
    console.log(`✅ Generated advice (${result.advice.length} characters)`);
    console.log(`   Bible Verse: ${result.bibleVerse || 'Not provided'}`);

    res.json({
      advice: result.advice,
      bibleVerse: result.bibleVerse || null,
      detectedEmotion: result.detectedEmotion,
      confidence: result.confidence,
      timestamp: new Date().toISOString(),
      source: 'local-fallback',
    });
    console.log(`📤 Sent response to client\n`);
  } catch (error) {
    console.error('Error getting advice:', error);

    // Last resort: Use local AI engine even on error (still AI-generated, not hardcoded)
    try {
      const language = req.body?.language || 'en';
      const text = req.body?.text || '';
      const result = adviceEngine.generateAdvice(text, language);

      res.json({
        advice: result.advice,
        bibleVerse: result.bibleVerse || null,
        detectedEmotion: result.detectedEmotion,
        confidence: result.confidence,
        timestamp: new Date().toISOString(),
        source: 'local-fallback',
      });
    } catch (fallbackError) {
      // Only if everything fails, return a minimal error message
      res.status(500).json({
        error: 'Unable to generate advice at this time. Please try again later.',
        timestamp: new Date().toISOString(),
      });
    }
  }
});

// ==================== QUIZ SERVICES (AI-generated) ====================

// Generate Bible verse quiz questions using Gemini AI
// IMPORTANT: This endpoint ONLY uses AI (Gemini) - NO hardcoded questions or fallback questions
// If Gemini is not available, it returns an error. Games MUST use AI-generated questions.
app.post('/api/quiz/bible-verse', async (req, res) => {
  try {
    const { difficulty = 'easy', count = 5, language = 'en' } = req.body;

    console.log(`\n📖 Generating Bible verse quiz: difficulty=${difficulty}, count=${count}, language=${language}`);

    // Validate inputs
    if (!['easy', 'medium', 'hard'].includes(difficulty)) {
      return res.status(400).json({ error: 'Invalid difficulty. Must be easy, medium, or hard' });
    }

    if (count < 1 || count > 20) {
      return res.status(400).json({ error: 'Count must be between 1 and 20' });
    }

    // Generate questions using Gemini AI ONLY - no fallback questions
    const questions = await quizService.generateBibleVerseQuiz(difficulty, count, language);

    if (!questions) {
      // NO fallback questions - games MUST use AI (Gemini)
      return res.status(503).json({
        error: 'Quiz generation unavailable. Please ensure Gemini API key is configured.',
        fallback: true,
      });
    }

    console.log(`✅ Generated ${questions.length} Bible verse quiz questions`);

    res.json({
      questions: questions,
      difficulty: difficulty,
      count: questions.length,
      language: language,
      timestamp: new Date().toISOString(),
      source: 'gemini',
    });
  } catch (error) {
    console.error('Error generating Bible verse quiz:', error);
    res.status(500).json({
      error: 'Failed to generate quiz questions',
      fallback: true,
    });
  }
});

// Generate Emotions quiz questions using Gemini AI
// IMPORTANT: This endpoint ONLY uses AI (Gemini) - NO hardcoded questions or fallback questions
// If Gemini is not available, it returns an error. Games MUST use AI-generated questions.
app.post('/api/quiz/emotions', async (req, res) => {
  try {
    const { difficulty = 'easy', count = 5, language = 'en' } = req.body;

    console.log(`\n😊 Generating Emotions quiz: difficulty=${difficulty}, count=${count}, language=${language}`);

    // Validate inputs
    if (!['easy', 'medium', 'hard'].includes(difficulty)) {
      return res.status(400).json({ error: 'Invalid difficulty. Must be easy, medium, or hard' });
    }

    if (count < 1 || count > 20) {
      return res.status(400).json({ error: 'Count must be between 1 and 20' });
    }

    // Generate questions using Gemini AI ONLY - no fallback questions
    const questions = await quizService.generateEmotionsQuiz(difficulty, count, language);

    if (!questions) {
      // NO fallback questions - games MUST use AI (Gemini)
      return res.status(503).json({
        error: 'Quiz generation unavailable. Please ensure Gemini API key is configured.',
        fallback: true,
      });
    }

    console.log(`✅ Generated ${questions.length} Emotions quiz questions`);

    res.json({
      questions: questions,
      difficulty: difficulty,
      count: questions.length,
      language: language,
      timestamp: new Date().toISOString(),
      source: 'gemini',
    });
  } catch (error) {
    console.error('Error generating Emotions quiz:', error);
    res.status(500).json({
      error: 'Failed to generate quiz questions',
      fallback: true,
    });
  }
});

// ==================== HEALTH CHECK ====================

app.get('/api/health', (req, res) => {
  const clientIp = req.ip || req.connection.remoteAddress || 'unknown';
  console.log(`\n🏥 Health check from: ${clientIp}`);
  res.json({
    status: 'ok',
    message: 'Inside Qoutes API is running',
    timestamp: new Date().toISOString(),
    clientIp: clientIp,
  });
});

// Test endpoint for connectivity
app.get('/api/test', (req, res) => {
  const clientIp = req.ip || req.connection.remoteAddress || 'unknown';
  console.log(`\n🧪 Test request from: ${clientIp}`);
  res.json({
    success: true,
    message: 'Connection test successful',
    serverTime: new Date().toISOString(),
    clientIp: clientIp,
  });
});

// Start server - listen on all network interfaces (0.0.0.0) to allow connections from other devices
const HOST = '0.0.0.0'; // Listen on all interfaces
app.listen(PORT, HOST, () => {
  console.log(`🚀 Inside Qoutes Backend Server running on http://localhost:${PORT}`);
  console.log(`📡 API endpoints available at http://localhost:${PORT}/api`);
  console.log(`🌐 Network access: http://10.0.2.165:${PORT}/api`);
  console.log(`✅ Server is listening on all network interfaces (0.0.0.0:${PORT})`);
  console.log(`\n💡 Make sure your phone and computer are on the same Wi-Fi network`);
  console.log(`💡 Use IP address 10.0.2.165:${PORT} in your Flutter app\n`);
});

