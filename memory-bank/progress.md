# Progress: Sıfır Atık Mutfak

**Son Guncelleme:** Mayis 2026 (17 Mayis)

---

## Tamamlanan Ozellikler

### Core Infrastructure
- Flutter proje yapisi (Clean Architecture, feature-based)
- Riverpod state management + code generation
- GoRouter navigation (slide transitions, 10+ route)
- Theme ve color system (brand turuncu paleti)
- Manrope font ailesi entegrasyonu (AppTextStyle ile 16 stil)
- SifirAtik markalama (ZeroWaste -> SifirAtik)

### Splash Screen
- 5 saniyelik staggered animasyon (4 asama)
- AB logolari + EU sponsor logosu (PNG)
- Admin giris butonu (sag alt, gelistirme amaciyla)

### AI Tarif Uretimi (DeepSeek)
- Malzeme girisi + son eklenenler (SharedPreferences)
- Mutfak stili secimi
- "EcoChef pisiriyor" loading overlay (denizati.png)
- RecipeParser ile AI ciktisi -> Recipe model
- Kaydettigim Tarifler (max 5, SharedPreferences)

### AI Sohbet (EcoChef)
- DeepSeek API, 20 mesaj/gun limiti
- 34 oneri, 5 kategoride, gunluk 5 random
- Typewriter animasyonu, Markdown render
- 5 dk background timer ile otomatik temizlik
- denizati.png maskot entegrasyonu

### Puan Sistemi (Gamification)
- PointsHeroCard: 2 modlu animasyon (Normal + Level-up)
- 5 seviye: Caylak -> Merakli -> Usta -> Efsane -> Efsane+
- Parlayan dairesel progress bar
- Inline leaderboard (top 3, KVKK opt-in)
- Nickname sistemi (ilk gonderide, KVKK/GDPR uyumlu)

### Points + Admin Firestore Entegrasyonu ✅
- PostEntry modeli + Firestore serilestirme
- PointsRepository: submitPost, query, onay/red, leaderboard
- Admin paneli: gonderi onay/red sayfasi
- PointsPage: Firestore baglantisi canli
- Responsive AdminShell (sidebar/drawer)
- Firestore rules + index'ler olusturuldu

### Admin Paneli
- Firebase Auth (Email/Password) + admin check
- Tarif CRUD
- Gonderi onay/red
- Responsive tasarim (desktop sidebar / mobile drawer)

---

## Bilinen Sorunlar (Co-zulmus)
- [x] Ticker dispose hatasi (PointsHeroCard)
- [x] ListTile / Nested Scaffold hatalari (admin)
- [x] Form.of() context hatasi (admin_recipe_form)
- [x] Chat input keyboard scroll sorunu
- [x] Chat keyboard layout kaymasi
- [x] SifirAtik markalama
- [x] Firestore security rules

## Bilinen Sorunlar (Devam Eden)
- [ ] Fotograf Storage'a yuklenmiyor (sadece local)
- [ ] RecipeSyncService main'de cagrilmadi
- [ ] Gunluk chat limit reset su an handle edilmemis olabilir
- [ ] Fotograf admin panelinde gozukmez

---

## Yapilacaklar

### Kritik / Acil (Bir Sonraki Oturum)
- [ ] **Admin paneli ayri web sitesine tasinacak** (Firebase Hosting plani incelenecek)
- [ ] **Firebase plan degerlendirmesi**: Spark -> Blaze gecisi gerekebilir
- [ ] **Storage entegrasyonu**: Fotograf yukleme (Storage veya Google Drive)
- [ ] **Ingilizce dil destegi**: flutter_localizations + intl ile 2 dil (TR/EN)
- [ ] Tarif entegrasyonu: RecipeSyncService main()'e eklenecek

### Kisa Vadeli
- [ ] Gunluk mesaj limit reset mekanizmasi (SharedPreferences)
- [ ] RecipeSyncService main()'e ekleme
- [ ] Fotograf gosterme iyilestirmesi (placeholder + ikon)

### Orta Vadeli
- [ ] Kullanici profilleri
- [ ] Push notification
- [ ] Topluluk ozellikleri (yorum, favori)

---

## Gelecek Plan Notlari

### Admin Panel Web'e Tasima
- Admin paneli mobil uygulamadan ayrilacak
- Ayri bir Flutter Web uygulamasi olarak Firebase Hosting'de yayinlanacak
- Firebase Hosting Spark plani yeterli mi -> Blaze gerekebilir -> incelenecek
- Eger hosting plani sorun cikarirsa: mobil icinde gizli admin yolu birakilacak

### Gorsel Paylasimi
- Firebase Storage Spark'ta 5GB, 20KB/gun upload (cok sinirli)
- Asilma durumunda alternatif: Google Drive API
- Base64 Firestore'da saklama son care (onerilmez)

### Firebase Plan
- Su an Spark (ucretsiz): Firestore, Auth, Hosting temel ihtiyaclar icin yeterli
- Storage eklenince Blaze onerilir (tahmini maliyet: $0-$5/ay)
- Hosting ek yuku az (sadece admin paneli statik dosyalari)
