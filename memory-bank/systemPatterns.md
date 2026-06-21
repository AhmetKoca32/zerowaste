# System Patterns: Atıksız Mutfak

**Son Güncelleme:** Mayıs 2026

---

## Mimari Genel Bakış

### Mimari Stil
- **Clean Architecture:** Feature-based klasör yapısı
- **State Management:** Riverpod (Provider pattern, code generation)
- **Routing:** GoRouter (declarative routing, slide transitions)
- **Dependency Injection:** Riverpod providers

### Katman Yapısı
```
lib/
├── core/
│   ├── theme/              # AppColors, AppTheme, AppTextStyle
│   ├── shell/              # MainTabShell, CustomBottomNav, tabIndexProvider
│   ├── services/           # DeepSeekService (retry, exceptions)
│   ├── network/            # NetworkService (Dio, redacted log)
│   ├── router/             # AppRouter (GoRouter)
│   ├── constants/          # AppConstants
│   ├── providers/          # Global providers (localeProvider vs.)
│   └── widgets/            # Ortak UI bileşenleri
│
└── features/
    ├── home/               # Tarif listesi + malzeme filtreleme
    ├── recipe_generator/   # AI tarif üretimi (DeepSeek)
    ├── chat/               # EcoChef AI sohbet (Limitli: 20 mesaj/gün)
    ├── splash/             # Splash açılış ekranı
    └── points/             # Gamification sistemi (Firestore bağlantılı)
        ├── data/models/    # PostEntry, LeaderboardDoc
        ├── data/repositories/ # PointsRepository (Firestore)
        └── presentation/   # Page, Widgets
```

---

## State Management Patterns

### Riverpod Kullanımı

#### Provider Tipleri
1. **Provider:** Singleton servisler (NetworkService, DeepSeekService, PointsRepository)
2. **FutureProvider (keepAlive: true):** Tarif listesi, RecentIngredients, DailyChatSuggestions
3. **StateProvider:** dailyMessageCountProvider (int, max 20), tabIndexProvider
4. **StateNotifierProvider:** ChatMessages (message list management)

#### Önemli Providerlar
```dart
// pointsRepositoryProvider: Points işlemleri için Firestore repository
final pointsRepositoryProvider = Provider<PointsRepository>((ref) {
  return PointsRepository();
});

// tabIndexProvider: Bottom nav sekmeleri (0=Tarifler, 1=Oluştur, 2=Chat, 3=Puan)
final tabIndexProvider = StateProvider<int>((ref) => 0);
```

---

## Tasarım & Animasyon Pattern'leri

### 1. PointsHeroCard Animation Pattern (Ardışık Animasyon)
İki mod:
- **Normal**: Counter + progress bar animasyonu (0→X veya previous→current)
- **Level-up Journey**: Multi-level geçiş, her seviye için celebration overlay
- Ticker sızıntı koruması: `_activeProgressController` pattern (dispose + null)
- `didUpdateWidget` ile `startAnimation` false→true geçişi

### 2. Points Page Data Refresh Pattern
- Tab değişiminde (`tabIndexProvider` listener) `_loadPosts()` tetiklenir
- SharedPreferences karşılaştırması ile animasyon kararı
- `previousPoints > 0` ise animasyon, değilse statik gösterim
- `key: ValueKey('hero_$_totalPoints')` ile widget yeniden oluşturma

### 3. Çift Dilli Admin Notları Pattern
- PostEntry'de `adminNote` (TR) + `adminNoteEn` (EN) alanları
- `localizedAdminNote(localeCode)` metodu: EN locale'de adminNoteEn, diğer durumlarda adminNote
- Admin panel web'de iki input alanı

### 4. SharedPreferences Daily Reset Pattern
- Günlük görevler için `missions_date` + `missions_completed`
- Tarih karşılaştırması ile sıfırlama
- Aynı pattern nickname ve leaderboard opt-in için de kullanılır

---

## Data Flow Patterns

### Points & Admin Entegrasyonu (Firestore)
```
Kullanıcı fotoğraf çeker → Nickname dialog (ilk sefer)
  → PostEntry oluşturulur → PointsRepository.submitPost()
  → Firestore'da posts koleksiyonu
  → Admin web panel → getPendingPosts() ile listele
  → Onayla → approvePost() → status='approved' + leaderboard recalculate
  → Kullanıcı tab değiştirince → _loadPosts() → SharedPrefs karşılaştırması → animasyon
```

### Leaderboard Mekanizması
```
Admin post onaylar → _recalculateLeaderboard()
  → Tüm approved + optIn postlar sorgulanır → puanlar toplanır
  → leaderboard/current dokümanı güncellenir
  → PointsPage'deki _LeaderboardTop3 → getLeaderboard() → top 3 gösterilir

Kullanıcı opt-out yapar → optOutUser() → batch update leaderboardOptIn=false
  → _recalculateLeaderboard() → kullanıcı leaderboard'dan kaybolur
```

### Account Deletion Detection
```
_loadPosts() çalışır
  → SharedPreferences'dan 'last_known_points_{nickname}' okunur
  → previousPoints > 0 && approved.isEmpty && total == 0 ise
  → Hesap silinmiş demektir → _showAccountDeletedDialog()
  → Dialog: "Tüm gönderileriniz ve puanlarınız admin tarafından silinmiş"
```

### Admin Panel Responsive Tasarım
```
LayoutBuilder → genişlik >= 600px ise Row(sidebar | content)
               → genişlik < 600px ise Scaffold(drawer | body)
```

