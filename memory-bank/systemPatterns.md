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
    │   │   └── repositories/ # RecipeRepository (Firestore + fallback)
    │   └── presentation/
    │       ├── pages/      # HomePage (arama + filtre butonu + liste)
    │       ├── providers/  # recipeListProvider (keepAlive: true)
    │       └── widgets/    # RecipeBlogCard, RecipeDetailSheet, IngredientFilterSheet
    │
    ├── recipe_generator/   # AI tarif üretimi
    │   ├── data/           # CuisineOptions, RecipeParser, SavedRecipe, SavedRecipesStorage
    │   └── presentation/
    │       ├── pages/      # RecipeGeneratorPage
    │       ├── providers/  # IngredientList, RecentIngredients, GeneratedRecipe, SavedRecipes
    │       └── widgets/    # ChefLoadingOverlay, RecipeResultSheet, SavedRecipesSheet
    │
    ├── chat/               # Leafy AI sohbet
    ├── points/             # Puan sistemi
    └── admin/              # Web admin paneli
```

---

## State Management Pattern

### Riverpod Kullanımı

#### Provider Tipleri
1. **Provider:** Singleton servisler (NetworkService, DeepSeekService)
2. **FutureProvider (keepAlive: true):** Tarif listesi, RecentIngredients
3. **StateProvider:** Basit state (tabIndexProvider)
4. **StreamProvider:** Real-time data (adminUserProvider)
5. **StateNotifierProvider:** Kompleks state (chatMessagesProvider)
6. **@riverpod class:** IngredientList, SelectedCuisine, GeneratedRecipes, SavedRecipes, GeneratedRecipe, RecentIngredients

#### Önemli Providerlar
```dart
// recipeListProvider: keepAlive: true ile sadece ilk açılışta fetch
@Riverpod(keepAlive: true)
Future<List<Recipe>> recipeList(RecipeListRef ref) async { ... }

// RecentIngredients: SharedPreferences ile kalıcı, max 10 malzeme
@Riverpod(keepAlive: true)
class RecentIngredients extends _$RecentIngredients {
  Future<List<String>> build() async { ... } // SharedPreferences'dan oku
  Future<void> addAll(List<String> ingredients) async { ... } // Kaydet
}

// IngredientList: removeAt bug fix
void removeAt(int index) => state = [...state]..removeAt(index); // Kopyala sonra sil
```

---

## UI Patterns

### Inner Shadow Pattern
Arama çubukları ve dropdown'larda kullanılıyor:
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(50), // veya 28
    border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
  ),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withOpacity(0.05), Colors.transparent,
          Colors.transparent, Colors.black.withOpacity(0.02),
        ],
        stops: const [0.0, 0.15, 0.85, 1.0],
      ),
    ),
    child: ClipRRect(..., child: TextField(...)),
  ),
)
```

### Bottom Sheet Pattern
Tüm sheet'lerde kullanılan ortak yapı:
```dart
showModalBottomSheet(
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.75-0.85,
    builder: (context, scrollController) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // Drag handle (40x4, stone renk)
        // Başlık
        // İçerik (Expanded + ListView)
        // Alt butonlar (varsa)
      ]),
    ),
  ),
);
```

### Navigation Pattern
- **CustomBottomNav:** Pill-shaped frosted glass navbar
- **MainTabShell:** TabBarView, extendBody: true
  - İç sayfalar inTabs: true iken inner Scaffold bypass

### Tarifler Sayfası Pattern (HomePage)
```dart
// Arama çubuğu + filtre butonu (Row)
// Seçili malzeme chip'leri (seçim varsa gösterilir, yoksa gizli)
// Tarif listesi (ListView.builder)
// Filtre: showIngredientFilterSheet() → Set<String> döner
```

### Oluştur Sayfası Pattern (RecipeGeneratorPage)
```dart
// Başlık + açıklama (info ikonu ile)
// Input (inner shadow) + "+" butonu
// Turuncu dolgulu aktif malzeme chip'leri
// Son eklenenler (RecentIngredients, turuncu kenarlı chip'ler)
// Mutfak dropdown (pill-shape, inner shadow, arrow_icon.png, animasyonlu açılır liste)
// Tarif Oluştur butonu
// Kaydettiğim Tarifler (max 5 + "Tümünü gör")
```

### Tarif Detay Pattern (RecipeDetailSheet)
```dart
// DraggableScrollableSheet (0.85)
// Başlık + silme/kapat butonları
// Kaydet/Kapat butonları (showSavePrompt ise)
// Resim (showPlaceholderImage parametresi kontrol eder)
// Özet istatistik barı (malzeme + adım sayısı)
// Açıklama (description varsa)
// Malzemeler kartı (kenarlıklı, turuncu nokta ile madde listesi)
// Yapılış kartı (kenarlıklı, numaralı adımlar, ayraç çizgiler)
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
- `arrow_icon.png` - Dropdown ok ikonu

### Placeholder Görseller (assets/images/image/)
- `yemek.png` - Tarif kartları ve detay sayfası varsayılan görseli

### Font (assets/fonts/)
- Manrope-Regular.ttf, Manrope-Medium.ttf, Manrope-Bold.ttf, Manrope-Light.ttf

---

## Data Flow Patterns

### Tarif Listesi + Filtreleme
```
App Açılış → recipeListProvider (keepAlive) → RecipeRepository → Firestore (boşsa → yerel JSON)
  ↓
HomePage: allIngredients çıkar
  ↓
Kullanıcı filtre butonuna dokunur → IngredientFilterSheet açılır → malzeme seçer → "Uygula"
  ↓
_selectedIngredients güncellenir → filtered.sort(matchCount) → UI güncellenir
  ↓
RecipeBlogCard: matchCount/totalSelected ile eşleşme göstergesi
```

### Tarif Oluşturma + Son Eklenenler
```
Kullanıcı malzeme ekler (IngredientList) → "Tarif Oluştur" → DeepSeek API
  ↓
generate() içinde: recentIngredientsProvider.addAll(ingredients) → SharedPreferences'a kaydet
  ↓
Tarif başarılı → ingredientList.clear() → detay sheet açılır
  ↓
Sayfa geri döndüğünde: "Son eklenenler" güncel (aktif listede olmayan recent malzemeler)
```

### Kaydettiğim Tarifler
```
Tarif detayda "Kaydet" → savedRecipesProvider.addRecipe() → SharedPreferences
  ↓
RecipeGeneratorPage: _SavedRecipesSection (max 5 yatay + "Tümünü gör")
  ↓
"Tümünü gör" → SavedRecipesSheet (arama + dikey liste + detay/silme/fotoğraf)
```
