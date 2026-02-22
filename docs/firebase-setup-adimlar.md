# Firebase Kurulum Adımları – ZeroWaste

Firebase Console’da projeyi oluşturduktan sonra uygulamayı bağlamak için aşağıdaki adımları uygulayın.

---

## 1. Firebase CLI ve FlutterFire CLI

### 1.1 Firebase CLI

- Node.js yüklü olmalı.  
- [Firebase CLI kurulum](https://firebase.google.com/docs/cli#setup_update_cli) sayfasına göre kurun.  
  Windows’ta örnek:

```bash
npm install -g firebase-tools
```

- Giriş yapın:

```bash
firebase login
```

Tarayıcı açılır, Google hesabınızla giriş yapın.

### 1.2 FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

`dart pub global` yolunun PATH’te olduğundan emin olun (genelde `$HOME/.pub-cache/bin` veya `%LOCALAPPDATA%\Pub\Cache\bin`).

---

## 2. Projeyi Firebase’e Bağlama

Proje kökünde (ör. `d:\ZeroWaste\zerowaste`) terminalde:

```bash
cd d:\ZeroWaste\zerowaste
flutterfire configure
```

Bu komut:

1. Firebase’e giriş yapılmamışsa giriş ister.
2. **Mevcut Firebase projenizi seçin** (Console’da oluşturduğunuz proje).
3. Platform seçimi ister (Android, iOS, Web). En az **Android**’i seçin.
4. `lib/firebase_options.dart` dosyasını oluşturur.

Bu adımı yapmadan proje derlenmez; `firebase_options.dart` bu komutla oluşur.

---

## 3. Bağımlılıklar ve Çalıştırma

```bash
flutter pub get
flutter run
```

Önce `flutterfire configure`, sonra `flutter run` yeterli.

---

## 4. Firebase Console’da Açılacak Servisler

İleride kullanacağınız özellikler için Console’da şunları açın:

### 4.1 Firestore (tarifler, gönderiler, puanlar)

1. [Firebase Console](https://console.firebase.google.com/) → projeniz.
2. Sol menüden **Build → Firestore Database**.
3. **Create database**.
4. **Test mode** veya **Production mode** seçin (geliştirme için test mode kullanılabilir).
5. Bölge seçin (örn. `europe-west1`).

### 4.2 Storage (fotoğraflar)

1. Sol menüden **Build → Storage**.
2. **Get started**.
3. Kurallar için **Next** deyip varsayılanla başlayabilirsiniz (sonra güvenlik kurallarını sıkılaştırın).

### 4.3 Authentication (isterseniz sonra)

1. **Build → Authentication**.
2. **Get started**.
3. İleride e-posta/şifre, Google vb. etkinleştirirsiniz.

---

## 5. Özet Kontrol Listesi

- [ ] Node.js kurulu, `firebase login` yapıldı.
- [ ] `dart pub global activate flutterfire_cli` çalıştırıldı.
- [ ] Proje kökünde `flutterfire configure` çalıştırıldı ve mevcut Firebase projesi seçildi.
- [ ] `lib/firebase_options.dart` oluştu.
- [ ] `flutter pub get` ve `flutter run` ile uygulama çalışıyor.
- [ ] Firestore ve Storage (ve istenirse Authentication) Console’da açıldı.

---

## 6. Sonraki Kod Adımları

Firebase bağlandıktan sonra:

1. **Firestore:** Tarifleri `recipes` koleksiyonuna taşımak, `RecipeRepository`’yi Firestore’a bağlamak.
2. **Storage:** Kullanıcı fotoğraflarını yüklemek için `firebase_storage` ekleyip upload akışı yazmak.
3. **Auth (opsiyonel):** `firebase_auth` ile giriş eklemek.

Bu doküman sadece “projeyi oluşturdum, uygulamayı bağlamak için ne yapmalıyım?” adımlarını kapsar. Kod tarafı (Firestore/Storage kullanımı) ayrı bir aşamada yapılacak.
