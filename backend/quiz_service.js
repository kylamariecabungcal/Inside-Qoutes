// Quiz Question Generation Service using Groq AI
// 
// This service generates quiz questions dynamically using Groq AI.
// All quiz questions are AI-generated in real-time - no hardcoded questions.
// 
// Requirements:
// - GROQ_API_KEY must be set in .env file
//
const groqService = require('./groq_service');

class QuizService {
  /**
   * Generate Bible verse quiz questions using Groq AI
   * @param {string} difficulty - 'easy', 'medium', or 'hard'
   * @param {number} count - Number of questions to generate
   * @param {string} language - 'en' or 'tl'
   * @returns {Promise<Array>} Array of quiz questions (null if Groq not available)
   */
  async generateBibleVerseQuiz(difficulty, count = 5, language = 'en') {
    if (!groqService.isAvailable) {
      return null;
    }

    try {
      console.log(`   ⏱️  Calling Groq API for Bible verse quiz...`);
      const startTime = Date.now();
      
      const questions = await groqService.generateQuiz('bible', difficulty, count, language);
      
      const elapsedTime = ((Date.now() - startTime) / 1000).toFixed(2);
      console.log(`   ⏱️  Groq API responded in ${elapsedTime} seconds`);

      if (!questions) {
        console.error('No valid questions from Groq');
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

      console.log(`✅ Validated ${validatedQuestions.length} Bible verse quiz questions from Groq AI`);
      return validatedQuestions;
    } catch (error) {
      console.error('Error generating Bible verse quiz:', error);
      return null;
    }
  }

  /**
   * Generate Emotions quiz questions using Groq AI
   * @param {string} difficulty - 'easy', 'medium', or 'hard'
   * @param {number} count - Number of questions to generate
   * @param {string} language - 'en' or 'tl'
   * @returns {Promise<Array>} Array of quiz questions (null if Groq not available)
   */
  async generateEmotionsQuiz(difficulty, count = 5, language = 'en') {
    if (!groqService.isAvailable) {
      return null;
    }

    try {
      console.log(`   ⏱️  Calling Groq API for Emotions quiz...`);
      const startTime = Date.now();
      
      const questions = await groqService.generateQuiz('emotions', difficulty, count, language);
      
      const elapsedTime = ((Date.now() - startTime) / 1000).toFixed(2);
      console.log(`   ⏱️  Groq API responded in ${elapsedTime} seconds`);

      if (!questions) {
        console.error('No valid questions from Groq');
        return null;
      }

      // Validate and ensure correct format for emotions (4 options)
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

      console.log(`✅ Validated ${validatedQuestions.length} Emotions quiz questions from Groq AI`);
      return validatedQuestions;
    } catch (error) {
      console.error('Error generating emotions quiz:', error);
      return null;
    }
  }
}

module.exports = new QuizService();

