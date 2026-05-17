# Active Context: Sıfır Atık Mutfak

**Son Guncelleme:** Mayis 2026 (17 Mayis)  
**Aktif Calisma:** Admin paneli + Firestore entegrasyonu tamamlandi. Test asamasinda.

---

## Son Yapilan Degisiklikler

### 1. Admin Paneli + Firestore Entegrasyonu (MAJOR)

#### Yeni Dosyalar
- **`lib/features/points/data/models/post_entry.dart`**: PostEntry modeli (fromFirestore/toFirestore), ayri dosyaya tasindi
- **`lib/features/points/data/models/leaderboard_doc.dart`**: LeaderboardEntry + LeaderboardDoc modelleri
- **`lib/features/points/data/repositories/points_repository.dart`**: submitPost, getPostsByNickname, getPendingPosts, approvePost, rejectPost, getLeaderboard, _recalculateLeaderboard
- **`lib/features/points/presentation/providers/points_providers.dart`**: pointsRepositoryProvider (Riverpod)
- **`lib/features/admin/presentation/pages/admin_posts_page.dart`**: Bekleyen gonderi listesi + onay/red
- **`lib/features/home/data/services/recipe_sync_service.dart`**: Gunluk Firestore tarif senkronizasyonu

#### Guncellenen Dosyalar
- **`lib/features/admin/presentation/widgets/admin_sidebar.dart`**: YENIDEN YAZILDI -> AdminShell (responsive: sidebar desktop / drawer mobile, tek Scaffold)
- **`lib/features/admin/presentation/pages/admin_dashboard_page.dart`**: ListTile kaldirildi, InkWell+Row kullanildi
- **`lib/features/admin/presentation/pages/admin_recipe_edit_page.dart`**: AdminShell baglantili
- **`lib/features/admin/presentation/widgets/admin_recipe_form.dart`**: Form.of() -> widget.formKey duzeltmesi
- **`lib/features/admin/presentation/pages/admin_posts_page.dart`**: AdminGuard + AdminShell entegre
- **`lib/features/points/presentation/pages/points_page.dart`**: Firestore baglantisi canli, mock data kaldirildi, nickname sistemi, leaderboard
- **`lib/features/points/presentation/widgets/recent_posts_grid.dart`**: Eski PostEntry/PostStatus kaldirildi, yeni model kullanimi
- **`lib/core/router/app_router.dart`**: /admin/posts rotasi eklendi
- **`lib/features/splash/presentation/pages/splash_page.dart`**: Admin giris butonu eklendi (sag alt kose)
- **`lib/features/chat/presentation/widgets/ecochef_welcome.dart`**: denizati.png ikonu
- **`lib/features/chat/presentation/widgets/ecochef_chat_empty.dart`**: denizati.png ikonu
- **`lib/features/chat/presentation/widgets/chat_bubble.dart`**: denizati.png ikonu
- **`lib/features/chat/presentation/widgets/ecochef_typing_indicator.dart`**: denizati.png ikonu
- **`lib/features/chat/presentation/pages/chat_page.dart`**: denizati.png ikonu, keyboard fix, klavye acilinca layout duzeltmesi
- **`lib/features/recipe_generator/presentation/widgets/chef_loading_overlay.dart`**: denizati.png, "EcoChef pisiriyor" yazisi
- **`lib/core/services/deep_seek_service.dart`**: SifirAtik prompt guncellemesi
- **`lib/features/recipe_generator/data/recipe_parser.dart`**: Baslik temizleme
- **`lib/main.dart`**: SifirAtikApp olarak yeniden adlandirma
- **`lib/features/points/presentation/widgets/points_hero_card.dart`**: nickname parametresi
- **`lib/features/home/presentation/widgets/ingredient_filter_sheet.dart`**: Overflow fix
- **`firestore.rules`**: posts ve leaderboard koleksiyonlari eklendi

---

## Cozulen Sorunlar

- **ListTile hatalari**: Tum admin sayfalarinda ListTile -> InkWell+Row, nested Scaffold cozumu
- **Form.of() hatasi**: AdminRecipeForm'da widget.formKey kullanimi
- **Firestore index gereksinimi**: posts(status, createdAt), posts(nickname, createdAt), posts(status, leaderboardOptIn) index'leri olusturuldu
- **Fotograf gosterimi**: Yerel dosya yoluyla calisiyor, Firebase Storage henuz entegre degil (fotograf admin panelinde gozukmez)
- **SifirAtik markalama**: ZeroWaste -> SifirAtik, denizati.png EcoChef ikonu

---

## Bilinen Sorunlar

- [ ] Fotograflar Firebase Storage'a yuklenmiyor (sadece yerel gosterim)
- [ ] Fotograf admin panelinde gozukmez (gecici dosyaya erisilemez)
- [ ] RecipeSyncService main() icinde henuz cagrilmadi
- [ ] Gunluk mesaj limiti reset'i su an hardcoded olabilir

---

## Firebase Yapilandirmasi (Tamamlandi)

- [x] `posts` koleksiyonu olusturuldu
- [x] `leaderboard/current` dokumani olusturuldu (bos entries)
- [x] `admins/{uid}` dokumani olusturuldu (role: "admin")
- [x] Firebase Authentication Email/Password etkin
- [x] Firestore rules guncellendi
- [x] Firebase index'leri olusturuldu

---

## Planlanan Ozellikler

### Ingilizce Dil Destegi
- Uygulamaya `flutter_localizations` ve `intl` paketleri ile Ingilizce destegi eklenecek
- Baslangicta 2 dil: Turkce (TR) + Ingilizce (EN)
- Tum hardcoded string'ler `.arb` dosyalarina tasinacak ve `AppLocalizations` uzerinden kullanilacak
- Dil secimi: Cihaz diline otomatik uyum veya kullanici tercihi (ayarlar sayfasi)
- Asamali plan: once ana arayuz (navbar, butonlar, basliklar), sonra icerik (tarif detay, sohbet, puan)
