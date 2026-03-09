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
- Arama çubuğu (inner shadow efektli, beyaz, search_icon.png)
- Altında yatay kaydırılabilir malzeme chip'leri:
  - "Tümü" chip'i (seçim temizleme)
  - Tüm tariflerden çıkarılan benzersiz malzemeler
  - Multi-select: seçili chip turuncu dolgu, seçili olmayan beyaz/turuncu outline
- Tarifler akıllı sıralama ile listelenir (seçilen malzemelerle en çok eşleşen üstte)
- Her tarif kartında eşleşme göstergesi: "3/4 malzeme elinizde"
- Tarif kartları: beyaz arka plan, yuvarlak köşeli yemek resmi (16px padding), başlık, malzeme chip'leri (turuncu kenarlı), "Tarifi İncele" butonu
- Karta tıklanınca bottom sheet detay açılır

### 2. Tarif Detay (Bottom Sheet)
- Beyaz arka plan, yumuşak gölge
- Yemek resmi (yuvarlak köşeli, yemek.png placeholder)
- Başlık (Manrope Bold 20)
- Malzemeler: turuncu kenarlıklı chip'ler (alisveris_icon.png ikonu ile)
- Yapılış: numaralı adımlar (turuncu daire numaralar)
- Kaydet/Kapat butonları (varsa)

### 3. AI Tarif Üretimi (Oluştur)
- Malzeme girişi + mutfak stili seçimi
- AI ile tarif üretimi (DeepSeek API)
- Üretilen tarifi kaydetme ve fotoğraf ekleme

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
- **Custom PNG ikonlar** (Flutter material ikonları yerine)
- **Pill-shaped navbar** frosted glass efektli
- **Inner shadow** arama çubuğu
- **Chip-based** malzeme gösterimi ve filtreleme

### Navigation
- Bottom tab bar (4 sekme): Tarifler, Oluştur, Chat, Puan
- Custom ikonlar: tarifler_icon, olustur_icon, chat_icon, puan_icon
- Aktif sekme: turuncu pill + beyaz ikon + Manrope Bold 12 yazı
- Pasif sekme: beyaz daire + turuncu outline ikon

### Önemli UX Detayları
- Tarifler sadece ilk açılışta fetch edilir (keepAlive: true)
- Loading states ve error handling
- Malzeme filtresi ile akıllı sıralama (tam eşleşme gerekmez, en çok eşleşen üstte)
- Eşleşme göstergesi kartlarda ("X/Y malzeme elinizde")
