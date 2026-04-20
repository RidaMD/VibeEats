import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch all recipes from Firestore
  Future<List<Recipe>> getRecipes() async {
    try {
      final snapshot = await _db.collection('recipes').get();
      return snapshot.docs.map((doc) {
        return Recipe.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
          debugPrint("Error fetching recipes from Firestore: $e");
      return [];
    }
  }

  /// One-time helper to map JSON file to Firestore.
  /// You can call this somewhere in your app if the 'recipes' collection is empty.
  Future<void> migrateJsonToFirestore() async {
    try {
      final existingDocs = await _db.collection('recipes').limit(1).get();
      if (existingDocs.docs.isNotEmpty) {
        debugPrint("Data already exists in Firestore.");
        return;
      }

      debugPrint("Migrating local JSON to Firestore...");
      final data = await rootBundle.loadString('assets/recipes.json');
      final decodedList = json.decode(data) as List;

      // Use a batch to write everything at once
      final batch = _db.batch();

      for (var jsonMap in decodedList) {
        final docRef = _db.collection('recipes').doc(jsonMap['id'].toString());
        batch.set(docRef, jsonMap);
      }

      await batch.commit();
      debugPrint("Migration successful.");
    } catch (e) {
      debugPrint("Failed to migrate data: $e");
    }
  }
}
