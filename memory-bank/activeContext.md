# Active Context: Sıfır Atık Mutfak

**Son Güncelleme:** Nisan 2026 (16 Nisan - Gece Oturumu)  
**Aktif Çalışma:** Puan sistemi modernizasyonu (Level-up journey), Chat günlük limit (20 mesaj), Kamera/Galeri entegrasyonu, Ticker sızıntı koruması.

---

## Şu Anki Odak

### Son Yapılan Değişiklikler (16 Nisan 2026 - Gece Oturumu)

#### 1. Gamification — Puan Sistemi Modernizasyonu ✨
- **PointsHeroCard Yeniden Tasarlandı:**
  - **İki Modlu Animasyon:** Sayfa her açıldığında "Normal" (mevcut seviye dolumu) ve puan artışı olduğunda "Level-up Journey" (sıfırdan başlayıp seviyeleri tek tek geçen sinematik yolculuk) modları.
  - **Seviye Sistemi:** Çaylak (0-50), Meraklı (50-150), Usta (150-300), Efsane (300-600), Efsane+ (600+).
  - **UI Detayları:** Parlayan dairesel progress bar (`_GradientArcPainter`), hareketli puan sayacı, seviye geçişlerinde kutlama overlay'leri (`_buildCelebrationOverlay`).
- **Puan Sayfası Akışı:** Yolculuk animasyonu sırasında sayfa içeriği (görevler/postlar) gizlenir, "Tebrikler" dialogundan sonra yolculuk başlar ve tamamlanınca içerik süzülerek (Fade + Slide) geri gelir.
- **Admin Bonus Kartı:** Admin tarafından verilen manuel puanlar için özel altın temalı (`_buildAdminBonusCard`) kart tasarımı.

#### 2. Chat — Günlük Mesaj Sınırı
- **Sınır:** Her kullanıcı için günlük 20 mesaj hakkı tanımlandı.
- **Teknik:** `dailyMessageCountProvider` (Riverpod) ile mesaj sayısı takip ediliyor.
- **UX:** limit dolduğunda kullanıcıya SnackBar ile bilgi veriliyor ve mesaj göndermesi engelleniyor.
- **Welcome Sayfası:** Kullanıcıyı bilgilendirmek için "Günlük 20 mesaj hakkı" ibaresi taşıyan şık bir bilgilendirme rozeti eklendi.

#### 3. Gönderi Paylaşımı & Medya Entegrasyonu
- **Image Picker:** `image_picker` paketi entegre edilerek Kamera ve Galeri desteği getirildi.
- **Özel Dialog:** Kamera mı galeri mi seçileceğini soran tertemiz, premium tasarımlı beyaz dialog.
- **Post Modeli:** `PostEntry` modeline `localImagePath` alanı eklendi.
- **RecentPostsGrid:** Artık hem statik fotoğrafları hem de kullanıcının o an çektiği/seçtiği yerel cihaz fotoğraflarını (`FileImage`) gösterebiliyor.

#### 4. Gönderi Detay Görünümü
- **Premium Dialog:** Gönderiye tıklandığında açılan, fotoğrafın ön planda (320px boyunda) olduğu detay penceresi.
- **Detaylar:** Admin notu bölümü, yüzer "Kapat" butonu ve arka plan bulanıklaştırma efekti.

#### 5. Stabilizasyon & Bug Fix
- **Ticker Leak Fix:** Animasyonlar sırasında sayfa değiştirilince oluşan "disposed with active Ticker" hatası giderildi.
- **Çözüm:** `_activeProgressController` merkezi yönetimi, `_isAnimating` ve `_isDisposed` kilit mekanizması eklendi. Tüm kontrolcüler `dispose` anında kesin olarak temizleniyor.

---

## Çözülen Sorunlar

- **Ticker Dispose Hatası:** `PointsHeroCard` animasyonları sırasında sayfa değişikliğinde oluşan çökme giderildi.
- **Medya Erişimi:** iOS/Android simülatör ve cihazlarda kamera/galeri erişimi sağlandı.
- **Post Detay:** "Paylaş" butonu kullanıcı isteği üzerine kaldırıldı, sadece "Kapat" butonu bırakıldı.
- **Grid Hataları:** `recent_posts_grid.dart` içindeki parantez hataları ve scope (kapsam) sorunları giderildi.
- **Navbar Swipe Senkronizasyonu:** TabController listener ile navbar geçişi pürüzsüzleştirildi.

---

## Yapılacaklar

### Kısa Vadeli
- **Liderlik Tablosu (Leaderboard):** Kullanıcıların puanlarına göre sıralandığı interaktif liste tasarımı.
- **Başarımlar (Achievements):** Belirli hedeflere ulaşınca kazanılan rozetler için koleksiyon sayfası.
- **Chat limit sıfırlama:** Günlük limitin her gece 00:00'da sıfırlanması için SharedPreferences kontrolü.

### Orta Vadeli
- **Backend Entegrasyonu:** Puanların ve postların Firebase'e kaydedilmesi.
- **Admin Panel:** Gönderilen postları onaylama/reddetme arayüzü.
- **Push Notification:** Puan eklendiğinde bildirim gönderimi.

---

## Önemli Tasarım Kararları

### Gamification Pattern
- Animasyonlar kullanıcıyı ödüllendirme odaklı, yavaş ve tatmin edici (`elasticOut`, `easeInOut`).
- Seviye atlama kutlamalarında "ekranı karartma + parlayan altın yazı" efekti standartlaştırıldı.

### Ticker Güvenliği (Pattern)
- Her `StatefulWidget` animasyonunda `_activeController` kullanılarak "create-before-dispose" kuralı uygulanıyor.
- `if (!mounted)` kontrolleri her `await` sonrasında zorunlu.

### Medya Pattern
- Fotoğraflar önce yerel state'e (`localImagePath`) alınır, upload süreci kullanıcıyı bekletmez.
- `PostDetail` görünümünde fotoğraf her zaman `BoxFit.cover` ve yüksek çözünürlüklü gösterilir.
- Font: Manrope her zaman kullanılmalı.
