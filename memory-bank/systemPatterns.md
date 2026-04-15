# System Patterns: Sıfır Atık Mutfak

**Son Güncelleme:** Nisan 2026 (16 Nisan - Gece Oturumu)

---

## Mimari Genel Bakış

### Mimari Stil
- **Clean Architecture:** Feature-based klasör yapısı.
- **State Management:** Riverpod (Provider pattern, code generation).
- **Routing:** GoRouter (declarative routing).
- **Dependency Injection:** Riverpod providers.

### Katman Yapısı
```
lib/
├── core/
│   ├── theme/              # AppColors (brandOrange), AppTheme
│   ├── shell/              # MainTabShell, CustomBottomNav
│   └── widgets/            # Ortak UI bileşenleri
│
└── features/
    ├── home/               # Tarif listesi + malzeme filtreleme
    ├── recipe_generator/   # AI tarif üretimi (DeepSeek)
    ├── chat/               # EcoChef AI sohbet (Limitli: 20 mesaj/gün)
    ├── points/             # Gamification sistemi (Level-up journey)
    └── admin/              # Web admin paneli
```

---

## State Management Patterns

### Riverpod Kullanımı

#### Provider Tipleri
1. **Provider:** Singleton servisler (NetworkService, DeepSeekService).
2. **FutureProvider (keepAlive: true):** Tarif listesi, RecentIngredients.
3. **StateNotifierProvider:** Chat mesajları (`chatMessagesProvider`).
4. **@riverpod class:** IngredientList, SavedRecipes, DailyMessageCount.

#### Önemli Providerlar
```dart
// dailyMessageCountProvider: Günlük mesaj limitini takip eder (Max 20)
@riverpod
class DailyMessageCount extends _$DailyMessageCount {
  @override
  int build() => 0; // Şimdilik session bazlı, SharedPreferences eklenecek
  void increment() => state++;
  bool get isLimitReached => state >= 20;
}
```

---

## Tasarım & Animasyon Pattern'leri ✨

### 1. Sequential Animation Controller Pattern (Ardışık Animasyon)
`PointsHeroCard` gibi birden fazla aşamalı animasyon içeren bileşenlerde kullanılan güvenli yapı:
- **Tek Kontrolcü:** Tüm dinamik animasyonlar için tek bir `_activeProgressController` kullanılır.
- **Race Condition Koruması:** Yeni bir animasyon başlamadan önce `_activeProgressController?.dispose()` ile eskisi temizlenir.
- **Lifecycle Guard:** `dispose()` içinde tüm ticker'lar temizlenir ve `_isDisposed` bayrağı ile animasyon döngüleri (loop) anında durdurulur.
- **Mounted Check:** Her `await` sonrasında `if (!mounted) return;` kontrolü zorunludur.

### 2. Inner Shadow Pattern
Arama çubukları ve dropdown'larda derinlik hissi için iki katmanlı `BoxDecoration` kullanımı:
- Dış: İnce border + beyaz dolgu.
- İç: `LinearGradient` ile üstten %5, alttan %2 opaklıkta siyah gölge.

### 3. Liquid Glass Navbar Pattern
- `BackdropFilter(filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15))`
- `Colors.white.withOpacity(0.1)` dolgu.
- Pill-shaped tasarım, sayfa üzerinde süzülen (floating) görünüm.

### 4. Premium Dialog Pattern (Medya & Detay)
- **Bulanık Arka Plan:** `showDialog` veya `showModalBottomSheet` ile birlikte `BackdropFilter` kullanımı.
- **Yüzey:** Beyaz arka plan, 24-32px border radius.
- **Kapatma Butonu:** Sağ üstte yüzer (floating) daire buton.
- **Görsel Odak:** Fotoğrafların `BoxFit.cover` ile geniş alan kaplaması (320px+ yükseklik).

---

## Asset & Medya Pattern'leri

### Medya Entegrasyonu (image_picker)
- Kullanıcıya her zaman "Kamera" ve "Galeri" seçeneklerini sunan özel tasarlanmış bir dialog gösterilir.
- Seçilen fotoğraf yerel cihaz yoluna (`localImagePath`) kaydedilir ve anlık olarak `FileImage` ile UI'da gösterilir.
- `PostEntry` modeli yerel ve uzak (URL) görselleri destekleyecek şekilde hibrit yapıdadır.

### Custom İkon Sistemi
- Navbar ve başlıklar için `assets/images/icons/` altında PNG ikonlar kullanılır.
- İkonlar aktif durumda turuncu (`brandOrange`), pasif durumda beyaz/stonel rengidir.

---

## Data Flow Patterns

### Puan Arttırma & Seviye Atlama (Gamification Flow)
```
Admin Puan Ekler (Mock/Backend) → previousPoints tetiklenir
  ↓
PointsPage: İçeriği gizle → "Tebrikler" Dialogu Göster
  ↓
Kullanıcı "Devam Et" der → PointsHeroCard: _startLevelUpJourney(0)
  ↓
Döngü: Her seviye için _animateProgress → Kutlama Overlay → Kısa Bekleme
  ↓
Bitiş: _isAnimating = false → Sayfa içeriği Fade-in ile geri gelir
```

### Chat Limit Akışı
```
Kullanıcı Mesaj Yazar → check isLimitReached
  ↓
Evet → SnackBar göster → Mesajı gönderme
  ↓
Hayır → Mesajı gönder → dailyMessageCountProvider.increment()
```
