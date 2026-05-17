# System Patterns: Sıfır Atık Mutfak

**Son Guncelleme:** Mayis 2026

---

## Mimari Genel Bakis

### Mimari Stil
- **Clean Architecture:** Feature-based klasor yapisi.
- **State Management:** Riverpod (Provider pattern, code generation).
- **Routing:** GoRouter (declarative routing, slide transitions).
- **Dependency Injection:** Riverpod providers.

### Katman Yapisi
```
lib/
├── core/
│   ├── theme/              # AppColors, AppTheme, AppTextStyle
│   ├── shell/              # MainTabShell, CustomBottomNav
│   ├── services/           # DeepSeekService (retry, exceptions)
│   ├── network/            # NetworkService (Dio, redacted log)
│   ├── router/             # AppRouter (GoRouter)
│   ├── constants/          # AppConstants
│   ├── providers/          # Global providers
│   └── widgets/            # Ortak UI bilesenleri
│
└── features/
    ├── home/               # Tarif listesi + malzeme filtreleme
    ├── recipe_generator/   # AI tarif uretimi (DeepSeek)
    ├── chat/               # EcoChef AI sohbet (Limitli: 20 mesaj/gün)
    ├── splash/             # Splash acilis ekrani
    ├── points/             # Gamification sistemi (Firestore baglantili)
    │   ├── data/models/    # PostEntry, LeaderboardDoc
    │   ├── data/repositories/ # PointsRepository (Firestore)
    │   └── presentation/   # Page, Widgets, Providers
    └── admin/              # Web admin paneli
```

---

## State Management Patterns

### Riverpod Kullanimi

#### Provider Tipleri
1. **Provider:** Singleton servisler (NetworkService, DeepSeekService).
2. **FutureProvider (keepAlive: true):** Tarif listesi, RecentIngredients, DailyChatSuggestions.
3. **StateProvider:** dailyMessageCountProvider (int, max 20).
4. **StateNotifierProvider:** ChatMessages (message list management).

#### Onemli Providerlar
```dart
// pointsRepositoryProvider: Points islemleri icin Firestore repository
final pointsRepositoryProvider = Provider<PointsRepository>((ref) {
  return PointsRepository();
});
```

---

## Tasarim & Animasyon Pattern'leri

### 1. Sequential Animation Controller Pattern (Ardisik Animasyon)
`PointsHeroCard` gibi birden fazla asamali animasyon iceren bilesenlerde guvenli yapi.

### 2. Inner Shadow Pattern
Arama cubuklari ve dropdown'larda BoxDecoration ile iki katmanli derinlik.

### 3. Liquid Glass Navbar Pattern
`BackdropFilter(filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15))` ile pill-shaped navbar.

### 4. Premium Dialog Pattern
Bulanik arka plan, beyaz yuzey, 24-32px radius, yuzer kapatma butonu.

### 5. Chat Suggestion Rotation Pattern
Gunluk 5 rastgele oneri, SharedPreferences indeks bazli cache.

### 6. DeepSeek Error Handling Pattern
4 exception tipi, retry loop (2 kez), refund mekanizmasi.

### 7. Typography System Pattern
AppTextStyle ile 16 stil, Manrope font.

### 8. Recipe Markdown Parsing Pattern
RecipeParser ile AI ciktisini Recipe modeline cevirme.

### 9. Background Timer Pattern
5 dakika inaktivite sonrasi chat temizleme.

---

## Data Flow Patterns

### Points & Admin Entegrasyonu (Firestore)
```
Kullanici fotograf ceker -> Nickname dialog (ilk sefer)
  -> PostEntry olusturulur -> PointsRepository.submitPost() -> Firestore'da posts koleksiyonu
  -> Admin paneli -> getPendingPosts() ile listele
  -> Onayla -> approvePost() -> status='approved' + leaderboard recalculate
  -> Kullanici ekrani -> _loadPosts() ile guncelle -> puan hesabi
```

### Leaderboard Mekanizmasi
```
Admin post onaylar -> _recalculateLeaderboard()
  -> Tum approved + optIn postlar sorgulanir -> puanlar toplanir
  -> leaderboard/current dokumani guncellenir
  -> PointsPage'deki _LeaderboardTop3 -> getLeaderboard() -> top 3 gosterilir
```

### Admin Panel Responsive Tasarimi
```
LayoutBuilder -> genislik >= 600px ise Row(sidebar | content)
               -> genislik < 600px ise Scaffold(drawer | body)
```

### RecipeSyncService (Gunluk Sync)
```
main() baslangicinda -> RecipeSyncService.syncIfNeeded()
  -> Son sync gunu kontrol (SharedPreferences)
  -> Farkli gunse -> RecipeRepository(useFirestore: true) ile tarifleri cek
  -> SharedPreferences'a cache'le
  -> Hata olursa sessizce basarisiz (fallback zaten var)
```

