# Product Context: Atıksız Mutfak

**Son Güncelleme:** Temmuz 2026 (17 Temmuz)

---

## Neden Bu Proje Var?

### Problem
- Gıda israfı dünya çapında büyük bir sorun
- İnsanlar elindeki malzemelerle ne yapacağını bilemiyor
- Atıksız mutfak pratikleri yeterince yaygın değil

### Çözüm
Atıksız Mutfak, AI teknolojisini kullanarak kullanıcıların elindeki malzemelerle yaratıcı tarifler oluşturmasına yardımcı olur. Gamification sistemi ile sürdürülebilir mutfak pratiklerini teşvik eder: fotoğraf paylaşımı, puan toplama, seviye atlama ve lider tablosunda rekabet.

---

## Kullanıcı Yolculuğu

### 1. Tarifler Sayfası (Ana Sayfa)
- Firestore'dan tarif listesi yüklenir
- Liste boşsa **RecipesComingSoon** animasyonlu placeholder gösterilir
- Arama + malzeme bazlı filtreleme
- Tarif detayında: açıklama (paragraf), malzemeler (madde madde), adımlar (numaralı)

### 2. AI Tarif Üretimi (Oluştur)
- Malzeme girişi + mutfak stili seçimi
- DeepSeek API; **uygulama locale'ine göre** (TR/EN toggle) tarif üretimi
- Loading: "EcoChef pişiriyor" animasyonu
- Üretilen tarifi kaydetme

### 3. AI Sohbet (Chat/EcoChef)
- Welcome → Active Chat akışı
- Günlük 5 öneri, 20 mesaj limiti
- **Kullanıcının yazdığı dilde yanıt** (EN/TR)
- Markdown render, typewriter efekti

### 4. Puan Sistemi (Gamification)
- **PointsHeroCard**: Progress animasyonu + seviye atlama
- 5 seviye, dairesel progress bar
- **Günlük Görevler**: Gönderi paylaşarak tamamlama
- **Gönderi Paylaşımı**: Fotoğraf → Firebase Storage → Firestore → admin onayı → puan
- **Leaderboard**: Inline top 3, KVKK/GDPR opt-in
- **Yarışmadan Çıkma**: HeroCard üzerinden opt-out
- **Admin İşlemleri**: Bonus/kesinti (çift dilli not)

### 5. Admin Paneli (Ayrı Web Projesi)
- Mobil uygulamadan ayrı Flutter Web projesi
- Firebase Auth ile giriş (sadece `admins/{uid}`)
- **Tarif CRUD**: Mobil ile aynı veri yapısı
  - Malzemeler: madde madde dinamik liste
  - Adımlar: numaralı dinamik liste
  - Açıklama: tek paragraf textarea
- Gönderi onay/red + kullanıcı yönetimi

---

## UI/UX Hedefleri

### Tasarım Dili
- Beyaz kartlar üzerine turuncu vurgular
- Manrope font ailesi
- Custom PNG ikonlar (denizati.png EcoChef maskotu)
- Pill-shaped navbar

### Navigation
- Bottom tab bar (4 sekme): Tarifler, Oluştur, Chat, Puan
- Tab değişiminde veri yenileme (points sayfası)

### Önemli UX Detayları
- Tarif listesi boşken Coming Soon (yayın öncesi 3–5 bilingual tarif doldurulmalı)
- Gönderi fotoğrafları Firebase Storage (`imageUrl`)
- Puan: artış/azalışta overlay + hero stepper; `last_known_points` animasyon sonrası
- KVKK/GDPR: nickname + leaderboard opt-in
- Admin notları / tarif metinleri locale’e göre (TR/EN)

### Admin ↔ Mobil Veri Tutarlılığı
Admin panelde girilen tarif verisi mobilde birebir aynı görünmelidir:
- Her malzeme ayrı satır → mobilde bullet list (TR veya EN locale’e göre)
- Her adım ayrı satır → mobilde 1, 2, 3 numaralı adımlar
- Açıklama tek metin → mobilde paragraf
- **TR + EN zorunlu** (`title`/`titleEn`, `ingredients`/`ingredientsEn`, `instructions`/`instructionsEn`); eksik dil mobilde listelenmez
