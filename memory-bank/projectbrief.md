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
- Mutfak stili seçimi (locale'e göre lokalize etiket)
- **Uygulama locale'ine göre tarif dili** (TR/EN AppBar toggle)
- Loading overlay (EcoChef denizati animasyonu)
- RecipeParser (TR + EN format)
- Kaydettiğim Tarifler: max 5

### 3. AI Sohbet (EcoChef)
- Sıfır atık mutfak yardımcısı
- DeepSeek API ile sohbet, günlük 20 mesaj sınırı
- **Kullanıcının yazdığı dilde yanıt** (EN in → EN out, TR in → TR out)
- Welcome ekranı + öneri havuzu (34 öneri, locale'e göre)
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
- **Firebase Blaze** planı (Temmuz 2026)
- Anonim Firebase Auth (startup + upload öncesi, kullanıcıdan login istenmez)
- `posts/{postId}/photo.jpg` upload (`putData(bytes)`, max 2 MB, timeout'lu)
- Firestore'da `imageUrl` (Storage download URL)
- Admin panel (ayrı repo): `imageUrl` ile fotoğraf gösterimi (yapılacak)

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

### Admin Panel (Ayrı Web Projesi)
- `DynamicStringListField` + `AdminRecipeForm` tarif CRUD
- Gönderi onay ekranında `imageUrl` ile fotoğraf gösterimi
- İlk tariflerin eklenmesi (mobilde Coming Soon kalkar)

### Firebase Blaze Kota Yönetimi
- Blaze'e geçildi; düşük trafikte $0
- Bütçe uyarısı ($5–10) aktif tutulmalı

### Admin ↔ Mobil Senkronizasyon
- Kullanıcı opt-out/silme durumunun admin panele yansıması
- Firestore listener veya manuel refresh
