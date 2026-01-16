// AI-like Advice Engine (Fallback Only)
// This is a LAST RESORT fallback when Gemini AI is unavailable
// Uses sentiment analysis and pattern matching with varied templates
// Note: Gemini AI is the primary source - this only runs if Gemini fails

class AdviceEngine {
  constructor() {
    // Emotion patterns with weights (for sentiment analysis)
    this.emotionPatterns = {
      happy: {
        keywords: ['happy', 'saya', 'excited', 'joy', 'glad', 'masaya', 'delighted', 'cheerful', 'great', 'wonderful', 'amazing', 'fantastic', 'good', 'nice', 'feeling good', 'feeling great', 'mabuti', 'maganda'],
        weight: 1.0,
      },
      sad: {
        keywords: ['sad', 'lungkot', 'lonely', 'down', 'depressed', 'malungkot', 'unhappy', 'terrible', 'awful', 'bad', 'feeling sad', 'feeling down', 'feeling low', 'nalulungkot', 'malungkot'],
        weight: -1.0,
      },
      tired: {
        keywords: ['tired', 'pagod', 'drained', 'exhausted', 'worn', 'napapagod', 'fatigue', 'weary', 'sleepy', 'feeling tired', 'so tired', 'very tired', 'napapagod'],
        weight: -0.5,
      },
      angry: {
        keywords: ['angry', 'galit', 'mad', 'furious', 'irritated', 'nagagalit', 'annoyed', 'upset', 'frustrated', 'feeling angry', 'feeling mad', 'nagagalit'],
        weight: -0.8,
      },
      anxious: {
        keywords: ['anxious', 'worried', 'takot', 'nervous', 'afraid', 'kabado', 'fear', 'scared', 'panic', 'feeling anxious', 'feeling worried', 'kinakabahan', 'natatakot'],
        weight: -0.7,
      },
      grateful: {
        keywords: ['grateful', 'pasasalamat', 'thankful', 'appreciative', 'nagpapasalamat', 'blessed', 'thankful', 'gratitude'],
        weight: 0.8,
      },
      stressed: {
        keywords: ['stressed', 'stress', 'pressure', 'overwhelmed', 'napipressure', 'tension', 'strain', 'feeling stressed', 'under pressure'],
        weight: -0.6,
      },
    };

    // Advice templates (more flexible, AI-like responses)
    this.adviceTemplates = {
      happy: {
        en: [
          'That\'s wonderful to hear! Embrace this positive energy and share it with others. Use this moment to do something meaningful.',
          'I\'m glad you\'re feeling good! This is a great time to spread positivity and make the most of your day.',
          'Your happiness is beautiful! Channel this energy into something creative or helpful to others.',
        ],
        tl: [
          'Napakaganda naman! I-enjoy mo ang sandaling ito at ibahagi sa iba. Gamitin mo ang enerhiya na ito para gumawa ng makabuluhang bagay.',
          'Masaya ako para sa iyo! Ito ang tamang panahon para magbahagi ng positibong enerhiya.',
          'Ang iyong kaligayahan ay napakaganda! Gamitin mo ito para gumawa ng mabuti.',
        ],
      },
      sad: {
        en: [
          'I understand you\'re going through a difficult time. Remember, it\'s okay to feel this way. Reach out to someone you trust, and know that this feeling will pass.',
          'Your feelings are valid. Take a moment to breathe. You don\'t have to face this alone - there are people who care about you.',
          'It\'s completely normal to feel down sometimes. Be gentle with yourself today. Consider talking to someone or doing something that brings you comfort.',
        ],
        tl: [
          'Naiintindihan ko na mahirap ang nararamdaman mo ngayon. Tandaan, okay lang na makaramdam ng ganito. Kumonekta sa taong pinagkakatiwalaan mo, at lilipas din ito.',
          'Ang iyong nararamdaman ay valid. Huminga ka muna. Hindi mo kailangang harapin ito mag-isa - may mga taong nagmamahal sa iyo.',
          'Normal lang na makaramdam ng lungkot minsan. Maging mabait sa sarili mo ngayon. Subukan mong makipag-usap sa iba o gumawa ng bagay na nagpapagaan sa pakiramdam mo.',
        ],
      },
      tired: {
        en: [
          'You deserve rest. Listen to your body and take a break. Rest is not laziness - it\'s necessary for your well-being.',
          'Feeling tired is your body\'s way of telling you to slow down. Take some time to recharge and be kind to yourself.',
        ],
        tl: [
          'Karapat-dapat kang magpahinga. Pakinggan ang iyong katawan at magpahinga. Ang pahinga ay hindi pagiging tamad - ito ay kailangan para sa iyong kalusugan.',
          'Ang pagkapagod ay paraan ng iyong katawan na sabihin na magpahinga ka. Maglaan ng oras para mag-recharge.',
        ],
      },
      angry: {
        en: [
          'Anger is a natural emotion. Take a moment to pause and breathe deeply. Try to respond thoughtfully rather than react impulsively.',
          'It\'s okay to feel angry. Consider what\'s really bothering you and find a healthy way to express or address it.',
        ],
        tl: [
          'Normal na emosyon ang galit. Huminto ka muna at huminga nang malalim. Subukan mong sumagot nang mahinahon, hindi padalos-dalos.',
          'Okay lang na makaramdam ng galit. Isipin mo kung ano ang talagang nakakabother sa iyo at humanap ng healthy na paraan para ma-express ito.',
        ],
      },
      anxious: {
        en: [
          'When your mind feels noisy, focus on what you can control right now. Take one small step at a time. You\'ve got this.',
          'Anxiety can be overwhelming, but remember: you\'ve handled difficult situations before. Focus on your breathing and take things one moment at a time.',
        ],
        tl: [
          'Kapag maingay ang isip mo, ituon ang pansin sa mga bagay na kaya mong kontrolin ngayon. Isang maliit na hakbang lang sa isang pagkakataon. Kaya mo ito.',
          'Ang anxiety ay nakakabagabag, pero tandaan: nakayanan mo na ang mahihirap na sitwasyon dati. Huminga ka at isa-isahin lang ang mga bagay.',
        ],
      },
      grateful: {
        en: [
          'Gratitude is a beautiful feeling. Hold onto it and share it with others. Practicing gratitude can bring more positivity into your life.',
        ],
        tl: [
          'Napakaganda ng pakiramdam ng pasasalamat. Panatilihin mo ito at ibahagi sa iba. Ang pagpapasalamat ay nagdudulot ng mas maraming positibong enerhiya.',
        ],
      },
      stressed: {
        en: [
          'Stress can feel overwhelming, but remember you don\'t have to do everything at once. Prioritize what\'s most important and take breaks when needed.',
        ],
        tl: [
          'Ang stress ay nakakabagabag, pero tandaan na hindi mo kailangang gawin ang lahat nang sabay-sabay. Unahin ang mahahalaga at magpahinga kapag kailangan.',
        ],
      },
      default: {
        en: [
          'Thank you for sharing how you feel. Your emotions are valid, and it\'s important to acknowledge them. Take a deep breath, and remember you don\'t have to carry everything alone. There are people who care and are willing to help.',
          'I hear you. Whatever you\'re feeling right now, know that it\'s okay. Be gentle with yourself, and remember that difficult feelings don\'t last forever.',
        ],
        tl: [
          'Salamat sa pagbabahagi ng iyong nararamdaman. Ang iyong emosyon ay valid, at mahalaga na kilalanin mo ito. Huminga nang malalim, at tandaan na hindi mo kailangang pasanin ang lahat mag-isa. May mga taong nagmamahal at handang tumulong.',
          'Naririnig kita. Anuman ang nararamdaman mo ngayon, tandaan na okay lang yan. Maging mabait sa sarili mo, at tandaan na ang mahihirap na pakiramdam ay hindi magtatagal.',
        ],
      },
    };
  }

  // Analyze sentiment and detect primary emotion
  analyzeEmotion(text) {
    const lowerText = text.toLowerCase();
    const scores = {};

    // Calculate emotion scores
    for (const [emotion, pattern] of Object.entries(this.emotionPatterns)) {
      let score = 0;
      let matchCount = 0;
      
      for (const keyword of pattern.keywords) {
        // Use word boundary matching for better accuracy
        const regex = new RegExp(`\\b${keyword.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\w*\\b`, 'i');
        if (regex.test(lowerText)) {
          matchCount++;
          score += pattern.weight;
          // Boost score if keyword appears multiple times or with intensity words
          if (this.hasIntensityWords(lowerText, keyword)) {
            score += pattern.weight * 0.5;
          }
        }
      }
      
      // Boost score if multiple keywords match
      if (matchCount > 1) {
        score += pattern.weight * 0.3;
      }
      
      scores[emotion] = score;
    }

    // Find dominant emotion (lower threshold for better detection)
    const dominantEmotion = Object.entries(scores)
      .filter(([_, score]) => Math.abs(score) > 0.01) // Lower threshold
      .sort(([_, a], [__, b]) => Math.abs(b) - Math.abs(a))[0];

    // Debug logging (can be removed in production)
    if (process.env.DEBUG) {
      console.log('Emotion scores:', scores);
      console.log('Detected emotion:', dominantEmotion ? dominantEmotion[0] : 'default');
    }

    return dominantEmotion ? dominantEmotion[0] : 'default';
  }

  // Check for intensity words (very, so, really, etc.)
  hasIntensityWords(text, keyword) {
    const intensityWords = ['very', 'so', 'really', 'extremely', 'super', 'napaka', 'masyado', 'talaga'];
    const keywordIndex = text.indexOf(keyword);
    if (keywordIndex === -1) return false;

    const beforeKeyword = text.substring(Math.max(0, keywordIndex - 20), keywordIndex);
    return intensityWords.some(intensity => beforeKeyword.includes(intensity));
  }

  // Generate AI-like advice (Bible verses come from Gemini AI only, not hardcoded)
  generateAdvice(text, language = 'en') {
    const emotion = this.analyzeEmotion(text);
    const templates = this.adviceTemplates[emotion] || this.adviceTemplates.default;
    const langKey = language === 'tl' ? 'tl' : 'en';
    
    // Randomly select from available templates for variety (AI-like)
    const availableTemplates = templates[langKey] || templates['en'];
    
    if (!availableTemplates || availableTemplates.length === 0) {
      // Fallback to default if no templates available
      const defaultTemplates = this.adviceTemplates.default[langKey] || this.adviceTemplates.default['en'];
      return {
        advice: defaultTemplates[0],
        bibleVerse: null, // Bible verses only come from Gemini AI, not hardcoded
        detectedEmotion: 'default',
        confidence: 0.3,
      };
    }
    
    const randomIndex = Math.floor(Math.random() * availableTemplates.length);
    
    return {
      advice: availableTemplates[randomIndex],
      bibleVerse: null, // Bible verses only come from Gemini AI, not hardcoded
      detectedEmotion: emotion,
      confidence: this.calculateConfidence(text, emotion),
    };
  }

  // Calculate confidence score
  calculateConfidence(text, emotion) {
    if (emotion === 'default') return 0.3;
    
    const pattern = this.emotionPatterns[emotion];
    if (!pattern) return 0.5;

    const lowerText = text.toLowerCase();
    let matches = 0;
    for (const keyword of pattern.keywords) {
      const regex = new RegExp(`\\b${keyword}\\w*\\b`, 'i');
      if (regex.test(lowerText)) matches++;
    }

    // Higher confidence if multiple keywords match or text is longer
    const baseConfidence = Math.min(0.9, 0.5 + (matches * 0.1));
    return Math.min(0.95, baseConfidence + (text.length > 20 ? 0.1 : 0));
  }
}

module.exports = AdviceEngine;

