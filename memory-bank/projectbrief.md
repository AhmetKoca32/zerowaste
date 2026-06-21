# Project Brief: Atıksız Mutfak (ZeroWaste)

**Proje Adı:** Atıksız Mutfak  
**Versiyon:** 0.4.0  
**Oluşturulma Tarihi:** Şubat 2025  
**Son Güncelleme:** Mayıs 2026  
**Durum:** Aktif Geliştirme (Test + İyileştirme Aşaması)

---

## Proje Özeti

Atıksız Mutfak (eski adıyla Sıfır Atık Mutfak), kullanıcıların elindeki malzemelerle atıksız prensiplerine uygun tarifler oluşturmasına yardımcı olan bir Flutter mobil uygulamasıdır. AI destekli tarif üretimi (DeepSeek API), malzeme bazlı tarif filtreleme, çevre bilinci odaklı sohbet (EcoChef maskotu), gamification (puan/seviye sistemi + leaderboard) ile sürdürülebilir mutfak pratiklerini teşvik eder. Admin paneli ayrı bir web projesine taşınmıştır.

---

## Temel Gereksinimler

### 1. Tarif Yönetimi
- Firestore'dan tarifler yükleniyor (keepAlive: true, sadece ilk açılışta fetch)
- Firestore boşsa veya hata verirse yerel JSON fallback (7 detaylı tarif)
- JSON→Firestore migration helper (RecipeMigrationHelper)
- Admin paneli web üzerinden tarif ekleme/düzenleme/silme

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
- Parlayan dairesel progress bar (CustomPaint _GradientArcPainter)
- Günlük Görev Kartları (SharedPreferences tabanlı, günlük sıfırlanma)
- Gönderi Paylaşımı: Firestore'a kayıt, admin onayı ile puan kazanma
- **Leaderboard**: Firestore tabanlı, opt-in, inline top 3
- **Nickname sistemi**: KVKK/GDPR uyumlu, ilk gönderide sorulur
- **Yarışmadan Çıkma (Opt-Out)**: Kullanıcı istediği zaman ayrılabilir
- **Admin Kesintisi/Bonusu**: Çift dilli not desteği (TR/EN)

### 5. Admin Paneli (Ayrı Web Projesi)
- Admin paneli mobil uygulamadan tamamen ayrılmıştır
- Ayrı Flutter Web projesi olarak geliştirilecek
- Firebase Hosting'de yayınlanacak (plan değerlendirmesi sürüyor)
- Tarif CRUD + gönderi onay/red + kullanıcı yönetimi

---

## Tasarım Prensipleri

### Renk Paleti
- **Brand Ana Renkler:** brandOrange (#ED6826), brandCream (#FFFFCC), brandBlack, brandWhite
- **Brand Yardımcı:** brandOrange84, brandOrange70, brandCream84, brandCream70, brandBlack84, brandBlack70
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
- **iOS:** Gelecek
- **Web:** Sadece admin paneli (ayrı proje)
- **Dil:** Türkçe (TR) + İngilizce (EN) — flutter_localizations + intl
- **Minimum SDK:** Dart 3.10.7

---

## Gelecek Planlar (Kritik Kararlar)

### Firebase Spark Plan Kısıtlamalarını Aşma
- Testler bittikten sonra kapsamlı bir Firestore kota yönetim planı yapılacak
- Spark (ücretsiz): 1GB depolama, 10K yazma/gün, 50K okuma/gün
- Storage: 20KB/gün upload → çok yetersiz
- Blaze (kullan-at) geçişi değerlendirilecek

### Fotoğraf Sorunu — Google Drive Çözümü
- Firebase Storage Spark limitleri yetersiz (20KB/gün upload)
- Çözüm: **Google Drive API** ile fotoğraf yükleme
- Veya base64 Firestore'da saklama (son çare, önerilmez)

### Admin Panelin Web'e Taşınması
- Admin paneli ayrı Flutter Web projesi olarak Firebase Hosting'de yayınlanacak
- Kullanıcı silme/çıkış durumunun admin panele anlık yansıması sağlanacak

### Mobil Kullanıcı Çıkışı → Admin Panel Senkronizasyonu
- Kullanıcı mobilde opt-out yaparsa/kendini silerse admin panel güncellenmeli
- Firestore realtime listener veya manuel refresh mekanizması

