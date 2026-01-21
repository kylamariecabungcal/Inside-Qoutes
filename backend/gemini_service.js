// Google Gemini AI Service for generating personalized advice
const { GoogleGenerativeAI } = require('@google/generative-ai');

class GeminiService {
  constructor() {
    // Get API key from environment variable
    const apiKey = process.env.GEMINI_API_KEY;
    
    if (!apiKey) {
      console.warn('⚠️  GEMINI_API_KEY not found in environment variables. Gemini AI will be disabled.');
      this.isAvailable = false;
      this.genAI = null;
      return;
    }

    try {
      this.genAI = new GoogleGenerativeAI(apiKey);
      this.isAvailable = true;
      console.log('✅ Gemini AI service initialized successfully');
    } catch (error) {
      console.error('❌ Error initializing Gemini AI:', error);
      this.isAvailable = false;
      this.genAI = null;
    }
  }

  /**
   * Generate personalized advice using Gemini AI
   * @param {string} text - User's feeling/emotion text
   * @param {string} language - Language code ('en' or 'tl')
   * @returns {Promise<{advice: string, detectedEmotion: string, confidence: number}>}
   */
  async generateAdvice(text, language = 'en') {
    if (!this.isAvailable || !this.genAI) {
      return null; // Will fallback to local AI engine
    }

    try {
      const model = this.genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });
      
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

      const prompt = `${systemPrompt}\n\n${userPrompt}`;

      const result = await model.generateContent(prompt);
      const response = await result.response;
      const fullResponse = response.text().trim();

      // Parse the response to extract advice and Bible verse
      const { advice, bibleVerse } = this.parseAdviceResponse(fullResponse, isTagalog);

      // Detect emotion from the advice/input (simple detection)
      const detectedEmotion = isEmpty ? 'neutral' : this.detectEmotionFromText(trimmedText);
      
      return {
        advice: advice,
        bibleVerse: bibleVerse,
        detectedEmotion: detectedEmotion,
        confidence: 0.9, // High confidence for Gemini responses
      };
    } catch (error) {
      console.error('Error generating advice with Gemini:', error);
      return null; // Fallback to local AI engine
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
      /([A-Za-z]+ \d+:\d+[-\d]*\s*-?\s*.+)/, // Pattern: Book Chapter:Verse - Text
    ];

    for (const pattern of versePatterns) {
      const match = response.match(pattern);
      if (match) {
        bibleVerse = match[1].trim();
        // Remove the verse from advice text
        advice = response.replace(pattern, '').trim();
        break;
      }
    }

    // If no verse found, try to find any verse-like pattern in the response
    if (!bibleVerse) {
      const verseLikePattern = /([A-Za-z]+ \d+:\d+[-\d]*\s*-?\s*.+)/;
      const match = response.match(verseLikePattern);
      if (match) {
        bibleVerse = match[1].trim();
        advice = response.replace(verseLikePattern, '').trim();
      }
    }

    // Clean up advice text - remove "Advice:" or "Payo:" prefix if present
    advice = advice.replace(/^(Advice|Payo):\s*/i, '').trim();
    
    // If still no verse found, try to extract from the end of response
    if (!bibleVerse) {
      const lines = response.split('\n');
      for (let i = lines.length - 1; i >= 0; i--) {
        const line = lines[i].trim();
        if (line.match(/[A-Za-z]+ \d+:\d+/)) {
          bibleVerse = line;
          advice = lines.slice(0, i).join('\n').trim();
          break;
        }
      }
    }

    // If no verse was found, try more aggressive parsing
    if (!bibleVerse) {
      // Try to find verse in any line
      const lines = response.split('\n');
      for (const line of lines) {
        // Look for patterns like "John 3:16" or "Psalm 23:1"
        const verseMatch = line.match(/([A-Za-z]+(?:\s+[A-Za-z]+)?\s+\d+:\d+(?:-\d+)?)\s*-?\s*(.+)/);
        if (verseMatch) {
          bibleVerse = `${verseMatch[1]} - ${verseMatch[2].trim()}`;
          // Remove from advice
          advice = response.replace(line, '').trim();
          break;
        }
      }
    }

    // If still no verse, log warning but don't add hardcoded fallback
    if (!bibleVerse) {
      console.log('⚠️  No Bible verse found in Gemini response');
      console.log('   Response was:', response.substring(0, 200));
      // Don't add hardcoded fallback - Bible verses must come from AI/Gemini
    } else {
      console.log('✅ Bible verse extracted:', bibleVerse.substring(0, 50) + '...');
    }

    return { advice, bibleVerse };
  }

  /**
   * Simple emotion detection for metadata
   */
  detectEmotionFromText(text) {
    const lowerText = text.toLowerCase();
    
    if (lowerText.includes('happy') || lowerText.includes('saya') || lowerText.includes('masaya') || lowerText.includes('glad') || lowerText.includes('excited')) {
      return 'happy';
    }
    if (lowerText.includes('sad') || lowerText.includes('lungkot') || lowerText.includes('lonely') || lowerText.includes('down')) {
      return 'sad';
    }
    if (lowerText.includes('tired') || lowerText.includes('pagod') || lowerText.includes('exhausted')) {
      return 'tired';
    }
    if (lowerText.includes('angry') || lowerText.includes('galit') || lowerText.includes('mad') || lowerText.includes('frustrated')) {
      return 'angry';
    }
    if (lowerText.includes('anxious') || lowerText.includes('worried') || lowerText.includes('takot') || lowerText.includes('nervous')) {
      return 'anxious';
    }
    if (lowerText.includes('grateful') || lowerText.includes('thankful') || lowerText.includes('pasasalamat')) {
      return 'grateful';
    }
    if (lowerText.includes('stressed') || lowerText.includes('pressure') || lowerText.includes('overwhelmed')) {
      return 'stressed';
    }
    
    return 'default';
  }
}

// Export singleton instance
const geminiService = new GeminiService();
module.exports = geminiService;

