/// Mutfak seçenekleri (isteğe bağlı) – tarif oluştururken kullanılır.
///
/// Values are used directly in the UI and sent to the DeepSeek API.
/// They remain hardcoded since cuisine names are brand-specific terminology.
abstract final class CuisineOptions {
  CuisineOptions._();

  /// "Seçim yok" için kullanılan değer (null ile eşdeğer).
  static const String none = 'Fark etmez';

  static const List<String> all = [
    none,
    'Akdeniz mutfağı',
    'Ege mutfağı',
    'Karadeniz mutfağı',
    'Güneydoğu Anadolu mutfağı',
    'İç Anadolu mutfağı',
    'Marmara mutfağı',
    'Doğu Anadolu mutfağı',
    'Türk mutfağı (genel)',
    'İtalyan mutfağı',
    'Fransız mutfağı',
    'Japon mutfağı',
    'Meksika mutfağı',
    'Hint mutfağı',
    'Arap mutfağı',
    'Özbek mutfağı',
    'Yunan mutfağı',
    'Orta Doğu mutfağı',
    'Asya mutfağı',
    'Vejetaryen / bitkisel',
  ];

  /// English translations used when the app locale is English.
  /// Falls back to the Turkish name for entries without a translation.
  static String localized(String cuisine, String localeCode) {
    if (localeCode != 'en') return cuisine;
    return _enTranslations[cuisine] ?? cuisine;
  }

  static const Map<String, String> _enTranslations = {
    'Fark etmez': 'No preference',
    'Akdeniz mutfağı': 'Mediterranean',
    'Ege mutfağı': 'Aegean',
    'Karadeniz mutfağı': 'Black Sea',
    'Güneydoğu Anadolu mutfağı': 'Southeastern Anatolia',
    'İç Anadolu mutfağı': 'Central Anatolia',
    'Marmara mutfağı': 'Marmara',
    'Doğu Anadolu mutfağı': 'Eastern Anatolia',
    'Türk mutfağı (genel)': 'Turkish (general)',
    'İtalyan mutfağı': 'Italian',
    'Fransız mutfağı': 'French',
    'Japon mutfağı': 'Japanese',
    'Meksika mutfağı': 'Mexican',
    'Hint mutfağı': 'Indian',
    'Arap mutfağı': 'Arabic',
    'Özbek mutfağı': 'Uzbek',
    'Yunan mutfağı': 'Greek',
    'Orta Doğu mutfağı': 'Middle Eastern',
    'Asya mutfağı': 'Asian',
    'Vejetaryen / bitkisel': 'Vegetarian / Plant-based',
  };
}
