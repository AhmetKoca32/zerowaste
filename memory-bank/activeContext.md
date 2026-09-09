# Active Context: Atıksız Mutfak

**Son Güncelleme:** Eylül 2026 (8 Eylül)  
**Aktif Çalışma:** App Store yolu **bloke** (Apple Developer hesabı fesih). Support appeal bekleniyor. Checklist: [`app-store-checklist.md`](app-store-checklist.md)

---

## Sıradaki Yol Haritası

### 1. Apple Developer / iOS Store (bloke)
- Bundle ID + Firebase **projede tamam** (`com.ahmetkoca.zerowaste`)
- **Bloke edici:** Apple Developer Program hesabı **29 Temmuz 2026** itibarıyla feshedildi (“fraudulent conduct” / §3.2(f)); en az 1 yıl reapply reddi
- Kullanıcı Support’a appeal yazdı → cevap bekleniyor
- ASC App ID / TestFlight / IPA **hesap Active olmadan yapılamaz**
- Ban delmek için yeni Apple ID + tekrar ödeme **önerilmiyor** (hesap bağlama riski)

### 2. Store öncesi içerik / paralel
- [ ] 3–5 bilingual tarif Firestore’da (Coming Soon kalmasın)
- [ ] Privacy Policy URL
- [ ] Version bump (`0.1.0` → örn. `1.0.0`)
- İsteğe bağlı: **Google Play** (iOS beklerken)

### 3. Düşük / sonra
- Admin post `imageUrl` gösterimi
- Progress bar hizalama
- Kayıtlı tarif fotoğrafları şu an **yalnızca local** (Firebase Storage yok); cloud sync istenirse ayrı tasarım

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

### Bundle / marka
- **Bundle / applicationId:** `com.ahmetkoca.zerowaste`
- Launcher: TR **Atıksız Mutfak** / EN **Zerowaste Kitchen** (`InfoPlist.strings` + Android `values` / `values-tr`)
- Locale: kayıtlı tercih yoksa cihaz dili (`en` → EN, else TR)

---

## Son Yapılan (7–8 Ağustos 2026 + bellek güncelleme 8 Eyl)

- [x] Bundle ID `com.ahmetkoca.zerowaste` (iOS + Android + macOS hizası)
- [x] `flutterfire configure` → yeni iOS/Android Firebase app’ler + `firebase_options` / `google-services.json` / `GoogleService-Info.plist`
- [x] Splash: marka + EU logo dil bazlı (EN lockup asset; TR mevcut asset)
- [x] Günlük local bildirim metinleri: sabah D + akşam 3 (l10n)
- [x] Apple hesabı durumu teşhis: ödeme 16/05/2026 var; fesih 29/07/2026; appeal metni hazırlandı

---

## Bilinen Sorunlar / açık işler

### Kritik (store)
- [ ] Apple Developer hesabı **Active** değil (termination) — Support appeal
- [ ] Privacy Policy sayfası
- [ ] App Store Connect listing + screenshots + submit (hesap açılınca)
- [ ] Bilingual tarif içeriği (yeterli adet)

### Orta
- [ ] Kayıtlı tarif foto: local OK; `flutter run`/reinstall data siler → kullanıcı “kayboldu” sanabilir (beklenen)
- [ ] google-services.json checklist satırı: flutterfire sonrası güncel (işaretlenebilir)

### Düşük
- [ ] Progress bar hizalama
- [ ] Dashboard totalUsers post-aggregate (admin)
- [ ] Admin post imageUrl UI

---

## Karar Günlüğü

| Tarih | Karar | Gerekçe |
|-------|-------|---------|
| 8 Eylül | Memory-bank: Apple termination + Bundle/Firebase/splash/bildirim durumu | Gerçek bloker net |
| 7–8 Ağ | Bundle `com.ahmetkoca.zerowaste`; yeni Apple ID ile ban delme yok | Fraud ban + hesap bağlama |
| 7–8 Ağ | Splash/launcher TR/EN ayrı asset + InfoPlist | Global Zerowaste Kitchen / yerel Atıksız Mutfak |
| 8 Ağ | Bildirim sabah D / akşam 3 | Kullanıcı seçimi |
| 4 Ağustos | App Store checklist; bundle `com.example.*` bloke | Store kabul etmez |
| 4 Ağustos | recipes zorunlu TR+EN | Dil toggle uyumu |
| 4 Ağustos | Level stepper hero içi; puan düşüşü ayrı diyalog | UX |
| 4 Ağustos | Ban = wipe; Plan B user_stats | Kota + tutarlılık |
| 2 Ağustos | Zerowaste Kitchen / Atıksız Mutfak | Store vs l10n |
