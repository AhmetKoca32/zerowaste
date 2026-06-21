# Tech Context: Atıksız Mutfak

**Son Güncelleme:** Mayıs 2026

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

### Firebase
- **firebase_core:** ^3.8.1
- **firebase_auth:** ^5.3.3 (web admin paneli)
- **cloud_firestore:** ^5.5.2 (tarif, post, leaderboard veritabanı)
- **Firebase Spark (Ücretsiz) Plan:** 1GB depolama, 10K belge yazma/gün, 50K okuma/gün
  - Storage: 5GB depolama, 20KB yükleme/gün, 20KB indirme/gün
  - Hosting: 10GB depolama, 100MB/gün bant genişliği

### Data & Storage
- **shared_preferences:** ^2.3.3 (RecentIngredients, SavedRecipes, ChatSuggestions, nickname, missions, points cache)
- **path_provider:** ^2.1.4

### UI & Content
- **flutter_markdown:** ^0.7.4+1 (EcoChef sohbet balonlarında Markdown render)
- **image_picker:** ^1.1.2 (kamera/galeri entegrasyonu)
- **flutter_svg:** ^2.0.17 (SVG logolar, splash ekranı sponsor logoları)

### Localization
- **flutter_localizations:** Çoklu dil desteği
- **intl:** ARB dosya tabanlı string yönetimi
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
│   │   ├── network/            # NetworkService (Dio + redacted log)
│   │   ├── providers/          # Global providers (localeProvider)
│   │   ├── router/             # AppRouter (GoRouter)
│   │   ├── services/           # DeepSeekService
│   │   ├── shell/              # MainTabShell, CustomBottomNav, tabIndexProvider
│   │   ├── theme/              # AppTheme, AppColors, AppTextStyle
│   │   └── widgets/
│   │
│   ├── features/
│   │   ├── home/               # Tarif listesi + malzeme filtreleme
│   │   ├── recipe_generator/   # AI tarif üretimi
│   │   ├── chat/               # EcoChef sohbet
│   │   ├── splash/             # Splash açılış ekranı
│   │   └── points/             # Puan sistemi (Firestore bağlantılı)
│   │       ├── data/models/    # PostEntry, LeaderboardDoc
│   │       ├── data/repositories/ # PointsRepository (Firestore)
│   │       └── presentation/   # PointsPage, PointsHeroCard, RecentPostsGrid, MissionCards
│   │
│   ├── l10n/                   # ARB dosyaları (app_en.arb, app_tr.arb)
│   ├── firebase_options.dart
│   └── main.dart
│
├── assets/
│   ├── data/recipes.json       # Fallback tarifler
│   ├── fonts/                  # Manrope ailesi
│   └── images/icons/           # PNG ikonlar (denizati.png, ab-baskanligi-logo.png, vb.)
│
├── firestore.rules
├── firebase.json
└── memory-bank/
```

---

## Önemli Dosya Listesi

### Points Feature
| Dosya | Açıklama |
|-------|----------|
| `lib/features/points/data/models/post_entry.dart` | PostEntry model + Firestore serileştirme (fromFirestore/toFirestore), çift dilli adminNote, isAdminPenalty |
| `lib/features/points/data/models/leaderboard_doc.dart` | LeaderboardEntry + LeaderboardDoc modelleri |
| `lib/features/points/data/repositories/points_repository.dart` | PointsRepository: submitPost, getPostsByNickname, approvePost, rejectPost, getLeaderboard, _recalculateLeaderboard, deductPoints, addBonusPoints, optOutUser |
| `lib/features/points/presentation/pages/points_page.dart` | Ana points sayfası: ConsumerStatefulWidget, tab switch listener, _loadPosts, SharedPrefs karşılaştırma, animasyon yönetimi |
| `lib/features/points/presentation/widgets/points_hero_card.dart` | Gamification hero card: 2 modlu animasyon, _GradientArcPainter, _BackgroundRingPainter |
| `lib/features/points/presentation/widgets/recent_posts_grid.dart` | Gönderi gridi + admin bonus/penalty kartları |
| `lib/features/points/presentation/widgets/mission_cards.dart` | Günlük görev kartları (staggered giriş animasyonu) |

### Core
| Dosya | Açıklama |
|-------|----------|
| `lib/core/shell/main_tab_shell.dart` | Tab yapısı + tabIndexProvider + locale toggle |
| `lib/core/shell/custom_bottom_nav.dart` | Liquid glass navbar |
| `lib/core/services/deep_seek_service.dart` | DeepSeek API servisi |

### L10n
| Dosya | Açıklama |
|-------|----------|
| `lib/l10n/app_en.arb` | İngilizce string'ler |
| `lib/l10n/app_tr.arb` | Türkçe string'ler |

---

## Firestore Koleksiyon Yapısı

### `posts` koleksiyonu
```
/posts/{postId}
  nickname: string (zorunlu)
  category: string (Dolap / Yemek Anı / Artık Değerlendirme / Diğer / Puan Kesintisi / Admin Bonusu)
  points: int (negatif olabilir, kesinti için)
  status: string (pending / approved / rejected)
  createdAt: timestamp
  leaderboardOptIn: bool
  imagePath: string? (ileride Storage URL)
  imageColor: int? (placeholder rengi)
  isAdminBonus: bool
  isAdminPenalty: bool
  adminNote: string? (TR not)
  adminNoteEn: string? (EN not)
```

### `leaderboard/current` dokümanı
```
/leaderboard/current
  entries: [{nickname: string, points: int}]
  lastUpdated: timestamp
```

### `admins/{userId}` dokümanı
```
/admins/{userId}
  role: string? ("admin" veya boş)
```

---

## Firestore Index'leri (Manuel Oluşturuldu)
1. `posts` koleksiyonu: `status` (Asc) + `createdAt` (Desc)
2. `posts` koleksiyonu: `nickname` (Asc) + `createdAt` (Desc)
3. `posts` koleksiyonu: `status` (Asc) + `leaderboardOptIn` (Asc)

---

## SharedPreferences Anahtarları

| Anahtar | Kullanım |
|---------|----------|
| `leaderboard_nickname` | Kullanıcının takma adı |
| `leaderboard_opt_in` | Leaderboard'a katılım izni |
| `last_known_points_{nickname}` | Son bilinen puan (değişiklik tespiti için) |
| `missions_date` | Günlük görevlerin son sıfırlanma tarihi |
| `missions_completed` | Tamamlanan görev listesi ['fridge', 'cooking', 'leftovers'] |

---

## Development Setup

### Kurulum
1. `flutter pub get`
2. `.env` dosyası oluştur: `DEEPSEEK_API_KEY=your_key`
3. `dart run build_runner build --delete-conflicting-outputs`

### Build Commands
```bash
flutter build apk --release          # Android
dart run build_runner build --delete-conflicting-outputs  # Code gen
flutter clean                         # Build cache temizle
```

---

## Gelecek Teknik Planlar

### Admin Panel Web'e Taşıma
- Ayrı Flutter Web projesi oluşturulacak
- Firebase Hosting'e deploy edilecek
- Kullanıcı silme/opt-out durumunun admin panele yansıması sağlanacak

### Firebase Spark Plan Kısıtlamalarını Aşma
- Firestore: 10K yazma/gün, 50K okuma/gün
- Storage: 20KB/gün upload (son derece yetersiz)
- Blaze geçişi değerlendirilecek (tahmini maliyet $0-$5/ay)
- Stream yerine tek seferlik get() kullanımı ile okuma sayısı minimize edildi

### Fotoğraf Yükleme Alternatifleri
1. 🔴 Firebase Storage (Spark limitleri çok düşük)
2. 🟡 **Google Drive API** (öncelikli alternatif)
3. ⚪ Base64 Firestore'da saklama (son çare, önerilmez)
