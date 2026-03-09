import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/recipe.dart';

/// Fetches recipes from local JSON asset or Firestore.
/// Set [useFirestore] to true to use Firestore instead of local assets.
class RecipeRepository {
  RecipeRepository({
    this.useFirestore = false,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final bool useFirestore;
  final FirebaseFirestore _firestore;

  static const String _collectionName = 'recipes';

  /// Fetches recipes: from asset if local, from Firestore if remote.
  Future<List<Recipe>> getRecipes() async {
    if (useFirestore) {
      return _loadFromFirestore();
    }
    return _loadFromAsset();
  }

  Future<List<Recipe>> _loadFromAsset() async {
    final jsonString = await rootBundle.loadString(
      AppConstants.recipesAssetPath,
    );
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Recipe>> _loadFromFirestore() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('title')
          .get();

      // Firestore boşsa veya hata olursa yerel tarifleri kullan
      if (snapshot.docs.isEmpty) {
        return _loadFromAsset();
      }

      return snapshot.docs
          .map((doc) => Recipe.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Fallback to local if Firestore fails
      return _loadFromAsset();
    }
  }

  /// Adds a recipe to Firestore.
  Future<void> addRecipe(Recipe recipe) async {
    if (!useFirestore) return;
    await _firestore.collection(_collectionName).doc(recipe.id).set(
          recipe.toFirestore(),
        );
  }

  /// Updates a recipe in Firestore.
  Future<void> updateRecipe(Recipe recipe) async {
    if (!useFirestore) return;
    await _firestore.collection(_collectionName).doc(recipe.id).update(
          recipe.toFirestore(),
        );
  }

  /// Deletes a recipe from Firestore.
  Future<void> deleteRecipe(String recipeId) async {
    if (!useFirestore) return;
    await _firestore.collection(_collectionName).doc(recipeId).delete();
  }
}
