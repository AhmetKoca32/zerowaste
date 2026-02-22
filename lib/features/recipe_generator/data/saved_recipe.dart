import '../../home/data/models/recipe.dart';

/// A recipe saved by the user (AI-generated), with optional local photo.
class SavedRecipe {
  const SavedRecipe({
    required this.recipe,
    this.localImagePath,
  });

  final Recipe recipe;
  final String? localImagePath;

  Map<String, dynamic> toJson() => {
        'recipe': recipe.toJson(),
        'local_image_path': localImagePath,
      };

  factory SavedRecipe.fromJson(Map<String, dynamic> json) {
    return SavedRecipe(
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
      localImagePath: json['local_image_path'] as String?,
    );
  }
}
