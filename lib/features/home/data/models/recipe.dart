import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe.freezed.dart';

@freezed
class Recipe with _$Recipe {
  const Recipe._();

  const factory Recipe({
    required String id,
    required String title,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? description,
    required List<String> instructions,
    required List<String> ingredients,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      instructions: (json['instructions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image_url': imageUrl,
        'description': description,
        'instructions': instructions,
        'ingredients': ingredients,
      };

  /// Creates a Recipe from a Firestore document.
  factory Recipe.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Recipe(
      id: doc.id,
      title: data['title'] as String? ?? '',
      imageUrl: data['image_url'] as String?,
      description: data['description'] as String?,
      instructions: (data['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      ingredients: (data['ingredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Converts Recipe to Firestore document data.
  Map<String, dynamic> toFirestore() => {
        'title': title,
        'image_url': imageUrl,
        'description': description,
        'instructions': instructions,
        'ingredients': ingredients,
      };
}
