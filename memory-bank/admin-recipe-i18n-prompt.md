# Admin prompt: Tarif TR/EN zorunlu CRUD

Aşağıdaki metni admin paneli (ayrı Flutter web) Cursor oturumuna yapıştır.

---

## Bağlam

Mobil uygulama curated tarifleri `recipes/{id}` üzerinden okuyor. Sözleşme güncellendi:

- Mobil **yalnızca** her iki dili de dolu tarifleri listeler (`isBilingualComplete`).
- UI app locale’ine göre TR veya EN alanları gösterir.
- Tek dilli / eksik EN tarifler mobilde **görünmez** (Coming Soon veya listeden düşer).

Mevcut post notları gibi paralel alan stili kullan: `adminNote` / `adminNoteEn`.

## Firestore alanları (`recipes/{id}`)

```
title: string          # TR zorunlu
titleEn: string        # EN zorunlu
description: string?   # TR
descriptionEn: string? # EN
ingredients: string[]     # TR zorunlu, ≥1
ingredientsEn: string[]   # EN zorunlu, ≥1
instructions: string[]    # TR zorunlu, ≥1
instructionsEn: string[]  # EN zorunlu, ≥1
image_url: string?
```

Eski alanlar (`title`, `ingredients`, `instructions`, `description`) TR kabul edilir; yeni `*En` alanları eklenir. Legacy dokümanları bozma; düzenlemede EN boşsa kaydetmeyi engelle.

## Yapılacaklar

1. **Recipe model** (admin shared): `titleEn`, `descriptionEn`, `ingredientsEn`, `instructionsEn` ekle; fromFirestore/toFirestore.
2. **AdminRecipeForm** (veya eşdeğeri):
   - TR / EN sekmeleri **veya** yan yana bölümler.
   - Her dil için: title, description, ingredients list (DynamicStringListField), instructions list.
   - Ortak: `image_url`.
3. **Validation (kaydet / güncelle öncesi — zorunlu):**
   - `title.trim()` ve `titleEn.trim()` boş olamaz.
   - `ingredients` ve `ingredientsEn` en az 1 dolu satır.
   - `instructions` ve `instructionsEn` en az 1 dolu satır.
   - Eksikse: submit butonu disabled + net hata mesajı (TR/EN hangi alanlar eksik).
   - Taslak kaydetme yok; publish = her iki dil complete.
4. **Liste UI:** Eksik EN olan tarifleri “Eksik çeviri” badge ile işaretle; düzenlemeden kaydetme engeli.
5. **memory-bank / docs:** Admin tarafında recipes şemasını aynı sözleşmeyle güncelle.

## Bilinçli dışarıda

- Otomatik çeviri / DeepSeek yok.
- Mobil AI tarif üreticisi bu sözleşmeye dahil değil (kullanıcı üretimi).
- `orderBy('title')` TR canonical kalır (mobil).

## Kabul kriterleri

- [ ] Yalnızca TR doluyken Kaydet → engellenir
- [ ] TR+EN title + lists doluyken Kaydet → Firestore’da tüm `*En` alanları yazar
- [ ] Mobil cold start sonrası tarif görünür; dil toggle TR↔EN metni değiştirir
- [ ] Eski tek dilli tarif mobilde listelenmez ta ki EN doldurulana kadar
