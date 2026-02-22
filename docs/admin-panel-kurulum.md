# Admin Panel Kurulum

**Tarih:** Şubat 2025

---

## ✅ Yapılanlar

- Desktop-friendly **sidebar** layout
- **Tarif CRUD:** listeleme, ekleme, düzenleme, silme
- **Firebase Auth** ile giriş
- **Admin kontrolü:** Firestore `admins` collection
- **Route guard:** Giriş yapmamış veya admin değilse login'e yönlendirme

---

## 🔧 Kurulum Adımları

### 1. Firebase Authentication (Email/Password)

1. [Firebase Console](https://console.firebase.google.com/project/zerowaste-46d54/authentication) → **Authentication**
2. **Get started** (henüz açılmadıysa)
3. **Sign-in method** sekmesi → **Email/Password** → **Enable** → Kaydet
4. İlk admin kullanıcıyı **Users** sekmesinden **Add user** ile ekle (email + şifre)

### 2. Firestore'da Admin Kaydı

Giriş yapabilsin diye kullanıcının **admin** sayılması gerekiyor. Bunun için Firestore'da `admins` collection'ına, **document ID = Firebase Auth UID** olan bir döküman eklemen lazım.

**Yöntem A – Console’dan:**

1. Firebase Console → **Authentication** → **Users** → ilgili kullanıcıyı aç
2. **User UID** değerini kopyala (örn. `abc123xyz...`)
3. **Firestore Database** → **Start collection** (veya mevcut projede devam et)
4. Collection ID: **`admins`**
5. Document ID: **yapıştırdığın UID** (kullanıcının Auth UID’si)
6. İstediğin alanları ekle, örn.:
   - `email` (string): admin email
   - `role` (string): `admin`
   - `createdAt` (timestamp): şu an

**Yöntem B – Örnek yapı:**

```
Collection: admins
Document ID: <Firebase Auth User UID>
Fields:
  - email: "admin@example.com"
  - role: "admin"
  - createdAt: <timestamp>
```

Bu döküman yoksa `AdminAuthService.isCurrentUserAdmin()` false döner ve giriş sonrası “Bu kullanıcı admin değil” hatası alırsın.

### 3. Web’de Çalıştırma

```bash
flutter pub get
flutter run -d chrome
```

Tarayıcıda admin panele gitmek için:

- **Login:** `http://localhost:xxxx/#/admin/login`
- **Dashboard (giriş sonrası):** `http://localhost:xxxx/#/admin/dashboard`

Production’da aynı path’ler kullanılır, sadece domain değişir:
- `https://your-domain.com/#/admin/login`
- `https://your-domain.com/#/admin/dashboard`

---

## 🛣️ Admin Route’lar

| Path | Açıklama |
|------|----------|
| `/admin/login` | Admin giriş sayfası |
| `/admin/dashboard` | Tarif listesi (sidebar ile) |
| `/admin/recipes/new` | Yeni tarif formu |
| `/admin/recipes/:id` | Tarif düzenleme formu |

---

## 🔒 Güvenlik

- **Frontend:** Sadece admin sayfalarına erişim; yetkisiz kullanıcı login’e yönlendirilir.
- **Backend:** Firestore Security Rules ile `recipes` ve `admins` için kuralları sıkılaştır (production’da mutlaka yap).

Örnek kurallar için `docs/admin-panel-implementation-plan.md` içindeki “Firestore Rules” bölümüne bak.

---

## 📁 Eklenen Dosyalar

```
lib/features/admin/
├── services/
│   └── admin_auth_service.dart
├── presentation/
│   ├── pages/
│   │   ├── admin_login_page.dart
│   │   ├── admin_dashboard_page.dart
│   │   └── admin_recipe_edit_page.dart
│   ├── providers/
│   │   ├── admin_providers.dart
│   │   └── admin_providers.g.dart
│   └── widgets/
│       ├── admin_guard.dart
│       ├── admin_sidebar.dart
│       └── admin_recipe_form.dart
```

---

**Son Güncelleme:** Şubat 2025
