# System Patterns: Atıksız Mutfak

**Son Güncelleme:** Temmuz 2026 (17 Temmuz)

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
│   ├── services/           # DeepSeek, AnonymousAuth, PostImageStorage
│   ├── network/            # NetworkService (Dio)
│   ├── router/             # AppRouter (GoRouter)
│   ├── constants/
│   ├── providers/          # core_providers, localeProvider
│   └── widgets/
│
└── features/
    ├── home/               # Tarif listesi + RecipesComingSoon
    ├── recipe_generator/   # AI tarif üretimi (DeepSeek)
    ├── chat/               # EcoChef AI sohbet
    ├── splash/
    └── points/             # Gamification + gönderi upload
```

---

## State Management Patterns

### Riverpod Kullanımı

#### Provider Tipleri
1. **Provider:** Singleton servisler (NetworkService, DeepSeekService, AnonymousAuthService, PostImageStorageService)
2. **FutureProvider (keepAlive: true):** `recipeList`, RecentIngredients, DailyChatSuggestions
3. **StateProvider:** `dailyMessageCountProvider`, `tabIndexProvider`
4. **StateNotifierProvider:** ChatMessages

#### Önemli Providerlar
```dart
// core_providers.dart
final anonymousAuthServiceProvider = Provider<AnonymousAuthService>(...);
final postImageStorageServiceProvider = Provider<PostImageStorageService>(...);

// home_providers.dart
@Riverpod(keepAlive: true)
Future<List<Recipe>> recipeList(RecipeListRef ref) async { ... }

// tabIndexProvider: 0=Tarifler, 1=Oluştur, 2=Chat, 3=Puan
```

---

## Tasarım & Animasyon Pattern'leri

### 1. PointsHeroCard Animation Pattern
- **Normal**: Counter + progress bar (0→X veya previous→current)
- **Level-up Journey**: Multi-level geçiş + celebration overlay
- Ticker sızıntı koruması: `_activeProgressController` pattern

### 2. Points Page Data Refresh & Animation Pattern
- Tab değişiminde `_loadPosts(allowAnimation: true)` — sadece Puan sekmesine geçildiğinde
- `total > previousPoints` ise animasyon; değilse statik gösterim
- SharedPreferences güncellemesi animasyon bitince (`onAnimationComplete`)
- `_heroAnimationNonce` ile widget yeniden oluşturma
- Arka planda mount olan TabBarView'da animasyon oynatılmaz

### 3. RecipesComingSoon Empty State Pattern
- `RecipeRepository._loadFromFirestore()` boş veya hata → `[]`
- `HomePage`: `recipes.isEmpty` → `RecipesComingSoon` widget
- Admin panelden tarif eklenene kadar placeholder gösterilir

### 4. Post Image Upload Pattern
```
Startup: main() → anonymousAuthService.ensureSignedIn() (20s timeout)
Submit:  image_picker → readAsBytes()
         → ensureSignedIn() (retry)
         → postId = repo.newPostId()
         → PostImageStorageService.uploadPostImage(bytes, postId) (90s timeout)
         → PostEntry(imageUrl: url) → PointsRepository.submitPost(id: postId)
Display: PostImageThumbnail → CachedNetworkImage(imageUrl)
```
**Admin panel upload'a dahil değil** — sadece Firestore `imageUrl` okur.

### 5. AI Language Patterns
- **Chat**: Kullanıcı mesaj dilinde yanıt (`_detectMessageLanguage` + `[LANGUAGE RULE]` tag)
- **Recipe Generator**: App `localeProvider` dilinde (`languageCode` param, ayrı TR/EN prompt)
- Chat ≠ Create: chat serbest metin, create AppBar TR/EN toggle

### 6. Recipe Data Model ↔ Admin Form Alignment
Mobil ve admin panel aynı Firestore şemasını paylaşır:
```
title:        string          → tek satır input
description:  string?         → multiline textarea
ingredients:  string[]        → DynamicStringListField (bullet list mobilde)
instructions: string[]        → DynamicStringListField + showNumbers (numaralı adım mobilde)
image_url:    string?         → URL input (ileride upload)
```
**Kural:** ingredients/instructions asla tek string veya virgülle ayrılmış metin olarak kaydedilmez.

### 7. Çift Dilli Admin Notları Pattern
- `adminNote` (TR) + `adminNoteEn` (EN)
- `localizedAdminNote(localeCode)` metodu

### 8. SharedPreferences Daily Reset Pattern
- `missions_date` + `missions_completed` ile günlük görev sıfırlama

---

## Data Flow Patterns

### Points & Admin Entegrasyonu
```
Kullanıcı fotoğraf çeker → Nickname dialog (ilk sefer)
  → anonymousAuth.ensureSignedIn()
  → Storage upload (posts/{postId}/photo.jpg)
  → PostEntry(imageUrl) → PointsRepository.submitPost()
  → Admin web panel → getPendingPosts() → onayla/reddet
  → Kullanıcı tab değiştirince → _loadPosts() → animasyon kararı
```

### Recipe Data Flow
```
Admin panel → Firestore recipes/{id} (ingredients[], instructions[])
  → RecipeRepository.getRecipes() → recipeListProvider
  → HomePage → RecipeBlogCard → RecipeDetailSheet
  → ingredients: bullet list, instructions: numbered steps
```

### Leaderboard Mekanizması
```
Admin onaylar → _recalculateLeaderboard()
  → approved + optIn postlar → puan toplama
  → leaderboard/current güncelleme

Kullanıcı opt-out → optOutUser() → leaderboardOptIn=false batch
  → _recalculateLeaderboard()
```

---

## Admin Panel Responsive Tasarım (Ayrı Web Projesi)
```
LayoutBuilder → genişlik >= 600px → Row(sidebar | content)
               → genişlik < 600px → Scaffold(drawer | body)
```

### Admin Recipe Form (Planlanan)
```
DynamicStringListField
  ├── items: List<String>
  ├── onChanged: (List<String>) → void
  ├── addButtonText, placeholder, label
  └── showNumbers: bool (adımlar için true)

AdminRecipeForm
  ├── title (TextField)
  ├── description (TextField, multiline)
  ├── image_url (TextField, optional)
  ├── ingredients (DynamicStringListField)
  ├── instructions (DynamicStringListField, showNumbers: true)
  └── validation: title required, min 1 ingredient, min 1 instruction
```
