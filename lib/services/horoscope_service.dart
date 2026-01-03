import 'dart:math';

/// Service to generate daily horoscope predictions
/// Uses algorithmic generation based on planetary positions and date
class HoroscopeService {
  static final HoroscopeService _instance = HoroscopeService._internal();
  factory HoroscopeService() => _instance;
  HoroscopeService._internal();

  // Zodiac sign data
  static const List<Map<String, dynamic>> zodiacSigns = [
    {'name': 'Aries', 'symbol': '♈', 'hindi': 'मेष', 'element': 'Fire', 'ruler': 'Mars', 'dates': 'Mar 21 - Apr 19'},
    {'name': 'Taurus', 'symbol': '♉', 'hindi': 'वृषभ', 'element': 'Earth', 'ruler': 'Venus', 'dates': 'Apr 20 - May 20'},
    {'name': 'Gemini', 'symbol': '♊', 'hindi': 'मिथुन', 'element': 'Air', 'ruler': 'Mercury', 'dates': 'May 21 - Jun 20'},
    {'name': 'Cancer', 'symbol': '♋', 'hindi': 'कर्क', 'element': 'Water', 'ruler': 'Moon', 'dates': 'Jun 21 - Jul 22'},
    {'name': 'Leo', 'symbol': '♌', 'hindi': 'सिंह', 'element': 'Fire', 'ruler': 'Sun', 'dates': 'Jul 23 - Aug 22'},
    {'name': 'Virgo', 'symbol': '♍', 'hindi': 'कन्या', 'element': 'Earth', 'ruler': 'Mercury', 'dates': 'Aug 23 - Sep 22'},
    {'name': 'Libra', 'symbol': '♎', 'hindi': 'तुला', 'element': 'Air', 'ruler': 'Venus', 'dates': 'Sep 23 - Oct 22'},
    {'name': 'Scorpio', 'symbol': '♏', 'hindi': 'वृश्चिक', 'element': 'Water', 'ruler': 'Mars', 'dates': 'Oct 23 - Nov 21'},
    {'name': 'Sagittarius', 'symbol': '♐', 'hindi': 'धनु', 'element': 'Fire', 'ruler': 'Jupiter', 'dates': 'Nov 22 - Dec 21'},
    {'name': 'Capricorn', 'symbol': '♑', 'hindi': 'मकर', 'element': 'Earth', 'ruler': 'Saturn', 'dates': 'Dec 22 - Jan 19'},
    {'name': 'Aquarius', 'symbol': '♒', 'hindi': 'कुंभ', 'element': 'Air', 'ruler': 'Saturn', 'dates': 'Jan 20 - Feb 18'},
    {'name': 'Pisces', 'symbol': '♓', 'hindi': 'मीन', 'element': 'Water', 'ruler': 'Jupiter', 'dates': 'Feb 19 - Mar 20'},
  ];

  // Prediction templates by category
  static const Map<String, List<String>> _predictionTemplates = {
    'love': [
      'Romance is in the air today. Express your feelings openly.',
      'A meaningful conversation with your partner brings you closer.',
      'Single? An unexpected encounter may spark interest.',
      'Focus on building trust in your relationships today.',
      'Your charm is irresistible today. Use it wisely.',
      'Take time to appreciate the small gestures of love around you.',
      'Past misunderstandings may find resolution today.',
      'Your emotional intelligence helps navigate relationship matters.',
    ],
    'career': [
      'Professional growth opportunities are on the horizon.',
      'Your hard work will be noticed by superiors today.',
      'Networking brings valuable connections to your career.',
      'A creative solution to a work problem emerges.',
      'Stay focused on your goals despite minor distractions.',
      'Collaboration with colleagues leads to success.',
      'Your leadership skills shine in group settings.',
      'Financial decisions related to work require careful thought.',
    ],
    'health': [
      'Your energy levels are high - make the most of it.',
      'Pay attention to your dietary habits today.',
      'A short meditation session can restore balance.',
      'Physical activity brings mental clarity.',
      'Rest is important - don\'t overexert yourself.',
      'Hydration and nutrition should be priorities.',
      'Stress management techniques benefit you greatly.',
      'Listen to your body\'s signals today.',
    ],
    'finance': [
      'A favorable day for financial planning.',
      'Unexpected gains may come your way.',
      'Avoid impulsive spending decisions.',
      'Investments made today could be profitable.',
      'Review your budget and cut unnecessary expenses.',
      'A business opportunity deserves consideration.',
      'Save for the future rather than splurging today.',
      'Financial advice from elders proves valuable.',
    ],
    'general': [
      'Today brings opportunities for personal growth.',
      'Trust your intuition in decision-making.',
      'A positive attitude attracts good fortune.',
      'Patience is your ally in challenging situations.',
      'Creative pursuits bring joy and fulfillment.',
      'Family bonds strengthen through quality time.',
      'Spiritual practices enhance inner peace.',
      'Your optimism inspires those around you.',
    ],
  };

  static const List<String> _luckyColors = [
    'Red', 'Blue', 'Green', 'Yellow', 'White', 'Orange', 
    'Purple', 'Pink', 'Gold', 'Silver', 'Turquoise', 'Maroon'
  ];

  /// Get daily horoscope for a specific zodiac sign
  Map<String, dynamic> getDailyHoroscope(String signName, {DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final signIndex = zodiacSigns.indexWhere(
      (s) => s['name'].toString().toLowerCase() == signName.toLowerCase()
    );
    
    if (signIndex == -1) {
      return {'error': 'Invalid zodiac sign'};
    }
    
    final sign = zodiacSigns[signIndex];
    final seed = _generateSeed(signIndex, targetDate);
    final random = Random(seed);
    
    // Generate predictions
    final generalPrediction = _generatePrediction(random, 'general');
    final lovePrediction = _generatePrediction(random, 'love');
    final careerPrediction = _generatePrediction(random, 'career');
    final healthPrediction = _generatePrediction(random, 'health');
    final financePrediction = _generatePrediction(random, 'finance');
    
    // Generate ratings (1-5)
    final overallRating = (random.nextInt(3) + 3).toDouble(); // 3-5
    final loveRating = (random.nextInt(4) + 2).toDouble(); // 2-5
    final careerRating = (random.nextInt(4) + 2).toDouble();
    final healthRating = (random.nextInt(4) + 2).toDouble();
    
    // Lucky items
    final luckyNumber = random.nextInt(99) + 1;
    final luckyColor = _luckyColors[random.nextInt(_luckyColors.length)];
    final luckyTime = '${(random.nextInt(12) + 1)}:${random.nextInt(60).toString().padLeft(2, '0')} ${random.nextBool() ? 'AM' : 'PM'}';
    
    return {
      'sign': sign['name'],
      'symbol': sign['symbol'],
      'hindi': sign['hindi'],
      'element': sign['element'],
      'ruler': sign['ruler'],
      'dates': sign['dates'],
      'date': '${targetDate.day}/${targetDate.month}/${targetDate.year}',
      'predictions': {
        'general': generalPrediction,
        'love': lovePrediction,
        'career': careerPrediction,
        'health': healthPrediction,
        'finance': financePrediction,
      },
      'ratings': {
        'overall': overallRating,
        'love': loveRating,
        'career': careerRating,
        'health': healthRating,
      },
      'lucky': {
        'number': luckyNumber,
        'color': luckyColor,
        'time': luckyTime,
      },
      'compatibility': _getCompatibleSigns(signIndex, random),
    };
  }

  /// Get all horoscopes for today
  List<Map<String, dynamic>> getAllDailyHoroscopes({DateTime? date}) {
    return zodiacSigns.map((sign) => 
      getDailyHoroscope(sign['name'], date: date)
    ).toList();
  }

  /// Get weekly horoscope
  Map<String, dynamic> getWeeklyHoroscope(String signName) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final dailyHoroscopes = List.generate(7, (i) {
      final date = weekStart.add(Duration(days: i));
      return getDailyHoroscope(signName, date: date);
    });
    
    // Calculate weekly summary
    final avgRating = dailyHoroscopes.fold<double>(0, (sum, h) => 
      sum + (h['ratings']['overall'] as double)) / 7;
    
    return {
      'sign': signName,
      'weekStart': '${weekStart.day}/${weekStart.month}',
      'weekEnd': '${weekStart.add(Duration(days: 6)).day}/${weekStart.add(Duration(days: 6)).month}',
      'dailyPredictions': dailyHoroscopes,
      'averageRating': avgRating.toStringAsFixed(1),
      'weeklyAdvice': _getWeeklyAdvice(signName),
    };
  }

  /// Get monthly horoscope
  Map<String, dynamic> getMonthlyHoroscope(String signName, {int? month, int? year}) {
    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;
    
    final signIndex = zodiacSigns.indexWhere(
      (s) => s['name'].toString().toLowerCase() == signName.toLowerCase()
    );
    
    final seed = _generateSeed(signIndex, DateTime(targetYear, targetMonth, 15));
    final random = Random(seed);
    
    return {
      'sign': signName,
      'month': _getMonthName(targetMonth),
      'year': targetYear,
      'overview': _generateMonthlyOverview(random),
      'keyDates': _generateKeyDates(random, targetMonth, targetYear),
      'focus': {
        'love': _generatePrediction(random, 'love'),
        'career': _generatePrediction(random, 'career'),
        'health': _generatePrediction(random, 'health'),
        'finance': _generatePrediction(random, 'finance'),
      },
      'advice': _getMonthlyAdvice(signIndex, targetMonth),
    };
  }

  // Private helper methods
  int _generateSeed(int signIndex, DateTime date) {
    return signIndex * 10000 + date.year * 100 + date.month * 10 + date.day;
  }

  String _generatePrediction(Random random, String category) {
    final templates = _predictionTemplates[category] ?? _predictionTemplates['general']!;
    return templates[random.nextInt(templates.length)];
  }

  List<String> _getCompatibleSigns(int signIndex, Random random) {
    final compatible = <String>[];
    final count = random.nextInt(2) + 2; // 2-3 compatible signs
    
    // Element-based compatibility
    final element = zodiacSigns[signIndex]['element'];
    for (var i = 0; i < zodiacSigns.length && compatible.length < count; i++) {
      if (i != signIndex && zodiacSigns[i]['element'] == element) {
        compatible.add(zodiacSigns[i]['name']);
      }
    }
    
    // Add opposite sign
    final oppositeIndex = (signIndex + 6) % 12;
    if (!compatible.contains(zodiacSigns[oppositeIndex]['name'])) {
      compatible.add(zodiacSigns[oppositeIndex]['name']);
    }
    
    return compatible.take(3).toList();
  }

  String _getWeeklyAdvice(String signName) {
    final advices = [
      'Focus on self-improvement and personal goals this week.',
      'Strengthen bonds with family and close friends.',
      'Take calculated risks for career advancement.',
      'Balance work and leisure for optimal well-being.',
      'Trust your instincts in financial matters.',
    ];
    final index = signName.hashCode % advices.length;
    return advices[index.abs()];
  }

  String _generateMonthlyOverview(Random random) {
    final overviews = [
      'This month brings transformation and growth in multiple areas of life.',
      'Expect positive changes in career and relationships this month.',
      'A month of reflection and planning for future success.',
      'Opportunities for financial growth and personal development await.',
      'Focus on health and relationships for a balanced month ahead.',
    ];
    return overviews[random.nextInt(overviews.length)];
  }

  List<Map<String, dynamic>> _generateKeyDates(Random random, int month, int year) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final keyDates = <Map<String, dynamic>>[];
    
    for (var i = 0; i < 3; i++) {
      final day = random.nextInt(daysInMonth) + 1;
      keyDates.add({
        'date': '$day/${month}',
        'significance': ['Favorable for new beginnings', 'Good for financial decisions', 
                        'Ideal for relationship matters'][i],
      });
    }
    
    return keyDates;
  }

  String _getMonthlyAdvice(int signIndex, int month) {
    final element = zodiacSigns[signIndex]['element'];
    final ruler = zodiacSigns[signIndex]['ruler'];
    return 'As a $element sign ruled by $ruler, focus on channeling your natural strengths this month.';
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}

