# System Patterns: ZeroWaste Mutfak

**Son Güncelleme:** Şubat 2025

---

## 🏗️ Mimari Genel Bakış

### Mimari Stil
- **Clean Architecture:** Feature-based klasör yapısı
- **State Management:** Riverpod (Provider pattern)
- **Routing:** GoRouter (declarative routing)
- **Dependency Injection:** Riverpod providers

### Katman Yapısı
```
lib/
├── core/                    # Paylaşılan core bileşenler
│   ├── constants/          # Sabitler (API URLs, app name)
│   ├── network/            # HTTP client (Dio)
│   ├── providers/          # Global providers
│   ├── router/             # Routing yapılandırması
│   ├── services/           # Business logic servisleri
│   ├── shell/              # App shell (tab navigation)
│   ├── theme/              # Tema ve renkler
│   └── widgets/            # Paylaşılan widget'lar
│
└── features/               # Feature modülleri
    ├── home/               # Tarif listesi
    │   ├── data/
    │   │   ├── models/      # Recipe model
    │   │   └── repositories/ # RecipeRepository
    │   └── presentation/
    │       ├── pages/       # HomePage
    │       ├── providers/   # Home providers
    │       └── widgets/     # RecipeBlogCard, RecipeDetailSheet
    │
    ├── recipe_generator/    # AI tarif üretimi
    │   ├── data/           # SavedRecipe, RecipeParser
    │   └── presentation/
    │       ├── pages/      # RecipeGeneratorPage
    │       ├── providers/  # Generator providers
    │       └── widgets/    # Loading overlay, result sheet
    │
    ├── chat/               # Leafy AI sohbet
    │   └── presentation/
    │       ├── pages/      # ChatPage
    │       ├── providers/  # Chat providers
    │       └── widgets/    # ChatBubble, TypingIndicator
    │
    ├── points/             # Puan sistemi
    │   └── presentation/
    │       └── pages/      # PointsPage
    │
    └── admin/              # Web admin paneli
        ├── services/       # AdminAuthService
        └── presentation/
            ├── pages/      # AdminLoginPage, AdminDashboardPage, AdminRecipeEditPage
            ├── providers/  # Admin providers (auth, recipe list)
            └── widgets/    # AdminGuard, AdminSidebar, AdminRecipeForm
```

---

## 🔄 State Management Pattern

### Riverpod Kullanımı

#### Provider Tipleri
1. **Provider:** Singleton servisler (NetworkService, DeepSeekService, AdminAuthService)
2. **FutureProvider:** Async veri yükleme (recipeListProvider, adminRecipeListProvider)
3. **StateProvider:** Basit state (tabIndexProvider, ingredientListProvider)
4. **StreamProvider:** Real-time data (adminUserProvider - Firebase Auth state)
5. **StateNotifierProvider:** Kompleks state yönetimi (chatMessagesProvider)

#### Örnek Provider Yapısı
```dart
// Core providers (core/providers/core_providers.dart)
final networkServiceProvider = Provider<NetworkService>((ref) => NetworkService());
final deepSeekServiceProvider = Provider<DeepSeekService>((ref) => ...);

// Feature providers (features/home/presentation/providers/home_providers.dart)
@riverpod
RecipeRepository recipeRepository(RecipeRepositoryRef ref) => RecipeRepository(useFirestore: true);

@riverpod
Future<List<Recipe>> recipeList(RecipeListRef ref) async {
  final repo = ref.watch(recipeRepositoryProvider);
  final fromRepo = await repo.getRecipes();
  final generated = ref.watch(generatedRecipesProvider);
  return [...generated, ...fromRepo];
}

// Admin providers (features/admin/presentation/providers/admin_providers.dart)
@Riverpod(keepAlive: true)
AdminAuthService adminAuthService(AdminAuthServiceRef ref) => AdminAuthService();

@Riverpod(keepAlive: true)
Stream<User?> adminUser(AdminUserRef ref) {
  return ref.watch(adminAuthServiceProvider).authStateChanges;
}

@Riverpod(keepAlive: true)
Future<List<Recipe>> adminRecipeList(AdminRecipeListRef ref) async {
  final repo = ref.watch(adminRecipeRepositoryProvider);
  return repo.getRecipes(); // Sadece Firestore'dan (generated recipes yok)
}
```

### State Yönetimi Prensipleri
- **Single Source of Truth:** Her veri için tek bir provider
- **Reactive Updates:** `ref.watch()` ile otomatik yenileme
- **Separation of Concerns:** Business logic servislerde, UI logic widget'larda
- **Error Handling:** AsyncValue ile loading/error/data durumları
- **KeepAlive:** Admin providers için `keepAlive: true` (session boyunca aktif kalır)

---

## 🌐 Network Pattern

### HTTP Client Yapısı
- **Library:** Dio (HTTP client)
- **Service:** NetworkService (singleton)
- **Base URL:** DeepSeek API için varsayılan, custom base URL desteği var

### API Entegrasyonu
```dart
// DeepSeek API çağrısı
class DeepSeekService {
  Future<String> generateRecipe(List<String> ingredients, {String? cuisine}) async {
    return _chat(
      systemPrompt: _recipeSystemPrompt,
      userContent: userContent,
    );
  }
}
```

### Error Handling Pattern
- **Custom Exceptions:** DeepSeekAuthException, DeepSeekTimeoutException, DeepSeekApiException
- **Try-Catch:** Service katmanında yakalanır, UI'a user-friendly mesaj olarak döner
- **Retry Logic:** Şu an yok, gelecekte eklenebilir

---

## 📦 Data Layer Pattern

### Repository Pattern
```dart
class RecipeRepository {
  final bool useFirestore;
  final FirebaseFirestore _firestore;
  
  Future<List<Recipe>> getRecipes() async {
    if (useFirestore) {
      return _loadFromFirestore();  // Firestore'dan yükle
    }
    return _loadFromAsset();  // Fallback: local JSON
  }
  
  Future<void> addRecipe(Recipe recipe) async {
    if (!useFirestore) return;
    await _firestore.collection('recipes').doc(recipe.id).set(
      recipe.toFirestore(),
    );
  }
}
```

### Model Pattern
- **Freezed:** Immutable data classes için
- **JSON Serialization:** `fromJson` / `toJson` metodları
- **Firestore Serialization:** `fromFirestore` / `toFirestore` metodları
- **Example:** `Recipe` modeli (id, title, imageUrl, description, ingredients, instructions)

### Local Storage Pattern
- **SharedPreferences:** Kullanıcı tercihleri için (gelecek)
- **PathProvider:** Dosya yolları için (saved recipe images)
- **SavedRecipesStorage:** Kaydedilen tarifler için custom storage

---

## 🎨 UI Pattern

### Widget Composition
- **Reusable Widgets:** `EmptyPlaceholder`, `RecipeBlogCard`, `ChatBubble`
- **Feature-Specific Widgets:** Her feature kendi widget'larını içerir
- **Custom Bottom Navigation:** `CustomBottomNav` ile tab navigation (mobil)
- **Admin Sidebar:** `AdminSidebar` ile desktop-friendly navigation (web)

### Navigation Pattern
- **GoRouter:** Declarative routing
- **Tab Navigation:** `MainTabShell` ile 4 sekme (Tarifler, Oluştur, Leafy, Puan)
- **Admin Routes:** Web admin paneli için (`/admin/login`, `/admin/dashboard`, `/admin/recipes/*`)
- **Deep Linking:** Route paths ile (`/`, `/generate`, `/chat`, `/puan`, `/admin/*`)
- **Transitions:** Slide transition animasyonları
- **Route Guard:** `AdminGuard` widget ile admin sayfalarında yetki kontrolü

### Loading & Error States
- **AsyncValue Pattern:** `when()` metodu ile loading/data/error durumları
- **Loading Overlay:** `ChefLoadingOverlay` (tarif üretimi için)
- **Empty States:** `EmptyPlaceholder` widget'ı
- **Error Handling:** User-friendly error mesajları ve retry butonları

---

## 🔐 Security Pattern

### API Key Management
- **Environment Variables:** `.env` dosyası ile (flutter_dotenv)
- **Fallback:** `--dart-define` ile compile-time değişkenler
- **No Hardcoding:** API anahtarları kodda hardcode edilmez

### Authentication Pattern
- **Firebase Auth:** Email/Password ile admin girişi
- **Admin Control:** Firestore `admins` collection'ında kontrol (document ID = Auth UID)
- **Route Guard:** `AdminGuard` widget ile yetkisiz erişimi engelleme
- **Session Management:** Firebase Auth otomatik session yönetimi

### Data Privacy
- **Local Storage:** Şu an sadece local (saved recipes)
- **Firestore:** Tarifler herkese açık okunabilir, yazma admin'e kısıtlı (Security Rules ile)
- **Future:** Firebase Authentication ile güvenli kullanıcı verileri

---

## 🔥 Firebase Integration Patterns (Implemented)

### Firestore Integration Pattern
```dart
// RecipeRepository with Firestore
class RecipeRepository {
  final FirebaseFirestore _firestore;
  final bool useFirestore;
  
  Future<List<Recipe>> getRecipes() async {
    if (useFirestore) {
      final snapshot = await _firestore
          .collection('recipes')
          .orderBy('title')
          .get();
      return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
    }
    return _loadFromAsset(); // Fallback
  }
  
  Future<void> addRecipe(Recipe recipe) async {
    if (!useFirestore) return;
    await _firestore.collection('recipes').doc(recipe.id).set(
      recipe.toFirestore(),
    );
  }
}
```

### Admin Authentication Pattern
```dart
// AdminAuthService
class AdminAuthService {
  Future<void> signInWithEmailAndPassword({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(...);
    final isAdmin = await _isAdmin(credential.user!.uid);
    if (!isAdmin) {
      await signOut();
      throw Exception('Bu kullanıcı admin değil');
    }
  }
  
  Future<bool> _isAdmin(String userId) async {
    final doc = await _firestore.collection('admins').doc(userId).get();
    return doc.exists;
  }
}
```

### Admin Route Guard Pattern
```dart
// AdminGuard widget
class AdminGuard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(adminUserProvider);
    final isAdminAsync = ref.watch(isAdminProvider);
    
    return userAsync.when(
      data: (user) => isAdminAsync.when(
        data: (isAdmin) {
          if (!isAdmin || user == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(AppRouter.adminLogin);
            });
            return LoadingWidget();
          }
          return child;
        },
        ...
      ),
      ...
    );
  }
}
```

### Recipe Model Firestore Helpers
```dart
// Recipe model
class Recipe {
  // Firestore'dan okuma
  factory Recipe.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Recipe(
      id: doc.id,
      title: data['title'] ?? '',
      // ...
    );
  }
  
  // Firestore'a yazma
  Map<String, dynamic> toFirestore() => {
    'title': title,
    'ingredients': ingredients,
    // ...
  };
}
```

---

## 🧪 Testing Pattern (Gelecek)

### Unit Tests
- Services (DeepSeekService, AdminAuthService, RecipeParser)
- Repositories (RecipeRepository)
- Providers (state management logic)

### Widget Tests
- Reusable widgets
- Feature pages (critical paths)
- Admin paneli sayfaları

### Integration Tests
- End-to-end user flows
- API integration tests
- Firebase integration tests

---

## 📱 Platform-Specific Patterns

### Flutter Best Practices
- **const constructors:** Mümkün olduğunca const kullanımı
- **StatefulWidget vs StatelessWidget:** Gereksiz state'ten kaçınma
- **Dispose:** Controllers ve focus nodes dispose edilmeli
- **Build Context:** `mounted` kontrolü async işlemlerden sonra

### Performance Optimizations
- **Lazy Loading:** ListView.builder ile sadece görünen item'lar render edilir
- **Image Optimization:** Gelecekte cached_network_image kullanılabilir
- **Provider Optimization:** `select()` ile gereksiz rebuild'ler önlenir
- **KeepAlive:** Admin providers için session boyunca aktif kalır

### Web-Specific Patterns
- **Responsive Design:** Admin paneli desktop-friendly (sidebar layout)
- **Platform Detection:** `kIsWeb` ile web-specific kod
- **Route Handling:** Web'de hash routing (`/#/admin/login`)

---

## 🔄 Data Flow Pattern

### Tarif Listesi Akışı
```
User Action → HomePage → recipeListProvider → RecipeRepository → 
  → getRecipes() → Firestore Query → Recipe.fromFirestore() → List<Recipe> → UI Update
  → Hata durumunda: Local JSON fallback
```

### AI Tarif Üretimi Akışı
```
User Input → RecipeGeneratorPage → ingredientListProvider → 
  → Generate Button → generatedRecipeProvider → DeepSeekService → 
  → API Call → Response → RecipeParser → Recipe → RecipeDetailSheet
```

### Chat Akışı
```
User Message → ChatPage → chatMessagesProvider.add() → 
  → DeepSeekService.chatWithMascot() → API Call → 
  → Response → chatMessagesProvider.add() → UI Update
```

### Admin Paneli Akışı
```
Admin Login → AdminLoginPage → AdminAuthService.signInWithEmailAndPassword() →
  → Firebase Auth → Firestore admins check → AdminDashboardPage →
  → adminRecipeListProvider → RecipeRepository.getRecipes() → Firestore →
  → Recipe List → UI Update
```

---

## 🚀 Future Architecture Patterns

### Photo Upload Pattern (Gelecek)
```dart
// Gelecek: Photo Upload Service
class PhotoUploadService {
  Future<String> uploadPhoto(File photo) async {
    // Compress photo (flutter_image_compress)
    final compressed = await compressImage(photo, targetSize: 200 * 1024); // 200 KB
    // Upload to Firebase Storage
    final ref = _storage.ref().child('submissions/${DateTime.now()}.jpg');
    await ref.putFile(compressed);
    return await ref.getDownloadURL();
  }
}
```

### Scoring Pattern (Gelecek)
```dart
// Gelecek: Scoring Service
class ScoringService {
  Future<void> scoreSubmission(String submissionId, int points) async {
    await _firestore.collection('submissions').doc(submissionId).update({
      'points': points,
      'scoredBy': currentUserId,
      'scoredAt': FieldValue.serverTimestamp(),
      'status': 'scored',
    });
  }
}
```

---

## 📚 Key Design Decisions

1. **Riverpod over Provider:** Daha modern, compile-time safety
2. **GoRouter over Navigator 2.0:** Daha basit declarative routing
3. **Freezed for Models:** Immutability ve JSON serialization kolaylığı
4. **Feature-based Structure:** Scalability ve maintainability için
5. **Repository Pattern:** Data source abstraction için
6. **Service Layer:** Business logic separation için
7. **Flutter Web for Admin:** Tek codebase, aynı modeller ve repository'ler
8. **Firebase Spark Plan:** Ücretsiz başlangıç, gerekirse Blaze'a geçiş

---

## 🔗 İlgili Dokümanlar

- [Project Brief](projectbrief.md)
- [Tech Context](techContext.md)
- [Active Context](activeContext.md)
