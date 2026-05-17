import 'package:flutter/material.dart';

/// A single suggestion shown in the EcoChef welcome screen.
class ChatSuggestion {
  const ChatSuggestion({required this.icon, required this.text, this.textEn});

  final IconData icon;
  final String text;

  /// English translation, optional. Falls back to [text] when null.
  final String? textEn;

  /// Returns the suggestion text localized for the current [localeCode].
  String localized(String localeCode) =>
      localeCode == 'en' && textEn != null ? textEn! : text;
}

/// Flat pool of suggestion prompts. The welcome screen picks 5 at random on
/// every mount, so adding/removing entries here is the only change required to
/// curate what users see.
const List<ChatSuggestion> kChatSuggestionPool = [
  // ── Artıklardan değerlendirme / Using leftovers ──────────────────
  ChatSuggestion(
    icon: Icons.bakery_dining_rounded,
    text: 'Bayat ekmeklerle ne yapabilirim?',
    textEn: 'What can I do with stale bread?',
  ),
  ChatSuggestion(
    icon: Icons.spa_rounded,
    text: 'Meyve kabuklarını nasıl değerlendiririm?',
    textEn: 'How can I use fruit peels?',
  ),
  ChatSuggestion(
    icon: Icons.grass_rounded,
    text: 'Sebze kabuklarından neler yapılır?',
    textEn: 'What can be made from vegetable peels?',
  ),
  ChatSuggestion(
    icon: Icons.soup_kitchen_rounded,
    text: 'Tavuk ve et kemiklerinden suyu nasıl çıkarırım?',
    textEn: 'How do I make broth from chicken and meat bones?',
  ),
  ChatSuggestion(
    icon: Icons.icecream_rounded,
    text: 'Peynir kabuklarını nasıl kullanabilirim?',
    textEn: 'How can I use cheese rinds?',
  ),
  ChatSuggestion(
    icon: Icons.coffee_rounded,
    text: 'Kahve telvesini değerlendirme yolları nelerdir?',
    textEn: 'Ways to reuse coffee grounds?',
  ),
  ChatSuggestion(
    icon: Icons.egg_alt_rounded,
    text: 'Yumurta kabuklarını ne için kullanabilirim?',
    textEn: 'What can I use eggshells for?',
  ),
  ChatSuggestion(
    icon: Icons.emoji_food_beverage_rounded,
    text: 'Çay posasından nasıl faydalanırım?',
    textEn: 'How can I benefit from tea leaves?',
  ),
  ChatSuggestion(
    icon: Icons.rice_bowl_rounded,
    text: 'Pirinç ve makarna suyunu nasıl kullanırım?',
    textEn: 'How can I use rice and pasta water?',
  ),
  ChatSuggestion(
    icon: Icons.eco_outlined,
    text: 'Maydanoz ve baharat saplarından ne yapabilirim?',
    textEn: 'What can I make with parsley and herb stems?',
  ),

  // ── Saklama & ömür uzatma / Storage & shelf life ──────────────────
  ChatSuggestion(
    icon: Icons.ac_unit_rounded,
    text: 'Taze otları nasıl dondurarak saklarım?',
    textEn: 'How do I freeze fresh herbs?',
  ),
  ChatSuggestion(
    icon: Icons.timelapse_rounded,
    text: 'Sebzelerin buzdolabında ömrünü nasıl uzatırım?',
    textEn: 'How do I extend vegetable shelf life in the fridge?',
  ),
  ChatSuggestion(
    icon: Icons.bakery_dining_outlined,
    text: 'Ekmeği bayatlatmadan nasıl saklarım?',
    textEn: 'How do I keep bread fresh longer?',
  ),
  ChatSuggestion(
    icon: Icons.local_drink_rounded,
    text: 'Evde kolayca turşu nasıl kurulur?',
    textEn: 'How to easily make pickles at home?',
  ),
  ChatSuggestion(
    icon: Icons.wb_sunny_rounded,
    text: 'Sebze ve meyveleri kurutarak nasıl saklarım?',
    textEn: 'How to preserve fruits and vegetables by drying?',
  ),
  ChatSuggestion(
    icon: Icons.inventory_2_rounded,
    text: 'Vakumlu saklama yöntemleri nasıl çalışır?',
    textEn: 'How does vacuum storage work?',
  ),
  ChatSuggestion(
    icon: Icons.kitchen_rounded,
    text: 'Soğan ve sarımsağı en uzun nasıl saklarım?',
    textEn: 'How to store onions and garlic the longest?',
  ),
  ChatSuggestion(
    icon: Icons.severe_cold_rounded,
    text: 'Hangi yemekler dondurularak saklanabilir?',
    textEn: 'Which meals can be frozen?',
  ),

  // ── Sıfır atık ipuçları / Zero-waste tips ────────────────────────
  ChatSuggestion(
    icon: Icons.eco_rounded,
    text: 'Atıksız mutfak ipuçları ver',
    textEn: 'Give me zero-waste kitchen tips',
  ),
  ChatSuggestion(
    icon: Icons.lightbulb_outline_rounded,
    text: 'Gıda israfını azaltmanın 5 yolu',
    textEn: '5 ways to reduce food waste',
  ),
  ChatSuggestion(
    icon: Icons.shopping_basket_rounded,
    text: 'Daha bilinçli alışveriş listesi nasıl yapılır?',
    textEn: 'How to make a smarter shopping list?',
  ),
  ChatSuggestion(
    icon: Icons.event_available_rounded,
    text: 'Son kullanma tarihi yaklaşan ürünleri nasıl değerlendiririm?',
    textEn: 'How to use up near-expiry products?',
  ),
  ChatSuggestion(
    icon: Icons.restaurant_rounded,
    text: 'Porsiyon yönetimini nasıl yapmalıyım?',
    textEn: 'How should I manage portions?',
  ),
  ChatSuggestion(
    icon: Icons.dashboard_rounded,
    text: 'Mutfak dolabını nasıl daha düzenli organize ederim?',
    textEn: 'How to organize my kitchen cabinet?',
  ),
  ChatSuggestion(
    icon: Icons.insights_rounded,
    text: 'Gıda israfı dünyada ne durumda?',
    textEn: 'What is the state of food waste globally?',
  ),

  // ── Sürdürülebilir mutfak / Sustainable kitchen ──────────────────
  ChatSuggestion(
    icon: Icons.recycling_rounded,
    text: 'Mutfak atıklarından nasıl kompost yapabilirim?',
    textEn: 'How can I compost kitchen waste?',
  ),
  ChatSuggestion(
    icon: Icons.do_not_disturb_on_rounded,
    text: 'Mutfakta plastik kullanımını nasıl azaltırım?',
    textEn: 'How to reduce plastic use in the kitchen?',
  ),
  ChatSuggestion(
    icon: Icons.calendar_month_rounded,
    text: 'Mevsiminde olan sebze ve meyveler hangileri?',
    textEn: 'Which fruits and vegetables are in season?',
  ),
  ChatSuggestion(
    icon: Icons.storefront_rounded,
    text: 'Lokal üretici ürünleri neden tercih etmeliyim?',
    textEn: 'Why should I choose local produce?',
  ),
  ChatSuggestion(
    icon: Icons.water_drop_rounded,
    text: 'Mutfakta su tasarrufu için ne yapabilirim?',
    textEn: 'What can I do to save water in the kitchen?',
  ),
  ChatSuggestion(
    icon: Icons.bolt_rounded,
    text: 'Pişirme sırasında enerji nasıl tasarruf edilir?',
    textEn: 'How to save energy while cooking?',
  ),
  ChatSuggestion(
    icon: Icons.inventory_rounded,
    text: 'Tekrar kullanılabilir mutfak ambalajları öner',
    textEn: 'Suggest reusable kitchen packaging',
  ),

  // ── Tarif fikirleri / Recipe ideas ────────────────────────────────
  ChatSuggestion(
    icon: Icons.dinner_dining_rounded,
    text: 'Tek tencerede yapabileceğim sıfır atık tarifler',
    textEn: 'One-pot zero-waste recipes',
  ),
  ChatSuggestion(
    icon: Icons.set_meal_rounded,
    text: 'Akşamdan kalanlarla ne pişirebilirim?',
    textEn: 'What can I cook with leftovers?',
  ),
  ChatSuggestion(
    icon: Icons.timer_rounded,
    text: '15 dakikada hazırlanan pratik tarifler',
    textEn: 'Quick recipes ready in 15 minutes',
  ),
  ChatSuggestion(
    icon: Icons.savings_rounded,
    text: 'Bütçeyi zorlamayan ekonomik tarifler ver',
    textEn: 'Give me budget-friendly recipes',
  ),
  ChatSuggestion(
    icon: Icons.kitchen_outlined,
    text: 'Dolaptaki malzemelerle ne yapabilirim?',
    textEn: 'What can I make with fridge ingredients?',
  ),
  ChatSuggestion(
    icon: Icons.local_florist_rounded,
    text: 'Etsiz, vejetaryen tarifler öner',
    textEn: 'Suggest meatless, vegetarian recipes',
  ),
  ChatSuggestion(
    icon: Icons.child_friendly_rounded,
    text: 'Çocuklar için sağlıklı atıştırmalık fikirleri',
    textEn: 'Healthy snack ideas for kids',
  ),
  ChatSuggestion(
    icon: Icons.breakfast_dining_rounded,
    text: 'Atıksız bir kahvaltı sofrası nasıl olur?',
    textEn: 'What does a zero-waste breakfast table look like?',
  ),
];
