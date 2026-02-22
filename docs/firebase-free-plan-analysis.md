# Firebase Ücretsiz Plan (Spark) - ZeroWaste Projesi Kapasite Analizi

**Tarih:** Şubat 2025  
**Firebase Plan:** Spark (Ücretsiz)  
**Proje:** ZeroWaste Mutfak

---

## 📊 Firebase Spark Plan Limitleri (2025)

### Cloud Firestore (Veritabanı)
- **Depolama:** 1 GiB (1,024 MB) toplam veri
- **Okuma (Reads):** 50,000 okuma/gün
- **Yazma (Writes):** 20,000 yazma/gün
- **Silme (Deletes):** 20,000 silme/gün
- **Ağ Çıkışı (Egress):** 10 GiB/ay

### Cloud Storage (Fotoğraf Depolama)
- **Depolama:** 5 GB (yeni bucket'lar için 5 GB-ay)
- **İndirme Bandwidth:** 1 GB/gün (eski bucket) veya 100 GB/ay (yeni bucket)
- **Upload İşlemleri:** 20,000 upload/gün
- **Download İşlemleri:** 50,000 download/gün

⚠️ **ÖNEMLİ:** 3 Şubat 2026'dan itibaren eski Cloud Storage bucket'ları (*.appspot.com) Blaze planına geçiş gerektiriyor. Yeni bucket'lar (*.firebasestorage.app) kullanılmalı.

---

## 🧮 Kapasite Hesaplamaları

### 1. Fotoğraf Depolama (Cloud Storage)

#### Senaryo: Sıkıştırılmış Fotoğraflar
- **Ortalama fotoğraf boyutu:** 200 KB (sıkıştırılmış, 800x600 veya benzer)
- **Maksimum fotoğraf sayısı:** 5 GB ÷ 200 KB = **~25,000 fotoğraf**

#### Senaryo: Orta Kalite Fotoğraflar
- **Ortalama fotoğraf boyutu:** 500 KB (orta kalite, 1200x900)
- **Maksimum fotoğraf sayısı:** 5 GB ÷ 500 KB = **~10,000 fotoğraf**

#### Senaryo: Yüksek Kalite Fotoğraflar
- **Ortalama fotoğraf boyutu:** 1 MB (yüksek kalite, 1920x1080)
- **Maksimum fotoğraf sayısı:** 5 GB ÷ 1 MB = **~5,000 fotoğraf**

**Öneri:** Flutter'da fotoğraf yüklerken sıkıştırma yapılmalı (ör. `flutter_image_compress`). Hedef: **200-300 KB/fotoğraf** → **~15,000-20,000 fotoğraf** kapasitesi.

---

### 2. Kullanıcı Sayısı Hesaplaması (Firestore Reads/Writes)

#### Günlük Aktivite Senaryoları

**Aktif Kullanıcı Tanımı:** Günde en az 1 işlem yapan kullanıcı

#### Senaryo A: Düşük Aktivite
- Kullanıcı başına günlük:
  - Tarif listesi görüntüleme: 1 read (ana sayfa)
  - Tarif detay görüntüleme: 2 reads (detay sayfası)
  - Fotoğraf yükleme: 1 write (submission kaydı)
  - **Toplam:** ~3 reads + 1 write/kullanıcı/gün

- **Maksimum aktif kullanıcı:**
  - Reads: 50,000 ÷ 3 = **~16,600 aktif kullanıcı/gün**
  - Writes: 20,000 ÷ 1 = **20,000 aktif kullanıcı/gün**
  - **Sınırlayıcı:** Reads → **~16,000 aktif kullanıcı/gün**

#### Senaryo B: Orta Aktivite
- Kullanıcı başına günlük:
  - Tarif listesi: 1 read
  - 3 tarif detayı: 6 reads
  - Fotoğraf yükleme: 1 write
  - Puan kontrolü: 1 read
  - **Toplam:** ~8 reads + 1 write/kullanıcı/gün

- **Maksimum aktif kullanıcı:**
  - Reads: 50,000 ÷ 8 = **~6,250 aktif kullanıcı/gün**
  - Writes: 20,000 ÷ 1 = **20,000 aktif kullanıcı/gün**
  - **Sınırlayıcı:** Reads → **~6,000 aktif kullanıcı/gün**

#### Senaryo C: Yüksek Aktivite
- Kullanıcı başına günlük:
  - Tarif listesi: 1 read
  - 5 tarif detayı: 10 reads
  - Fotoğraf yükleme: 2 writes (2 farklı kategori)
  - Puan kontrolü: 2 reads
  - **Toplam:** ~13 reads + 2 writes/kullanıcı/gün

- **Maksimum aktif kullanıcı:**
  - Reads: 50,000 ÷ 13 = **~3,800 aktif kullanıcı/gün**
  - Writes: 20,000 ÷ 2 = **10,000 aktif kullanıcı/gün**
  - **Sınırlayıcı:** Reads → **~3,800 aktif kullanıcı/gün**

**Gerçekçi Tahmin:** Ortalama aktivite ile **~5,000-8,000 aktif kullanıcı/gün** desteklenebilir.

---

### 3. Tarif Verileri (Firestore)

#### Tarif Verisi Boyutu
- **Ortalama tarif:** ~2-5 KB (JSON, başlık, malzemeler, adımlar, fotoğraf URL'i)
- **100 tarif:** ~200-500 KB
- **1,000 tarif:** ~2-5 MB

**Sonuç:** Firestore'un 1 GB depolama limiti ile **~200,000-500,000 tarif** saklanabilir (pratikte çok daha az olacak, çünkü kullanıcı verileri de bu alanı kullanır).

---

### 4. Kullanıcı Verileri (Firestore)

#### Kullanıcı Profili + Submission Verileri
- **Kullanıcı profili:** ~1 KB (isim, email, toplam puan, kayıt tarihi)
- **Submission (gönderi):** ~0.5 KB (fotoğraf URL'i, açıklama, kategori, tarih, puan)
- **Kullanıcı başına ortalama:** 1 KB (profil) + 5 submission × 0.5 KB = **~3.5 KB**

**10,000 kullanıcı:** ~35 MB  
**50,000 kullanıcı:** ~175 MB  
**100,000 kullanıcı:** ~350 MB

**Sonuç:** Kullanıcı verileri için Firestore limiti yeterli (1 GB içinde).

---

## 📈 Toplam Kapasite Özeti

### Senaryo: Orta Aktivite + Sıkıştırılmış Fotoğraflar

| Metrik | Değer |
|--------|-------|
| **Maksimum Fotoğraf Sayısı** | ~15,000-20,000 fotoğraf |
| **Maksimum Aktif Kullanıcı/Gün** | ~5,000-8,000 kullanıcı |
| **Maksimum Toplam Kullanıcı** | ~100,000+ kullanıcı (veri boyutu açısından) |
| **Maksimum Tarif Sayısı** | ~10,000+ tarif (pratik limit) |

### Sınırlayıcı Faktörler

1. **En Sıkı Sınır:** Firestore günlük reads (50,000/gün)
   - → Aktif kullanıcı sayısını sınırlar
   - **Çözüm:** Cache mekanizmaları, pagination, gereksiz okumaları azaltma

2. **İkinci Sınır:** Cloud Storage depolama (5 GB)
   - → Toplam fotoğraf sayısını sınırlar
   - **Çözüm:** Fotoğraf sıkıştırma, eski fotoğrafları arşivleme

3. **Üçüncü Sınır:** Firestore writes (20,000/gün)
   - → Günlük yeni gönderi sayısını sınırlar
   - **Çözüm:** Batch writes, gereksiz yazmaları azaltma

---

## 🎯 Optimizasyon Önerileri

### 1. Fotoğraf Optimizasyonu
- ✅ Flutter'da fotoğraf yüklerken sıkıştırma (`flutter_image_compress`)
- ✅ Hedef boyut: 200-300 KB/fotoğraf
- ✅ Maksimum çözünürlük: 1200x900 (orta kalite yeterli)

### 2. Firestore Reads Optimizasyonu
- ✅ Tarif listesi için pagination (sayfa başına 10-20 tarif)
- ✅ Cache mekanizması (local storage veya Flutter cache)
- ✅ Gereksiz detay okumalarını azaltma (sadece listeleme için minimal veri)
- ✅ Real-time listener'ları dikkatli kullanma (sadece gerekli yerlerde)

### 3. Firestore Writes Optimizasyonu
- ✅ Batch writes kullanma (birden fazla işlemi tek seferde)
- ✅ Gereksiz güncellemeleri önleme (sadece değişen alanları güncelle)

### 4. Bandwidth Optimizasyonu
- ✅ Fotoğrafları lazy loading ile yükleme
- ✅ Thumbnail'lar kullanma (küçük önizleme görselleri)
- ✅ CDN kullanımı (Firebase Storage otomatik sağlar)

---

## ⚠️ Limit Aşımı Durumunda

Firebase Spark planında limit aşılırsa:
- **Firestore:** Okuma/yazma işlemleri reddedilir (hata döner)
- **Storage:** Upload işlemleri reddedilir
- **Çözüm:** Blaze planına geçiş gerekir (pay-as-you-go, yalnızca kullandığın kadar ödersin)

**Blaze Plan Avantajları:**
- Spark plan limitleri hala ücretsiz (free tier)
- Limit aşımında otomatik ücretlendirme
- Daha yüksek kapasite

---

## 📋 Sonuç ve Öneriler

### ZeroWaste Projesi İçin Uygun mu?

**Evet, başlangıç için uygun!** 

- ✅ **İlk 5,000-8,000 aktif kullanıcıya kadar** ücretsiz çalışır
- ✅ **~15,000-20,000 fotoğraf** depolanabilir
- ✅ **10,000+ tarif** saklanabilir
- ✅ Optimizasyonlarla daha da uzatılabilir

### İlk Aşama Planı

1. **Fotoğraf sıkıştırma** implementasyonu (200-300 KB hedef)
2. **Pagination** tarif listesi için
3. **Cache mekanizması** tarifler için
4. **Monitoring** Firebase Console'dan kullanım takibi

### Gelecek Planlama

- İlk 3-6 ay: Spark plan ile test ve geliştirme
- Kullanıcı sayısı artınca: Blaze planına geçiş (free tier korunur, sadece aşım ücretlendirilir)
- Alternatif: Supabase'e geçiş (farklı limitler, PostgreSQL tabanlı)

---

**Hazırlayan:** AI Assistant  
**Son Güncelleme:** Şubat 2025  
**Kaynak:** Firebase Pricing Documentation (2025)
