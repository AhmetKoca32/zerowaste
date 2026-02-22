# Product Context: ZeroWaste Mutfak

**Son Güncelleme:** Şubat 2025

---

## 🎯 Neden Bu Proje Var?

### Problem
- Gıda israfı dünya çapında büyük bir sorun
- İnsanlar elindeki malzemelerle ne yapacağını bilemiyor
- Sıfır atık mutfak pratikleri yeterince yaygın değil
- Kullanıcılar sürdürülebilir mutfak alışkanlıkları konusunda rehberlik istiyor

### Çözüm
ZeroWaste Mutfak, AI teknolojisini kullanarak kullanıcıların elindeki malzemelerle yaratıcı tarifler oluşturmasına yardımcı olur ve sıfır atık mutfak kültürünü gamification ile teşvik eder.

---

## 👥 Hedef Kitle

### Birincil Kullanıcılar
- **Çevre Bilincine Sahip Bireyler:** Sürdürülebilir yaşam tarzına önem verenler
- **Ev Hanımları/Hanımları:** Mutfakta zaman geçiren, gıda israfını azaltmak isteyenler
- **Yemek Severler:** Yaratıcı tarifler arayan, malzemelerini değerlendirmek isteyenler
- **Öğrenciler:** Sınırlı bütçe ile yemek yapmak zorunda olanlar

### İkincil Kullanıcılar
- **Ekip Üyeleri:** Fotoğrafları puanlayan, içerik moderasyonu yapan kişiler
- **Admin Kullanıcılar:** Web admin paneli üzerinden tarif ekleyen ve güncelleyen yöneticiler
  - **Erişim:** `/admin/login` → Email/Password ile giriş
  - **Özellikler:** Tarif listesi, ekleme, düzenleme, silme
  - **Platform:** Flutter Web (desktop-friendly sidebar layout)
  - **Kapasite:** Firebase Hosting Spark plan yeterli (~5-50 admin için)

---

## 💡 Ürün Nasıl Çalışmalı?

### Kullanıcı Yolculuğu (User Journey)

#### 1. İlk Açılış
- Kullanıcı uygulamayı açar
- Ana sayfada tarif listesi görür (blog-style kartlar)
- Bottom navigation ile 4 sekme görür:
  - **Tarifler:** Mevcut tarifleri görüntüleme
  - **Oluştur:** AI ile tarif üretme
  - **Leafy:** AI sohbet
  - **Puan:** Puan sistemi ve gönderiler

#### 2. Tarif Görüntüleme
- Kullanıcı bir tarife tıklar
- Bottom sheet açılır, tarif detayları gösterilir
- Malzemeler ve adım adım yapılış görüntülenir
- Fotoğraf varsa gösterilir

#### 3. AI Tarif Üretimi
- Kullanıcı "Oluştur" sekmesine gider
- Malzemelerini text field'a girer ve "Ekle" butonuna basar
- Malzemeler chip olarak görünür
- İsteğe bağlı mutfak stili seçer (Türk, İtalyan, vb.)
- "Tarif Oluştur" butonuna basar
- Loading overlay gösterilir (şef animasyonu)
- AI tarif üretir ve bottom sheet'te gösterilir
- Kullanıcı tarifi kaydedebilir ve fotoğraf ekleyebilir

#### 4. AI Sohbet (Leafy)
- Kullanıcı "Leafy" sekmesine gider
- Chat arayüzü açılır
- Kullanıcı soru sorar (ör: "Domateslerim çürüyor, ne yapabilirim?")
- Leafy sıfır atık odaklı cevap verir
- Konuşma geçmişi ekranda kalır

#### 5. Puan Sistemi (Gelecek)
- Kullanıcı "Puan" sekmesine gider
- Toplam puanını görür
- "Gönderi ekle" butonuna basar
- Kategori seçer (dolap, yemek anı, artıklardan ne yaptım)
- Fotoğraf çeker/yükler
- İsteğe bağlı açıklama ekler
- Gönderi yüklenir
- Ekip üyeleri gönderiyi görüp puanlar
- Kullanıcı puanını görür

#### 6. Admin Paneli (Web)
- Admin web tarayıcıda `/admin/login` sayfasına gider
- Email/Password ile giriş yapar
- Firebase Auth ile authenticate olur
- Firestore'da `admins` collection'ında kontrol edilir
- Admin ise `/admin/dashboard` sayfasına yönlendirilir
- Sidebar ile navigasyon:
  - **Tarifler:** Tüm tarifleri listeler, düzenle/sil butonları
  - **Yeni Tarif:** Form ile yeni tarif ekleme
  - **Çıkış Yap:** Oturumu kapatma
- Tarif ekleme/düzenleme formu:
  - Başlık, açıklama, fotoğraf URL
  - Malzemeler (satır satır)
  - Yapılış adımları (satır satır)
- Değişiklikler Firestore'a kaydedilir
- Mobil uygulamada anında görünür

---

## 🎨 Kullanıcı Deneyimi Hedefleri

### Temel Prensipler
1. **Basitlik:** Karmaşık olmayan, sezgisel arayüz
2. **Hız:** Hızlı yükleme, akıcı animasyonlar
3. **Görsel Çekicilik:** Pastel renkler, temiz tasarım
4. **Bilgilendirme:** Kullanıcıyı sıfır atık konusunda eğitme
5. **Teşvik:** Gamification ile kullanıcıları motive etme

### Önemli UX Detayları
- **Loading States:** Her async işlemde loading gösterimi
- **Error Handling:** Kullanıcı dostu hata mesajları
- **Empty States:** Boş durumlar için anlamlı placeholder'lar
- **Offline Support:** Gelecekte offline cache desteği
- **Smooth Transitions:** Sayfa geçişlerinde slide animasyonları
- **Responsive Design:** Admin paneli desktop-friendly (sidebar)

---

## 🔄 İş Akışları (Workflows)

### Tarif Yönetimi İş Akışı
```
1. Uygulama açılır
2. RecipeRepository.getRecipes() çağrılır (useFirestore: true)
3. Firebase Firestore'dan tarifler yüklenir
4. Hata durumunda: Local JSON'dan fallback
5. Tarifler HomePage'de listelenir
6. Kullanıcı tarife tıklar → RecipeDetailSheet açılır
```

### AI Tarif Üretimi İş Akışı
```
1. Kullanıcı malzemeleri girer
2. "Tarif Oluştur" butonuna basar
3. DeepSeekService.generateRecipe() çağrılır
4. API'ye istek gönderilir
5. Yanıt alınır ve RecipeParser.parse() ile parse edilir
6. RecipeDetailSheet'te gösterilir
7. Kullanıcı kaydedebilir → SavedRecipesStorage'a kaydedilir
```

### Admin Paneli İş Akışı
```
1. Admin web tarayıcıda /admin/login sayfasına gider
2. Email/Password ile giriş yapar
3. Firebase Auth ile authenticate olur
4. Firestore'da admins collection kontrol edilir
5. Admin ise /admin/dashboard'a yönlendirilir
6. Sidebar ile tarif listesi görüntülenir
7. Yeni tarif ekleme: /admin/recipes/new → Form doldur → Firestore'a kaydet
8. Tarif düzenleme: /admin/recipes/:id → Form düzenle → Firestore'da güncelle
9. Tarif silme: Listeden sil butonu → Firestore'dan sil
10. Değişiklikler mobil uygulamada anında görünür
```

### Puan Sistemi İş Akışı (Gelecek)
```
1. Kullanıcı fotoğraf çeker/yükler
2. Gönderi bilgileri (kategori, açıklama) eklenir
3. Fotoğraf Cloud Storage'a yüklenir
4. Gönderi Firestore'a kaydedilir (status: pending)
5. Ekip üyesi admin panelinde gönderiyi görür
6. Ekip üyesi puan verir (örn: 10, 20, 30 puan)
7. Firestore'da gönderi güncellenir (status: scored, points: X)
8. Kullanıcı uygulamada puanını görür
```

---

## 📊 Başarı Kriterleri

### Kullanıcı Metrikleri
- Günlük aktif kullanıcı sayısı
- Üretilen tarif sayısı
- Kaydedilen tarif sayısı
- Chat mesaj sayısı
- Yüklenen fotoğraf sayısı
- Puanlanan gönderi sayısı

### Teknik Metrikler
- API response süreleri
- Uygulama crash oranı
- Firebase kullanım metrikleri (reads/writes/storage)
- Fotoğraf yükleme başarı oranı

### İş Metrikleri
- Kullanıcı tutma oranı (retention)
- Kullanıcı başına ortalama puan
- En çok kullanılan özellikler
- Admin paneli kullanım istatistikleri

---

## 🎯 Gelecek Vizyon

### Kısa Vadeli (3-6 ay)
- ✅ Firebase backend entegrasyonu (Firestore + Auth)
- ✅ Admin paneli tamamlama
- ⏳ Puan sistemi tamamlama
- ⏳ Cloud Storage entegrasyonu
- ⏳ Fotoğraf yükleme ve puanlama akışı

### Orta Vadeli (6-12 ay)
- Tarif arama ve filtreleme
- Kullanıcı profilleri
- Topluluk özellikleri (yorumlar, favoriler)
- Push notifications

### Uzun Vadeli (12+ ay)
- Çoklu dil desteği
- Offline mode geliştirmeleri
- Tarif önerileri (AI-based)
- Sosyal medya entegrasyonu
- İstatistikler ve raporlar

---

## 🔗 İlgili Dokümanlar

- [Firebase Ücretsiz Plan Analizi](../docs/firebase-free-plan-analysis.md)
- [Firebase Hosting Kapasite Analizi](../docs/firebase-hosting-admin-panel-kapasite.md)
- [Sistem Mimarisi](systemPatterns.md)
- [Teknik Bağlam](techContext.md)
