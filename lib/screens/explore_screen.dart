import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'detail_screen.dart';

// ─── Panchabaksha Categories ──────────────────────────────────────────────────
class _Baksha {
  final String key, label, telugu, description, emoji;
  final Color color;
  final List<Color> gradient;
  const _Baksha(this.key, this.label, this.telugu, this.description, this.emoji,
      this.color, this.gradient);
}

const List<_Baksha> _categories = [
  _Baksha('all', 'All Recipes', 'అన్ని', 'Browse everything', '🍽️',
      Color(0xFFFF6B35), [Color(0xFFFF9A56), Color(0xFFFF6B35)]),
  _Baksha('baksham', 'Baksham', 'భక్ష్యం', 'Foods you bite & eat', '🍪',
      Color(0xFFFF9F1C), [Color(0xFFFFBF49), Color(0xFFFF9F1C)]),
  _Baksha('bojyam', 'Bojyam', 'భోజ్యం', 'Foods you chew', '🍛',
      Color(0xFF0A9396), [Color(0xFF2EC4B6), Color(0xFF0A9396)]),
  _Baksha('choshyam', 'Choshyam', 'చోష్యం', 'Slurp & sip foods', '🥣',
      Color(0xFF0055CC), [Color(0xFF3A86FF), Color(0xFF0055CC)]),
  _Baksha('lehyam', 'Lehyam', 'లేహ్యం', 'Lickable delights', '🍯',
      Color(0xFFFF9E00), [Color(0xFFFFBE0B), Color(0xFFFF9E00)]),
  _Baksha('paaniyam', 'Paaniyam', 'పానీయం', 'Drinks & beverages', '🥛',
      Color(0xFF0077B6), [Color(0xFF4CC9F0), Color(0xFF0077B6)]),
];

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
// ─────────────────────────────────────────────────────────────────────────────

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
  int _selectedCategoryIndex = 0;
  final RecipeService _recipeService = RecipeService();
  final ScrollController _catScroll = ScrollController();

  Map<String, List<String>> _groupedIngredients = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _catScroll.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final recipes = await _recipeService.getRecipes();
    final allIngs = _recipeService.getAllIngredients(recipes);
    final grouped = _recipeService.groupIngredientsByCategory(allIngs);
    setState(() {
      _allRecipes = recipes;
      _groupedIngredients = grouped;
      _loading = false;
    });
  }

  List<Recipe> get _filtered {
    final cat = _categories[_selectedCategoryIndex];
    return _allRecipes.where((r) {
      final catMatch = cat.key == 'all' || r.panchabaksha == cat.key;
      if (!catMatch) return false;
      if (_selectedIngredients.isEmpty) return true;
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
    final cat = _categories[_selectedCategoryIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFFF6B35)),
                  const SizedBox(height: 16),
                  Text('Loading recipes…',
                      style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // ── Hero SliverAppBar ─────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 190,
                  pinned: true,
                  stretch: true,
                  backgroundColor: cat.gradient.first,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  actions: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.tune_rounded),
                          onPressed: _openFilterSheet,
                          tooltip: 'Filter',
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
                                    fontSize: 9,
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
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.fadeTitle,
                    ],
                    background: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: cat.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),
                              Row(
                                children: [
                                  Text(
                                    cat.emoji,
                                    style: const TextStyle(fontSize: 38),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cat.label,
                                          style: GoogleFonts.poppins(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            height: 1.1,
                                          ),
                                        ),
                                        if (cat.key != 'all')
                                          Text(
                                            cat.telugu,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.white70,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${_filtered.length} dishes',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cat.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Explore',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    centerTitle: false,
                  ),
                ),

                // ── Category Pills ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                    child: SingleChildScrollView(
                      controller: _catScroll,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_categories.length, (i) {
                          final c = _categories[i];
                          final selected = i == _selectedCategoryIndex;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategoryIndex = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOut,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 9),
                                decoration: BoxDecoration(
                                  gradient: selected
                                      ? LinearGradient(colors: c.gradient)
                                      : null,
                                  color:
                                      selected ? null : const Color(0xFFF0EDEA),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: c.color.withOpacity(0.4),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  children: [
                                    Text(c.emoji,
                                        style: const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Text(
                                      c.label,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selected
                                            ? Colors.white
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),

                // ── Active filter chips ────────────────────────────────────
                if (_selectedIngredients.isNotEmpty)
                  SliverToBoxAdapter(child: _buildFilterChips()),

                // ── Recipe Grid ───────────────────────────────────────────
                _filtered.isEmpty
                    ? SliverFillRemaining(
                        child: _EmptyState(
                            categoryKey: _categories[_selectedCategoryIndex].key),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _RecipeCard(
                              recipe: _filtered[i],
                              category: _categoryOf(_filtered[i]),
                            ),
                            childCount: _filtered.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.68,
                          ),
                        ),
                      ),
              ],
            ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: const Color(0xFFFFFCF8),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          ..._selectedIngredients.map((ing) {
            return Chip(
              label: Text(ing,
                  style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFFFF6B35).withOpacity(0.1),
              deleteIconColor: const Color(0xFFFF6B35),
              side: const BorderSide(color: Color(0xFFFF6B35), width: 1),
              labelPadding: EdgeInsets.zero,
              onDeleted: () =>
                  setState(() => _selectedIngredients.remove(ing)),
            );
          }),
          ActionChip(
            label: Text('Clear all',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.w600)),
            backgroundColor: Colors.red.withOpacity(0.08),
            side: const BorderSide(color: Colors.red, width: 1),
            onPressed: () => setState(() => _selectedIngredients.clear()),
          ),
        ],
      ),
    );
  }
}

// ─── Ingredient Filter ────────────────────────────────────────────────────────
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

  static const Map<String, String> _catEmoji = {
    'Vegetables': '🥦',
    'Fruits': '🍊',
    'Grains & Legumes': '🌾',
    'Dairy': '🥛',
    'Spices & Herbs': '🌿',
    'Flowers': '🌸',
    'Nuts & Seeds': '🥜',
    'Sweeteners': '🍯',
    'Other': '🫙',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter by Ingredients',
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        if (_local.isNotEmpty)
                          Text(
                            '${_local.length} selected — must contain ALL',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                      ],
                    ),
                    const Spacer(),
                    if (_local.isNotEmpty)
                      TextButton(
                        onPressed: () => setState(() => _local.clear()),
                        child: Text('Clear',
                            style: GoogleFonts.poppins(
                                color: Colors.red, fontSize: 13)),
                      ),
                  ],
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
                    final emoji = _catEmoji[entry.key] ?? '🫙';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 14, 0, 10),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: catColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(emoji,
                                      style: const TextStyle(fontSize: 16)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                entry.key,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: catColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: catColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${entry.value.length}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: catColor,
                                    fontWeight: FontWeight.w600,
                                  ),
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
                                duration: const Duration(milliseconds: 160),
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
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected ? Colors.white : catColor,
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
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9F1C), Color(0xFFFF6B35)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_local);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Recipe Card ──────────────────────────────────────────────────────────────
class _RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final _Baksha category;
  const _RecipeCard({required this.recipe, required this.category});

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
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
        duration: const Duration(milliseconds: 140),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: cat.color.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Image ──────────────────────────────────────────────
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(22)),
                      child: Image.asset(
                        widget.recipe.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: cat.gradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(22)),
                          ),
                          child: Center(
                            child: Text(cat.emoji,
                                style: const TextStyle(fontSize: 52)),
                          ),
                        ),
                      ),
                    ),
                    // Gradient overlay at bottom of image
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Rasa badge
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: rasaColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: rasaColor.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
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
                    // Panchabaksha badge bottom-left
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${cat.emoji} ${cat.label}',
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

              // ── Info ───────────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.recipe.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A1A),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 12, color: cat.color),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              widget.recipe.state,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 16, color: Colors.grey[400]),
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

// ─── Empty State ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String categoryKey;
  const _EmptyState({required this.categoryKey});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🍽️', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No recipes here yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              categoryKey == 'all'
                  ? 'No recipes match your current filters'
                  : 'Add dishes with this panchabaksha tag to recipes.json',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}