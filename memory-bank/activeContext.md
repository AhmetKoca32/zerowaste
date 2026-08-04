# Active Context: Atıksız Mutfak

**Son Güncelleme:** Ağustos 2026 (4 Ağustos)  
**Aktif Çalışma:** App Store hazırlık. Checklist: [`app-store-checklist.md`](app-store-checklist.md)

---

## Sıradaki Yol Haritası

### 1. App Store (ana hat)
- Checklist: [`app-store-checklist.md`](app-store-checklist.md)
- **Bloke edici:** Bundle ID `com.example.zerowaste` → production ID
- Version bump (`0.1.0` → örn. `1.0.0`), Privacy Policy URL, screenshots, App Privacy formu
- TestFlight smoke → Submit for Review
- Blaze Usage / bütçe uyarısı

### 2. Store öncesi içerik
- [ ] 3–5 bilingual tarif Firestore’da (Coming Soon kalmasın)

### 3. Düşük / sonra
- Admin post `imageUrl` gösterimi
- Progress bar hizalama
- Google Play (iOS sonrası)

---

## Sözleşmeler (özet)

### recipes (TR/EN)
```
title / titleEn | description / descriptionEn
ingredients[] / ingredientsEn[] | instructions[] / instructionsEn[]
image_url?
```
Mobil: `isBilingualComplete` + `localized*`. Admin: TR+EN zorunlu kaydet. **Yapıldı.**

### Plan B / yarışma
- `user_stats` + incremental LB; ban/opt-out = wipe (`leaveContest` / `deleteAppUser`)
- claimedByUid uniqueness; rules admin deploy (mobil yeniden deploy etme)
- **E2E yapıldı.**

### Puan UI
- 7 rol (0/50/150/300/500/800/1200); hero stepper up/down; puan silindi diyaloğu

---

## Son Yapılan (4 Ağustos)

- [x] Plan B mobil + admin; leaveContest wipe; claimedByUid
- [x] Puan roller, level stepper, puan silindi / red diyalogları, leaderboard rol
- [x] Tarif TR/EN mobil + admin CRUD
- [x] Plan B E2E (+ foto / wipe / bilingual)
- [x] App Store checklist dokümanı

---

## Bilinen Sorunlar / açık işler

### Yüksek (store)
- [ ] Bundle ID production’a çevir
- [ ] Privacy Policy sayfası
- [ ] App Store Connect listing + screenshots + submit
- [ ] Bilingual tarif içeriği (yeterli adet)

### Düşük
- [ ] Progress bar hizalama
- [ ] Dashboard totalUsers post-aggregate (admin)
- [ ] Admin post imageUrl UI

---

## Karar Günlüğü

| Tarih | Karar | Gerekçe |
|-------|-------|---------|
| 4 Ağustos | App Store checklist; bundle `com.example.*` bloke | Store kabul etmez |
| 4 Ağustos | recipes zorunlu TR+EN | Dil toggle uyumu |
| 4 Ağustos | Level stepper hero içi; puan düşüşü ayrı diyalog | UX |
| 4 Ağustos | Ban = wipe; Plan B user_stats | Kota + tutarlılık |
| 2 Ağustos | Zerowaste Kitchen / Atıksız Mutfak | Store vs l10n |
