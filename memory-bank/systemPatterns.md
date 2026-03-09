# System Patterns: Sıfır Atık Mutfak

**Son Güncelleme:** Mart 2025

---

## Mimari Genel Bakış

### Mimari Stil
- **Clean Architecture:** Feature-based klasör yapısı
- **State Management:** Riverpod (Provider pattern, code generation)
- **Routing:** GoRouter (declarative routing)
- **Dependency Injection:** Riverpod providers

### Katman Yapısı
```
lib/
├── core/
│   ├── constants/          # AppConstants (appName: 'Sıfır Atık Mutfak')
│   ├── network/            # NetworkService (Dio)
│   ├── providers/          # Global providers
│   ├── router/             # AppRouter (GoRouter)
│   ├── services/           # DeepSeekService
│   ├── shell/              # MainTabShell, CustomBottomNav
│   ├── theme/              # AppTheme, AppColors
│   └── widgets/            # EmptyPlaceholder
│
└── features/
    ├── home/               # Tarif listesi + filtreleme
    │   ├── data/
    │   │   ├── models/     # Recipe (Freezed)
    │   │   └── repositories/ # RecipeRepository (Firestore)
    │   └── presentation/
    │       ├── pages/      # HomePage (arama + chip filter + liste)
    │       ├── providers/  # recipeListProvider (keepAlive: true)
    │       └── widgets/    # RecipeBlogCard, RecipeDetailSheet
    │
    ├── recipe_generator/   # AI tarif üretimi
    ├── chat/               # Leafy AI sohbet
    ├── points/             # Puan sistemi
    └── admin/              # Web admin paneli
```

---

## State Management Pattern

### Riverpod Kullanımı

#### Provider Tipleri
1. **Provider:** Singleton servisler (NetworkService, DeepSeekService)
2. **FutureProvider (keepAlive: true):** Tarif listesi (sadece ilk açılışta fetch)
3. **StateProvider:** Basit state (tabIndexProvider, ingredientListProvider)
4. **StreamProvider:** Real-time data (adminUserProvider)
5. **StateNotifierProvider:** Kompleks state (chatMessagesProvider)

#### Önemli Provider Değişiklikleri
```dart
// recipeListProvider: keepAlive: true ile sadece ilk açılışta fetch
@Riverpod(keepAlive: true)
Future<List<Recipe>> recipeList(RecipeListRef ref) async {
  final repo = ref.watch(recipeRepositoryProvider);
  final fromRepo = await repo.getRecipes();
  final generated = ref.watch(generatedRecipesProvider);
  return [...generated, ...fromRepo];
}
```

---

## UI Pattern

### Navigation Pattern
- **CustomBottomNav:** Pill-shaped frosted glass navbar
  - BackdropFilter ile blur efekti
  - Custom PNG ikonlar (assetPath parametresi)
  - Aktif: turuncu pill + beyaz ikon + Manrope Bold 12 text
  - Pasif: beyaz daire + turuncu outline ikon
- **MainTabShell:** TabBarView, extendBody: true
  - İç sayfalar (RecipeGeneratorPage, ChatPage, PointsPage) inTabs: true iken inner Scaffold bypass eder
  - SafeArea kaldırılmış, alt padding 100-120px eklenerek içerik navbar arkasından scroll eder

### Tarifler Sayfası Pattern (HomePage)
```dart
// State
String _searchQuery = '';
Set<String> _selectedIngredients = {};

// Tüm tariflerden benzersiz malzemeler
final allIngredients = recipes.expand((r) => r.ingredients).toSet().toList()..sort();

// Arama filtresi
var filtered = _searchQuery.isEmpty ? recipes.toList() : recipes.where(...).toList();

// Malzeme bazlı akıllı sıralama
if (_selectedIngredients.isNotEmpty) {
  filtered.sort((a, b) => _matchCount(b).compareTo(_matchCount(a)));
}

// ListView: index 0 = search bar + chip bar, index > 0 = tarif kartları
```

### Tarif Kartı Pattern (RecipeBlogCard)
- Beyaz Card, turuncu kenarlı malzeme chip'leri
- Opsiyonel matchCount/totalSelected parametreleri
- Eşleşme göstergesi: "X/Y malzeme elinizde" (filtre aktifken)
- Resim: 16px padding, 16px border radius, 220px yükseklik
- Placeholder: yemek.png (assets/images/image/)

### Tarif Detay Pattern (RecipeDetailSheet)
- DraggableScrollableSheet (initialChildSize: 0.85)
- Beyaz arka plan, yumuşak gölge
- Malzemeler chip formatında (turuncu kenarlı)
- Yapılış adımları numaralı (turuncu daire)
- Tüm fontlar Manrope
- Placeholder: yemek.png

### Tema ve Renk Pattern
```dart
// AppColors - Brand renkleri (yeşiller kaldırıldı)
static const Color brandOrange = Color(0xFFED6826);
static const Color brandCream = Color(0xFFFFFFCC);
static const Color brandBlack = Color(0xFF000000);
static const Color brandWhite = Color(0xFFFFFFFF);

// AppTheme
ColorScheme.fromSeed(
  seedColor: AppColors.brandOrange,
  primary: AppColors.brandOrange,
  tertiary: AppColors.brandCream,
)
```

---

## Asset Management

### Custom İkonlar (assets/images/icons/)
- `tarifler_icon.png` - Navbar tarifler ikonu
- `chat_icon.png` - Navbar chat ikonu
- `puan_icon.png` - Navbar puan ikonu
- `oluştur_icon.png` - Navbar oluştur ikonu
- `alisveris_icon.png` - Malzemeler başlığı ikonu
- `search_icon.png` - Arama çubuğu ikonu

### Placeholder Görseller (assets/images/image/)
- `yemek.png` - Tarif kartları ve detay sayfası varsayılan görseli

### Font (assets/fonts/)
- Manrope-Regular.ttf
- Manrope-Medium.ttf
- Manrope-Bold.ttf
- Manrope-Light.ttf

---

## Data Flow Pattern

### Tarif Listesi + Filtreleme Akışı
```
App Açılış → recipeListProvider (keepAlive) → RecipeRepository → Firestore → List<Recipe>
  ↓
HomePage: allIngredients çıkar → chip bar render
  ↓
Kullanıcı chip seçer → _selectedIngredients güncelle → filtered.sort(matchCount) → UI güncelle
  ↓
RecipeBlogCard: matchCount/totalSelected ile eşleşme göstergesi
```

### Sayfa Geçişlerinde Cache
- recipeListProvider keepAlive: true → sayfa geçişlerinde re-fetch yok
- ref.invalidate(recipeListProvider) ile manuel yenileme mümkün (hata durumunda "Tekrar Dene")
