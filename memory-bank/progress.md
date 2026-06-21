# Progress: Atıksız Mutfak

**Son Güncelleme:** Mayıs 2026 (18 Mayıs)

---

## Tamamlanan Özellikler

### Core Infrastructure
- Flutter proje yapısı (Clean Architecture, feature-based)
- Riverpod state management + code generation
- GoRouter navigation (slide transitions, 10+ route)
- Theme ve color system (brand turuncu paleti)
- Manrope font ailesi entegrasyonu
- SıfırAtık → Atıksız Mutfak markalama
- flutter_localizations + intl ile çift dilli destek (TR/EN)

### Splash Screen
- 5 saniyelik staggered animasyon (4 aşama)
- AB logoları + EU sponsor logosu
- Admin giriş butonu kaldırıldı (artık ayrı web projesi)

### AI Tarif Üretimi (DeepSeek)
- Malzeme girişi + son eklenenler (SharedPreferences)
- Mutfak stili seçimi
- "EcoChef pişiriyor" loading overlay (denizati.png)
- RecipeParser ile AI çıktısı → Recipe model
- Kaydettiğim Tarifler (max 5, SharedPreferences)

### AI Sohbet (EcoChef)
- DeepSeek API, 20 mesaj/gün limiti
- 34 öneri, 5 kategoride, günlük 5 random
- Typewriter animasyonu, Markdown render
- 5 dk background timer ile otomatik temizlik
- denizati.png maskot entegrasyonu

### Puan Sistemi (Gamification)
- PointsHeroCard: 2 modlu animasyon (Normal progress + Level-up Journey)
- 5 seviye: Çaylak → Meraklı → Usta → Efsane → Efsane+
- Parlayan dairesel progress bar (_GradientArcPainter + _BackgroundRingPainter)
- Inline leaderboard (top 3, KVKK opt-in)
- Nickname sistemi (ilk gönderide, KVKK/GDPR uyumlu)
- Günlük Görev Kartları (SharedPreferences tabanlı, günlük sıfırlanma)
- Gönderi paylaşımı → admin onayı → puan kazanma
- Yarışmadan çıkma (Opt-Out): Firestore batch ile
- Admin bonus/kesinti: Çift dilli not (TR/EN), özel UI kartları
- Hesap silme tespiti: SharedPreferences karşılaştırması + dialog
- Mock data tamamen kaldırıldı (streak, görevler, puanlar)
- Kullanıcı adı uyarısı: "bir daha değiştiremezsin"

### Admin Paneli (Web'e Taşındı)
- ✅ Admin paneli mobil uygulamadan tamamen temizlendi
- ✅ Ayrı Flutter Web projesi için rehber dokümanı oluşturuldu
- Ayrı projede geliştirme devam ediyor

---

## Bilinen Sorunlar (Çözülmüş)

- [x] Ticker dispose hatası (PointsHeroCard)
- [x] ListTile / Nested Scaffold hataları (admin)
- [x] Form.of() context hatası (admin_recipe_form)
- [x] Chat input keyboard scroll sorunu
- [x] Chat keyboard layout kayması
- [x] SıfırAtık → Atıksız markalama
- [x] Firestore security rules (leaderboardOptIn, leaderboard write)
- [x] Günlük görevlerdeki mock yapı (SharedPreferences tabanlı)
- [x] Yeni kullanıcıda "hesap silindi" yanlış pozitif (nickname bazlı anahtar)
- [x] Animasyon tetiklenmemesi sorunu (SharedPrefs karşılaştırması + key)

---

## 🔴 Bilinen Sorunlar (Devam Eden — Öncelik Sırasına Göre)

### 1. Puan Sayfası Animasyon Sorunu (KRİTİK)
- **Problem**: HeroCard counter her sayfa açılışında 0'dan sayıyor (previousPoints yerine level.minPoints'ten başlıyor)
- **Beklenen**: Değişiklik varsa önceki puandan başlayıp yeni puana animasyon; değişiklik yoksa doğrudan mevcut puanı göstermeli
- **İlgili Dosyalar**: `points_hero_card.dart`, `points_page.dart`
- **Çözüm Aşaması**: Active geliştirme

### 2. Progress Bar Hizalama (YÜKSEK)
- **Problem**: Arka plan dairesi ile ön gradient arc tam örtüşmüyor olabilir
- **Not**: _BackgroundRingPainter eklendi ancak test edilmedi

### 3. Mobil Kullanıcı Çıkışı → Admin Panel Güncellemesi (YÜKSEK)
- **Problem**: Kullanıcı mobilde opt-out yaparsa veya kendini silerse, admin web paneli bu durumu yansıtmıyor
- **Çözüm**: Admin panelde Firestore realtime listener veya manuel refresh butonu eklenecek

### 4. Fotoğraf Sorunu — Google Drive (YÜKSEK)
- **Problem**: Firebase Storage Spark 20KB/gün upload limiti çok düşük
- **Şu anki durum**: Fotoğraflar sadece local dosya yolunda, admin panelinde görünmez
- **Alternatif**: Google Drive API entegrasyonu planlanıyor

### 5. Firebase Spark Plan Kısıtlamaları (YÜKSEK — Planlama Aşaması)
- **Kapsam**: Firestore okuma/yazma, Storage upload, Hosting bant genişliği
- **Aksiyon**: Testler bittikten sonra kapsamlı bir plan hazırlanacak
- **Not**: Stream yerine get() kullanımı ile okuma sayısı minimize edildi

---

## Yapılacaklar

### 🔴 Kritik / Acil (Bir Sonraki Oturum)
- [ ] **Animasyon sorununu çöz**: HeroCard counter 0'dan değil, önceki puandan başlamalı
- [ ] Progress bar hizalama testi ve düzeltmesi

### 🟡 Yüksek Öncelik
- [ ] **Mobil çıkış/silme → admin panel senkronizasyonu**
- [ ] **Google Drive API ile fotoğraf yükleme entegrasyonu**
- [ ] **Firebase Spark plan kısıtlama aşma planı** (testler bittikten sonra)

### 🟢 Düşük Öncelik
- [ ] Günlük chat limit reset mekanizması kontrolü
- [ ] RecipeSyncService main()'e ekleme
- [ ] Fotoğraf gösterme iyileştirmesi (placeholder + ikon)
