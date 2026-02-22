import '../../home/data/models/recipe.dart';

/// Parses AI-generated Markdown into a [Recipe] for display like home page recipes.
class RecipeParser {
  RecipeParser._();

  /// Removes common Markdown from AI text so it displays as plain (e.g. **başlık** → başlık).
  static String stripMarkdown(String text) {
    if (text.trim().isEmpty) return text;
    String s = text
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'__'), '')
        .replaceFirst(RegExp(r'^#+\s*'), '')
        .trim();
    s = s.replaceAllMapped(RegExp(r'(?<!\s)\*([^*]+)\*'), (m) => m.group(1)!);
    s = s.replaceAllMapped(RegExp(r'(?<!\s)_([^_]+)_'), (m) => m.group(1)!);
    return s.trim();
  }

  /// Tries to parse [markdown] into [Recipe]. Returns null if parsing fails.
  static Recipe? parse(String markdown, {String? id}) {
    if (markdown.trim().isEmpty) return null;
    final lines = markdown.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (lines.isEmpty) return null;

    final title = stripMarkdown(_extractTitle(lines));
    final description = _extractDescription(lines);
    final ingredients = _extractIngredients(lines).map(stripMarkdown).toList();
    final instructions = _extractInstructions(lines).map(stripMarkdown).toList();

    if (title.isEmpty || (ingredients.isEmpty && instructions.isEmpty)) return null;

    return Recipe(
      id: id ?? 'gen-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      imageUrl: null,
      description: (description == null || description.isEmpty) ? null : description,
      ingredients: ingredients,
      instructions: instructions.isEmpty ? ['Tarif metnini detaylı inceleyin.'] : instructions,
    );
  }

  static String? _extractDescription(List<String> lines) {
    const markers = ['**Kısa Açıklama:**', '**Kısa Açıklama**', 'Kısa Açıklama:'];
    int foundIndex = -1;
    String? sameLineSuffix;
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();
      for (final m in markers) {
        final mLower = m.toLowerCase();
        if (lower.contains(mLower)) {
          foundIndex = i;
          final idx = lower.indexOf(mLower);
          final after = line.substring(idx + mLower.length).trim();
          if (after.isNotEmpty) sameLineSuffix = after;
          break;
        }
      }
      if (foundIndex >= 0) break;
    }
    if (foundIndex >= 0) {
      final buffer = <String>[];
      if (sameLineSuffix != null) buffer.add(sameLineSuffix);
      for (int i = foundIndex + 1; i < lines.length; i++) {
        final line = lines[i];
        if (line.startsWith('**') || line.startsWith('##')) break;
        buffer.add(line);
      }
      final text = buffer.join(' ').trim();
      if (text.isNotEmpty) return stripMarkdown(text);
    }
    if (lines.isNotEmpty) {
      final first = lines.first;
      if (!first.startsWith('##') && !first.startsWith('**') && first.length > 80) {
        return stripMarkdown(first);
      }
    }
    return null;
  }

  static String _extractTitle(List<String> lines) {
    for (final line in lines) {
      final t = line.replaceFirst(RegExp(r'^#+\s*'), '').trim();
      if (t.isNotEmpty && t.length < 200) return t;
    }
    if (lines.isEmpty) return 'Yeni Tarif';
    final first = lines.first;
    if (first.length <= 80) return first;
    return '${first.substring(0, 80).trim()}...';
  }

  static bool _isSectionHeader(String line) =>
      line.startsWith('##') || (line.startsWith('**') && line.length > 3);

  static List<String> _extractIngredients(List<String> lines) {
    const markers = [
      '**Malzemeler:**', '**Malzemeler**', '**Malzeme:**', 'Malzemeler:',
      '## Malzemeler:', '## Malzemeler', '## Malzeme:',
    ];
    int start = -1;
    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      if (markers.any((m) => lower.contains(m.toLowerCase()))) {
        start = i + 1;
        break;
      }
    }
    if (start < 0) return [];
    return _collectIngredientLinesOnly(lines, start);
  }

  /// Collects only lines that look like list items (-, *, •). Stops at next section or non-bullet line.
  static List<String> _collectIngredientLinesOnly(List<String> lines, int startIndex) {
    final bulletRe = RegExp(r'^(\*\s*|[-•]\s*)\s*');
    final out = <String>[];
    for (int i = startIndex; i < lines.length; i++) {
      final line = lines[i];
      if (_isSectionHeader(line)) break;
      if (!bulletRe.hasMatch(line)) break;
      final cleaned = line.replaceFirst(bulletRe, '').trim();
      if (cleaned.isNotEmpty) out.add(cleaned);
    }
    return out;
  }

  static List<String> _extractInstructions(List<String> lines) {
    const markers = [
      '**Yapılış Adımları:**', '**Yapılış adımları:**',
      '**Yapılış:**', '**Yapılışı:**', '**Yapılış**', 'Yapılış:', '**Hazırlanış:**',
      '## Yapılışı:', '## Yapılış:', '## Yapılış', '## Hazırlanış:',
    ];
    int start = -1;
    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      if (markers.any((m) => lower.contains(m.toLowerCase()))) {
        start = i + 1;
        break;
      }
    }
    if (start < 0) {
      final numbered = <String>[];
      final re = RegExp(r'^(\d+)\.\s*(.+)$');
      for (final line in lines) {
        final m = re.firstMatch(line);
        if (m != null) numbered.add(m.group(2)!.trim());
      }
      if (numbered.isNotEmpty) return numbered;
      return _extractListItems(lines, RegExp(r'^\d+\.\s+'), RegExp(r'^\*\s+'));
    }
    final merged = _collectInstructionsWithContinuation(lines, start);
    return merged.map((s) => s.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim()).where((s) => s.isNotEmpty).toList();
  }

  /// Merges lines so that "1. **Title:**" and "   continuation..." become one step.
  static List<String> _collectInstructionsWithContinuation(List<String> lines, int startIndex) {
    final stepStartRe = RegExp(r'^\d+\.\s*');
    final out = <String>[];
    String? current;
    for (int i = startIndex; i < lines.length; i++) {
      final line = lines[i];
      if (_isSectionHeader(line)) break;
      if (stepStartRe.hasMatch(line)) {
        if (current != null) out.add(current);
        current = line;
      } else if (current != null) {
        current = '$current ${line.trim()}';
      } else {
        current = line;
      }
    }
    if (current != null) out.add(current);
    return out;
  }

  static List<String> _extractListItems(List<String> lines, RegExp re1, RegExp re2) {
    final out = <String>[];
    for (final line in lines) {
      final stripped = line.replaceFirst(re1, '').replaceFirst(re2, '').trim();
      if (stripped.isNotEmpty && !stripped.startsWith('**')) out.add(stripped);
    }
    return out;
  }
}

