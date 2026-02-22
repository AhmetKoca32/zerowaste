# Project Brief: ZeroWaste Mutfak

**Proje Adı:** ZeroWaste Mutfak  
**Versiyon:** 0.1.0  
**Oluşturulma Tarihi:** Şubat 2025  
**Durum:** Aktif Geliştirme

---

## 🎯 Proje Özeti

ZeroWaste Mutfak, kullanıcıların elindeki malzemelerle sıfır atık prensiplerine uygun tarifler oluşturmasına yardımcı olan bir Flutter uygulamasıdır (mobil + web). AI destekli tarif üretimi, çevre bilinci odaklı sohbet, puanlama sistemi ve **web admin paneli** (tarif CRUD) ile sürdürülebilir mutfak pratiklerini teşvik eder.

---

## 🎨 Temel Değerler ve Hedefler

### Misyon
Gıda israfını azaltmak ve sıfır atık mutfak kültürünü yaygınlaştırmak için teknolojiyi kullanarak kullanıcılara pratik çözümler sunmak.

### Temel Değerler
- **Sürdürülebilirlik:** Çevre dostu mutfak pratiklerini desteklemek
- **Pratiklik:** Günlük hayatta kolayca uygulanabilir çözümler
- **Eğitim:** Kullanıcıları sıfır atık konusunda bilinçlendirmek
- **Topluluk:** Kullanıcıların birbirinden öğrenmesini sağlamak

---

## 📋 Temel Gereksinimler

### 1. Tarif Yönetimi
- **Mevcut Durum:** 
  - ✅ Firestore'dan tarifler yükleniyor (`RecipeRepository` Firestore entegrasyonu tamamlandı)
  - ✅ Admin paneli ile dışarıdan tarif ekleme/düzenleme/silme yapılabiliyor
  - ✅ Fallback: Firestore başarısız olursa local JSON'dan yükleniyor
- **Özellikler:**
  - Tarif listesi görüntüleme (HomePage)
  - Tarif detay sayfası (RecipeDetailSheet - bottom sheet)
  - Blog-style kart tasarımı (RecipeBlogCard)
  - Fotoğraf desteği (opsiyonel - image_url field)

### 2. AI Tarif Üretimi
- **Teknoloji:** DeepSeek API (OpenAI uyumlu)
- **Özellikler:**
  - Kullanıcı malzemelerini girme (text field + chips)
  - Mutfak stili seçimi (Türk, İtalyan, Asya, vb. - opsiyonel)
  - AI ile tarif üretimi
  - Üretilen tarifleri kaydetme (local storage)
  - Kaydedilen tariflere fotoğraf ekleme (local storage)

### 3. AI Sohbet (Leafy Mascot)
- **Karakter:** Leafy - sıfır atık mutfak yardımcısı
- **Teknoloji:** DeepSeek API
- **Özellikler:**
  - Kullanıcı ile sohbet
  - Sıfır atık ipuçları verme
  - Tarif önerileri
  - Gıda israfını azaltma konusunda rehberlik

### 4. Puan Sistemi (Gamification)
- **Mevcut Durum:** Sadece UI tasarımı mevcut, backend entegrasyonu yok
- **Gelecek Plan:** 
  - Kullanıcılar fotoğraf çekecek (3 kategori: dolap/kiler, yemek anı, artıklardan ne yaptım)
  - Ekip üyeleri bu fotoğrafları görüp manuel olarak puanlayacak
  - Kullanıcılar toplam puanlarını görecek
- **Kategoriler:**
  1. **Dolabını paylaş:** Buzdolabı veya kiler fotoğrafı
  2. **Yemek anını paylaş:** Malzemelerle yemek yaparken çekilen fotoğraf
  3. **Artıklardan ne yaptın?:** Kalan malzemelerden yapılan tarif veya değerlendirme

### 5. Admin Paneli (Web)
- **Platform:** Flutter Web (aynı proje içinde)
- **Durum:** ✅ Tamamlandı
- **Özellikler:**
  - Desktop-friendly sidebar layout
  - Firebase Authentication (Email/Password)
  - Admin kontrolü (Firestore `admins` collection)
  - Tarif CRUD işlemleri (ekleme, düzenleme, silme, listeleme)
  - Route guard (yetki kontrolü)
- **Route'lar:**
  - `/admin/login` - Admin giriş sayfası
  - `/admin/dashboard` - Tarif listesi (sidebar ile)
  - `/admin/recipes/new` - Yeni tarif ekleme
  - `/admin/recipes/:id` - Tarif düzenleme

---

## 🏗️ Mimari Gereksinimler

### Backend Stratejisi
- **Durum:** ✅ Firebase entegrasyonu tamamlandı
- **Plan:** Firebase Spark (ücretsiz plan ile başlangıç)
- **Kapasite Hedefleri:**
  - ~5,000-8,000 aktif kullanıcı/gün
  - ~15,000-20,000 fotoğraf (sıkıştırılmış)
  - ~10,000+ tarif
- **Bileşenler:**
  - ✅ **Cloud Firestore:** Tarifler (`recipes` collection), admin kontrolü (`admins` collection)
  - ⏳ **Cloud Storage:** Kullanıcı fotoğrafları (Spark plan limiti nedeniyle şimdilik bekliyor)
  - ✅ **Firebase Authentication:** Admin paneli için aktif (Email/Password)
  - ⏳ **Firebase Hosting:** Web admin paneli için (Spark plan: 10 GB depolama, 360 MB/gün transfer)

### Ücretsiz Kalma Kriterleri
- Tüm özellikler ücretsiz plan limitleri içinde kalmalı
- Fotoğraf sıkıştırma zorunlu (200-300 KB hedef)
- Firestore reads/writes optimizasyonu gerekli
- Cache mekanizmaları kullanılmalı
- Admin paneli için Firebase Hosting Spark plan yeterli (~5-50 admin için)

---

## 🎨 Tasarım Prensipleri

### Renk Paleti
- **Doğa Dostu Pastel Yeşiller:** Sage, Mint, Fern, Moss, Forest
- **Toprak Tonları:** Sand, Stone, Terracotta, Clay, Bark
- **Nötr Renkler:** Cream, Paper, Ink, InkLight

### UI/UX Yaklaşımı
- Minimalist ve temiz tasarım
- Blog-style kartlar (tarifler için)
- Pastel renkler ve yumuşak gölgeler
- Kolay navigasyon (bottom tab bar - mobil, sidebar - web admin)
- Loading states ve error handling

---

## 📱 Platform

- **Platform:** Flutter (cross-platform)
- **Hedef:** 
  - ✅ **Android:** Mobil uygulama
  - ⏳ **iOS:** Mobil uygulama (gelecek)
  - ✅ **Web:** Admin paneli (Flutter Web)
- **Minimum SDK:** Dart 3.10.7

---

## 🔐 Güvenlik ve Gizlilik

- API anahtarları `.env` dosyası veya `--dart-define` ile yönetiliyor
- **Admin Authentication:** Firebase Auth (Email/Password) + Firestore `admins` collection kontrolü
- **Firestore Security Rules:** Production için sıkılaştırılmalı (şu an test mode)
- Fotoğraflar local storage'da (gelecekte Cloud Storage'a yüklenecek)

---

## 📊 Başarı Metrikleri (Gelecek)

- Aktif kullanıcı sayısı
- Üretilen tarif sayısı
- Yüklenen fotoğraf sayısı
- Puanlanan gönderi sayısı
- Firebase kullanım metrikleri (reads/writes/storage)
- Admin paneli kullanım istatistikleri

---

## 🚀 Gelecek Özellikler

1. **Backend Entegrasyonu:**
   - ✅ Firebase Firestore entegrasyonu (tarifler için tamamlandı)
   - ⏳ Cloud Storage entegrasyonu (Spark plan limiti nedeniyle bekliyor)
   - ✅ Authentication sistemi (admin paneli için aktif)

2. **Puan Sistemi Tamamlama:**
   - ⏳ Fotoğraf yükleme akışı (Cloud Storage gerekli)
   - ⏳ Admin panelinde puanlama özelliği ekleme
   - ⏳ Puan geçmişi ve istatistikler

3. **Tarif Yönetimi:**
   - ✅ Dışarıdan tarif ekleme/güncelleme (admin paneli ile)
   - ⏳ Tarif arama ve filtreleme
   - ⏳ Kullanıcı tarif paylaşımı

4. **Admin Paneli Geliştirmeleri:**
   - ✅ Desktop-friendly sidebar layout
   - ✅ Tarif CRUD işlemleri
   - ⏳ Puanlama paneli entegrasyonu
   - ⏳ İstatistikler ve raporlar

5. **Topluluk Özellikleri:**
   - ⏳ Kullanıcı profilleri
   - ⏳ Tarif yorumları
   - ⏳ Favori tarifler

---

## 📝 Notlar

- **İlk yapılacaklar:** (1) Firebase bağlantısı testi, (2) Firestore şemaları kontrolü, (3) 2–3–4. sayfalarda nav bar arka planı kaldırılması, (4) ileride gönderi özelliğinin aktifleştirilmesi. Detay: [Active Context](activeContext.md), [Progress](progress.md).
- Proje şu an MVP (Minimum Viable Product) aşamasında
- ✅ Firebase backend entegrasyonu tamamlandı (Firestore + Auth)
- ✅ Admin paneli (Flutter Web) tamamlandı
- ⏳ Cloud Storage entegrasyonu bekliyor (Spark plan limiti nedeniyle)
- Puan sistemi UI'ı hazır, backend entegrasyonu bekliyor
- Tüm özellikler ücretsiz Firebase planı limitleri içinde tasarlanmalı
