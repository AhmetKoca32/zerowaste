# Firestore Entegrasyonu - Kurulum ve Kullanım

**Tarih:** Şubat 2025  
**Durum:** ✅ Tamamlandı

---

## ✅ Yapılanlar

1. **`cloud_firestore` paketi eklendi** (`pubspec.yaml`)
2. **`RecipeRepository` Firestore'a bağlandı**
3. **`Recipe` model'ine Firestore helper metodları eklendi:**
   - `Recipe.fromFirestore()` - Firestore document'ten Recipe oluşturur
   - `Recipe.toFirestore()` - Recipe'yi Firestore document'e çevirir
4. **Provider güncellendi** - Artık Firestore kullanıyor

---

## 🚀 İlk Kurulum

### 1. Paketleri Yükle

```bash
flutter pub get
```

### 2. Firestore'a İlk Tarifleri Yükle

Mevcut tarifleri (`assets/data/recipes.json`) Firestore'a yüklemek için:

**Seçenek A: Firebase Console'dan Manuel Ekleme**

1. [Firebase Console → Firestore Database](https://console.firebase.google.com/project/zerowaste-46d54/firestore)
2. **"Start collection"** butonuna tıkla
3. Collection ID: `recipes`
4. İlk document'i ekle:
   - Document ID: `1` (veya auto-generate)
   - Fields:
     - `title` (string): "Sıfır Atık Sebze Sote"
     - `image_url` (string, optional): null
     - `description` (string, optional): null
     - `instructions` (array): ["Sebzeleri eşit parçalar halinde doğrayın.", ...]
     - `ingredients` (array): ["Artık sebzeler", "Soya sosu", ...]
5. Diğer tarifleri de ekle (id: `2`, `3`)

**Seçenek B: Migration Helper ile (Kod ile)**

Gelecekte bir migration script'i çalıştırabilirsin (şu an için manuel ekleme daha kolay).

---

## 📊 Firestore Collection Yapısı

### Collection: `recipes`

Her document şu alanları içerir:

```typescript
{
  id: string,              // Document ID
  title: string,           // Tarif başlığı
  image_url?: string,       // Fotoğraf URL'i (opsiyonel)
  description?: string,    // Kısa açıklama (opsiyonel)
  instructions: string[],  // Yapılış adımları
  ingredients: string[]    // Malzemeler listesi
}
```

### Örnek Document:

```json
{
  "title": "Sıfır Atık Sebze Sote",
  "image_url": null,
  "description": null,
  "instructions": [
    "Sebzeleri eşit parçalar halinde doğrayın.",
    "Tavada yağı kızdırın, sarımsak ekleyin.",
    "Sebzeleri yumuşayana kadar soteleyin.",
    "Soya sosu ekleyip servis edin."
  ],
  "ingredients": [
    "Artık sebzeler",
    "Soya sosu",
    "Sarımsak",
    "Yağ"
  ]
}
```

---

## 🔧 Firestore Security Rules

Firestore Console → Rules sekmesinde şu kuralları ayarla:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Recipes collection - herkes okuyabilir, sadece admin yazabilir
    match /recipes/{recipeId} {
      allow read: if true;  // Herkes okuyabilir
      allow write: if false;  // Şimdilik yazma kapalı (admin panel eklenince açılacak)
    }
  }
}
```

**Not:** Şu an test mode'da olduğun için zaten herkes okuyup yazabilir. Production'a geçerken kuralları sıkılaştır.

---

## 📝 Kod Kullanımı

### Tarifleri Çekme

```dart
final repository = RecipeRepository(useFirestore: true);
final recipes = await repository.getRecipes();
```

### Yeni Tarif Ekleme (Gelecek - Admin Panel)

```dart
final repository = RecipeRepository(useFirestore: true);
await repository.addRecipe(recipe);
```

### Tarif Güncelleme (Gelecek - Admin Panel)

```dart
await repository.updateRecipe(updatedRecipe);
```

### Tarif Silme (Gelecek - Admin Panel)

```dart
await repository.deleteRecipe(recipeId);
```

---

## 🔄 Local vs Firestore Geçişi

### Şu Anki Durum
- `useFirestore: true` → Firestore kullanılıyor
- `useFirestore: false` → Local JSON kullanılıyor (fallback)

### Provider'da Değiştirme

`lib/features/home/presentation/providers/home_providers.dart`:

```dart
@riverpod
RecipeRepository recipeRepository(RecipeRepositoryRef ref) {
  return RecipeRepository(useFirestore: true);  // Firestore kullan
  // return RecipeRepository(useFirestore: false);  // Local JSON kullan
}
```

---

## ⚠️ Önemli Notlar

1. **Firestore Index:** `title` field'ına göre sıralama yapıyoruz. Eğer hata alırsan, Firestore Console → Indexes'ten otomatik index oluşturulmasını bekle veya manuel oluştur.

2. **Error Handling:** Firestore bağlantısı başarısız olursa otomatik olarak local JSON'a fallback yapıyor.

3. **Offline Support:** Firestore offline persistence varsayılan olarak açık değil. İstersen açabilirsin (gelecek).

4. **Pagination:** Şu an tüm tarifler bir seferde çekiliyor. İleride pagination ekleyeceğiz (Firestore limitleri için).

---

## 🎯 Sonraki Adımlar

1. ✅ Firestore entegrasyonu tamamlandı
2. ⏳ İlk tarifleri Firestore'a ekle (Console'dan)
3. ⏳ Uygulamayı test et (`flutter run`)
4. ⏳ Admin panel ekle (tarif ekleme/güncelleme için)
5. ⏳ Pagination ekle (Firestore reads optimizasyonu için)

---

**Son Güncelleme:** Şubat 2025
