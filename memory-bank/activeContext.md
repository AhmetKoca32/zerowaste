# Active Context: Atıksız Mutfak

**Son Güncelleme:** Ağustos 2026 (2 Ağustos)  
**Aktif Çalışma:** EcoChef chat / branding turu kapandı. Sıradaki odak **prod öncesi Firebase Blaze kotası planı**, hemen ardından **App Store gönderimi**.

---

## Sıradaki Yol Haritası (öncelik sırası)

### 1. Prod — Firebase Blaze / ücretsiz kota koruması
Blaze planındayız; ücretli sınıra düşmemek için prod’a çıkmadan önce **az okuma/yazma/istek** odaklı bir kullanım senaryosu kurgulanacak:

- Firestore / Storage / Auth isteklerini envanterle (hangi ekranda ne kadar read/write)
- Gereksiz realtime dinleyicileri, tekrarlı fetch’leri, tab-switch’te aşırı yenilemeyi azalt
- Cache / local-first (SharedPreferences, in-memory keepAlive) ile cloud’a gitmeyi minimize et
- Bütçe uyarısı + Blaze free tier limitlerine göre hedef kotanın altında kalacak mimari kararlar
- DeepSeek ayrı faturalı; Firebase tarafı odak (kotayı aşmama)

Amaç: Uygulama canlıdayken Blaze’in ücretsiz kotasını **olabildiğince zorlamadan** çalışsın.

### 2. App Store’a gönderme
Firebase prod planı netleştikten / uygulanmaya başlandıktan **hemen sonra** App Store Connect’e yükleme (metadata, ekran görüntüleri, privacy, build). Play Store bu maddenin peşi sıra veya aynı sprint’te ayrı not edilebilir.

---

## Son Yapılan Değişiklikler (Ağustos 2026)

### 1. EcoChef Chat — Layout
- **Üst padding:** `reverse: true` ListView’da floating EcoChef pill için `MediaQuery.padding.top + 64`
- **Alt katman kaldırıldı:** Input floating Stack; liste full-bleed (`extendBody: true`)

### 2. EcoChef Chat — Lokal Session
- **`ChatSessionStorage`**: 24h TTL, max 50 balon; 5 dk auto-clear kaldırıldı
- Soft-delete / opt-out → chat clear

### 3. EcoChef Chat — Typewriter / API Memory
- Typewriter yalnız fresh reply; API son **20** balon + assistant truncate ~1200

### 4. Branding
- Launcher display name: **Zerowaste Kitchen** (iOS `CFBundleDisplayName`, Android `android:label`)
- Splash partner logoları; launcher `App_Logo.png`
- In-app TR adı hâlâ **Atıksız Mutfak** (`l10n.appName`) — ana ekran ikon etiketi ayrı

---

## Bilinen Sorunlar (Öncelik Sırasına Göre)

### 🟡 YÜKSEK (prod / store öncesi de bakılabilir)

- [ ] **Gönderi fotoğrafı upload testi**
- [ ] **Admin panel gönderi fotoğrafı / tarif CRUD**
- [ ] **Mobil çıkış/silme → admin senkronizasyonu**

### 🟢 DÜŞÜK

- [ ] Progress bar hizalama
- [ ] RecipeSyncService main()'de çağrılmadı
- [ ] Firestore `recipes` ilk içerik (admin)

---

## Firebase Yapılandırması

- [x] Firebase **Blaze**, Anonymous Auth, Storage rules
- [ ] **Prod kota / az-istek senaryosu** (sıradaki ana iş)
- [ ] Admin panelden `recipes` doldurma

---

## Karar Günlüğü

| Tarih | Karar | Gerekçe |
|-------|-------|---------|
| 2 Ağustos | Sonraki sprint: Blaze free-tier korumalı prod planı → sonra App Store | Canlıda sürpriz fatura yok; store’a kotası düşünülmüş build ile çıkılsın |
| 2 Ağustos | Ana ekran adı “Zerowaste Kitchen”; in-app TR “Atıksız Mutfak” | Store/home etiketi EN marka; uygulama içi lokalizasyon ayrı |
| 2 Ağustos | Chat history local 24h + API 20 balon | Memory + maliyet dengesi |
| 17 Temmuz | Firebase Blaze + Anonymous Auth + putData | Storage upload |
