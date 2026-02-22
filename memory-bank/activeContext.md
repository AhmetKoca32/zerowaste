# Active Context: ZeroWaste Mutfak

**Son Güncelleme:** Şubat 2025  
**Aktif Çalışma:** Firebase entegrasyonu tamamlandı, admin paneli aktif

---

## 🎯 Şu Anki Odak

### Ana Görev
Firebase backend entegrasyonu ve admin paneli tamamlandı. Şimdi:
- Admin kullanıcıları ekleme (Firebase Console)
- İlk tarifleri Firestore'a ekleme
- Web'de admin panelini test etme

### Son Yapılanlar
1. ✅ Firebase projesi oluşturuldu (`zerowaste-46d54`)
2. ✅ FlutterFire CLI ile Firebase yapılandırması (`firebase_options.dart`)
3. ✅ Firestore entegrasyonu tamamlandı (`RecipeRepository` Firestore'a bağlandı)
4. ✅ Firebase Authentication eklendi (`firebase_auth`)
5. ✅ Admin paneli tamamlandı (Flutter Web, desktop-friendly sidebar)
6. ✅ Admin route'ları eklendi (`/admin/login`, `/admin/dashboard`, `/admin/recipes/*`)
7. ✅ Admin authentication ve route guard implementasyonu
8. ✅ Tarif CRUD işlemleri (ekleme, düzenleme, silme)
9. ✅ Memory Bank dokümantasyonu güncellendi

---

## 📋 Aktif Kararlar ve Düşünceler

### Backend Stratejisi
- **Durum:** ✅ Firebase entegrasyonu tamamlandı
- **Plan:** Firebase Spark (ücretsiz plan ile başlangıç)
- **Gerekçe:** 
  - Ücretsiz plan yeterli kapasite sunuyor (~5,000-8,000 aktif kullanıcı/gün)
  - Flutter ile kolay entegrasyon
  - Real-time özellikler için hazır
  - Authentication ve Storage dahil
- **Tamamlanan:**
  - ✅ Firestore Database aktif ve entegre
  - ✅ Firebase Authentication aktif (Email/Password)
  - ✅ Admin paneli ile tarif yönetimi
- **Bekleyen:**
  - ⏳ Cloud Storage (Spark plan limiti nedeniyle şimdilik bekliyor)

### Firebase Kapasite Planlaması
- **Fotoğraf Depolama:** ~15,000-20,000 fotoğraf (200-300 KB sıkıştırma ile)
- **Aktif Kullanıcı:** ~5,000-8,000/gün (orta aktivite senaryosu)
- **Tarif Sayısı:** ~10,000+ tarif
- **Sınırlayıcı Faktör:** Firestore günlük reads (50,000/gün)
- **Admin Paneli:** ~5-50 admin için Firebase Hosting Spark plan yeterli (%1-3 kullanım)

### Optimizasyon Gereksinimleri
1. **Fotoğraf Sıkıştırma:** Zorunlu (200-300 KB hedef) - Cloud Storage açıldığında
2. **Pagination:** Tarif listesi için gerekli (Firestore reads optimizasyonu)
3. **Cache Mekanizması:** Tarifler için local cache
4. **Reads Optimizasyonu:** Gereksiz okumaları azaltma

---

## 🚧 Yapılacaklar (Backlog)

### İlk Yapılacaklar (Öncelik Sırasıyla)
1. **Firebase bağlantısı test edilecek**
   - Firestore okuma/yazma testi
   - Auth bağlantı testi
   - Hata durumunda fallback davranışının doğrulanması

2. **Firestore şemaları kontrol edilecek**
   - `recipes` collection şeması oluşuyor mu / tutarlı mı kontrol
   - `admins` collection yapısı doğrulanacak
   - Gerekirse şema dokümantasyonu güncellenecek

3. **Nav bar arka planı kaldırılacak**
   - 2. sayfa (Oluştur), 3. sayfa (Leafy), 4. sayfa (Puan) sekmelerinde bottom navigation bar arka planı kaldırılacak
   - Sadece ilgili sayfalarda nav bar arka planı şeffaf/uyumlu yapılacak

4. **Gönderi özelliği aktifleştirilecek (ileride)**
   - Puan sistemi gönderi akışı (fotoğraf + kategori) backend’e bağlanacak
   - Firestore `submissions` (veya benzeri) collection ile entegrasyon
   - Cloud Storage hazır olduğunda fotoğraf yükleme devreye alınacak

### Öncelikli (Sıradaki)
1. **Admin Panel Kurulumu**
   - ✅ Firebase Authentication Email/Password aktif
   - ⏳ İlk admin kullanıcıyı Firebase Console'dan ekleme
   - ⏳ Firestore'da `admins` collection'ına admin kaydı ekleme
   - ⏳ Web'de admin panelini test etme

2. **Firestore Tarif Verisi**
   - ⏳ İlk tarifleri Firestore'a ekleme (Console'dan veya admin panelinden)
   - ⏳ Firestore Security Rules güncelleme (production için)

3. **Cloud Storage Entegrasyonu**
   - ⏳ Cloud Storage'ı açma (Spark plan limiti nedeniyle bekliyor)
   - ⏳ Fotoğraf upload servisi
   - ⏳ Fotoğraf sıkıştırma implementasyonu (`flutter_image_compress`)
   - ⏳ Storage rules yapılandırması

4. **Puan Sistemi Backend**
   - ⏳ Submission model'i tasarlama
   - ⏳ Fotoğraf upload akışı (Cloud Storage gerekli)
   - ⏳ Admin panelinde puanlama özelliği ekleme
   - ⏳ Puan hesaplama ve güncelleme

### Orta Vadeli
- Tarif arama ve filtreleme
- Pagination (Firestore reads optimizasyonu)
- Cache mekanizması
- Kullanıcı authentication (mobil uygulama için)
- Push notifications

### Uzun Vadeli
- Topluluk özellikleri
- Çoklu dil desteği
- Offline mode geliştirmeleri
- Analytics ve raporlama

---

## 💡 Önemli Öğrenmeler ve İçgörüler

### Firebase Limitleri
- En sıkı sınır: Firestore reads (50,000/gün)
- Optimizasyon kritik: Cache ve pagination şart
- Fotoğraf boyutu önemli: Sıkıştırma zorunlu
- Admin paneli için Firebase Hosting Spark plan yeterli (%1-3 kullanım)

### Proje Yapısı
- Feature-based klasör yapısı iyi çalışıyor
- Riverpod state management güçlü
- Repository pattern doğru seçim
- Flutter Web ile admin paneli tek codebase'de çalışıyor

### Kullanıcı Deneyimi
- Loading states önemli (ChefLoadingOverlay güzel çalışıyor)
- Error handling kullanıcı dostu olmalı
- Empty states anlamlı olmalı
- Desktop-friendly sidebar admin paneli için ideal

---

## 🎨 Tasarım Tercihleri

### Renk Paleti
- Doğa dostu pastel yeşiller (sage, mint, fern, moss, forest)
- Toprak tonları (sand, stone, terracotta, clay, bark)
- Nötr renkler (cream, paper, ink, inkLight)

### UI Patterns
- Blog-style kartlar (tarifler için)
- Bottom sheet'ler (detay sayfaları için)
- Slide transitions (sayfa geçişleri için)
- Custom bottom navigation (4 sekme - mobil)
- **Sidebar navigation (admin paneli - web)**

---

## 🔧 Teknik Tercihler ve Standartlar

### Code Style
- const constructors mümkün olduğunca
- Freezed ile immutable models
- Repository pattern data layer için
- Service layer business logic için

### Error Handling
- Custom exceptions (DeepSeekAuthException, vb.)
- User-friendly error mesajları
- Retry mekanizmaları (gelecek)

### Performance
- ListView.builder lazy loading
- Provider optimization (select kullanımı)
- Image caching (gelecek)
- KeepAlive providers (admin session için)

---

## 📝 Notlar ve Hatırlatmalar

### API Keys
- `.env` dosyası kullanılıyor (flutter_dotenv)
- Alternatif: `--dart-define` compile-time
- Production'da güvenli key management gerekli

### Fotoğraf Yönetimi
- Şu an: Local storage (SavedRecipesStorage)
- Gelecek: Cloud Storage (Spark plan limiti nedeniyle bekliyor)
- Sıkıştırma: flutter_image_compress paketi gerekli

### Backend Geçiş Stratejisi
1. ✅ Firestore entegrasyonu (tarifler) - Tamamlandı
2. ⏳ Cloud Storage (fotoğraflar) - Bekliyor
3. ⏳ Authentication (mobil uygulama kullanıcıları) - Gelecek

### Admin Panel
- **Platform:** Flutter Web (aynı proje içinde)
- **Layout:** Desktop-friendly sidebar
- **Authentication:** Firebase Auth (Email/Password)
- **Authorization:** Firestore `admins` collection kontrolü
- **Route Guard:** `AdminGuard` widget ile yetki kontrolü
- **Kapasite:** Firebase Hosting Spark plan yeterli (~5-50 admin için)

---

## 🔄 Son Değişiklikler

### Şubat 2025
- ✅ Firebase projesi oluşturuldu (`zerowaste-46d54`)
- ✅ FlutterFire CLI ile Firebase yapılandırması
- ✅ Firestore entegrasyonu tamamlandı
- ✅ Firebase Authentication eklendi
- ✅ Admin paneli tamamlandı (Flutter Web)
- ✅ Admin route'ları ve guard implementasyonu
- ✅ Tarif CRUD işlemleri
- ✅ Memory Bank dokümantasyonu güncellendi

---

## 🎯 Bir Sonraki Adımlar

**İlk yapılacaklar (sırayla):**
1. Firebase bağlantısını test et (Firestore + Auth).
2. Firestore şemalarının oluştuğunu / tutarlı olduğunu kontrol et (`recipes`, `admins`).
3. 2, 3, 4. sayfalardaki (Oluştur, Leafy, Puan) nav bar arka planını kaldır.
4. İleride: Gönderi özelliğini aktifleştir (puan sistemi + Firestore/Storage).

**Ardından:**
1. **Admin Kullanıcı Kurulumu**
   - Firebase Console → Authentication → Users → Add user (email + şifre)
   - User UID'yi kopyala
   - Firestore → Collection: `admins` → Document ID: UID → Fields ekle (email, role: "admin")

2. **İlk Tarifleri Ekleme**
   - Admin panelinden (`/admin/login` → `/admin/dashboard` → Yeni Tarif)
   - Veya Firebase Console'dan manuel ekleme

3. **Web'de Test Etme**
   - `flutter run -d chrome`
   - `http://localhost:port/#/admin/login` adresine git
   - Giriş yap ve tarif ekleme/düzenleme test et

4. **Firestore Security Rules**
   - Production için kuralları sıkılaştır
   - `recipes` collection: herkes okuyabilir, sadece admin yazabilir
   - `admins` collection: sadece admin okuyabilir

5. **Cloud Storage (Gelecek)**
   - Spark plan limiti aşılırsa veya gerekirse Blaze plana geç
   - Storage'ı aç ve fotoğraf upload özelliğini ekle

---

## 🔗 İlgili Dokümanlar

- [Firebase Ücretsiz Plan Analizi](../docs/firebase-free-plan-analysis.md)
- [Firebase Hosting Kapasite Analizi](../docs/firebase-hosting-admin-panel-kapasite.md)
- [Admin Panel Kurulum](../docs/admin-panel-kurulum.md)
- [Firestore Setup](../docs/firestore-setup.md)
- [System Patterns](systemPatterns.md)
- [Progress](progress.md)
