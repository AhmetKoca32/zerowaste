# Project Brief: Sıfır Atık Mutfak (ZeroWaste)

**Proje Adı:** Sıfır Atık Mutfak  
**Versiyon:** 0.4.0  
**Oluşturulma Tarihi:** Şubat 2025  
**Son Güncelleme:** Mayıs 2026  
**Durum:** Aktif Geliştirme (Admin Panel + Firestore Entegrasyonu Tamamlandi)

---

## Proje Özeti

Sıfır Atık Mutfak, kullanıcıların elindeki malzemelerle sıfır atık prensiplerine uygun tarifler oluşturmasına yardımcı olan bir Flutter uygulamasıdır (mobil + web). AI destekli tarif üretimi (DeepSeek API), malzeme bazlı tarif filtreleme, çevre bilinci odaklı sohbet (EcoChef maskotu), gamification (puan/seviye sistemi + leaderboard) ve web admin paneli (tarif CRUD + post onay) ile sürdürülebilir mutfak pratiklerini teşvik eder.

---

## Temel Gereksinimler

### 1. Tarif Yönetimi
- Firestore'dan tarifler yükleniyor (keepAlive: true, sadece ilk açılışta fetch)
- Firestore boşsa veya hata verirse yerel JSON fallback (7 detaylı tarif)
- JSON→Firestore migration helper (RecipeMigrationHelper)
- Admin paneli ile tarif ekleme/düzenleme/silme
- Firestore Security Rules: recipes herkes okur, admin yazar
- Blog-style kart tasarımı (beyaz kart, yuvarlak resim, turuncu chip'ler, "N malzeme · N adım" özeti)
- Tarif detay (bottom sheet): özet istatistik barı, kenarlıklı kart bölümler, madde listesi malzemeler, numaralı adımlar
- Malzeme filtresi: filtre butonu + bottom sheet (arama + wrap layout + uygula/temizle)
- Arama çubuğu (inner shadow efekti, search_icon.png)

### 2. AI Tarif Üretimi
- DeepSeek API (OpenAI uyumlu, retry mekanizmalı)
- Malzeme girişi (inner shadow input + turuncu "+" butonu)
- Son eklenenler (SharedPreferences, max 10, kalıcı)
- Mutfak stili seçimi (pill-shape dropdown, inner shadow, arrow_icon.png)
- Loading overlay (EcoChef denizati animasyonu)
- Üretilen tarifleri kaydetme ve fotoğraf ekleme (image_picker)
- AI çıktısını Recipe modeline dönüştürme (RecipeParser - Markdown parsing)
- Kaydettiğim Tarifler: max 5 + "Tümünü gör" bottom sheet

### 3. AI Sohbet (EcoChef Mascot)
- Sıfır atık mutfak yardımcısı
- DeepSeek API ile sohbet
- Günlük 20 mesaj sınırı (dailyMessageCountProvider)
- Welcome ekranı + öneri havuzu (günlük 5 rastgele öneri, SharedPreferences)
- 34 öneri, 5 kategoride (artıklar, saklama, ipuçları, sürdürülebilirlik, tarifler)
- Typewriter + reverse typewriter animasyonlu empty state
- Markdown destekli sohbet balonları (flutter_markdown)
- Arka plan 5 dk auto-clear timer
- DeepSeek hata yönetimi (5 exception tipi, refund mekanizması)

### 4. Puan Sistemi (Gamification)
- PointsHeroCard: iki modlu animasyon (Normal + Level-up Journey)
- 5 seviyeli hiyerarşi: Çaylak (0-50), Meraklı (50-150), Usta (150-300), Efsane (300-600), Efsane+ (600+)
- Parlayan dairesel progress bar (_GradientArcPainter)
- Seviye atlama kutlama overlay'leri
- Ticker sızıntı koruması (_activeProgressController pattern)
- Günlük Görev Kartları (MissionCardsSection - staggered entrance animasyonlu)
- Gönderi Paylaşımı: Kamera/Galeri (image_picker)
- Gönderi Akışı: 2 sütunlu grid, 3 durum (pending/approved/rejected)
- **Firestore entegrasyonu**: Gonderiler Firestore'a kaydedilir, admin onay/red yapar
- **Leaderboard**: Inline top 3 gostergesi (Firestore tabanli, opt-in)
- **Nickname sistemi**: KVKK/GDPR uyumlu takma ad, ilk gonderide sorulur

### 5. Admin Paneli (Flutter Web -> AYRI WEBSITESINE TASINACAK)
- Flutter Web, responsive tasarim (sidebar desktop / drawer mobile)
- Firebase Authentication (Email/Password) + Firestore admin kontrolu
- Tarif CRUD islemleri
- **YENI**: Gonderi onay/red sayfasi (bekleyen gonderiler listesi)
- **NOT**: Admin paneli mobil uygulamadan ayrilip bagimsiz bir web sitesi olarak yayinlanacak
- Hosting plani Firebase Hosting uzerinden degerlendirilecek

---

## Tasarim Prensipleri

### Renk Paleti (Guncel)
- **Brand Ana Renkler:** brandOrange (#ED6826), brandCream (#FFFFCC), brandBlack, brandWhite
- **Brand Yardimci:** brandOrange84, brandOrange70, brandCream84, brandCream70, brandBlack84, brandBlack70
- **Extended Palette:** 21 renk
- **Toprak Tonlari:** Sand, Stone, Terracotta, Clay, Bark
- **Notr Renkler:** Cream, Paper, Ink, InkLight

### Font
- **Manrope** ailesi: Light (300), Regular (400), Medium (500), Bold (700)
- AppTextStyle ile 16 stil tanimi (display/headline/title/body/label)

### UI/UX Yaklasimi
- Minimalist ve temiz beyaz/turuncu tasarim
- Blog-style kartlar (beyaz arka plan, yuvarlak koseli resimler, turuncu vurgular)
- Pill-shaped frosted glass bottom navigation bar
- Custom PNG ikonlar (denizati.png EcoChef maskotu dahil)
- Bottom sheet bazli detay/filtre/liste gorunumleri

---

## Platform
- **Android:** Mobil uygulama (aktif)
- **iOS:** Gelecek
- **Web:** Admin paneli -> ayri web sitesine tasinacak
- **Dil:** Turkce (TR) + Ingilizce (EN) -> flutter_localizations + intl
- **Minimum SDK:** Dart 3.10.7

---

## Gelecek Planlar (Kritik Kararlar)

### Admin Panelinin Web'e Tasinmasi
- Admin paneli ayri bir Flutter Web uygulamasi olarak Firebase Hosting'de yayinlanacak
- Firebase Hosting plani (Spark -> Blaze gecisi gerekebilir) incelenecek
- Eger hosting sikinti cikarirsa, mobil uygulama icinde gizli bir admin girisi birakilacak

### Firebase Plan Degerlendirmesi
- Su an: Spark (ucretsiz) planda -- Firestore 1GB, 10K belge yazma/gun, 50K okuma/gun
- Storage eklenirse: Spark'ta 5GB depolama, 20KB yukleme/gun, 20KB indirme/gun
- Hosting eklenirse: Spark'ta 10GB depolama, 100MB/gun bant genisligi
- Yuksek ihtimalle Blaze (kullandikca ode) planina gecmek gerekebilir

### Gorsel Paylasimi Cozumu (Storage)
- Firebase Storage Spark'ta sinirli (20KB/gun upload)
- Storage kotasi asilirsa alternatif: **Google Drive API** ile gorsel yukleme
- Veya gorselleri base64 olarak Firestore'da saklama (oenerilmez, belge boyutunu cok artirir)

### Coklu Dil Desteji (Ingilizce)
- Uygulamaya Ingilizce dil desteji eklenecek
- Baslangicta 2 dil: Turkce (TR) + Ingilizce (EN)
- Yontem: Flutter'in yerel `flutter_localizations` paketi + `intl` (arb dosyalari)
- Dil secimi: Kullanici tarafindan ayarlar kisminda secilebilir veya cihaz diline otomatik uyum
- Tasarim: Tum string'ler `AppLocalizations` uzerinden cekilecek, hardcoded string'ler kaldirilacak
- Planlama: Tarim asamali, once ana arayuz (navbar, sayfa basliklari, butonlar), sonra icerik (tarif detay, sohbet, puan sistemi)


---

## Notlar
- Proje v0.4.0 asamasinda: Admin paneli + Firestore entegrasyonu tamamlandi
- "SifirAtik" olarak yeniden markalasti (ZeroWaste -> SifirAtik)
- EcoChef maskotu denizati.png olarak guncellendi
- Points page: Firestore baglantisi canli, mock data kaldirildi
- RecipeSyncService: Gunluk Firestore senkronizasyonu (henuz main'e eklenmedi)
- Firestore index'leri: posts(status, createdAt), posts(nickname, createdAt), posts(status, leaderboardOptIn)
