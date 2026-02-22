# Firebase Hosting - Ücretsiz Tier Açıklaması

**Tarih:** Şubat 2025

---

## 🎯 Kısa Cevap

Firebase Hosting **Spark (ücretsiz) planında** dahil ve **10 GB depolama + 360 MB/gün transfer** limiti var. Küçük-orta büyüklükteki web uygulamaları için yeterli.

---

## 📊 Firebase Hosting Ücretsiz Limitleri (Spark Plan)

### Depolama (Storage)
- **10 GB** toplam depolama alanı
- Statik dosyalar (HTML, CSS, JS, images) için

### Transfer (Bandwidth)
- **360 MB/gün** (yaklaşık 10 GB/ay)
- İndirilen veri miktarı

### Özellikler
- ✅ **SSL sertifikası** otomatik (ücretsiz)
- ✅ **CDN** dahil (dünya çapında hızlı erişim)
- ✅ **Custom domain** desteği
- ✅ **Automatic HTTPS** (güvenli bağlantı)
- ✅ **Rollback** özelliği (önceki versiyona dönme)

---

## 💡 ZeroWaste Projesi İçin Hesaplama

### Flutter Web Build Boyutu

**Tipik bir Flutter web build:**
- **İlk yükleme:** ~2-5 MB (gzip ile sıkıştırılmış)
- **Sonraki yüklemeler:** ~100-500 KB (cache sayesinde)

### Senaryo Hesaplaması

**Günlük Aktif Kullanıcı:**
- 1,000 kullanıcı/gün × 3 MB (ilk yükleme) = **3 GB/gün** ❌ (limit aşar)
- 1,000 kullanıcı/gün × 500 KB (cache'li) = **500 MB/gün** ✅ (limit içinde)

**Gerçekçi Senaryo:**
- İlk 100 kullanıcı: 100 × 3 MB = 300 MB ✅
- Sonraki kullanıcılar: Cache'den yükler (~100 KB)
- **Günlük ortalama:** ~400-500 MB ✅ (limit içinde)

**Sonuç:** İlk yükleme yüksek olsa da, cache sayesinde günlük limit genelde yeterli.

---

## ⚠️ Limit Aşımı Durumunda

### Ne Olur?

- **Depolama limiti aşılınca:** Yeni deploy başarısız olur
- **Transfer limiti aşılınca:** Site yavaşlar veya erişilemez hale gelir

### Çözüm

**Blaze Planına Geçiş:**
- Spark plan limitleri hala ücretsiz kalır
- Limit aşımında otomatik ücretlendirme
- Sadece kullandığın kadar ödersin

**Blaze Plan Fiyatlandırma (2025):**
- **Depolama:** $0.026/GB/ay (ilk 10 GB ücretsiz)
- **Transfer:** $0.15/GB (ilk 10 GB/ay ücretsiz)

**Örnek:**
- 15 GB depolama kullanırsan: (15-10) × $0.026 = **$0.13/ay**
- 15 GB transfer kullanırsan: (15-10) × $0.15 = **$0.75/ay**

---

## 🚀 Optimizasyon İpuçları

### 1. Build Optimizasyonu

```bash
# Release build (sıkıştırılmış)
flutter build web --release

# Tree shaking (kullanılmayan kodları kaldırır)
# Otomatik olarak yapılır
```

### 2. Cache Stratejisi

Firebase Hosting otomatik cache headers ekler:
- **Static assets:** 1 yıl cache
- **HTML:** Cache yok (her zaman güncel)

### 3. CDN Kullanımı

Firebase Hosting otomatik CDN kullanır:
- Dosyalar dünya çapında edge server'larda saklanır
- Kullanıcıya en yakın server'dan servis edilir
- Transfer maliyeti azalır

### 4. Gzip Compression

Firebase Hosting otomatik gzip yapar:
- Dosyalar sıkıştırılmış gönderilir
- Transfer miktarı azalır

---

## 📋 Firebase Hosting vs Diğer Hosting

| Özellik | Firebase Hosting | Netlify | Vercel |
|---------|------------------|---------|--------|
| **Ücretsiz Depolama** | 10 GB | 100 GB | 100 GB |
| **Ücretsiz Transfer** | 360 MB/gün | 100 GB/ay | 100 GB/ay |
| **SSL** | ✅ Otomatik | ✅ Otomatik | ✅ Otomatik |
| **CDN** | ✅ Dahil | ✅ Dahil | ✅ Dahil |
| **Custom Domain** | ✅ Ücretsiz | ✅ Ücretsiz | ✅ Ücretsiz |
| **Firebase Entegrasyonu** | ✅ Mükemmel | ❌ Yok | ❌ Yok |

**Firebase Hosting Avantajı:**
- Firebase projenle tam entegre
- Firestore, Storage, Auth ile kolay entegrasyon
- Tek platform yönetimi

**Dezavantajı:**
- Transfer limiti daha düşük (ama küçük-orta projeler için yeterli)

---

## 🎯 ZeroWaste Projesi İçin Öneri

### Senaryo 1: Küçük Kullanıcı Base (< 1,000 aktif/gün)

**Firebase Hosting Spark Plan:**
- ✅ Yeterli
- ✅ Ücretsiz
- ✅ Kolay yönetim

### Senaryo 2: Orta Kullanıcı Base (1,000-5,000 aktif/gün)

**Firebase Hosting Spark Plan:**
- ⚠️ Limit yakın olabilir
- ✅ Cache sayesinde genelde yeterli
- ⚠️ İzle ve gerekirse Blaze'a geç

### Senaryo 3: Büyük Kullanıcı Base (> 5,000 aktif/gün)

**Firebase Hosting Blaze Plan:**
- ✅ Limit aşımında otomatik ücretlendirme
- ✅ İlk 10 GB/ay hala ücretsiz
- ✅ Sadece aşım için ödeme

---

## 💰 Maliyet Tahmini

### Spark Plan (Ücretsiz)
- **0-10 GB depolama:** Ücretsiz ✅
- **0-360 MB/gün transfer:** Ücretsiz ✅
- **Toplam:** **$0/ay**

### Blaze Plan (Pay-as-you-go)

**Küçük Proje Senaryosu:**
- Depolama: 5 GB (ücretsiz limit içinde)
- Transfer: 500 MB/gün = 15 GB/ay
  - İlk 10 GB: Ücretsiz
  - Sonraki 5 GB: 5 × $0.15 = **$0.75/ay**
- **Toplam:** **~$0.75-1/ay**

**Orta Proje Senaryosu:**
- Depolama: 12 GB
  - İlk 10 GB: Ücretsiz
  - Sonraki 2 GB: 2 × $0.026 = $0.052/ay
- Transfer: 1 GB/gün = 30 GB/ay
  - İlk 10 GB: Ücretsiz
  - Sonraki 20 GB: 20 × $0.15 = $3/ay
- **Toplam:** **~$3-4/ay**

---

## ✅ Sonuç

**Firebase Hosting Spark Plan:**
- ✅ **10 GB depolama** ücretsiz
- ✅ **360 MB/gün transfer** ücretsiz
- ✅ Küçük-orta projeler için yeterli
- ✅ SSL ve CDN dahil
- ✅ Firebase entegrasyonu mükemmel

**ZeroWaste Projesi İçin:**
- ✅ Başlangıç için Spark plan yeterli
- ✅ Cache sayesinde transfer limiti genelde sorun değil
- ✅ Büyüdükçe Blaze plana geçiş kolay (ilk 10 GB hala ücretsiz)

**Öneri:** Spark plan ile başla, kullanımı izle, gerekirse Blaze'a geç.

---

**Son Güncelleme:** Şubat 2025
