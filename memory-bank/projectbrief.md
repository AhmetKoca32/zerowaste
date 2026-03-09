# Project Brief: Sıfır Atık Mutfak (ZeroWaste)

**Proje Adı:** Sıfır Atık Mutfak  
**Versiyon:** 0.2.0  
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
- Admin paneli ile tarif ekleme/düzenleme/silme
- Fallback: Firestore başarısız olursa local JSON'dan yükleme
- Blog-style kart tasarımı (beyaz kart, yuvarlak köşeli resim, turuncu kenarlıklı malzeme chip'leri)
- Tarif detay sayfası (bottom sheet, chip-style malzemeler, numaralı yapılış adımları)
- Malzeme bazlı tarif filtreleme (yatay chip bar, akıllı sıralama, eşleşme göstergesi)
- Arama çubuğu (inner shadow efekti, custom search ikonu)

### 2. AI Tarif Üretimi
- DeepSeek API (OpenAI uyumlu)
- Malzeme girişi + mutfak stili seçimi
- Loading overlay (şef animasyonu)
- Üretilen tarifleri kaydetme ve fotoğraf ekleme

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
- **Extended Palette:** 21 renk (paletteLightGreen, paletteBrightYellow, vb.)
- **Toprak Tonları:** Sand, Stone, Terracotta, Clay, Bark
- **Nötr Renkler:** Cream, Paper, Ink, InkLight
- NOT: Eski yeşil tonları (sage, mint, fern, moss, forest) kaldırıldı

### Font
- **Manrope** ailesi: Regular, Medium, Bold, Light ağırlıkları
- Tüm UI bileşenlerinde tutarlı Manrope kullanımı

### UI/UX Yaklaşımı
- Minimalist ve temiz beyaz/turuncu tasarım
- Blog-style kartlar (beyaz arka plan, yuvarlak köşeli resimler, turuncu vurgular)
- Pill-shaped frosted glass bottom navigation bar
- Custom PNG ikonlar (tarifler, chat, puan, oluştur, alışveriş, arama)
- Inner shadow arama çubuğu
- Malzeme bazlı akıllı filtreleme chip'leri

---

## Platform
- **Android:** Mobil uygulama (aktif)
- **iOS:** Gelecek
- **Web:** Admin paneli (Flutter Web)
- **Minimum SDK:** Dart 3.10.7

---

## Notlar
- Proje MVP aşamasından çıkıp UI/UX polish aşamasına geçti
- Eski yeşil renk paleti tamamen turuncu/krem brand renkleriyle değiştirildi
- Tarif filtreleme sistemi eklendi (malzeme bazlı)
- Tüm fontlar Manrope'a çevrildi
- Custom asset ikonları kullanımda
