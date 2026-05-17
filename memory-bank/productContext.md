# Product Context: Sıfır Atık Mutfak

**Son Güncelleme:** Mayıs 2026

---

## Neden Bu Proje Var?

### Problem
- Gıda israfı dünya çapında büyük bir sorun
- İnsanlar elindeki malzemelerle ne yapacağını bilemiyor
- Sıfır atık mutfak pratikleri yeterince yaygın değil

### Çözüm
Sıfır Atık Mutfak, AI teknolojisini kullanarak kullanıcıların elindeki malzemelerle yaratıcı tarifler oluşturmasına yardımcı olur. Malzeme bazlı filtreleme ile kullanıcılar ellerindeki malzemelere göre mevcut tarifler arasından en uygunlarını bulabilir.

---

## Kullanıcı Yolculuğu

### 1. Tarifler Sayfası (Ana Sayfa)
- Uygulama açılır splash ekrani sonrasi, "SıfırAtık Mutfak" başlığı görünür
- Arama çubuğu (inner shadow efektli, beyaz, search_icon.png) + sağında filtre butonu
- Filtre butonu: tune ikonu, seçili malzeme varsa turuncu + badge
- Filtre butonuna tıklayınca bottom sheet açılır
- Tarifler akıllı sıralama ile listelenir (en çok eşleşen üstte)
- Her kartta: başlık, "N malzeme · N adım" özeti, malzeme chip'leri, eşleşme göstergesi, "Tarifi İncele" butonu
- Karta tıklanınca bottom sheet detay açılır

### 2. Tarif Detay (Bottom Sheet)
- Beyaz arka plan, yumuşak gölge
- Başlık + kapat butonu
- Yemek resmi (yemek.png placeholder)
- Özet istatistik barı (malzeme sayısı + adım sayısı)
- Açıklama (description varsa)
- Malzemeler kartı: alisveris_icon.png, "N adet", turuncu noktalı madde listesi
- Yapılış kartı: numaralı adımlar, ayraç çizgiler

### 3. AI Tarif Üretimi (Oluştur)
- Başlık + info ikonu ile açıklama
- Inner shadow input alanı + turuncu "+" butonu
- Eklenen malzemeler turuncu chip'ler
- Son eklenenler: daha önce kullanılmış malzemeler (kalıcı, dokunulunca ekle)
- Mutfak dropdown (pill-shape, inner shadow, arrow_icon.png)
- "Tarif Oluştur" butonu → DeepSeek API (retry mekanizmalı) → detay sheet
- AI çıktısı RecipeParser ile Recipe modeline dönüştürülür (Markdown parsing)
- Loading: "EcoChef pişiriyor" animasyonu (denizati.png ikonu)

### 4. AI Sohbet (Chat/EcoChef)
- Iki asamali akis: Welcome (Giris) → Active Chat (Sohbet)
- **Welcome:** denizati.png avatar, "Sohbete Basla" butonu, gunluk 5 oneri
- **Sohbet:** DeepSeek API, Markdown render, typewriter efekti, input bar
- **Limit:** Gunluk 20 mesaj, hata durumunda refund

### 5. Puan Sistemi (Gamification)
- **PointsHeroCard:** Iki modlu animasyon
- **5 Seviye:** Caylak, Merakli, Usta, Efsane, Efsane+
- **Leaderboard:** Inline top 3, KVKK/GDPR opt-in
- **Gonderi Paylasimi:** Firebase'e kaydedilir, admin onay/red yapar
- **Nickname:** Ilk gonderi yuklemede sorulur, KVKK/GDPR acik riza

### 6. Admin Paneli (Web)
- Flutter Web, responsive (sidebar desktop / drawer mobile)
- Email/Password ile giris + Firestore admin check
- Tarif CRUD + Gonderi onay/red sayfasi
- **NOT:** Admin paneli ayri bir web sitesine tasinacak (Firebase Hosting)

---

## UI/UX Hedefleri

### Tasarim Dili
- **Beyaz kartlar** uzerine turuncu vurgular
- **Manrope** font ailesi tum metinlerde
- **Custom PNG ikonlar** (denizati.png dahil)
- **Pill-shaped navbar** frosted glass efektli
- **Inner shadow** arama cubuklari ve dropdown'lar

### Navigation
- Bottom tab bar (4 sekme): Tarifler, Olustur, Chat, Puan
- Custom ikonlar: tarifler_icon, olustur_icon, chat_icon, puan_icon
- TabController listener ile swipe senkronizasyonu

### Onemli UX Detaylari
- Splash screen: 4 asama, 5 saniye animasyonlu logo gosterimi
- Instagram-style gonderi paylasimi + admin onay akisi
- Gamification: seviye atlama animasyonu sirasinda icerik gizlenir
- KVKK/GDPR: nickname ve leaderboard opt-in acik riza ile
