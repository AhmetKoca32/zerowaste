import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_providers.g.dart';

/// Placeholder: will hold chat messages and AI mascot conversation state.
@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<ChatMessageEntry> build() => const [
        ChatMessageEntry(text: 'Merhaba Leafy! Buzdolabımda domates, biber ve yumurta var. Ne yapabilirim?', isUser: true),
        ChatMessageEntry(text: 'Merhaba! Bu malzemelerle harika bir menemen yapabilirsin. Domatesler ve biberleri küçük küçük doğra, tavaya biraz zeytinyağı ekle ve sotele. Yumuşayınca yumurtaları kır ve karıştır. Tuz, karabiber ve isteğe bağlı pul biber ekleyebilirsin. Afiyet olsun! 🍳', isUser: false),
        ChatMessageEntry(text: 'Harika fikir! Peki domateslerin bir kısmı biraz yumuşamış, onları da kullanabilir miyim?', isUser: true),
        ChatMessageEntry(text: 'Elbette! Yumuşamış domates menemen için aslında daha iyi bile olur çünkü daha kolay pişer ve daha lezzetli bir sos oluşturur. Sıfır atık için mükemmel bir tercih! Sadece çürümüş kısımları varsa onları kesin, geri kalanını rahatça kullanabilirsin.', isUser: false),
        ChatMessageEntry(text: 'Bayat ekmeklerim de var, onlarla ne yapabilirim?', isUser: true),
        ChatMessageEntry(text: 'Bayat ekmek çok değerli! İşte birkaç fikir:\n\n1. **Ekmek kızartması** - Zeytinyağında kızartıp menemenin yanında servis et\n2. **Galeta unu** - Rendele ve saklama kabında muhafaza et, kızartmalarda kullan\n3. **Ekmek pidesi** - Üzerine peynir ve domates koyup fırınla\n4. **Çorba koyulaştırıcı** - Herhangi bir çorbaya ekle\n\nBayat ekmeği asla çöpe atma! 🌿', isUser: false),
        ChatMessageEntry(text: 'Çok teşekkürler Leafy, süper fikirler!', isUser: true),
        ChatMessageEntry(text: 'Rica ederim! Sıfır atık mutfak yolculuğunda her zaman yanındayım. Başka soruların olursa çekinme! 🌱', isUser: false),
      ];

  void add(ChatMessageEntry entry) => state = [...state, entry];
  void clear() => state = [];
}

class ChatMessageEntry {
  const ChatMessageEntry({
    required this.text,
    required this.isUser,
  });
  final String text;
  final bool isUser;
}
