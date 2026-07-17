# Active Context: Atıksız Mutfak

**Son Güncelleme:** Temmuz 2026 (17 Temmuz)  
**Aktif Çalışma:** Admin paneli (ayrı web projesi) tarif formu tasarımı; mobilde gönderi fotoğrafı yükleme (Firebase Storage) tamamlandı.

---

## Son Yapılan Değişiklikler

### 1. Gönderi Fotoğrafı — Firebase Storage Entegrasyonu
- **`AnonymousAuthService`**: Uygulama açılışında anonim Firebase Auth oturumu (`main.dart`)
- **`PostImageStorageService`**: Fotoğrafları `posts/{postId}/photo.jpg` yoluna yükler (max 2 MB, JPEG)
- **`storage.rules`**: Auth zorunlu, 2 MB limit, sadece `image/*` content type
- **`PostEntry`**: `imageUrl` (Storage download URL) + `localPreviewPath` (optimistic preview, persist edilmez)
- **`PostImageThumbnail`**: `CachedNetworkImage` ile remote URL veya local preview gösterimi
- **`points_page.dart`**: Gönderi akışı önce Storage'a upload → sonra Firestore'a `imageUrl` ile kayıt
- **`firebase.json`**: Storage rules eklendi
- **`pubspec.yaml`**: `firebase_storage`, `cached_network_image` eklendi

### 2. Tarif Listesi — Firestore-Only + Coming Soon
- **`RecipeRepository`**: Firestore boşsa veya hata verirse artık local JSON fallback yok → `[]` döner
- **`RecipesComingSoon`**: Tarif listesi boşken animasyonlu placeholder gösterilir
- Admin panelden tarif eklenene kadar mobilde "yakında" ekranı görünür
- Yerel `assets/data/recipes.json` hâlâ mevcut ama runtime'da kullanılmıyor (`useFirestore: true`)

### 3. Admin Paneli Tarif Formu Tasarım Kararı (Ayrı Web Projesi)
Admin paneli mobil uygulamadan ayrı bir Flutter Web projesi olarak geliştiriliyor. Tarif ekleme/düzenleme formu mobil uygulamadaki görünümle birebir uyumlu olmalı:

| Alan | Admin input | Firestore tipi | Mobil görünüm |
|------|-------------|----------------|---------------|
| `title` | Tek satır TextField (zorunlu) | `string` | Başlık |
| `description` | Multiline textarea (opsiyonel) | `string?` | Tek paragraf |
| `ingredients` | Dinamik liste (ekle/sil) | `string[]` | Bullet list (madde madde) |
| `instructions` | Dinamik liste (ekle/sil, numaralı) | `string[]` | Numaralı adımlar (1, 2, 3…) |
| `image_url` | URL input (opsiyonel) | `string?` | Kapak fotoğrafı |

**Önemli kurallar:**
- Malzemeler ve adımlar tek textarea'ya virgülle/newline ile yazılmamalı
- Her malzeme/adım ayrı input satırı → Firestore'da `string[]` olarak kaydedilmeli
- Dizi sırası = mobildeki adım numarası
- Boş satırlar kayıt öncesi filtrelenmeli
- `DynamicStringListField` widget'ı hem malzemeler hem adımlar için yeniden kullanılabilir

### 4. iOS SceneDelegate
- **`ios/Runner/SceneDelegate.swift`**: iOS scene lifecycle desteği eklendi

---

## Bilinen Sorunlar (Öncelik Sırasına Göre)

### 🔴 KRİTİK

- [ ] **Puan Sayfası Animasyon Sorunu**: HeroCard counter her sayfa açılışında 0'dan sayıyor. Değişiklik olmasa bile. Beklenen: sadece puan arttığında önceki puandan başlayıp yeni puana animasyon; değişiklik yoksa statik gösterim.
- [ ] **Progress Bar Hizalama**: `_GradientArcPainter` ile `_BackgroundRingPainter` arasında hizalama sorunu olabilir.

### 🟡 YÜKSEK

- [ ] **Admin paneli tarif CRUD**: Ayrı web projesinde `DynamicStringListField` + `AdminRecipeForm` implementasyonu
- [ ] **Mobil çıkış/silme → admin panel senkronizasyonu**: Opt-out veya silme admin panelde yansımıyor; Firestore listener veya refresh gerekli
- [ ] **Firebase Spark plan kotası**: Storage upload limitleri (20KB/gün) test edilmeli; yoğun kullanımda Blaze geçişi gerekebilir
- [ ] **Firebase Spark Plan Kısıtlamalarını Aşma Planı**: Testler bittikten sonra kapsamlı kota stratejisi

### 🟢 DÜŞÜK

- [ ] Günlük chat limit reset mekanizması kontrolü
- [ ] RecipeSyncService main()'de çağrılmadı
- [ ] Firestore `recipes` koleksiyonuna ilk tariflerin admin panelden eklenmesi

---

## Firebase Yapılandırması

- [x] `posts` koleksiyonu
- [x] `leaderboard/current` dokümanı
- [x] `admins/{uid}` dokümanı
- [x] Firebase Authentication (Email/Password + Anonymous)
- [x] Firestore rules (`recipes` admin-only write)
- [x] Storage rules (`posts/{postId}/{fileName}`)
- [x] Firestore index'leri
- [ ] `recipes` koleksiyonuna admin panelden tarif ekleme (devam ediyor)

---

## Karar Günlüğü

| Tarih | Karar | Gerekçe |
|-------|-------|---------|
| 17 Temmuz | Admin tarif formu: malzeme/adım dinamik liste | Mobil uygulama `ingredients` ve `instructions` alanlarını `string[]` olarak madde madde / numaralı adım şeklinde render ediyor; tek textarea uyumsuz olur |
| 17 Temmuz | Tarif listesi local JSON fallback kaldırıldı | Admin panelden yönetilen tek kaynak Firestore; boşken RecipesComingSoon göster |
| 17 Temmuz | Gönderi fotoğrafları Firebase Storage'a | Google Drive yerine Firebase ekosistemi içinde çözüm; anonim auth ile nickname-only kullanıcılar upload yapabilir |
| 17 Temmuz | Anonim Firebase Auth startup'ta | Storage rules `request.auth != null` gerektiriyor; kullanıcıdan ayrı login istemiyoruz |
| 18 Mayıs | Puan animasyonu tab geçişinde tetiklensin | Küçük progress animasyonu UX için önemli |
| 18 Mayıs | Realtime stream yerine tab-switch listener | Firestore okuma kotası tasarrufu |
| 18 Mayıs | `firestore.rules` leaderboard write herkese açık | Mobil opt-out'u engellememek için |
