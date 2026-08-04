import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe.freezed.dart';

@freezed
class Recipe with _$Recipe {
  const Recipe._();

  const factory Recipe({
    required String id,
    /// Turkish title (canonical / sort key).
    required String title,
    /// English title — required for curated Firestore recipes.
    @Default('') String titleEn,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? description,
    String? descriptionEn,
    required List<String> instructions,
    @Default([]) List<String> instructionsEn,
    required List<String> ingredients,
    @Default([]) List<String> ingredientsEn,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      instructions: _stringList(json['instructions']),
      instructionsEn: _stringList(json['instructionsEn']),
      ingredients: _stringList(json['ingredients']),
      ingredientsEn: _stringList(json['ingredientsEn']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'titleEn': titleEn,
        'image_url': imageUrl,
        'description': description,
        'descriptionEn': descriptionEn,
        'instructions': instructions,
        'instructionsEn': instructionsEn,
        'ingredients': ingredients,
        'ingredientsEn': ingredientsEn,
      };

  /// Creates a Recipe from a Firestore document.
  factory Recipe.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Recipe(
      id: doc.id,
      title: data['title'] as String? ?? '',
      titleEn: data['titleEn'] as String? ?? '',
      imageUrl: data['image_url'] as String?,
      description: data['description'] as String?,
      descriptionEn: data['descriptionEn'] as String?,
      instructions: _stringList(data['instructions']),
      instructionsEn: _stringList(data['instructionsEn']),
      ingredients: _stringList(data['ingredients']),
      ingredientsEn: _stringList(data['ingredientsEn']),
    );
  }

  /// Converts Recipe to Firestore document data.
  Map<String, dynamic> toFirestore() => {
        'title': title,
        'titleEn': titleEn,
        'image_url': imageUrl,
        'description': description,
        'descriptionEn': descriptionEn,
        'instructions': instructions,
        'instructionsEn': instructionsEn,
        'ingredients': ingredients,
        'ingredientsEn': ingredientsEn,
      };

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).toList();
  }

  /// Curated recipes must have both TR and EN titles + non-empty lists.
  bool get isBilingualComplete {
    final trTitle = title.trim();
    final enTitle = titleEn.trim();
    return trTitle.isNotEmpty &&
        enTitle.isNotEmpty &&
        ingredients.isNotEmpty &&
        ingredientsEn.isNotEmpty &&
        instructions.isNotEmpty &&
        instructionsEn.isNotEmpty;
  }

  bool _preferEn(String languageCode) => languageCode.toLowerCase() == 'en';

  String localizedTitle(String languageCode) {
    if (_preferEn(languageCode)) {
      final en = titleEn.trim();
      if (en.isNotEmpty) return en;
    }
    return title;
  }

  String? localizedDescription(String languageCode) {
    if (_preferEn(languageCode)) {
      final en = descriptionEn?.trim();
      if (en != null && en.isNotEmpty) return en;
    }
    final tr = description?.trim();
    if (tr != null && tr.isNotEmpty) return tr;
    return null;
  }

  List<String> localizedIngredients(String languageCode) {
    if (_preferEn(languageCode) && ingredientsEn.isNotEmpty) {
      return ingredientsEn;
    }
    return ingredients;
  }

  List<String> localizedInstructions(String languageCode) {
    if (_preferEn(languageCode) && instructionsEn.isNotEmpty) {
      return instructionsEn;
    }
    return instructions;
  }

  /// Search haystack in both languages.
  bool matchesQuery(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return true;
    bool hit(String? s) => s != null && s.toLowerCase().contains(q);
    bool hitList(List<String> list) =>
        list.any((e) => e.toLowerCase().contains(q));
    return hit(title) ||
        hit(titleEn) ||
        hit(description) ||
        hit(descriptionEn) ||
        hitList(ingredients) ||
        hitList(ingredientsEn) ||
        hitList(instructions) ||
        hitList(instructionsEn);
  }
}
