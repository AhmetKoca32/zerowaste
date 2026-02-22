/// Mutfak seçenekleri (isteğe bağlı) – tarif oluştururken kullanılır.
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
}
