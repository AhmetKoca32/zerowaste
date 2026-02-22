import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/recipe.dart';

/// Helper class to migrate recipes from local JSON to Firestore.
/// Run this once to populate Firestore with initial recipes.
class RecipeMigrationHelper {
  RecipeMigrationHelper({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _collectionName = 'recipes';

  /// Migrates recipes from assets/data/recipes.json to Firestore.
  /// Call this once after Firestore is set up.
  Future<void> migrateRecipesToFirestore() async {
    try {
      // Load recipes from local JSON
      final jsonString = await rootBundle.loadString(
        AppConstants.recipesAssetPath,
      );
      final list = jsonDecode(jsonString) as List<dynamic>;
      final recipes = list
          .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
          .toList();

      // Check if recipes already exist
      final existingSnapshot = await _firestore.collection(_collectionName).get();
      if (existingSnapshot.docs.isNotEmpty) {
        print('⚠️ Recipes already exist in Firestore. Skipping migration.');
        return;
      }

      // Add recipes to Firestore
      final batch = _firestore.batch();
      for (final recipe in recipes) {
        final docRef = _firestore.collection(_collectionName).doc(recipe.id);
        batch.set(docRef, recipe.toFirestore());
      }
      await batch.commit();

      print('✅ Successfully migrated ${recipes.length} recipes to Firestore!');
    } catch (e) {
      print('❌ Error migrating recipes: $e');
      rethrow;
    }
  }

  /// Clears all recipes from Firestore (use with caution!).
  Future<void> clearAllRecipes() async {
    final snapshot = await _firestore.collection(_collectionName).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    print('✅ Cleared all recipes from Firestore');
  }
}
