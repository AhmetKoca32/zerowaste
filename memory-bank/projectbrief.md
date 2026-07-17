# Project Brief: Atıksız Mutfak (ZeroWaste)

**Proje Adı:** Atıksız Mutfak  
**Versiyon:** 0.4.0  
**Oluşturulma Tarihi:** Şubat 2025  
**Son Güncelleme:** Temmuz 2026 (17 Temmuz)  
**Durum:** Aktif Geliştirme (Admin panel web projesi + mobil iyileştirmeler)

---

## Proje Özeti

Atıksız Mutfak, kullanıcıların elindeki malzemelerle atıksız prensiplerine uygun tarifler oluşturmasına yardımcı olan bir Flutter mobil uygulamasıdır. AI destekli tarif üretimi (DeepSeek API), malzeme bazlı tarif filtreleme, çevre bilinci odaklı sohbet (EcoChef maskotu), gamification (puan/seviye sistemi + leaderboard) ile sürdürülebilir mutfak pratiklerini teşvik eder. Admin paneli ayrı bir Flutter Web projesine taşınmıştır.

---

## Temel Gereksinimler

### 1. Tarif Yönetimi
- Firestore `recipes` koleksiyonundan tarifler yükleniyor (keepAlive: true)
- Firestore boşsa **RecipesComingSoon** placeholder gösterilir (local JSON fallback kaldırıldı)
- Admin paneli (ayrı web projesi) üzerinden tarif ekleme/düzenleme/silme
- Tarif şeması: `title`, `description?`, `image_url?`, `ingredients[]`, `instructions[]`
- Admin formu mobil görünümle uyumlu: malzeme/adım dinamik liste input

### 2. AI Tarif Üretimi
- DeepSeek API (OpenAI uyumlu, retry mekanizmalı)
- Malzeme girişi + son eklenenler (SharedPreferences)
- Mutfak stili seçimi
- Loading overlay (EcoChef denizati animasyonu)
- AI çıktısını Recipe modeline dönüştürme (RecipeParser)
- Kaydettiğim Tarifler: max 5

### 3. AI Sohbet (EcoChef)
- Sıfır atık mutfak yardımcısı
- DeepSeek API ile sohbet, günlük 20 mesaj sınırı
- Welcome ekranı + öneri havuzu (5 kategori, 34 öneri)
- Typewriter + reverse typewriter animasyonu
- Markdown destekli sohbet balonları
- 5 dk auto-clear timer

### 4. Puan Sistemi (Gamification)
- **PointsHeroCard**: İki modlu animasyon (Normal progress + Level-up Journey)
- 5 seviye: Çaylak → Meraklı → Usta → Efsane → Efsane+
- Parlayan dairesel progress bar (CustomPaint)
- Günlük Görev Kartları (SharedPreferences tabanlı)
- Gönderi Paylaşımı: Firebase Storage upload → Firestore → admin onayı → puan
- **Leaderboard**: Firestore tabanlı, opt-in, inline top 3
- **Nickname sistemi**: KVKK/GDPR uyumlu
- **Yarışmadan Çıkma (Opt-Out)**
- **Admin Kesintisi/Bonusu**: Çift dilli not (TR/EN)

### 5. Gönderi Fotoğrafları (Firebase Storage)
- Anonim Firebase Auth ile oturum (kullanıcıdan login istenmez)
- `posts/{postId}/photo.jpg` yoluna upload (max 2 MB)
- Firestore'da `imageUrl` olarak download URL saklanır
- Admin panelde fotoğraf URL üzerinden görüntülenebilir

### 6. Admin Paneli (Ayrı Web Projesi)
- Mobil uygulamadan tamamen ayrılmış
- Ayrı Flutter Web projesi, Firebase Hosting'de yayınlanacak
- Tarif CRUD: mobil ile aynı Firestore şeması
  - Malzemeler: dinamik liste (`string[]`)
  - Adımlar: dinamik numaralı liste (`string[]`)
  - Açıklama: tek textarea (`string?`)
- Gönderi onay/red + kullanıcı yönetimi

---

## Tasarım Prensipleri

### Renk Paleti
- **Brand Ana Renkler:** brandOrange (#ED6826), brandCream (#FFFFCC), brandBlack, brandWhite
- **Toprak Tonları:** Sand, Stone, Terracotta, Clay, Bark
- **Nötr Renkler:** Cream, Paper, Ink, InkLight

### Font
- **Manrope** ailesi: Light (300), Regular (400), Medium (500), Bold (700)

### UI/UX Yaklaşımı
- Minimalist beyaz/turuncu tasarım
- Blog-style kartlar, pill-shaped navbar
- Custom PNG ikonlar (denizati.png EcoChef maskotu)
- Bottom sheet bazlı detay/filtre/liste görünümleri

---

## Platform
- **Android:** Mobil uygulama (aktif)
- **iOS:** SceneDelegate eklendi, geliştirme devam
- **Web:** Sadece admin paneli (ayrı proje)
- **Dil:** Türkçe (TR) + İngilizce (EN)
- **Minimum SDK:** Dart 3.10.7

---

## Gelecek Planlar

### Admin Panel Tarif Formu
- `DynamicStringListField` widget (malzeme + adım için ortak)
- `AdminRecipeForm` ile Firestore CRUD
- İlk tariflerin admin panelden eklenmesi

### Firebase Spark Plan Kotası
- Storage 20KB/gün upload limiti izlenmeli
- Yoğun kullanımda Blaze geçişi değerlendirilecek
- Stream yerine tek seferlik `get()` ile okuma minimize edildi

### Admin ↔ Mobil Senkronizasyon
- Kullanıcı opt-out/silme durumunun admin panele yansıması
- Firestore listener veya manuel refresh
