// Groq AI Service for generating personalized advice and quizzes
const Groq = require('groq-sdk');

class GroqService {
  constructor() {
    // Get API key from environment variable
    const apiKey = process.env.GROQ_API_KEY;
    
    if (!apiKey) {
      console.warn('⚠️  GROQ_API_KEY not found in environment variables. Groq AI will be disabled.');
      this.isAvailable = false;
      this.client = null;
      return;
    }

    try {
      this.client = new Groq({ apiKey });
      this.isAvailable = true;
      console.log('✅ Groq AI service initialized successfully');
    } catch (error) {
      console.error('❌ Error initializing Groq AI:', error);
      this.isAvailable = false;
      this.client = null;
    }
  }

  /**
   * Generate personalized advice using Groq AI
   * @param {string} text - User's feeling/emotion text
   * @param {string} language - Language code ('en' or 'tl')
   * @returns {Promise<{advice: string, bibleVerse: string, detectedEmotion: string, confidence: number}>}
   */
  async generateAdvice(text, language = 'en') {
    if (!this.isAvailable || !this.client) {
      return null; // Will fallback to local AI engine
    }

    try {
      const isTagalog = language === 'tl';
      const trimmedText = text.trim();
      const isEmpty = !trimmedText || trimmedText.length === 0;

      const systemPrompt = isTagalog
        ? `Ikaw ay isang mapagmahal at mapag-unawang AI counselor na nagbibigay ng personalized na payo at suporta na may kasamang Bible verse. 
Ang iyong layunin ay magbigay ng makabuluhan, praktikal, at nakakagaan ng loob na payo kasama ang isang relevant na Bible verse.

MGA PATNUBAY:
- Maging empathetic at understanding
- Magbigay ng praktikal at actionable na payo (2-3 sentences)
- LAGING magbigay ng isang relevant na Bible verse sa format: "Book Chapter:Verse - Verse Text"
- Pumili ng Bible verse na relevant sa nararamdaman ng user
- Gamitin ang Tagalog nang natural at malumanay
- Focus sa emotional support at practical steps
- Iwasan ang medical advice o diagnosis
- Kung walang input ang user, magbigay ng encouraging message na may Bible verse

FORMAT NG RESPONSE (LAGING SUNDIN):
Payo: [your advice here]

Bible Verse: [Book Chapter:Verse - Verse Text]`
        : `You are a caring and understanding AI counselor providing personalized advice and support with Bible verses. 
Your goal is to give meaningful, practical, and comforting advice along with a relevant Bible verse.

GUIDELINES:
- Be empathetic and understanding
- Provide practical and actionable advice (2-3 sentences)
- ALWAYS include a relevant Bible verse in format: "Book Chapter:Verse - Verse Text"
- Choose a Bible verse that is relevant to the user's feelings
- Keep advice to 2-3 sentences, not too long
- Focus on emotional support and practical steps
- Avoid medical advice or diagnosis
- If user has no input, provide an encouraging message with a Bible verse

RESPONSE FORMAT (ALWAYS FOLLOW):
Advice: [your advice here]

Bible Verse: [Book Chapter:Verse - Verse Text]`;

      let userPrompt;
      if (isEmpty) {
        userPrompt = isTagalog
          ? `Ang user ay hindi pa nagbigay ng input. Magbigay ng encouraging at welcoming na message na hikayatin silang magbahagi ng kanilang nararamdaman. Kasama ang isang relevant na Bible verse. Gawin itong personal at hindi generic.

Format:
Payo: [your advice]

Bible Verse: [Book Chapter:Verse - Verse Text]`
          : `The user hasn't provided any input yet. Give an encouraging and welcoming message that invites them to share their feelings. Include a relevant Bible verse. Make it personal and not generic.

Format:
Advice: [your advice]

Bible Verse: [Book Chapter:Verse - Verse Text]`;
      } else {
        userPrompt = isTagalog
          ? `Nararamdaman ng user: "${trimmedText}"

Magbigay ng personalized na payo na:
- Nakakagaan ng loob
- Praktikal at actionable
- Relevant sa nararamdaman nila
- Hindi generic
- May kasamang relevant na Bible verse

Format:
Payo: [your advice]

Bible Verse: [Book Chapter:Verse - Verse Text]`
          : `User is feeling: "${trimmedText}"

Provide personalized advice that is:
- Comforting and supportive
- Practical and actionable
- Relevant to their feelings
- Not generic
- Include a relevant Bible verse

Format:
Advice: [your advice]

Bible Verse: [Book Chapter:Verse - Verse Text]`;
      }

      console.log('🤖 Calling Groq API for advice...');
      
      const message = await this.client.chat.completions.create({
        messages: [
          {
            role: 'system',
            content: systemPrompt,
          },
          {
            role: 'user',
            content: userPrompt,
          },
        ],
        model: 'llama-3.3-70b-versatile',
        max_tokens: 500,
      });

      const fullResponse = message.choices[0].message.content.trim();

      // Parse the response to extract advice and Bible verse
      const { advice, bibleVerse } = this.parseAdviceResponse(fullResponse, isTagalog);

      // Detect emotion from the advice/input
      const detectedEmotion = isEmpty ? 'neutral' : this.detectEmotionFromText(trimmedText);
      
      return {
        advice: advice,
        bibleVerse: bibleVerse,
        detectedEmotion: detectedEmotion,
        confidence: 0.85,
      };
    } catch (error) {
      console.error('Error generating advice with Groq:', error);
      return null; // Fallback to local AI engine
    }
  }

  /**
   * Generate quiz questions using Groq AI
   * @param {string} type - 'bible' or 'emotions'
   * @param {string} difficulty - 'easy', 'medium', or 'hard'
   * @param {number} count - Number of questions
   * @param {string} language - 'en' or 'tl'
   * @returns {Promise<Array>} Array of quiz questions
   */
  async generateQuiz(type, difficulty, count = 5, language = 'en') {
    if (!this.isAvailable || !this.client) {
      return null;
    }

    try {
      const isTagalog = language === 'tl';
      const timestamp = Date.now();
      const randomSeed = Math.floor(Math.random() * 1000000);

      let prompt;
      if (type === 'bible') {
        const difficultyDesc = isTagalog
          ? { easy: 'mga kilalang Bible verse', medium: 'mga mas detalyadong Bible verse', hard: 'mga advanced na Bible verse' }
          : { easy: 'well-known Bible verses', medium: 'more detailed Bible verses', hard: 'advanced Bible verses' };

        prompt = isTagalog
          ? `Gumawa ng ${count} na high-quality Bible verse quiz questions na ${difficultyDesc[difficulty]}.

Para sa bawat tanong:
1. Magbigay ng isang kumpletong Bible verse text
2. Magbigay ng eksaktong 3 options: "Book Chapter:Verse"
3. Isa lang ang tamang sagot - accurate na Bible reference
4. Ang ibang 2 options ay believable pero mali
5. Dapat iba-iba ang mga tanong (timestamp: ${timestamp}, seed: ${randomSeed})

Format ng response (JSON array ONLY):
[
  {
    "question": "Complete Bible verse text here",
    "options": ["Book Chapter:Verse", "Book Chapter:Verse", "Book Chapter:Verse"],
    "correct": 0
  }
]

Generate exactly ${count} questions. Return ONLY the JSON array, nothing else.`
          : `Create ${count} high-quality Bible verse quiz questions that are ${difficultyDesc[difficulty]}.

For each question:
1. Provide a complete Bible verse text
2. Provide exactly 3 options in format: "Book Chapter:Verse"
3. Only one correct answer - accurate Bible reference
4. The other 2 options should be believable but wrong
5. Make questions diverse (timestamp: ${timestamp}, seed: ${randomSeed})

Response format (JSON array ONLY):
[
  {
    "question": "Complete Bible verse text here",
    "options": ["Book Chapter:Verse", "Book Chapter:Verse", "Book Chapter:Verse"],
    "correct": 0
  }
]

Generate exactly ${count} questions. Return ONLY the JSON array, nothing else.`;
      } else {
        const difficultyDesc = isTagalog
          ? { easy: 'mga basic na emosyon', medium: 'mga mas kumplikadong emosyon', hard: 'mga advanced na emosyon' }
          : { easy: 'basic emotions', medium: 'more complex emotions', hard: 'advanced emotions' };

        prompt = isTagalog
          ? `Gumawa ng ${count} na high-quality emotions quiz questions na ${difficultyDesc[difficulty]}.

Para sa bawat tanong:
1. Magbigay ng isang scenario o situasyon
2. Magbigay ng 4 emotional responses bilang options
3. Isa lang ang best response
4. Ang ibang 3 ay reasonable pero hindi optimal

Format ng response (JSON array ONLY):
[
  {
    "question": "Emotional scenario here",
    "options": ["Response 1", "Response 2", "Response 3", "Response 4"],
    "correct": 0,
    "explanation": "Why this is the best response"
  }
]

Generate exactly ${count} questions. Return ONLY the JSON array, nothing else.`
          : `Create ${count} high-quality emotions quiz questions that are ${difficultyDesc[difficulty]}.

For each question:
1. Provide an emotional scenario or situation
2. Provide 4 emotional responses as options
3. One is the best response
4. The other 3 are reasonable but not optimal

Response format (JSON array ONLY):
[
  {
    "question": "Emotional scenario here",
    "options": ["Response 1", "Response 2", "Response 3", "Response 4"],
    "correct": 0,
    "explanation": "Why this is the best response"
  }
]

Generate exactly ${count} questions. Return ONLY the JSON array, nothing else.`;
      }

      console.log(`   ⏱️  Calling Groq API for ${type} quiz...`);
      
      const message = await this.client.chat.completions.create({
        messages: [
          {
            role: 'user',
            content: prompt,
          },
        ],
        model: 'llama-3.3-70b-versatile',
        max_tokens: 2000,
      });

      const responseText = message.choices[0].message.content.trim();

      // Extract JSON from response
      const jsonMatch = responseText.match(/\[[\s\S]*\]/);
      if (!jsonMatch) {
        console.error('❌ Failed to parse quiz JSON from Groq response');
        return null;
      }

      const questions = JSON.parse(jsonMatch[0]);
      console.log(`✅ Generated ${questions.length} ${type} quiz questions with Groq`);
      return questions;
    } catch (error) {
      console.error(`Error generating ${type} quiz with Groq:`, error);
      return null;
    }
  }

  /**
   * Parse the AI response to extract advice and Bible verse
   */
  parseAdviceResponse(response, isTagalog) {
    let advice = response;
    let bibleVerse = null;

    // Try to extract Bible verse from the response
    const versePatterns = [
      /Bible Verse:\s*(.+?)(?:\n|$)/i,
      /Bible verse:\s*(.+?)(?:\n|$)/i,
      /Verse:\s*(.+?)(?:\n|$)/i,
      /([A-Za-z]+ \d+:\d+[-\d]*\s*-?\s*.+)/,
    ];

    for (const pattern of versePatterns) {
      const match = response.match(pattern);
      if (match) {
        bibleVerse = match[1].trim();
        advice = response.replace(pattern, '').trim();
        break;
      }
    }

    // Clean up advice text
    advice = advice.replace(/^(Advice|Payo):\s*/i, '').trim();
    
    if (!bibleVerse) {
      console.log('⚠️  No Bible verse found in Groq response');
    } else {
      console.log('✅ Bible verse extracted:', bibleVerse.substring(0, 50) + '...');
    }

    return { advice, bibleVerse };
  }

  /**
   * Simple emotion detection
   */
  detectEmotionFromText(text) {
    const lowerText = text.toLowerCase();
    
    if (lowerText.includes('happy') || lowerText.includes('saya') || lowerText.includes('masaya') || lowerText.includes('glad')) {
      return 'happy';
    }
    if (lowerText.includes('sad') || lowerText.includes('lungkot') || lowerText.includes('lonely')) {
      return 'sad';
    }
    if (lowerText.includes('tired') || lowerText.includes('pagod') || lowerText.includes('exhausted')) {
      return 'tired';
    }
    if (lowerText.includes('angry') || lowerText.includes('galit') || lowerText.includes('mad')) {
      return 'angry';
    }
    if (lowerText.includes('anxious') || lowerText.includes('worried') || lowerText.includes('takot')) {
      return 'anxious';
    }
    
    return 'default';
  }
}

// Export singleton instance
const groqService = new GroqService();
module.exports = groqService;
