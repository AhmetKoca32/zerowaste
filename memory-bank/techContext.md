# Tech Context: Atıksız Mutfak

**Son Güncelleme:** Ağustos 2026 (2 Ağustos)

---

## Teknoloji Stack

### Core Framework
- **Flutter:** 3.10.7+ (cross-platform mobile framework)
- **Dart:** 3.10.7+ (programming language)

### State Management
- **flutter_riverpod:** ^2.6.1
- **riverpod_annotation:** ^2.6.1
- **riverpod_generator:** ^2.6.3 (dev)

### Routing & Navigation
- **go_router:** ^14.6.2

### Network & API
- **dio:** ^5.7.0 (HTTP client, redacted log interceptor)
- **flutter_dotenv:** ^5.2.1 (environment variables)
- **DeepSeek** chat completions (OpenAI-compatible)
  - Recipe: single-turn
  - EcoChef: multi-turn — last **20** bubbles; assistant history truncate ~**1200** chars

### Firebase
- **firebase_core:** ^3.8.1
- **firebase_auth:** ^5.3.3 (anonim oturum + admin web paneli)
- **firebase_storage:** ^12.3.6 (gönderi fotoğrafları)
- **cloud_firestore:** ^5.5.2 (tarif, post, leaderboard, user_profiles)
- **Firebase Blaze Plan (Kullandıkça Öde):** Spark'tan yükseltildi (Temmuz 2026)
  - Storage: 5 GB depolama, günde 1 GB upload (ücretsiz kota içinde)
  - Düşük trafikli uygulama için aylık maliyet çoğunlukla $0
  - Bütçe uyarısı önerilir ($5–10)

### Data & Storage
- **shared_preferences:** ^2.3.3
  - Günlük sayaçlar, öneriler, missions, nickname
  - **EcoChef session:** `ecochef_chat_session` (JSON, 24h TTL, max 50 bubbles) — cloud chat store yok
- **path_provider:** ^2.1.4
- **cached_network_image:** ^3.4.1 (gönderi fotoğrafı thumbnail)

### UI & Content
- **flutter_markdown:** ^0.7.4+1
- **image_picker:** ^1.1.2
- **flutter_svg:** ^2.0.17

### Localization
- **flutter_localizations** + **intl**
- Desteklenen diller: Türkçe (TR) + İngilizce (EN)

### Code Generation
- **freezed:** ^2.5.7 + freezed_annotation
- **json_serializable:** ^6.8.0 + json_annotation
- **build_runner:** ^2.4.13
- **riverpod_generator:** ^2.6.3

---

## Proje Yapısı

```
zerowaste/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── network/            # NetworkService (Dio)
│   │   ├── providers/          # core_providers (DeepSeek, Auth, Storage)
│   │   ├── router/             # AppRouter (GoRouter)
│   │   ├── services/
│   │   │   ├── deep_seek_service.dart   # mascotHistoryLimit = 20
│   │   │   ├── anonymous_auth_service.dart
│   │   │   └── post_image_storage_service.dart
│   │   ├── shell/              # MainTabShell (extendBody: true), CustomBottomNav
│   │   ├── theme/
│   │   └── widgets/
│   │
│   ├── features/
│   │   ├── home/               # Tarif listesi + RecipesComingSoon
│   │   ├── recipe_generator/   # AI tarif üretimi
│   │   ├── chat/
│   │   │   ├── data/
│   │   │   │   ├── chat_message_entry.dart
│   │   │   │   └── chat_session_storage.dart
│   │   │   └── presentation/
│   │   ├── splash/
│   │   └── points/             # Puan sistemi + gönderi upload
│   │
│   ├── l10n/
│   ├── firebase_options.dart
│   └── main.dart               # Firebase init + anonim auth startup
│
├── assets/data/recipes.json    # Referans veri (runtime'da kullanılmıyor)
├── firestore.rules
├── storage.rules
├── firebase.json
└── memory-bank/
```

---

## EcoChef Limitleri (referans)

| Limit | Değer | Nerede |
|-------|-------|--------|
| Günlük user mesaj | 20 | `DailyMessageCount.maxMessages` |
| API context balon | 20 | `DeepSeekService.mascotHistoryLimit` |
| Disk session balon | 50 | `ChatSessionStorage.maxMessages` |
| Session TTL | 24h | `ChatSessionStorage.ttl` |
| History assistant truncate | ~1200 chars | `_maxHistoryAssistantChars` |

---

## Önemli Dosya Listesi

### Core Services
| Dosya | Açıklama |
|-------|----------|
| `lib/core/services/deep_seek_service.dart` | DeepSeek API; EcoChef multi-turn history + recipe single-turn |
| `lib/core/services/anonymous_auth_service.dart` | Anonim Auth; 20 sn timeout |
| `lib/core/services/post_image_storage_service.dart` | `putData(bytes)`, max 2 MB, 90 sn timeout |
| `lib/core/providers/core_providers.dart` | networkService, deepSeek, anonymousAuth, postImageStorage |

### Chat
| Dosya | Açıklama |
|-------|----------|
| `lib/features/chat/data/chat_session_storage.dart` | SharedPreferences session, 24h TTL |
| `lib/features/chat/data/chat_message_entry.dart` | text + isUser (+ JSON) |
| `lib/features/chat/presentation/providers/chat_providers.dart` | DailyMessageCount, ChatMessages, suggestions |
| `lib/features/chat/presentation/pages/chat_page.dart` | Stack layout, typewriter gate, priorTurns |

### Home / Recipes
| Dosya | Açıklama |
|-------|----------|
| `lib/features/home/data/models/recipe.dart` | Recipe model: title, description, ingredients[], instructions[], image_url |
| `lib/features/home/data/repositories/recipe_repository.dart` | Firestore-only; boşsa `[]` döner |
| `lib/features/home/presentation/widgets/recipes_coming_soon.dart` | Boş tarif listesi placeholder |
| `lib/features/home/presentation/widgets/recipe_detail_sheet.dart` | ingredients bullet, instructions numaralı |

### Points Feature
| Dosya | Açıklama |
|-------|----------|
| `lib/features/points/data/models/post_entry.dart` | imageUrl, localPreviewPath, çift dilli adminNote |
| `lib/features/points/data/repositories/points_repository.dart` | submitPost, approvePost, leaderboard, optOutUser |
| `lib/features/points/presentation/pages/points_page.dart` | Storage upload → Firestore; clears chat on soft-delete/opt-out |
| `lib/features/points/presentation/widgets/post_image_thumbnail.dart` | CachedNetworkImage + local preview |

---

## Firestore Koleksiyon Yapısı

### `recipes` koleksiyonu
```
/recipes/{recipeId}
  title: string (zorunlu)
  description: string? (opsiyonel, tek paragraf)
  image_url: string? (opsiyonel)
  ingredients: string[] (zorunlu, her eleman mobilde ayrı madde)
  instructions: string[] (zorunlu, sıra = adım numarası)
```
**Rules:** read herkese açık; write sadece `admins/{uid}` olan kullanıcılar.

### `posts` koleksiyonu
```
/posts/{postId}
  nickname: string
  category: string
  points: int
  status: string (pending / approved / rejected)
  createdAt: timestamp
  leaderboardOptIn: bool
  imageUrl: string? (Firebase Storage download URL)
  imageColor: int? (placeholder rengi)
  isAdminBonus: bool
  isAdminPenalty: bool
  adminNote: string? (TR)
  adminNoteEn: string? (EN)
```
**Not:** Eski `imagePath` alanı legacy destek için `PostEntry.fromFirestore`'da okunur.

### `leaderboard/current` dokümanı
```
  entries: [{nickname: string, points: int}]
  lastUpdated: timestamp
```

### `admins/{userId}` dokümanı
```
  role: string? ("admin")
```

### `user_profiles/{nickname}` (soft-delete)
```
  status: "deleted"
  reason / reasonEn?: string
```
Client read-only; yazma admin.

---

## Firebase Storage Yapısı

### Path: `posts/{postId}/photo.jpg`
- Max 2 MB, `image/jpeg` content type
- Public read; write sadece authenticated (anonim dahil)
- Rules: `storage.rules`

### Upload Akışı
```
image_picker → readAsBytes() → anonymousAuth.ensureSignedIn() (20s timeout)
  → postId = repo.newPostId()
  → PostImageStorageService.uploadPostImage(bytes, postId) (90s timeout)
  → download URL → PostEntry.imageUrl → Firestore submitPost()
```

---

## Ortam Değişkenleri

`.env` / `--dart-define`:
- `DEEPSEEK_API_KEY`

---

## Geliştirme Notları

- `MainTabShell.extendBody: true` — floating navbar; chat/points bottom padding ile içerik altına uzar
- Chat cloud’a yazılmaz; sadece cihaz SharedPreferences
- Admin paneli ayrı Flutter web repo
