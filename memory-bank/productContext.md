# Product Context: Sıfır Atık Mutfak

**Son Güncelleme:** Mart 2025

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
- Uygulama açılır, "Sıfır Atık Mutfak" başlığı görünür
- Arama çubuğu (inner shadow efektli, beyaz, search_icon.png) + sağında filtre butonu
- Filtre butonu: tune ikonu, seçili malzeme varsa turuncu + badge
- Filtre butonuna tıklayınca bottom sheet açılır:
  - Arama çubuğu ile malzeme ara
  - Seçili malzemeler üstte turuncu chip'ler
  - Tüm malzemeler wrap layout'ta (seçili: turuncu, değil: outline)
  - "Temizle" + "Uygula (N)" butonları
- Seçili malzemeler ana sayfada yatay chip bar'da gösterilir (+ "Temizle" chip'i)
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
- "Tarif Oluştur" butonu → DeepSeek API → detay sheet
- Kaydettiğim Tarifler: max 5 yatay + "Tümünü gör" bottom sheet
- Tarif detayda fotoğraf yoksa placeholder gösterilmez, "Fotoğraf ekle" butonu çıkar

### 4. AI Sohbet (Chat/Leafy)
- Sıfır atık mutfak yardımcısı ile sohbet
- Input bar navbar'ın üzerinde konumlandırılmış

### 5. Puan Sistemi
- Toplam puan gösterimi
- 3 kategori kartı
- Gönderi ekleme (gelecek: fotoğraf upload)

### 6. Admin Paneli (Web)
- Email/Password ile giriş
- Sidebar layout, tarif CRUD işlemleri

---

## UI/UX Hedefleri

### Tasarım Dili
- **Beyaz kartlar** üzerine turuncu vurgular
- **Manrope** font ailesi tüm metinlerde
- **Custom PNG ikonlar** (arrow_icon, search_icon, alisveris_icon vb.)
- **Pill-shaped navbar** frosted glass efektli
- **Inner shadow** arama çubukları ve dropdown'lar
- **Bottom sheet** bazlı detay/filtre/liste görünümleri

### Navigation
- Bottom tab bar (4 sekme): Tarifler, Oluştur, Chat, Puan
- Custom ikonlar: tarifler_icon, olustur_icon, chat_icon, puan_icon
- Aktif sekme: turuncu pill + beyaz ikon + Manrope Bold 12 yazı
- Pasif sekme: beyaz daire + turuncu outline ikon

### Önemli UX Detayları
- Tarifler sadece ilk açılışta fetch edilir (keepAlive: true)
- Firestore boşsa veya hata verirse yerel JSON fallback
- Malzeme filtresi bottom sheet ile (ana sayfada kalabalık yapmaz)
- Son eklenenler kalıcı (SharedPreferences) - kullanıcı aynı malzemeleri tekrar yazmaz
- Tarif oluşturulduktan sonra aktif malzeme listesi temizlenir
- Kaydettiğim tarifler max 5 gösterilir + "Tümünü gör" ile aranabilir sheet
