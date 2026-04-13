# Project Brief: Sıfır Atık Mutfak (ZeroWaste)

**Proje Adı:** Sıfır Atık Mutfak  
**Versiyon:** 0.3.0  
**Oluşturulma Tarihi:** Şubat 2025  
**Son Güncelleme:** Mart 2025  
**Durum:** Aktif Geliştirme

---

## Proje Özeti

Sıfır Atık Mutfak, kullanıcıların elindeki malzemelerle sıfır atık prensiplerine uygun tarifler oluşturmasına yardımcı olan bir Flutter uygulamasıdır (mobil + web). AI destekli tarif üretimi, malzeme bazlı tarif filtreleme, çevre bilinci odaklı sohbet, puanlama sistemi ve web admin paneli (tarif CRUD) ile sürdürülebilir mutfak pratiklerini teşvik eder.

---

## Temel Gereksinimler

### 1. Tarif Yönetimi
- Firestore'dan tarifler yükleniyor (keepAlive: true, sadece ilk açılışta fetch)
- Firestore boşsa veya hata verirse yerel JSON fallback (7 detaylı tarif)
- Admin paneli ile tarif ekleme/düzenleme/silme
- Firestore Security Rules: recipes herkes okur, admin yazar
- Blog-style kart tasarımı (beyaz kart, yuvarlak resim, turuncu chip'ler, "N malzeme · N adım" özeti)
- Tarif detay (bottom sheet): özet istatistik barı, kenarlıklı kart bölümler, madde listesi malzemeler, numaralı adımlar
- Malzeme filtresi: filtre butonu + bottom sheet (arama + wrap layout + uygula/temizle)
- Arama çubuğu (inner shadow efekti, search_icon.png)

### 2. AI Tarif Üretimi
- DeepSeek API (OpenAI uyumlu)
- Malzeme girişi (inner shadow input + turuncu "+" butonu)
- Son eklenenler (SharedPreferences, max 10, kalıcı)
- Mutfak stili seçimi (pill-shape dropdown, inner shadow, arrow_icon.png)
- Loading overlay (şef animasyonu)
- Üretilen tarifleri kaydetme ve fotoğraf ekleme
- Kaydettiğim Tarifler: max 5 + "Tümünü gör" bottom sheet

### 3. AI Sohbet (Leafy Mascot)
- Sıfır atık mutfak yardımcısı
- DeepSeek API ile sohbet
- Mock data ile test edilmiş

### 4. Puan Sistemi (Gamification)
- UI tasarımı mevcut, backend entegrasyonu bekliyor
- 3 kategori: dolap/kiler, yemek anı, artıklardan ne yaptım

### 5. Admin Paneli (Web)
- Flutter Web, desktop-friendly sidebar layout
- Firebase Authentication (Email/Password) + Firestore admin kontrolü
- Tarif CRUD işlemleri

---

## Tasarım Prensipleri

### Renk Paleti (Güncel)
- **Brand Ana Renkler:** brandOrange (#ED6826), brandCream (#FFFFCC), brandBlack, brandWhite
- **Brand Yardımcı:** brandOrange84, brandOrange70, brandCream84, brandCream70, brandBlack84, brandBlack70
- **Extended Palette:** 21 renk
- **Toprak Tonları:** Sand, Stone, Terracotta, Clay, Bark
- **Nötr Renkler:** Cream, Paper, Ink, InkLight
- NOT: Eski yeşil tonları (sage, mint, fern, moss, forest) kaldırıldı

### Font
- **Manrope** ailesi: Regular, Medium, Bold, Light ağırlıkları

### UI/UX Yaklaşımı
- Minimalist ve temiz beyaz/turuncu tasarım
- Blog-style kartlar (beyaz arka plan, yuvarlak köşeli resimler, turuncu vurgular)
- Pill-shaped frosted glass bottom navigation bar
- Custom PNG ikonlar (tarifler, chat, puan, oluştur, alışveriş, arama, arrow)
- Inner shadow arama çubukları ve dropdown'lar
- Bottom sheet bazlı detay/filtre/liste görünümleri
- Malzeme filtre bottom sheet (wrap layout, arama, uygula/temizle)

---

## Platform
- **Android:** Mobil uygulama (aktif)
- **iOS:** Gelecek
- **Web:** Admin paneli (Flutter Web)
- **Minimum SDK:** Dart 3.10.7

---

## Notlar
- Proje v0.3.0 aşamasında: UI/UX polish + özellik zenginleştirme
- Oluştur sayfası tamamen yeniden tasarlandı
- Tarif detay sheet zenginleştirildi
- Malzeme filtre sistemi bottom sheet'e taşındı
- 7 detaylı sıfır atık tarif (açıklama, miktarlı malzeme, detaylı adım)
- Son eklenenler kalıcı (SharedPreferences)
- Kaydettiğim tarifler aranabilir bottom sheet ile
