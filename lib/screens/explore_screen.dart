import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'detail_screen.dart';

// ─── Panchabaksha Categories ──────────────────────────────────────────────────
// These are the 5 classical Ayurvedic food groups based on HOW you consume them
// (Pancha Bhaksha Paramanna from Ayurvedic texts)
class _Baksha {
  final String key, label, telugu, description, emoji;
  final Color color;
  const _Baksha(this.key, this.label, this.telugu, this.description, this.emoji, this.color);
}

const List<_Baksha> _categories = [
  _Baksha('all', 'All', 'అన్ని', 'All recipes', '🍽️', Color(0xFF2D2D2D)),
  _Baksha(
    'baksham', 'Baksham', 'భక్ష్యం',
    'Foods you take a bite to eat',
    '🍪', Color(0xFFFF9F1C),
  ),
  _Baksha(
    'bojyam', 'Bojyam', 'భోజ్యం',
    'Foods you need to chew to consume',
    '🍛', Color(0xFF2EC4B6),
  ),
  _Baksha(
    'choshyam', 'Choshyam', 'చోష్యం',
    'Foods that need slurping or sipping',
    '🥣', Color(0xFF3A86FF),
  ),
  _Baksha(
    'lehyam', 'Lehyam', 'లేహ్యం',
    'Items that need licking (e.g. honey)',
    '🍯', Color(0xFFFFBE0B),
  ),
  _Baksha(
    'paaniyam', 'Paaniyam', 'పానీయం',
    'Drinks — water, juices, milk',
    '🥛', Color(0xFF4CC9F0),
  ),
];

// Rasa color for badge on card
const Map<String, Color> _rasaColors = {
  'madhura': Color(0xFFFFBE0B),
  'amla': Color(0xFFFF6B35),
  'lavana': Color(0xFF3A86FF),
  'katu': Color(0xFFFF006E),
  'tikta': Color(0xFF38B000),
  'kasaya': Color(0xFF8338EC),
};
const Map<String, String> _rasaLabel = {
  'madhura': 'Sweet',
  'amla': 'Sour',
  'lavana': 'Salty',
  'katu': 'Pungent',
  'tikta': 'Bitter',
  'kasaya': 'Astringent',
};
// ──────────────────────────────────────────────────────────────────────────────

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  List<Recipe> _allRecipes = [];
  Set<String> _selectedIngredients = {};
  bool _loading = true;
  late TabController _tabController;
  final RecipeService _recipeService = RecipeService();

  List<String> _allIngredients = [];
  Map<String, List<String>> _groupedIngredients = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final recipes = await _recipeService.getRecipes();
    final allIngs = _recipeService.getAllIngredients(recipes);
    final grouped = _recipeService.groupIngredientsByCategory(allIngs);
    setState(() {
      _allRecipes = recipes;
      _allIngredients = allIngs;
      _groupedIngredients = grouped;
      _loading = false;
    });
  }

  List<Recipe> _getFiltered(String categoryKey) {
    return _allRecipes.where((r) {
      final catMatch = categoryKey == 'all' || r.panchabaksha == categoryKey;
      if (!catMatch) return false;
      if (_selectedIngredients.isEmpty) return true;
      // AND filter: recipe must contain ALL selected ingredients
      return _selectedIngredients.every(
        (sel) => r.ingredientsList.any(
          (ing) => ing.toLowerCase() == sel.toLowerCase(),
        ),
      );
    }).toList();
  }

  _Baksha _categoryOf(Recipe recipe) {
    return _categories.firstWhere(
      (c) => c.key == recipe.panchabaksha,
      orElse: () => _categories[0],
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IngredientFilterSheet(
        groupedIngredients: _groupedIngredients,
        selected: _selectedIngredients,
        onApply: (selected) => setState(() => _selectedIngredients = selected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text('Explore',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2EC4B6),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: _openFilterSheet,
                tooltip: 'Filter by ingredients',
              ),
              if (_selectedIngredients.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFBE0B),
                    ),
                    child: Center(
                      child: Text(
                        '${_selectedIngredients.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          tabAlignment: TabAlignment.start,
          tabs: _categories.map((c) {
            return Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${c.emoji} ${c.label}', style: null),
                  if (c.key != 'all')
                    Text(
                      c.telugu,
                      style: GoogleFonts.poppins(fontSize: 9, color: Colors.white70),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Category description banner
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (_, __) {
                    final idx = _tabController.index;
                    final cat = _categories[idx];
                    if (cat.key == 'all') return const SizedBox.shrink();
                    return Container(
                      color: cat.color.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Text(cat.emoji,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${cat.label} (${cat.telugu})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: cat.color,
                                  ),
                                ),
                                Text(
                                  cat.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Active filter chips
                if (_selectedIngredients.isNotEmpty) _buildFilterChips(),
                // Recipe grid
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _categories.map((c) {
                      final filtered = _getFiltered(c.key);
                      return _RecipeGrid(
                        recipes: filtered,
                        getCategoryOf: _categoryOf,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _selectedIngredients.map((ing) {
                return Chip(
                  label: Text(
                    ing,
                    style: GoogleFonts.poppins(
                        fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFF2EC4B6).withOpacity(0.12),
                  deleteIconColor: const Color(0xFF2EC4B6),
                  side: const BorderSide(color: Color(0xFF2EC4B6), width: 1),
                  labelPadding: EdgeInsets.zero,
                  onDeleted: () =>
                      setState(() => _selectedIngredients.remove(ing)),
                );
              }).toList(),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedIngredients.clear()),
            child: Text('Clear',
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ─── Ingredient Filter Bottom Sheet ──────────────────────────────────────────
class _IngredientFilterSheet extends StatefulWidget {
  final Map<String, List<String>> groupedIngredients;
  final Set<String> selected;
  final ValueChanged<Set<String>> onApply;

  const _IngredientFilterSheet({
    required this.groupedIngredients,
    required this.selected,
    required this.onApply,
  });

  @override
  State<_IngredientFilterSheet> createState() => _IngredientFilterSheetState();
}

class _IngredientFilterSheetState extends State<_IngredientFilterSheet> {
  late Set<String> _local;

  @override
  void initState() {
    super.initState();
    _local = Set.from(widget.selected);
  }

  static const Map<String, Color> _catColors = {
    'Vegetables': Color(0xFF38B000),
    'Fruits': Color(0xFFFF6B35),
    'Grains & Legumes': Color(0xFFFFBE0B),
    'Dairy': Color(0xFF3A86FF),
    'Spices & Herbs': Color(0xFFFF006E),
    'Flowers': Color(0xFFF72585),
    'Nuts & Seeds': Color(0xFF8338EC),
    'Sweeteners': Color(0xFFFF9E00),
    'Other': Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF8F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Filter by Ingredients',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => _local.clear()),
                      child: Text('Clear all',
                          style: GoogleFonts.poppins(
                              color: Colors.red, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              if (_local.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${_local.length} selected — recipes must contain ALL',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: widget.groupedIngredients.entries.map((entry) {
                    final catColor =
                        _catColors[entry.key] ?? const Color(0xFF6B7280);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 12, 0, 8),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: catColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.key,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: catColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: entry.value.map((ing) {
                            final isSelected = _local.contains(ing);
                            return GestureDetector(
                              onTap: () => setState(() {
                                isSelected
                                    ? _local.remove(ing)
                                    : _local.add(ing);
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? catColor
                                      : catColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: catColor.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: catColor.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  ing,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color:
                                        isSelected ? Colors.white : catColor,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 4),
                      ],
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_local);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EC4B6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _local.isEmpty
                          ? 'Show All Recipes'
                          : 'Apply ${_local.length} Filter${_local.length > 1 ? 's' : ''}',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Recipe Grid ──────────────────────────────────────────────────────────────
class _RecipeGrid extends StatelessWidget {
  final List<Recipe> recipes;
  final _Baksha Function(Recipe) getCategoryOf;

  const _RecipeGrid({required this.recipes, required this.getCategoryOf});

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              'No recipes in this category yet',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Text(
              'Add dishes to recipes.json with this panchabaksha tag',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.70,
      ),
      itemCount: recipes.length,
      itemBuilder: (_, i) => _RecipeCard3D(
        recipe: recipes[i],
        category: getCategoryOf(recipes[i]),
      ),
    );
  }
}

// ─── 3D Vibrant Recipe Card ───────────────────────────────────────────────────
class _RecipeCard3D extends StatefulWidget {
  final Recipe recipe;
  final _Baksha category;
  const _RecipeCard3D({required this.recipe, required this.category});

  @override
  State<_RecipeCard3D> createState() => _RecipeCard3DState();
}

class _RecipeCard3DState extends State<_RecipeCard3D> {
  bool _pressed = false;

  // Each Panchabaksha category has its own gradient pair
  static const Map<String, List<Color>> _catGradients = {
    'baksham':  [Color(0xFFFF9F1C), Color(0xFFFF6B35)],
    'bojyam':   [Color(0xFF2EC4B6), Color(0xFF0A9396)],
    'choshyam': [Color(0xFF3A86FF), Color(0xFF0055CC)],
    'lehyam':   [Color(0xFFFFBE0B), Color(0xFFFF9E00)],
    'paaniyam': [Color(0xFF4CC9F0), Color(0xFF3A86FF)],
  };

  @override
  Widget build(BuildContext context) {
    final gradients = _catGradients[widget.recipe.panchabaksha] ??
        [const Color(0xFF2EC4B6), const Color(0xFF0A9396)];
    final rasaColor = _rasaColors[widget.recipe.rasa] ?? const Color(0xFFFF6B35);
    final rasaName = _rasaLabel[widget.recipe.rasa] ?? widget.recipe.rasa;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(recipe: widget.recipe),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradients,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: gradients.first.withOpacity(0.5),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image section
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22)),
                      child: Image.asset(
                        widget.recipe.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                gradients.first.withOpacity(0.3),
                                gradients.last.withOpacity(0.15),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.category.emoji,
                              style: const TextStyle(fontSize: 52),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Rasa taste badge (secondary info)
                    if (rasaName.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: rasaColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            rasaName,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    // Panchabaksha category badge bottom-left
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.category.emoji} ${widget.category.label}',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.recipe.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 11, color: Colors.white70),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              widget.recipe.state,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}