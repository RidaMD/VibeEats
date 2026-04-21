import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import 'firestore_service.dart';

class RecipeService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Returns recipes from Firestore when available, otherwise falls back to
  /// the local assets/recipes.json.  A 12-second overall timeout prevents
  /// the app from hanging when Firebase is misconfigured or offline.
  Future<List<Recipe>> getRecipes() async {
    try {
      final firestoreRecipes = await Future.any([
        _loadFromFirestore(),
        Future.delayed(
          const Duration(seconds: 12),
          () => <Recipe>[],
        ),
      ]);
      if (firestoreRecipes.isNotEmpty) {
        return firestoreRecipes;
      }
    } catch (e) {
      debugPrint('RecipeService: Firestore path failed – $e');
    }
    debugPrint('RecipeService: falling back to local JSON.');
    return _loadFromJson();
  }

  Future<List<Recipe>> _loadFromFirestore() async {
    await _firestoreService.migrateJsonToFirestore();
    return _firestoreService.getRecipes();
  }

  Future<List<Recipe>> _loadFromJson() async {
    try {
      final data = await rootBundle.loadString('assets/recipes.json');
      final List<dynamic> jsonList = json.decode(data);
      final recipes = jsonList.map((j) => Recipe.fromJson(j)).toList();
      debugPrint('RecipeService: loaded ${recipes.length} recipes from local JSON.');
      return recipes;
    } catch (e) {
      debugPrint('RecipeService: local JSON load failed – $e');
      return [];
    }
  }

  /// Returns all unique ingredient names across all recipes,
  /// excluding common items like salt, pepper, and water.
  List<String> getAllIngredients(List<Recipe> recipes) {
    const excluded = {'salt', 'pepper', 'water', 'black pepper'};
    final Set<String> ingredients = {};
    for (final recipe in recipes) {
      for (final ing in recipe.ingredientsList) {
        if (!excluded.contains(ing.toLowerCase())) {
          ingredients.add(ing);
        }
      }
    }
    final list = ingredients.toList();
    list.sort();
    return list;
  }

  /// Groups ingredients into Ayurvedic food categories.
  Map<String, List<String>> groupIngredientsByCategory(List<String> ingredients) {
    final Map<String, List<String>> grouped = {};
    for (final ing in ingredients) {
      final category = _categorize(ing);
      grouped.putIfAbsent(category, () => []).add(ing);
    }
    // Sort each category list
    for (final key in grouped.keys) {
      grouped[key]!.sort();
    }
    return grouped;
  }

  String _categorize(String ingredient) {
    final lower = ingredient.toLowerCase();
    const vegetables = [
      'carrot', 'beetroot', 'potato', 'tomato', 'onion', 'garlic', 'ginger',
      'spinach', 'cucumber', 'pumpkin', 'gourd', 'yam', 'drumstick', 'radish',
      'brinjal', 'capsicum', 'pea', 'bean', 'lotus root', 'taro'
    ];
    const fruits = [
      'mango', 'apple', 'banana', 'lemon', 'lime', 'tamarind', 'amla',
      'coconut', 'jackfruit', 'papaya', 'guava', 'pomegranate', 'orange',
      'dates', 'fig', 'raisin'
    ];
    const grains = [
      'rice', 'wheat', 'barley', 'millet', 'oats', 'corn', 'ragi', 'bajra',
      'jowar', 'flour', 'semolina', 'poha', 'besan', 'dal', 'lentil', 'gram',
      'chickpea', 'moong', 'urad', 'toor', 'chana'
    ];
    const dairy = [
      'milk', 'ghee', 'curd', 'butter', 'paneer', 'yogurt', 'cream',
      'buttermilk', 'khoa', 'chhena', 'cheese'
    ];
    const spices = [
      'cardamom', 'cinnamon', 'cumin', 'turmeric', 'coriander', 'fenugreek',
      'clove', 'bay leaf', 'star anise', 'asafoetida', 'saffron', 'nutmeg',
      'mace', 'fennel', 'curry leaf', 'tulsi', 'basil', 'mint', 'dill',
      'ajwain', 'kalonji', 'chili', 'chilli', 'pepper'
    ];
    const flowers = [
      'rose', 'jasmine', 'marigold', 'hibiscus', 'lotus flower', 'chamomile'
    ];
    const nutsSeeds = [
      'mustard', 'sesame', 'almond', 'cashew', 'peanut', 'walnut',
      'pistachio', 'flaxseed', 'hemp seed', 'sunflower seed', 'poppy seed',
      'chia', 'coconut (grated)'
    ];
    const sweeteners = ['jaggery', 'honey', 'sugar', 'palm sugar', 'maple'];

    if (vegetables.any((v) => lower.contains(v))) return 'Vegetables';
    if (fruits.any((v) => lower.contains(v))) return 'Fruits';
    if (grains.any((v) => lower.contains(v))) return 'Grains & Legumes';
    if (dairy.any((v) => lower.contains(v))) return 'Dairy';
    if (spices.any((v) => lower.contains(v))) return 'Spices & Herbs';
    if (flowers.any((v) => lower.contains(v))) return 'Flowers';
    if (nutsSeeds.any((v) => lower.contains(v))) return 'Nuts & Seeds';
    if (sweeteners.any((v) => lower.contains(v))) return 'Sweeteners';
    return 'Other';
  }
}
