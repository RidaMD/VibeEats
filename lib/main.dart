import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const VibeEatsApp());
}

class VibeEatsApp extends StatelessWidget {
  const VibeEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VibeEats',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3A5A40)),
        scaffoldBackgroundColor: const Color(0xFFF1F5F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3A5A40),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: index == 0 ? const ExploreScreen() : const StateScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: const Color(0xFF3A5A40),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            activeIcon: Icon(Icons.restaurant),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: "States",
          ),
        ],
      ),
    );
  }
}

class Recipe {
  final String id, name, image, type, state;
  final List<String> ingredients;
  final List<String> healthBenefits;
  final List<String> process;
  final List<String> analysis;
  final List<String> classicalReference;
  Recipe.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      image = json['image'],
      type = json['type'],
      state = json['state'],
      ingredients = List<String>.from(json['ingredients']),
      process = List<String>.from(json['process']),
      healthBenefits = List<String>.from(json['healthBenefits']),
      classicalReference = List<String>.from(json['classicalReference']),
      analysis = List<String>.from(json['analysis']);
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Recipe> recipes = [];
  String selectedType = "All";
  String ingredientFilter = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await rootBundle.loadString('assets/recipes.json');
    final decoded = json.decode(data);
    setState(() {
      recipes = (decoded as List).map((e) => Recipe.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = recipes.where((r) {
      final typeMatch = selectedType == "All" || r.type == selectedType;
      final ingredientMatch =
          ingredientFilter.isEmpty ||
          r.ingredients.any(
            (i) => i.toString().toLowerCase().contains(
              ingredientFilter.toLowerCase(),
            ),
          );
      return typeMatch && ingredientMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Explore Dishes")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: "Meal Type"),
                  items: const [
                    DropdownMenuItem(value: "All", child: Text("All")),
                    DropdownMenuItem(value: "meal", child: Text("Meal")),
                    DropdownMenuItem(value: "drink", child: Text("Drink")),
                    DropdownMenuItem(value: "sweet", child: Text("Sweet")),
                  ],
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Filter by ingredient",
                  ),
                  onChanged: (v) => setState(() => ingredientFilter = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("No recipes found"))
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final recipe = filtered[i];
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(recipe: recipe),
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15),
                                  ),
                                  child: Image.asset(
                                    recipe.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  recipe.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class StateScreen extends StatelessWidget {
  const StateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "India Map Feature Coming Soon 🚀",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Recipe recipe;

  const DetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: Text(recipe.name),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE HEADER
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
              child: Image.asset(
                recipe.image,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  "assets/placeholder.png",
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Ingredients"),
                  _cardList(recipe.ingredients, bullet: true),

                  _sectionTitle("Process"),
                  _cardList(recipe.process, numbered: true),

                  _sectionTitle("Health Benefits"),
                  _cardList(recipe.healthBenefits, bullet: true),

                  _sectionTitle("Classical Reference"),
                  _cardList(recipe.classicalReference, bullet: true),

                  _sectionTitle("Quantitative Analysis"),
                  _analysisTable(recipe.analysis),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      ),
    );
  }

  Widget _cardList(
    List<String> items, {
    bool bullet = false,
    bool numbered = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(items.length, (index) {
            String prefix = "";
            if (bullet) prefix = "• ";
            if (numbered) prefix = "${index + 1}. ";

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                prefix + items[index],
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _analysisTable(List<String> nutrients) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text(
                "Identified Nutrients",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: nutrients
              .map((n) => DataRow(cells: [DataCell(Text(n))]))
              .toList(),
        ),
      ),
    );
  }
}
