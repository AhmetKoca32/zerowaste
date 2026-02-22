import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'saved_recipe.dart';

const String _key = 'zerowaste_saved_recipes';

/// Persists saved recipes (JSON in SharedPreferences) and recipe images (files).
class SavedRecipesStorage {
  SavedRecipesStorage._();
  static const _imagesDirName = 'recipe_images';

  static Future<List<SavedRecipe>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SavedRecipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> save(List<SavedRecipe> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  /// Saves [imageBytes] as recipe image and returns the file path.
  static Future<String> saveRecipeImage(
      String recipeId, List<int> imageBytes) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_imagesDirName');
    if (!await dir.exists()) await dir.create(recursive: true);
    final path =
        '${dir.path}/${recipeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(path);
    await file.writeAsBytes(imageBytes);
    return path;
  }
}
