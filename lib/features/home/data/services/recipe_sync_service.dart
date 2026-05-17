import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';

/// Syncs recipes from Firestore once per day.
/// 
/// Firebase Spark kotalari: gunde 1 read/kullanici cok rahat.
/// Son sync zamani SharedPreferences'ta tutulur.
class RecipeSyncService {
  static const String _lastSyncKey = 'recipe_last_sync_date';

  /// Check if a sync is needed (once per day).
  Future<bool> needsSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString(_lastSyncKey);
    if (lastSync == null) return true;
    
    final lastDate = DateTime.tryParse(lastSync);
    if (lastDate == null) return true;

    final now = DateTime.now();
    // Same day? Skip sync.
    if (lastDate.year == now.year &&
        lastDate.month == now.month &&
        lastDate.day == now.day) {
      return false;
    }
    return true;
  }

  /// Sync recipes from Firestore to local cache.
  /// Returns true if sync happened, false if skipped.
  Future<bool> syncIfNeeded() async {
    if (!await needsSync()) return false;

    try {
      final repo = RecipeRepository(useFirestore: true);
      final recipes = await repo.getRecipes();
      
      if (recipes.isNotEmpty) {
        // Update the cached JSON asset equivalent in SharedPreferences
        final json = jsonEncode(recipes.map((r) => r.toJson()).toList());
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_recipes', json);
        await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get cached recipes (from SharedPreferences) or fallback to asset.
  static Future<List<Recipe>> getCachedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_recipes');
    
    if (cached != null && cached.isNotEmpty) {
      try {
        final list = jsonDecode(cached) as List<dynamic>;
        return list
            .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    // Fallback to asset
    final jsonString = await rootBundle.loadString(
      AppConstants.recipesAssetPath,
    );
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
