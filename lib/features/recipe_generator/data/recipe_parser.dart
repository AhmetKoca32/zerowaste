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
  static Recipe? parse(String markdown, {String? id, String languageCode = 'tr'}) {
    if (markdown.trim().isEmpty) return null;
    final isEnglish = languageCode == 'en';

    // Strip any introductory lines before the first section header (## or **)
    var cleaned = markdown.trim();
    final linesAll = cleaned.split('\n');
    int firstHeaderIdx = -1;
    for (int i = 0; i < linesAll.length; i++) {
      final line = linesAll[i].trim();
      final lower = line.toLowerCase();
      if (line.startsWith('## ') ||
          lower.contains('başlık') ||
          lower.contains('title') ||
          lower.contains('malzeme') ||
          lower.contains('ingredient') ||
          lower.contains('yapılış') ||
          lower.contains('hazırlanış') ||
          lower.contains('steps') ||
          lower.contains('instruction')) {
        firstHeaderIdx = i;
        break;
      }
    }
    if (firstHeaderIdx > 0) {
      // Remove lines before the first header
      cleaned = linesAll.sublist(firstHeaderIdx).join('\n').trim();
    }

    final lines = cleaned.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (lines.isEmpty) return null;

    final title = stripMarkdown(_extractTitle(lines, isEnglish: isEnglish));
    final description = _extractDescription(lines, isEnglish: isEnglish);
    final ingredients = _extractIngredients(lines, isEnglish: isEnglish).map(stripMarkdown).toList();
    final instructions = _extractInstructions(lines, isEnglish: isEnglish).map(stripMarkdown).toList();

    if (title.isEmpty || (ingredients.isEmpty && instructions.isEmpty)) return null;

    return Recipe(
      id: id ?? 'gen-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      imageUrl: null,
      description: (description == null || description.isEmpty) ? null : description,
      ingredients: ingredients,
      instructions: instructions.isEmpty
          ? [isEnglish ? 'Review the recipe text for details.' : 'Tarif metnini detaylı inceleyin.']
          : instructions,
    );
  }

  static String? _extractDescription(List<String> lines, {required bool isEnglish}) {
    final markers = isEnglish
        ? ['**Short Description:**', '**Short Description**', 'Short Description:', '**Description:**', 'Description:']
        : ['**Kısa Açıklama:**', '**Kısa Açıklama**', 'Kısa Açıklama:'];
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

  static String _extractTitle(List<String> lines, {required bool isEnglish}) {
    if (isEnglish) {
      const prefixes = [
        '## Title:', '## Title', '**Title:**', '**Title**', 'Title:',
        '## Başlık:', '## Başlık', '**Başlık:**', '**Başlık**', 'Başlık:',
        '## Başlik:', 'Başlik:',
      ];
      for (final line in lines) {
        final lower = line.toLowerCase();
        if (lower.contains('title:') ||
            lower.contains('başlık:') ||
            lower.contains('başlik:')) {
          for (final prefix in prefixes) {
            final idx = lower.indexOf(prefix.toLowerCase());
            if (idx >= 0) {
              final after = line.substring(idx + prefix.length).trim();
              if (after.isNotEmpty) return _cleanTitleLabel(after);
            }
          }
          final afterColon = _textAfterFirstColon(line);
          if (afterColon != null && afterColon.isNotEmpty) {
            return _cleanTitleLabel(afterColon);
          }
        }
      }

      // First markdown heading without a section keyword → treat as title
      for (final line in lines) {
        if (!line.startsWith('##') && !line.startsWith('**')) continue;
        final lower = line.toLowerCase();
        if (_isNonTitleSectionHeader(lower)) continue;
        final stripped = line
            .replaceFirst(RegExp(r'^#+\s*'), '')
            .replaceFirst(RegExp(r'^\*\*'), '')
            .replaceFirst(RegExp(r'\*\*$'), '')
            .trim();
        final afterColon = _textAfterFirstColon(stripped);
        if (afterColon != null && afterColon.isNotEmpty) {
          return _cleanTitleLabel(afterColon);
        }
        if (stripped.isNotEmpty && stripped.length < 120) {
          return _cleanTitleLabel(stripped);
        }
      }

      for (final line in lines) {
        final t = line.replaceFirst(RegExp(r'^#+\s*'), '').trim();
        const greetings = ['sure', 'here is', 'here\'s', 'hello', 'of course'];
        final lower = t.toLowerCase();
        if (_isNonTitleSectionHeader(lower)) continue;
        if (t.isNotEmpty && t.length < 200 && !greetings.any((g) => lower.startsWith(g))) {
          return _cleanTitleLabel(t);
        }
      }
      if (lines.isEmpty) return 'New Recipe';
      final first = lines.first;
      if (first.length <= 80) return _cleanTitleLabel(first);
      return '${_cleanTitleLabel(first.substring(0, 80).trim())}...';
    }

    // Prefer lines that match "## Başlık: ..." or "**Başlık:** ..." format
    final titleMarkers = ['başlık:', 'başlik:'];
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (titleMarkers.any((m) => lower.contains(m))) {
        // Extract text after the marker
        for (final m in ['## Başlık:', '## Başlık', '**Başlık:**', '**Başlık**', 'Başlık:']) {
          final idx = lower.indexOf(m.toLowerCase());
          if (idx >= 0) {
            final after = line.substring(idx + m.length).trim();
            if (after.isNotEmpty) return after;
          }
        }
        // Fallback: remove common prefixes
        return line.replaceFirst(RegExp(r'^##?\s*Başlık:?\s*', caseSensitive: false), '')
            .replaceFirst(RegExp(r'^\*\*Başlık:?\*\*\s*', caseSensitive: false), '')
            .trim();
      }
    }
    // Fallback: first non-empty line that isn't just a greeting
    for (final line in lines) {
      final t = line.replaceFirst(RegExp(r'^#+\s*'), '').trim();
      const greetings = ['elbette', 'işte', 'karşınızda', 'merhaba', 'tabii ki'];
      final lower = t.toLowerCase();
      if (t.isNotEmpty && t.length < 200 && !greetings.any((g) => lower.startsWith(g))) {
        return t;
      }
    }
    if (lines.isEmpty) return 'Yeni Tarif';
    final first = lines.first;
    if (first.length <= 80) return first;
    return '${first.substring(0, 80).trim()}...';
  }

  static bool _isNonTitleSectionHeader(String lower) =>
      lower.contains('ingredient') ||
      lower.contains('malzeme') ||
      lower.contains('description') ||
      lower.contains('açıklama') ||
      lower.contains('steps') ||
      lower.contains('instruction') ||
      lower.contains('yapılış') ||
      lower.contains('hazırlanış');

  static String? _textAfterFirstColon(String line) {
    final idx = line.indexOf(':');
    if (idx < 0 || idx >= line.length - 1) return null;
    return line.substring(idx + 1).trim();
  }

  static String _cleanTitleLabel(String title) {
    return title
        .replaceFirst(RegExp(r'^(title|başlık|başlik)\s*:?\s*', caseSensitive: false), '')
        .trim();
  }

  static bool _isSectionHeader(String line) =>
      line.startsWith('##') || (line.startsWith('**') && line.length > 3);

  static List<String> _extractIngredients(List<String> lines, {required bool isEnglish}) {
    final markers = isEnglish
        ? [
            '**Ingredients:**', '**Ingredients**', '**Ingredient:**', 'Ingredients:',
            '## Ingredients:', '## Ingredients', '## Ingredient:',
          ]
        : [
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

  static List<String> _extractInstructions(List<String> lines, {required bool isEnglish}) {
    final markers = isEnglish
        ? [
            '**Steps:**', '**Steps**', '**Instructions:**', '**Instructions**',
            'Steps:', 'Instructions:',
            '## Steps:', '## Steps', '## Instructions:', '## Instructions',
          ]
        : [
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

