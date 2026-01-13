import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tip.dart';

class TipsProvider extends ChangeNotifier {
  static const String _lastTipDateKey = 'last_tip_date';
  static const String _currentTipIndexKey = 'current_tip_index';

  final List<MenopauseTip> _tips = [];
  MenopauseTip? _todaysTip;
  final Random _random = Random();
  late SharedPreferences _prefs;

  MenopauseTip? get todaysTip => _todaysTip;
  List<MenopauseTip> get allTips => List.unmodifiable(_tips);

  TipsProvider() {
    _initializeTips();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    await _checkAndUpdateDailyTip();
  }

  void _initializeTips() {
    _tips.addAll([
      // Hydration & Hot Flash Management
      MenopauseTip(
        id: 'tip_001',
        titleEn: 'Stay Hydrated',
        titleBn: 'পানি পান করুন',
        contentEn:
            'Drink 8-10 glasses of water daily to reduce hot flashes and maintain healthy skin during menopause.',
        contentBn:
            'হট ফ্ল্যাশ কমাতে এবং ত্বক সুস্থ রাখতে দিনে ৮-১০ গ্লাস পানি পান করুন।',
        category: 'hydration',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_002',
        titleEn: 'Layer Your Clothing',
        titleBn: 'স্তরে স্তরে পোশাক পরুন',
        contentEn:
            'Wear breathable, layered clothing to easily adjust when hot flashes occur.',
        contentBn:
            'হট ফ্ল্যাশের সময় সহজে সামঞ্জস্য করতে শ্বাসযোগ্য, স্তরে স্তরে পোশাক পরুন।',
        category: 'lifestyle',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_003',
        titleEn: 'Cool Environment',
        titleBn: 'ঠান্ডা পরিবেশ',
        contentEn:
            'Keep your bedroom cool and well-ventilated for better sleep during menopause.',
        contentBn:
            'মেনোপজের সময় ভালো ঘুমের জন্য আপনার শোবার ঘর ঠান্ডা এবং বায়ু চলাচলযুক্ত রাখুন।',
        category: 'sleep',
        createdAt: DateTime.now(),
      ),

      // Nutrition & Diet
      MenopauseTip(
        id: 'tip_004',
        titleEn: 'Calcium Rich Foods',
        titleBn: 'ক্যালসিয়াম সমৃদ্ধ খাবার',
        contentEn:
            'Include dairy, leafy greens, and almonds in your diet to maintain bone health.',
        contentBn:
            'হাড়ের স্বাস্থ্য বজায় রাখতে দুগ্ধজাত খাবার, পাতাযুক্ত শাকসবজি এবং বাদাম খান।',
        category: 'nutrition',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_005',
        titleEn: 'Limit Caffeine',
        titleBn: 'ক্যাফেইন সীমিত করুন',
        contentEn:
            'Reduce coffee and tea intake as caffeine can trigger hot flashes and disrupt sleep.',
        contentBn:
            'কফি এবং চা কম পান করুন কারণ ক্যাফেইন হট ফ্ল্যাশ বাড়াতে এবং ঘুমের ব্যাঘাত ঘটাতে পারে।',
        category: 'nutrition',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_006',
        titleEn: 'Eat Phytoestrogens',
        titleBn: 'ফাইটোইস্ট্রোজেন খান',
        contentEn:
            'Include soy products, flaxseeds, and lentils that contain natural plant estrogens.',
        contentBn:
            'প্রাকৃতিক উদ্ভিদ ইস্ট্রোজেন সমৃদ্ধ সয়া পণ্য, তিসির বীজ এবং মসুর ডাল খান।',
        category: 'nutrition',
        createdAt: DateTime.now(),
      ),

      // Exercise & Movement
      MenopauseTip(
        id: 'tip_007',
        titleEn: 'Daily Walking',
        titleBn: 'প্রতিদিন হাঁটা',
        contentEn:
            'Walk for 30 minutes daily to improve mood, maintain weight, and strengthen bones.',
        contentBn:
            'মেজাজ ভালো রাখতে, ওজন নিয়ন্ত্রণে এবং হাড় মজবুত করতে প্রতিদিন ৩০ মিনিট হাঁটুন।',
        category: 'exercise',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_008',
        titleEn: 'Strength Training',
        titleBn: 'শক্তি প্রশিক্ষণ',
        contentEn:
            'Include light weight exercises twice a week to prevent muscle loss and osteoporosis.',
        contentBn:
            'পেশীর ক্ষয় এবং অস্টিওপোরোসিস প্রতিরোধে সপ্তাহে দুইবার হালকা ওজন ব্যায়াম করুন।',
        category: 'exercise',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_009',
        titleEn: 'Yoga for Balance',
        titleBn: 'ভারসাম্যের জন্য যোগা',
        contentEn:
            'Practice yoga to improve flexibility, balance, and reduce stress during menopause.',
        contentBn:
            'মেনোপজের সময় নমনীয়তা, ভারসাম্য বাড়াতে এবং চাপ কমাতে যোগাযোগ করুন।',
        category: 'exercise',
        createdAt: DateTime.now(),
      ),

      // Mental Health & Mood
      MenopauseTip(
        id: 'tip_010',
        titleEn: 'Deep Breathing',
        titleBn: 'গভীর শ্বাস',
        contentEn:
            'Practice deep breathing exercises to manage stress and reduce hot flash intensity.',
        contentBn:
            'চাপ নিয়ন্ত্রণ এবং হট ফ্ল্যাশের তীব্রতা কমাতে গভীর শ্বাসের ব্যায়াম করুন।',
        category: 'mental_health',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_011',
        titleEn: 'Meditation Time',
        titleBn: 'মেডিটেশনের সময়',
        contentEn:
            'Spend 10-15 minutes daily in meditation to improve emotional well-being.',
        contentBn:
            'আবেগিক সুস্বাস্থ্যের জন্য প্রতিদিন ১০-১৫ মিনিট মেডিটেশন করুন।',
        category: 'mental_health',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_012',
        titleEn: 'Social Connection',
        titleBn: 'সামাজিক যোগাযোগ',
        contentEn:
            'Stay connected with friends and family to combat feelings of isolation during menopause.',
        contentBn:
            'মেনোপজের সময় একাকীত্বের অনুভূতি দূর করতে বন্ধু ও পরিবারের সাথে যোগাযোগ রাখুন।',
        category: 'mental_health',
        createdAt: DateTime.now(),
      ),

      // Sleep & Rest
      MenopauseTip(
        id: 'tip_013',
        titleEn: 'Sleep Schedule',
        titleBn: 'ঘুমের সময়সূচি',
        contentEn:
            'Maintain a consistent sleep schedule by going to bed and waking up at the same time daily.',
        contentBn:
            'প্রতিদিন একই সময়ে ঘুমাতে যাওয়া ও ঘুম থেকে ওঠার মাধ্যমে ঘুমের সময়সূচি বজায় রাখুন।',
        category: 'sleep',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_014',
        titleEn: 'No Screen Before Bed',
        titleBn: 'ঘুমের আগে স্ক্রিন নয়',
        contentEn:
            'Avoid screens 1-2 hours before bedtime to improve sleep quality during menopause.',
        contentBn:
            'মেনোপজের সময় ঘুমের মান উন্নত করতে ঘুমের ১-২ ঘন্টা আগে স্ক্রিন এড়িয়ে চলুন।',
        category: 'sleep',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_015',
        titleEn: 'Relaxing Bath',
        titleBn: 'আরামদায়ক স্নান',
        contentEn:
            'Take a warm bath with lavender or chamomile before bed for better relaxation.',
        contentBn:
            'ভালো বিশ্রামের জন্য ঘুমের আগে ল্যাভেন্ডার বা ক্যামোমাইল দিয়ে গরম পানিতে স্নান করুন।',
        category: 'sleep',
        createdAt: DateTime.now(),
      ),

      // Skin & Hair Care
      MenopauseTip(
        id: 'tip_016',
        titleEn: 'Moisturize Daily',
        titleBn: 'প্রতিদিন ময়েশ্চারাইজ করুন',
        contentEn:
            'Use a rich moisturizer twice daily to combat dry skin caused by declining estrogen.',
        contentBn:
            'ইস্ট্রোজেন কমে যাওয়ার কারণে শুষ্ক ত্বকের বিরুদ্ধে লড়তে দিনে দুইবার পুষ্টিকর ময়েশ্চারাইজার ব্যবহার করুন।',
        category: 'skin_care',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_017',
        titleEn: 'Sun Protection',
        titleBn: 'সূর্য সুরক্ষা',
        contentEn:
            'Apply SPF 30+ sunscreen daily as menopausal skin is more sensitive to UV damage.',
        contentBn:
            'মেনোপজাল ত্বক UV ক্ষতির জন্য বেশি সংবেদনশীল তাই প্রতিদিন SPF 30+ সানস্ক্রিন ব্যবহার করুন।',
        category: 'skin_care',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_018',
        titleEn: 'Gentle Hair Care',
        titleBn: 'মৃদু চুলের যত্ন',
        contentEn:
            'Use sulfate-free shampoos and avoid excessive heat styling to prevent hair thinning.',
        contentBn:
            'চুল পাতলা হওয়া রোধ করতে সালফেট-মুক্ত শ্যাম্পু ব্যবহার করুন এবং অতিরিক্ত তাপ স্টাইলিং এড়িয়ে চলুন।',
        category: 'skin_care',
        createdAt: DateTime.now(),
      ),

      // Hormone Support
      MenopauseTip(
        id: 'tip_019',
        titleEn: 'Herbal Support',
        titleBn: 'ভেষজ সহায়তা',
        contentEn:
            'Consider black cohosh or red clover supplements after consulting with your doctor.',
        contentBn:
            'আপনার ডাক্তারের পরামর্শের পর ব্ল্যাক কোহোশ বা লাল ক্লোভার সাপ্লিমেন্ট বিবেচনা করুন।',
        category: 'supplements',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_020',
        titleEn: 'Vitamin D3',
        titleBn: 'ভিটামিন ডি৩',
        contentEn:
            'Take vitamin D3 supplements to support bone health and mood regulation.',
        contentBn:
            'হাড়ের স্বাস্থ্য এবং মেজাজ নিয়ন্ত্রণে সহায়তার জন্য ভিটামিন ডি৩ সাপ্লিমেন্ট নিন।',
        category: 'supplements',
        createdAt: DateTime.now(),
      ),

      // Weight Management
      MenopauseTip(
        id: 'tip_021',
        titleEn: 'Portion Control',
        titleBn: 'পরিমাণ নিয়ন্ত্রণ',
        contentEn:
            'Use smaller plates and practice mindful eating to manage menopausal weight gain.',
        contentBn:
            'মেনোপজাল ওজন বৃদ্ধি নিয়ন্ত্রণে ছোট প্লেট ব্যবহার করুন এবং সচেতন খাওয়ার অভ্যাস করুন।',
        category: 'weight_management',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_022',
        titleEn: 'Fiber Rich Diet',
        titleBn: 'ফাইবার সমৃদ্ধ খাদ্য',
        contentEn:
            'Include plenty of vegetables, fruits, and whole grains to support healthy digestion.',
        contentBn:
            'স্বাস্থ্যকর হজমের সহায়তার জন্য প্রচুর শাকসবজি, ফল এবং গোটা শস্য অন্তর্ভুক্ত করুন।',
        category: 'nutrition',
        createdAt: DateTime.now(),
      ),

      // Heart Health
      MenopauseTip(
        id: 'tip_023',
        titleEn: 'Heart Healthy Fats',
        titleBn: 'হৃদযন্ত্রের জন্য স্বাস্থ্যকর চর্বি',
        contentEn:
            'Include omega-3 rich foods like fish, walnuts, and flaxseeds for heart health.',
        contentBn:
            'হৃদযন্ত্রের স্বাস্থ্যের জন্য মাছ, আখরোট এবং তিসির বীজের মতো ওমেগা-৩ সমৃদ্ধ খাবার অন্তর্ভুক্ত করুন।',
        category: 'nutrition',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_024',
        titleEn: 'Regular Check-ups',
        titleBn: 'নিয়মিত চেক-আপ',
        contentEn:
            'Schedule regular health screenings including bone density and heart health checks.',
        contentBn:
            'হাড়ের ঘনত্ব এবং হৃদযন্ত্রের স্বাস্থ্য পরীক্ষা সহ নিয়মিত স্বাস্থ্য স্ক্রিনিং এর সময় নির্ধারণ করুন।',
        category: 'health_monitoring',
        createdAt: DateTime.now(),
      ),

      // Stress Management
      MenopauseTip(
        id: 'tip_025',
        titleEn: 'Hobby Time',
        titleBn: 'শখের সময়',
        contentEn:
            'Engage in hobbies you enjoy to reduce stress and maintain mental well-being.',
        contentBn:
            'চাপ কমাতে এবং মানসিক সুস্বাস্থ্য বজায় রাখতে আপনার পছন্দের শখে নিয়োজিত থাকুন।',
        category: 'mental_health',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_026',
        titleEn: 'Nature Walks',
        titleBn: 'প্রকৃতিতে হাঁটা',
        contentEn:
            'Spend time in nature to reduce cortisol levels and improve overall mood.',
        contentBn:
            'কর্টিসল মাত্রা কমাতে এবং সামগ্রিক মেজাজ উন্নত করতে প্রকৃতিতে সময় কাটান।',
        category: 'mental_health',
        createdAt: DateTime.now(),
      ),

      // Relationships
      MenopauseTip(
        id: 'tip_027',
        titleEn: 'Open Communication',
        titleBn: 'খোলা যোগাযোগ',
        contentEn:
            'Talk openly with your partner about menopausal changes to maintain intimacy.',
        contentBn:
            'ঘনিষ্ঠতা বজায় রাখতে আপনার সঙ্গীর সাথে মেনোপজাল পরিবর্তন নিয়ে খোলামেলা কথা বলুন।',
        category: 'relationships',
        createdAt: DateTime.now(),
      ),

      MenopauseTip(
        id: 'tip_028',
        titleEn: 'Support Groups',
        titleBn: 'সহায়তা গ্রুপ',
        contentEn:
            'Join menopause support groups to share experiences and learn coping strategies.',
        contentBn:
            'অভিজ্ঞতা ভাগাভাগি এবং মোকাবেলার কৌশল শিখতে মেনোপজ সহায়তা গ্রুপে যোগ দিন।',
        category: 'mental_health',
        createdAt: DateTime.now(),
      ),

      // Bone Health
      MenopauseTip(
        id: 'tip_029',
        titleEn: 'Weight Bearing Exercise',
        titleBn: 'ওজন বহনকারী ব্যায়াম',
        contentEn:
            'Include weight-bearing exercises like dancing or climbing stairs for bone strength.',
        contentBn:
            'হাড়ের শক্তির জন্য নাচ বা সিঁড়ি বেয়ে ওঠার মতো ওজন বহনকারী ব্যায়াম অন্তর্ভুক্ত করুন।',
        category: 'exercise',
        createdAt: DateTime.now(),
      ),

      // Self-Care
      MenopauseTip(
        id: 'tip_030',
        titleEn: 'Self-Compassion',
        titleBn: 'নিজের প্রতি করুণা',
        contentEn:
            'Be patient and kind to yourself during this natural life transition. You\'re doing great!',
        contentBn:
            'এই প্রাকৃতিক জীবন পরিবর্তনের সময় নিজের প্রতি ধৈর্যশীল এবং দয়ালু হন। আপনি ভালো করছেন!',
        category: 'self_care',
        createdAt: DateTime.now(),
      ),
    ]);
  }

  Future<void> _checkAndUpdateDailyTip() async {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    final lastTipDate = _prefs.getString(_lastTipDateKey);

    // If it's a new day or no tip has been set, select a new random tip
    if (lastTipDate != todayString) {
      await _selectRandomTip();
      await _prefs.setString(_lastTipDateKey, todayString);
    } else {
      // Load the existing tip for today
      final tipIndex = _prefs.getInt(_currentTipIndexKey) ?? 0;
      if (tipIndex < _tips.length) {
        _todaysTip = _tips[tipIndex];
        notifyListeners();
      }
    }
  }

  Future<void> _selectRandomTip() async {
    if (_tips.isNotEmpty) {
      // Generate a seed based on current date to ensure consistency throughout the day
      final today = DateTime.now();
      final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
      final seed = today.year * 1000 + dayOfYear;

      final random = Random(seed);
      final randomIndex = random.nextInt(_tips.length);

      _todaysTip = _tips[randomIndex];
      await _prefs.setInt(_currentTipIndexKey, randomIndex);
      notifyListeners();
    }
  }

  // Force refresh tip (useful for testing or manual refresh)
  Future<void> refreshTip() async {
    await _selectRandomTip();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    await _prefs.setString(_lastTipDateKey, todayString);
  }

  // Get tips by category
  List<MenopauseTip> getTipsByCategory(String category) {
    return _tips.where((tip) => tip.category == category).toList();
  }

  // Get all available categories
  List<String> getCategories() {
    return _tips.map((tip) => tip.category).toSet().toList();
  }

  // Get a specific tip by ID
  MenopauseTip? getTipById(String id) {
    try {
      return _tips.firstWhere((tip) => tip.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get random tips for a specific category
  List<MenopauseTip> getRandomTipsByCategory(String category, int count) {
    final categoryTips = getTipsByCategory(category);
    if (categoryTips.isEmpty) return [];

    categoryTips.shuffle(_random);
    return categoryTips.take(count).toList();
  }
}
