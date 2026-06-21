# Active Context: Sıfır Atık Mutfak

**Son Güncelleme:** Mayıs 2026 (18 Mayıs)  
**Aktif Çalışma:** Puan sistemi animasyon sorunları, test ve iyileştirme aşaması.

---

## Son Yapılan Değişiklikler

### 1. Admin Paneli Mobil'den Tamamen Temizlendi
- **`lib/features/admin/`** klasörü tamamen silindi (10+ dosya)
- Admin paneli ayrı bir Flutter Web projesine taşınıyor
- **`lib/core/router/app_router.dart`**: Admin route'ları kaldırıldı
- **`lib/features/splash/presentation/pages/splash_page.dart`**: Admin giriş butonu kaldırıldı
- **`lib/l10n/app_tr.arb` & `app_en.arb`**: admin* string'leri kaldırıldı

### 2. Puan Sistemi Geliştirmeleri

#### Yeni Özellikler
- **`deductPoints()`**: Admin puan kesintisi metodu (negatif puan, `isAdminPenalty`)
- **Çift Dilli Admin Notları**: `adminNote` (TR) + `adminNoteEn` (EN), locale'e göre otomatik gösterim
- **Kullanıcı Silme Tespiti**: SharedPreferences karşılaştırması ile admin tarafından silinme algılama + dialog
- **Yarışmadan Çıkma (Opt-Out)**: HeroCard sağ üst buton, Firestore batch ile leaderboardOptIn=false
- **Kullanıcı Adı Uyarısı**: Nickname dialog'da "bir daha değiştiremezsin" uyarısı
- **Admin Bonus Kartı**: Özel altın temalı UI (`_buildAdminBonusCard`)

#### Günlük Görevler (Missions)
- Mock yapı kaldırıldı, SharedPreferences tabanlı kalıcılık
- Gönderi gönderince ilgili görev otomatik tamamlanır
- Her gün sıfırlanma (tarih karşılaştırması)
- Anahtarlar: `missions_date`, `missions_completed`

#### Points Sayfası Temizliği
- `streakDays: 3` mock verisi kaldırıldı
- Streak badge UI'dan tamamen çıkarıldı (veri kaynağı olmadığı için)
- HeroCard `_buildTopRow` sadece seviye rozetini gösteriyor

#### Puan Animasyon Sistemi (AKTİF PROBLEM — Çözüm Aşamasında)
- **Akış**: `_loadPosts()` her tab geçişinde çalışır → SharedPreferences'dan son kaydedilen puanı alır → karşılaştırır
- **İlk yükleme**: Animasyon oynar (counter 0→X, progress bar dolar)
- **Değişiklik varsa**: Yine animasyon oynar (counter previousPoints→totalPoints)
- **Değişiklik yoksa**: Statik gösterim
- **Level-up**: Seviye atlama overlay'i + journey animasyonu
- **BİLİNEN SORUN**: Counter her zaman level minimumundan (0) başlıyor, önceki puandan değil. Değişiklik olmayan dönüşlerde bile 0→X animasyonu oynuyor.

### 3. Firestore Entegrasyonu ve Rules

#### Yeni Repository Metodları
- `deductPoints()`: Negatif puanlı admin kesintisi
- `addBonusPoints()`: Admin bonusu (approved statüde)
- `optOutUser()`: Batch write ile tüm gönderileri opt-out
- `_recalculateLeaderboard()`: catch bloğunda print eklendi

#### Firestore Rules Güncellemeleri
- `posts/{postId}`: update için `leaderboardOptIn` alanı herkese açık
- `leaderboard/{docId}`: write herkese açık (derlenmiş veri olduğu için güvenli)

---

## Bilinen Sorunlar (Öncelik Sırasına Göre)

### 🔴 KRİTİK — Çözülmesi Gerekenler

- [ ] **Puan Sayfası Animasyon Sorunu**: HeroCard counter her sayfa açılışında 0'dan sayıyor. Değişiklik olmasa bile. Beklenen: sadece puan arttığında önceki puandan başlayıp yeni puana animasyon yapmalı; değişiklik yoksa doğrudan mevcut puanı göstermeli.
- [ ] **Progress Bar Hizalama**: `_GradientArcPainter` ile `_BackgroundRingPainter` arasında hizalama sorunu olabilir (arka plan dairesi ile ön gradient arc tam örtüşmüyor).

### 🟡 YÜKSEK — Planlanan

- [ ] **Mobil Kullanıcı Çıkışı/Yarışmadan Ayrılma → Admin Panel Güncellemesi**: Kullanıcı mobilde opt-out yaparsa veya kendini silerse, admin web panelindeki leaderboard ve kullanıcı listesi bu durumu yansıtmıyor. Admin panelinde canlı/güncel veri göstermek için Firestore listener veya manuel refresh mekanizması eklenmeli.
- [ ] **Fotoğraf Sorunu — Google Drive Çözümü**: Firebase Storage Spark planında 20KB/gün upload limiti çok düşük. Fotoğraflar şu an sadece local dosya yolunda saklanıyor, admin panelinde görünmüyor. Çözüm: Google Drive API ile fotoğraf yükleme. Firebase Storage -> Google Drive geçiş planı yapılacak.
- [ ] **Firebase Spark Plan Kısıtlamalarını Aşma Planı**: Testler bittikten sonra Spark (ücretsiz) planının sınırlarını aşmamak için genel bir strateji belirlenecek. Firestore okuma/yazma limitleri, Storage upload limitleri, Hosting bant genişliği gibi tüm kısıtlar dökümante edilip bir aksiyon planı çıkarılacak.

### 🟢 DÜŞÜK

- [ ] Günlük chat limit reset mekanizması (şu an hardcoded olabilir)
- [ ] RecipeSyncService main()'de çağrılmadı

---

## Firebase Yapılandırması

- [x] `posts` koleksiyonu oluşturuldu
- [x] `leaderboard/current` dokümanı oluşturuldu (boş entries)
- [x] `admins/{uid}` dokümanı oluşturuldu (role: "admin")
- [x] Firebase Authentication Email/Password etkin
- [x] Firestore rules güncellendi
- [x] Firebase index'leri oluşturuldu

---

## Karar Günlüğü

| Tarih | Karar | Gerekçe |
|-------|-------|---------|
| 18 Mayıs | Puan animasyonu her sayfa açılışında tetiklensin | Kullanıcı deneyimi için küçük progress animasyonu önemli; sadece level-up overlay'i gerçek seviye atlamada gösterilsin |
| 18 Mayıs | Realtime stream yerine tab-switch listener kullanıldı | Stream gereksiz Firestore okuma kotası tüketiyor; tab değişiminde `_loadPosts()` tek seferlik `get()` ile yeterli |
| 18 Mayıs | Fotoğraf için Google Drive API planı | Firebase Storage Spark limitleri (20KB/gün upload) çok düşük; Drive API daha esnek |
| 18 Mayıs | `firestore.rules` leaderboard write herkese açık | Leaderboard verisi posts koleksiyonundan türetildiği için güvenli; admin yazma zorunluluğu mobil opt-out'u engelliyordu |
