import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';

class FirestoreService {
  /// Returns `null` if Firebase is not properly initialised.
  FirebaseFirestore? get _db {
    try {
      if (Firebase.apps.isEmpty) return null;
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Fetch all recipes from Firestore.
  /// Returns an empty list (not an exception) when Firestore is unavailable.
  Future<List<Recipe>> getRecipes() async {
    final db = _db;
    if (db == null) {
      debugPrint('FirestoreService: Firebase not initialised – skipping.');
      return [];
    }
    try {
      final snapshot = await db
          .collection('recipes')
          .get()
          .timeout(const Duration(seconds: 10));
      final recipes = snapshot.docs.map((doc) {
        return Recipe.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
      debugPrint('FirestoreService: loaded ${recipes.length} recipes.');
      return recipes;
    } catch (e) {
      debugPrint('FirestoreService: error fetching recipes – $e');
      return [];
    }
  }

  /// One-time migration helper: pushes recipes.json → Firestore if the
  /// collection is empty. Safe to call on every start; no-ops if data exists
  /// or if Firebase is unavailable.
  Future<void> migrateJsonToFirestore() async {
    final db = _db;
    if (db == null) {
      debugPrint('FirestoreService: Firebase not initialised – skipping migration.');
      return;
    }
    try {
      final existingDocs = await db
          .collection('recipes')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));
      if (existingDocs.docs.isNotEmpty) {
        debugPrint('FirestoreService: data already in Firestore, no migration needed.');
        return;
      }

      debugPrint('FirestoreService: migrating local JSON to Firestore…');
      final data = await rootBundle.loadString('assets/recipes.json');
      final decodedList = json.decode(data) as List;

      final batch = db.batch();
      for (var jsonMap in decodedList) {
        final docRef = db.collection('recipes').doc(jsonMap['id'].toString());
        batch.set(docRef, jsonMap);
      }
      await batch.commit();
      debugPrint('FirestoreService: migration successful.');
    } catch (e) {
      debugPrint('FirestoreService: migration failed – $e');
    }
  }
}
