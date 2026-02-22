# Admin Panel Implementation Plan

**Tarih:** Şubat 2025  
**Yaklaşım:** Flutter Web - Aynı Proje İçinde

---

## 🎯 Amaç

Dışarıdan tarif ekleme, düzenleme ve silme için web admin paneli.

---

## 📋 Özellikler

### 1. Authentication
- Email/Password ile giriş
- Firebase Authentication kullanılacak
- Admin kontrolü (Firestore'da `admins` collection)

### 2. Admin Dashboard
- Tarif listesi (tüm tarifler)
- Tarif ekleme formu
- Tarif düzenleme
- Tarif silme
- Basit arama

### 3. Güvenlik
- Sadece admin kullanıcılar erişebilir
- Route guard (giriş yapmamış kullanıcılar yönlendirilir)
- Firestore Security Rules ile backend kontrolü

---

## 🗂️ Dosya Yapısı

```
lib/
├── features/
│   └── admin/                    # Yeni admin feature
│       ├── data/
│       │   └── models/
│       │       └── admin_user.dart (opsiyonel)
│       ├── presentation/
│       │   ├── pages/
│       │   │   ├── admin_login_page.dart
│       │   │   ├── admin_dashboard_page.dart
│       │   │   └── admin_recipe_edit_page.dart
│       │   ├── providers/
│       │   │   └── admin_providers.dart
│       │   └── widgets/
│       │       └── admin_recipe_form.dart
│       └── services/
│           └── admin_auth_service.dart
```

---

## 🛣️ Route Yapısı

### Mobil Routes (Mevcut)
- `/` → Ana sayfa (tarifler)
- `/generate` → Tarif oluştur
- `/chat` → Leafy sohbet
- `/puan` → Puan sayfası

### Web Admin Routes (Yeni)
- `/admin/login` → Admin giriş sayfası
- `/admin/dashboard` → Admin dashboard (tarif listesi)
- `/admin/recipes/new` → Yeni tarif ekleme
- `/admin/recipes/:id` → Tarif düzenleme

**Not:** Web'de `/admin/*` route'ları admin paneli, mobilde normal uygulama açılır.

---

## 🔐 Authentication Flow

1. Admin `/admin/login` sayfasına gider
2. Email/password ile giriş yapar
3. Firebase Auth ile authenticate olur
4. Firestore'da `admins` collection'ında kontrol edilir
5. Admin ise dashboard'a yönlendirilir
6. Session korunur (Firebase Auth otomatik yönetir)

---

## 📊 Firestore Yapısı

### Collection: `admins`
```json
{
  "email": "admin@zerowaste.com",
  "name": "Admin User",
  "role": "admin",
  "createdAt": "2025-02-19T10:00:00Z"
}
```

**Not:** Admin kullanıcıları Firebase Console'dan manuel eklenir (Firestore'da `admins` collection'ına document olarak).

### Collection: `recipes` (Mevcut)
- Admin panelinden eklenen/güncellenen tarifler

---

## 🎨 UI Tasarım

- **Tema:** Mevcut app teması (AppColors, AppTheme)
- **Layout:** Desktop-friendly (sidebar navigation veya üst menü)
- **Form:** Material Design form elemanları
- **Responsive:** Desktop ve tablet için optimize

---

## 📝 Implementation Adımları

1. ✅ Plan oluşturuldu
2. ⏳ `firebase_auth` paketi ekle
3. ⏳ Admin feature klasör yapısı oluştur
4. ⏳ Admin auth service oluştur
5. ⏳ Admin login sayfası
6. ⏳ Admin dashboard sayfası
7. ⏳ Tarif ekleme/düzenleme formu
8. ⏳ Router'a admin route'ları ekle
9. ⏳ Route guard (admin kontrolü)
10. ⏳ Firestore Security Rules güncelle

---

## 🔒 Güvenlik

### Frontend
- Route guard ile yetkisiz erişimi engelle
- Admin kontrolü provider ile yapılır

### Backend (Firestore Rules)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Recipes - admin yazabilir, herkes okuyabilir
    match /recipes/{recipeId} {
      allow read: if true;
      allow write: if request.auth != null && 
        exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    
    // Admins - sadece admin okuyabilir
    match /admins/{adminId} {
      allow read: if request.auth != null && 
        exists(/databases/$(database)/documents/admins/$(request.auth.uid));
      allow write: if false; // Sadece Firebase Console'dan eklenir
    }
  }
}
```

---

## 🚀 Test Senaryoları

1. Admin giriş yapabilmeli
2. Admin olmayan kullanıcı erişememeli
3. Tarif ekleme çalışmalı
4. Tarif düzenleme çalışmalı
5. Tarif silme çalışmalı
6. Form validasyonu çalışmalı
7. Hata durumları handle edilmeli

---

## 📋 Checklist

- [ ] Firebase Authentication setup
- [ ] Admin kullanıcıları Firestore'a ekle
- [ ] Admin feature klasör yapısı
- [ ] Admin auth service
- [ ] Admin login page
- [ ] Admin dashboard page
- [ ] Recipe add/edit form
- [ ] Router'a admin routes ekle
- [ ] Route guard implementasyonu
- [ ] Firestore Security Rules güncelle
- [ ] Test et

---

**Son Güncelleme:** Şubat 2025
