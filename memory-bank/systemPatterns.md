# System Patterns: Atıksız Mutfak

**Son Güncelleme:** Ağustos 2026 (4 Ağustos)

---

## Mimari Genel Bakış

### Mimari Stil
- **Clean Architecture:** Feature-based klasör yapısı
- **State Management:** Riverpod (Provider pattern, code generation)
- **Routing:** GoRouter (declarative routing, slide transitions)
- **Dependency Injection:** Riverpod providers

### Katman Yapısı
```
lib/
├── core/
│   ├── theme/
│   ├── shell/              # MainTabShell (extendBody), CustomBottomNav
│   ├── services/           # DeepSeek, AnonymousAuth, PostImageStorage
│   ├── network/
│   ├── router/
│   ├── constants/
│   ├── providers/
│   └── widgets/
│
└── features/
    ├── home/
    ├── recipe_generator/
    ├── chat/
    │   ├── data/           # ChatMessageEntry, ChatSessionStorage
    │   └── presentation/
    ├── splash/
    └── points/
```

---

## State Management Patterns

### Riverpod Kullanımı

1. **Provider:** NetworkService, DeepSeekService, AnonymousAuthService, PostImageStorageService
2. **AsyncNotifier (keepAlive):** DailyMessageCount, DailyChatSuggestions, recipeList
3. **Notifier (keepAlive):** ChatMessages — hydrate/save via ChatSessionStorage
4. **StateProvider:** tabIndexProvider (0=Tarifler, 1=Oluştur, 2=Chat, 3=Puan)

```dart
DailyMessageCount.maxMessages // 20 user messages / day
chatMessagesProvider          // keepAlive + SharedPreferences session
```

---

## Tasarım & Animasyon Pattern'leri

### 1. PointsHeroCard Animation
- Seviyeler: `points_levels.dart` (7 rol, artan gap: 0/50/150/300/500/800/1200)
- Normal: previous→current ring + counter (aynı seviye içinde up/down)
- Level-up/down: hero içi yatay stepper (`level_up_stepper.dart`); roller L→R düşük→yüksek; up fill / down drain
- `last_known_points` yalnızca diyalog/animasyon bitince persist

### 2. Points Page Refresh
- Tab visible + puan artışı/azalışı → overlay sonra hero animasyonu
- Azalış: “Puanların güncellendi”; bekleyen red (puan aynı): “Gönderin reddedildi”
- Soft reload açık reject overlay’ini kapatmaz

### 3. RecipesComingSoon
- Firestore boş/hata → `[]` → Coming Soon

### 4. Post Image Upload
```
anon auth → putData(bytes) → PostEntry(imageUrl) → Firestore
```

### 5. AI Language
- **Chat:** user message language + `[LANGUAGE RULE]` on latest turn only
- **Create:** app localeProvider

### 6. EcoChef Chat Session & Layout
```
Disk: ChatSessionStorage (ecochef_chat_session)
  TTL 24h | max 50 bubbles

UI Stack:
  ListView.builder(reverse: true)
    topInset = safeArea.top + 64
    bottomInset = nav clearance + input height
  Positioned floating input
  Floating EcoChef pill

Typewriter: only fresh AI reply (_typewriterForLength == messages.length)
```

### 7. EcoChef API Conversation Memory
```
priorTurns = messages before new user bubble
chatWithMascot(message, priorTurns:)
  → last mascotHistoryLimit (20) bubbles
  → truncate assistant history ~1200 chars
  → LANGUAGE RULE only on latest user message
```

### 8. Recipe ↔ Admin Form
ingredients[] / instructions[] as string arrays only

### 9. Admin Notes
adminNote + adminNoteEn → localizedAdminNote(localeCode)

### 10. SharedPreferences Daily Reset
missions_date, daily_message_date, chat_suggestions_date

---

## Data Flow Patterns

### Points & Admin
```
foto → nickname claim → Storage → posts + pendingCount
admin onay → user_stats.totalPoints += + LB incremental
Puan tab → user_stats (1) + posts limit 12
leaveContest / deleteAppUser → wipeContestNickname (stats+posts+LB sil)
  → mobil: local session clear (stats yoksa auto-reclaim yok)
```

### Recipes
```
Admin → Firestore recipes (TR+EN) → RecipeRepository (isBilingualComplete) → locale resolve → HomePage
```

### EcoChef
```
ChatMessages ↔ ChatSessionStorage (24h)
  → DeepSeek: system + last 20 turns
```

### Leaderboard
```
approve/bonus/deduct (admin) → incremental entries patch
wipe (leaveContest / deleteAppUser) → remove nickname from entries
```

---

## Admin Panel (Ayrı Web)
LayoutBuilder ≥600 sidebar / &lt;600 drawer. Tarif formu: DynamicStringListField (planlanan).
