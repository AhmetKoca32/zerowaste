# Tech Context: Sıfır Atık Mutfak

**Son Guncelleme:** Mayis 2026

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
- **firebase_auth:** ^5.3.3 (admin paneli)
- **cloud_firestore:** ^5.5.2 (tarif, post, leaderboard veritabani)
- **Firebase Spark (Ucretsiz) Plan:** 1GB depolama, 10K belge yazma/gun, 50K okuma/gun

### Data & Storage
- **shared_preferences:** ^2.3.3 (RecentIngredients, SavedRecipes, ChatSuggestions, nickname)
- **path_provider:** ^2.1.4

### UI & Content
- **flutter_markdown:** ^0.7.4+1 (EcoChef sohbet balonlarinda Markdown render)
- **image_picker:** ^1.1.2 (kamera/galeri entegrasyonu)
- **flutter_svg:** ^2.0.17 (SVG logolar, splash ekrani sponsor logolari)

### Code Generation
- **freezed:** ^2.5.7 + freezed_annotation
- **json_serializable:** ^6.8.0 + json_annotation
- **build_runner:** ^2.4.13
- **riverpod_generator:** ^2.6.3

---

## Proje Yapisi

```
zerowaste/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── network/            # NetworkService (Dio + redacted log)
│   │   ├── providers/          # Global providers
│   │   ├── router/             # AppRouter (GoRouter, 10+ route)
│   │   ├── services/           # DeepSeekService
│   │   ├── shell/              # MainTabShell, CustomBottomNav
│   │   ├── theme/              # AppTheme, AppColors, AppTextStyle
│   │   └── widgets/
│   │
│   ├── features/
│   │   ├── home/               # Tarif listesi + malzeme filtreleme
│   │   ├── recipe_generator/   # AI tarif uretimi
│   │   ├── chat/               # EcoChef sohbet
│   │   ├── splash/             # Splash acilis ekrani
│   │   ├── points/             # Puan sistemi (Firestore baglantili)
│   │   │   ├── data/models/    # PostEntry, LeaderboardDoc
│   │   │   ├── data/repositories/ # PointsRepository (Firestore)
│   │   │   └── presentation/   # Page, Widgets, Providers
│   │   └── admin/              # Admin paneli (Web)
│   │       ├── data/           # (yeni modeller Points'ten import edilir)
│   │       └── presentation/   # Pages, Providers, Widgets, Services
│   │
│   ├── firebase_options.dart
│   └── main.dart
│
├── assets/
│   ├── data/recipes.json       # 7 detayli tarif (fallback)
│   ├── fonts/                  # Manrope ailesi
│   └── images/icons/ + image/  # PNG ikonlar (denizati.png dahil)
│
├── firestore.rules             # recipes, posts, leaderboard, admins koleksiyonlari
├── firebase.json
└── memory-bank/
```

---

## Onemli Dosya Listesi

### Points Feature (Yeni Firestore yapisi)
| Dosya | Aciklama |
|-------|----------|
| `lib/features/points/data/models/post_entry.dart` | **YENI** PostEntry model + Firestore serilestirme (fromFirestore/toFirestore) |
| `lib/features/points/data/models/leaderboard_doc.dart` | **YENI** LeaderboardEntry + LeaderboardDoc modelleri |
| `lib/features/points/data/repositories/points_repository.dart` | **YENI** PointsRepository: submitPost, getPostsByNickname, getPendingPosts, approvePost, rejectPost, getLeaderboard |
| `lib/features/points/presentation/providers/points_providers.dart` | **YENI** pointsRepositoryProvider (Riverpod) |

### Admin Feature (Guncel)
| Dosya | Aciklama |
|-------|----------|
| `admin_login_page.dart` | Email/Password giris |
| `admin_dashboard_page.dart` | **GUNCELLENDI** Tarif listesi (InkWell bazli, ListTile yok) |
| `admin_recipe_edit_page.dart` | **GUNCELLENDI** Tarif CRUD AdminShell'e baglandi |
| `admin_recipe_form.dart` | **GUNCELLENDI** Form.of() -> widget.formKey duzeltmesi |
| `admin_sidebar.dart` | **YENIDEN YAZILDI** AdminShell: responsive (sidebar/drawer), tek Scaffold |
| `admin_posts_page.dart` | **YENI** Gonderi onay/red sayfasi |
| `admin_guard.dart` | Auth guard (admin yetkisi kontrolu) |
| `admin_auth_service.dart` | Firebase Auth servisi |

### Home Data (Guncel)
| Dosya | Aciklama |
|-------|----------|
| `lib/features/home/data/services/recipe_sync_service.dart` | **YENI** Gunluk Firestore tarif senkronizasyonu |

---

## Firestore Koleksiyon Yapisi

### `posts` koleksiyonu
```
/posts/{postId}
  nickname: string (zorunlu)
  category: string (Dolap / Yemek Ani / ...)
  points: int
  status: string (pending / approved / rejected)
  createdAt: timestamp
  leaderboardOptIn: bool
  imagePath: string? (ileride Storage URL)
  imageColor: int? (placeholder rengi)
  isAdminBonus: bool
  adminNote: string?
```

### `leaderboard/current` dokumani
```
/leaderboard/current
  entries: [{nickname: string, points: int}]
  lastUpdated: timestamp
```

### `admins/{userId}` dokumani
```
/admins/{userId}
  (bos ya da role: "admin")
```

---

## Firestore Index'leri (Manuel Olusturuldu)
1. `posts` koleksiyonu: `status` (Asc) + `createdAt` (Desc)
2. `posts` koleksiyonu: `nickname` (Asc) + `createdAt` (Desc)
3. `posts` koleksiyonu: `status` (Asc) + `leaderboardOptIn` (Asc)

---

## Development Setup

### Kurulum
1. `flutter pub get`
2. `.env` dosyasi olustur: `DEEPSEEK_API_KEY=your_key`
3. `dart run build_runner build --delete-conflicting-outputs`

### Build Commands
```bash
flutter build apk --release          # Android
flutter build web --release           # Admin paneli (web)
flutter run -d chrome                 # Web gelistirme
dart run build_runner build --delete-conflicting-outputs  # Code gen
flutter clean                         # Build cache temizle
```

---

## Gelecek Teknik Planlar

### Admin Panel Web'e Tasima
- Ayri Flutter Web projesi olusturulacak
- Firebase Hosting'e deploy edilecek
- Mobil uygulama icindeki admin route'lari kaldirilacak veya gizlenecek
- Eger hosting plani sorun cikarirsa, mobilde gizli yol birakilacak

### Firebase Plan Degerlendirmesi
- Spark (ucretsiz): Storage icin 5GB, 20KB/gun upload -- yetersiz olabilir
- Blaze (kullandikca ode): sinirsiz, sadece kullanim kadar odenir
- Storage eklenmesi durumunda Blaze gecisi onerilir

### Gorsel Paylasimi Alternatifleri
1. Firebase Storage (oncelikli)
2. Firebase Storage kotasi asilirsa -> Google Drive API
3. Base64 Firestore'da saklama (son care, onerilmez)
