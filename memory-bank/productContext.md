# Product Context: Atıksız Mutfak

**Son Güncelleme:** Mayıs 2026

---

## Neden Bu Proje Var?

### Problem
- Gıda israfı dünya çapında büyük bir sorun
- İnsanlar elindeki malzemelerle ne yapacağını bilemiyor
- Atıksız mutfak pratikleri yeterince yaygın değil

### Çözüm
Atıksız Mutfak, AI teknolojisini kullanarak kullanıcıların elindeki malzemelerle yaratıcı tarifler oluşturmasına yardımcı olur. Gamification sistemi ile kullanıcıları sürdürülebilir mutfak pratiklerine teşvik eder: fotoğraf paylaşımı, puan toplama, seviye atlama ve lider tablosunda rekabet.

---

## Kullanıcı Yolculuğu

### 1. Tarifler Sayfası (Ana Sayfa)
- Uygulama açılır, splash ekranı sonrası tarif listesi görünür
- Arama çubuğu + filtre butonu ile malzeme bazlı filtreleme
- Tarifler akıllı sıralama (en çok eşleşen üstte)
- Blog-style kartlar, bottom sheet detay

### 2. AI Tarif Üretimi (Oluştur)
- Malzeme girişi + mutfak stili seçimi
- DeepSeek API ile AI tarif üretimi
- Loading: "EcoChef pişiriyor" animasyonu
- Üretilen tarifi kaydetme + fotoğraf ekleme

### 3. AI Sohbet (Chat/EcoChef)
- İki aşamalı akış: Welcome → Active Chat
- Günlük 5 öneri, 20 mesaj limiti
- Markdown render, typewriter efekti
- 5 dk otomatik temizlik

### 4. Puan Sistemi (Gamification)
- **PointsHeroCard**: Progress animasyonu + seviye atlama journey
- 5 seviye, dairesel progress bar
- **Günlük Görevler**: Gönderi paylaşarak tamamlama (SharedPreferences)
- **Leaderboard**: Inline top 3, KVKK/GDPR opt-in
- **Gönderi Paylaşımı**: Firestore → admin onayı → puan kazanma
- **Yarışmadan Çıkma**: HeroCard üzerinden opt-out
- **Admin İşlemleri**: Bonus/kesinti (çift dilli not desteği)

### 5. Admin Paneli (Ayrı Web Projesi)
- Mobil uygulamadan ayrı bir Flutter Web projesi
- Firebase Auth ile giriş
- Tarif CRUD + gönderi onay/red + kullanıcı yönetimi

---

## UI/UX Hedefleri

### Tasarım Dili
- Beyaz kartlar üzerine turuncu vurgular
- Manrope font ailesi
- Custom PNG ikonlar (denizati.png dahil)
- Pill-shaped navbar, inner shadow efektleri

### Navigation
- Bottom tab bar (4 sekme): Tarifler, Oluştur, Chat, Puan
- Custom ikonlar
- Tab değişiminde veri yenileme (points sayfası)

### Önemli UX Detayları
- Splash screen: 4 aşamalı animasyon
- Instagram-style gönderi paylaşımı + admin onay akışı
- Gamification: her sayfa açılışında progress animasyonu
- KVKK/GDPR: nickname ve leaderboard opt-in açık rıza ile
- Çift dilli içerik: admin notları kullanıcının diline göre gösterilir
