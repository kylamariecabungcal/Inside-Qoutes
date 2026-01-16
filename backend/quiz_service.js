// Quiz Question Generation Service using Google Gemini AI
// 
// This service generates quiz questions dynamically using Gemini AI.
// All quiz questions are AI-generated in real-time - no hardcoded questions.
// 
// Requirements:
// - GEMINI_API_KEY must be set in .env file
// - See GEMINI_SETUP.md for setup instructions
//
const geminiService = require('./gemini_service');
const { GoogleGenerativeAI } = require('@google/generative-ai');

class QuizService {
  /**
   * Generate Bible verse quiz questions using Gemini AI
   * IMPORTANT: This function ONLY uses AI (Gemini) - NO hardcoded questions or fallback
   * If Gemini is not available, returns null. Games MUST use AI-generated questions.
   * @param {string} difficulty - 'easy', 'medium', or 'hard'
   * @param {number} count - Number of questions to generate
   * @param {string} language - 'en' or 'tl'
   * @returns {Promise<Array>} Array of quiz questions (null if Gemini not available)
   */
  async generateBibleVerseQuiz(difficulty, count = 5, language = 'en') {
    if (!geminiService.isAvailable || !geminiService.genAI) {
      // NO fallback - games MUST use AI (Gemini)
      return null; // Return null if Gemini is not available
    }

    try {
      // Use the latest Gemini model for better quality and faster responses
      // gemini-1.5-flash is much faster than gemini-pro
      let model;
      try {
        model = geminiService.genAI.getGenerativeModel({ 
          model: 'gemini-1.5-flash',
          // Flash model is optimized for speed
        });
        console.log('   ✅ Using gemini-1.5-flash (fast model)');
      } catch (e) {
        // Fallback to gemini-pro if flash is not available
        console.log('   ⚠️  gemini-1.5-flash not available, using gemini-pro (slower)');
        model = geminiService.genAI.getGenerativeModel({ model: 'gemini-pro' });
      }
      const isTagalog = language === 'tl';
      
      // Add timestamp and random seed to ensure different questions each time
      const timestamp = Date.now();
      const randomSeed = Math.floor(Math.random() * 1000000);

      const difficultyDescription = {
        easy: isTagalog
          ? 'mga kilalang Bible verse (well-known verses)'
          : 'well-known Bible verses',
        medium: isTagalog
          ? 'mga mas detalyadong Bible verse (more detailed verses)'
          : 'more detailed Bible verses',
        hard: isTagalog
          ? 'mga advanced na Bible verse (advanced knowledge)'
          : 'advanced Bible verses requiring deeper knowledge',
      };

      const prompt = isTagalog
        ? `Ikaw ay isang expert Bible quiz generator na gumagamit ng AI. Gumawa ng ${count} na high-quality Bible verse quiz questions na ${difficultyDescription[difficulty]}.

⚠️ IMPORTANTE: Ang mga tanong na ito ay dapat TOTALLY IBA sa mga na-generate na tanong dati. Huwag mag-ulit ng parehong verse, book, o concept. Gumamit ng iba't ibang Bible verses at books para sa variety.

Para sa bawat tanong:
1. Magbigay ng isang kumpletong Bible verse text (quote) - dapat accurate at complete
2. Magbigay ng eksaktong 3 options na may format: "Book Chapter:Verse" (halimbawa: "John 3:16")
3. Isa lang ang tamang sagot - dapat accurate na Bible reference
4. Ang ibang 2 options ay dapat maging believable pero mali - dapat realistic na references pero hindi tama
5. Dapat iba-iba ang mga tanong - huwag mag-ulit ng parehong verse, book, o concept
6. Gumamit ng iba't ibang Bible books at verses para sa maximum variety (timestamp: ${timestamp}, seed: ${randomSeed})

Format ng response (JSON array ONLY, walang markdown, walang explanation):
[
  {
    "question": "Complete Bible verse text here",
    "options": ["Book Chapter:Verse", "Book Chapter:Verse", "Book Chapter:Verse"],
    "correct": 0
  }
]

CRITICAL REQUIREMENTS:
- Ibalik ang response sa PURE JSON format lang - walang markdown code blocks, walang explanation, walang ibang text
- Ang "correct" ay index ng tamang sagot (0, 1, o 2)
- Gumamit ng iba't ibang Bible books para sa variety
- Para sa easy: gamitin ang mga very well-known verses (John 3:16, Psalm 23:1, Matthew 6:9, etc.) PERO huwag ulitin ang parehong verses na na-generate na dati
- Para sa medium: gamitin ang mga verses na mas detalyado pero recognizable
- Para sa hard: gamitin ang mga verses na nangangailangan ng mas malalim na Bible knowledge
- Dapat accurate ang lahat ng Bible references
- Dapat unique ang bawat tanong - HINDI dapat pareho sa mga na-generate na tanong dati
- Gumamit ng iba't ibang Bible books at verses para sa maximum variety

Generate exactly ${count} questions. Return ONLY the JSON array, nothing else.`
        : `You are an expert Bible quiz generator powered by AI. Create ${count} high-quality Bible verse quiz questions that are ${difficultyDescription[difficulty]}.

⚠️ IMPORTANT: These questions must be TOTALLY DIFFERENT from any previously generated questions. Do NOT repeat the same verse, book, or concept. Use diverse Bible verses and books for variety.

For each question:
1. Provide a complete Bible verse text (quote) - must be accurate and complete
2. Provide exactly 3 options in format: "Book Chapter:Verse" (e.g., "John 3:16")
3. Only one is correct - must be the accurate Bible reference
4. The other 2 options should be believable but wrong - realistic references but incorrect
5. Questions should be varied - don't repeat the same verse, book, or concept
6. Use different Bible books and verses for maximum variety (timestamp: ${timestamp}, seed: ${randomSeed})

Response format (JSON array ONLY, no markdown, no explanation):
[
  {
    "question": "Complete Bible verse text here",
    "options": ["Book Chapter:Verse", "Book Chapter:Verse", "Book Chapter:Verse"],
    "correct": 0
  }
]

CRITICAL REQUIREMENTS:
- Return response in PURE JSON format only - no markdown code blocks, no explanation, no other text
- "correct" is the index of the correct answer (0, 1, or 2)
- Use different Bible books for variety
- For easy: use very well-known verses (John 3:16, Psalm 23:1, Matthew 6:9, etc.) BUT do NOT repeat the same verses that were generated before
- For medium: use more detailed but recognizable verses
- For hard: use verses requiring deeper Bible knowledge
- All Bible references must be accurate
- Each question must be unique - NOT the same as any previously generated questions
- Use diverse Bible books and verses for maximum variety

Generate exactly ${count} questions. Return ONLY the JSON array, nothing else.`;

      // Use generation config with higher temperature for more variety
      // Higher temperature = more creative and varied responses
      const generationConfig = {
        temperature: 0.9, // Increased from 0.7 to 0.9 for more variety
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048, // Limit output for faster generation
      };

      console.log(`   ⏱️  Calling Gemini API for Bible verse quiz...`);
      const startTime = Date.now();
      
      const result = await model.generateContent({
        contents: [{ role: 'user', parts: [{ text: prompt }] }],
        generationConfig: generationConfig,
      });
      const response = await result.response;
      const text = response.text().trim();
      
      const elapsedTime = ((Date.now() - startTime) / 1000).toFixed(2);
      console.log(`   ⏱️  Gemini API responded in ${elapsedTime} seconds`);

      // Parse JSON from response
      let questions;
      try {
        // Try to extract JSON from markdown code blocks if present
        const jsonMatch = text.match(/\[[\s\S]*\]/);
        if (jsonMatch) {
          questions = JSON.parse(jsonMatch[0]);
        } else {
          questions = JSON.parse(text);
        }
      } catch (parseError) {
        console.error('Error parsing quiz questions JSON:', parseError);
        console.error('Response was:', text);
        return null;
      }

      // Validate questions structure
      if (!Array.isArray(questions) || questions.length === 0) {
        console.error('Invalid questions format: not an array or empty');
        return null;
      }

      // Validate and ensure correct format
      const validatedQuestions = questions
        .filter((q) => q && q.question && Array.isArray(q.options) && q.options.length >= 3)
        .map((q, index) => {
          // Ensure correct index is within bounds
          const correctIndex = Math.max(0, Math.min(q.correct || 0, q.options.length - 1));
          return {
            question: (q.question || q.verse || '').trim(),
            options: q.options.slice(0, 3).map(opt => String(opt).trim()), // Ensure exactly 3 options
            correct: correctIndex,
          };
        })
        .filter((q) => q.question.length > 0 && q.options.length === 3);

      if (validatedQuestions.length === 0) {
        console.error('No valid questions after validation');
        return null;
      }

      console.log(`✅ Validated ${validatedQuestions.length} Bible verse quiz questions from Gemini AI`);
      return validatedQuestions;
    } catch (error) {
      console.error('Error generating Bible verse quiz:', error);
      return null;
    }
  }

  /**
   * Generate Emotions quiz questions using Gemini AI
   * IMPORTANT: This function ONLY uses AI (Gemini) - NO hardcoded questions or fallback
   * If Gemini is not available, returns null. Games MUST use AI-generated questions.
   * @param {string} difficulty - 'easy', 'medium', or 'hard'
   * @param {number} count - Number of questions to generate
   * @param {string} language - 'en' or 'tl'
   * @returns {Promise<Array>} Array of quiz questions (null if Gemini not available)
   */
  async generateEmotionsQuiz(difficulty, count = 5, language = 'en') {
    if (!geminiService.isAvailable || !geminiService.genAI) {
      // NO fallback - games MUST use AI (Gemini)
      return null; // Return null if Gemini is not available
    }

    try {
      // Use the latest Gemini model for better quality and faster responses
      // gemini-1.5-flash is much faster than gemini-pro
      let model;
      try {
        model = geminiService.genAI.getGenerativeModel({ 
          model: 'gemini-1.5-flash',
          // Flash model is optimized for speed
        });
        console.log('   ✅ Using gemini-1.5-flash (fast model)');
      } catch (e) {
        // Fallback to gemini-pro if flash is not available
        console.log('   ⚠️  gemini-1.5-flash not available, using gemini-pro (slower)');
        model = geminiService.genAI.getGenerativeModel({ model: 'gemini-pro' });
      }
      const isTagalog = language === 'tl';
      
      // Add timestamp and random seed to ensure different questions each time
      const timestamp = Date.now();
      const randomSeed = Math.floor(Math.random() * 1000000);

      const difficultyDescription = {
        easy: isTagalog
          ? 'mga basic na emosyon (basic emotions)'
          : 'basic emotions',
        medium: isTagalog
          ? 'mga mas kumplikadong emosyon (more complex emotions)'
          : 'more complex emotions',
        hard: isTagalog
          ? 'mga advanced na emosyon at emotional intelligence (advanced understanding)'
          : 'advanced emotions and emotional intelligence',
      };

      const prompt = isTagalog
        ? `Ikaw ay isang expert emotions quiz generator na gumagamit ng AI. Gumawa ng ${count} na high-quality emotions quiz questions na ${difficultyDescription[difficulty]}.

⚠️ IMPORTANTE: Ang mga tanong na ito ay dapat TOTALLY IBA sa mga na-generate na tanong dati. Huwag mag-ulit ng parehong tanong, scenario, o concept. Gumamit ng iba't ibang situations, emotions, at scenarios.

Para sa bawat tanong:
1. Magbigay ng isang engaging at clear na tanong tungkol sa emosyon o emotional situations
2. Magbigay ng eksaktong 4 options (mga emosyon o emotional states)
3. Isa lang ang tamang sagot - dapat accurate at well-reasoned
4. Ang ibang 3 options ay dapat maging believable pero mali - dapat related emotions pero hindi tama
5. Dapat iba-iba ang mga tanong - huwag mag-ulit ng parehong concept, scenario, o situation
6. Gumamit ng iba't ibang emotional scenarios para sa variety (timestamp: ${timestamp}, seed: ${randomSeed})

Format ng response (JSON array ONLY, walang markdown, walang explanation):
[
  {
    "question": "Clear question about emotions or emotional situation",
    "options": ["Emotion1", "Emotion2", "Emotion3", "Emotion4"],
    "correct": 0
  }
]

CRITICAL REQUIREMENTS:
- Ibalik ang response sa PURE JSON format lang - walang markdown code blocks, walang explanation, walang ibang text
- Ang "correct" ay index ng tamang sagot (0, 1, 2, o 3)
- Para sa easy: gamitin ang basic emotions (happy, sad, angry, scared, surprised, etc.) - simple scenarios
- Para sa medium: gamitin ang mas complex emotions (lonely, stressed, grateful, anxious, proud, etc.) - more nuanced situations
- Para sa hard: gamitin ang advanced concepts (emotional intelligence, empathy, emotional regulation, etc.) - deeper understanding required
- Dapat engaging at educational ang mga tanong
- Dapat unique ang bawat tanong - HINDI dapat pareho sa mga na-generate na tanong dati
- Gumamit ng iba't ibang scenarios, situations, at contexts para sa maximum variety

Generate exactly ${count} questions. Return ONLY the JSON array, nothing else.`
        : `You are an expert emotions quiz generator powered by AI. Create ${count} high-quality emotions quiz questions that are ${difficultyDescription[difficulty]}.

⚠️ IMPORTANT: These questions must be TOTALLY DIFFERENT from any previously generated questions. Do NOT repeat the same question, scenario, or concept. Use diverse situations, emotions, and scenarios.

For each question:
1. Provide an engaging and clear question about emotions or emotional situations
2. Provide exactly 4 options (emotions or emotional states)
3. Only one is correct - must be accurate and well-reasoned
4. The other 3 options should be believable but wrong - related emotions but incorrect
5. Questions should be varied - don't repeat the same concept, scenario, or situation
6. Use different emotional scenarios for variety (timestamp: ${timestamp}, seed: ${randomSeed})

Response format (JSON array ONLY, no markdown, no explanation):
[
  {
    "question": "Clear question about emotions or emotional situation",
    "options": ["Emotion1", "Emotion2", "Emotion3", "Emotion4"],
    "correct": 0
  }
]

CRITICAL REQUIREMENTS:
- Return response in PURE JSON format only - no markdown code blocks, no explanation, no other text
- "correct" is the index of the correct answer (0, 1, 2, or 3)
- For easy: use basic emotions (happy, sad, angry, scared, surprised, etc.) - simple scenarios
- For medium: use more complex emotions (lonely, stressed, grateful, anxious, proud, etc.) - more nuanced situations
- For hard: use advanced concepts (emotional intelligence, empathy, emotional regulation, etc.) - deeper understanding required
- Questions should be engaging and educational
- Each question must be unique - NOT the same as any previously generated questions
- Use diverse scenarios, situations, and contexts for maximum variety

Generate exactly ${count} questions. Return ONLY the JSON array, nothing else.`;

      // Use generation config with higher temperature for more variety
      // Higher temperature = more creative and varied responses
      const generationConfig = {
        temperature: 0.9, // Increased from 0.7 to 0.9 for more variety
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048, // Limit output for faster generation
      };

      console.log(`   ⏱️  Calling Gemini API for Emotions quiz...`);
      const startTime = Date.now();
      
      const result = await model.generateContent({
        contents: [{ role: 'user', parts: [{ text: prompt }] }],
        generationConfig: generationConfig,
      });
      const response = await result.response;
      const text = response.text().trim();
      
      const elapsedTime = ((Date.now() - startTime) / 1000).toFixed(2);
      console.log(`   ⏱️  Gemini API responded in ${elapsedTime} seconds`);

      // Parse JSON from response
      let questions;
      try {
        // Try to extract JSON from markdown code blocks if present
        const jsonMatch = text.match(/\[[\s\S]*\]/);
        if (jsonMatch) {
          questions = JSON.parse(jsonMatch[0]);
        } else {
          questions = JSON.parse(text);
        }
      } catch (parseError) {
        console.error('Error parsing emotions quiz questions JSON:', parseError);
        console.error('Response was:', text);
        return null;
      }

      // Validate questions structure
      if (!Array.isArray(questions) || questions.length === 0) {
        console.error('Invalid questions format: not an array or empty');
        return null;
      }

      // Validate and ensure correct format
      const validatedQuestions = questions
        .filter((q) => q && q.question && Array.isArray(q.options) && q.options.length >= 4)
        .map((q) => {
          // Ensure correct index is within bounds
          const correctIndex = Math.max(0, Math.min(q.correct || 0, q.options.length - 1));
          return {
            question: String(q.question || '').trim(),
            options: q.options.slice(0, 4).map(opt => String(opt).trim()), // Ensure exactly 4 options
            correct: correctIndex,
          };
        })
        .filter((q) => q.question.length > 0 && q.options.length === 4);

      if (validatedQuestions.length === 0) {
        console.error('No valid questions after validation');
        return null;
      }

      console.log(`✅ Validated ${validatedQuestions.length} Emotions quiz questions from Gemini AI`);
      return validatedQuestions;
    } catch (error) {
      console.error('Error generating emotions quiz:', error);
      return null;
    }
  }
}

module.exports = new QuizService();

