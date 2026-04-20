import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Recipe> _allRecipes = [];
  List<Recipe> _results = [];
  final TextEditingController _ctrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _ctrl.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onQueryChanged);
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    final recipes = await RecipeService().getRecipes();
    setState(() {
      _allRecipes = recipes;
      _results = recipes;
      _loading = false;
    });
  }

  void _onQueryChanged() {
    final query = _ctrl.text.trim();
    setState(() {
      _results = query.isEmpty
          ? _allRecipes
          : _allRecipes
              .where((r) => _isFuzzyMatch(r, query))
              .toList()
            ..sort((a, b) =>
                _matchScore(b, query).compareTo(_matchScore(a, query)));
    });
  }

  // ─── Fuzzy Search Algorithm ────────────────────────────────────────────────
  // Primary: substring match in name or ingredients (case-insensitive)
  // Secondary: Levenshtein distance per word (typo tolerance)
  // E.g. "canji" → Kanji, "sakhtu" → Saktu, "rasom" → Rasam

  bool _isFuzzyMatch(Recipe recipe, String query) {
    final q = query.toLowerCase();

    // 1. Direct substring in recipe name
    if (recipe.name.toLowerCase().contains(q)) return true;

    // 2. Substring in any ingredient
    if (recipe.ingredients.any((i) => i.toLowerCase().contains(q))) {
      return true;
    }

    // 3. Substring in state
    if (recipe.state.toLowerCase().contains(q)) return true;

    // 4. Word-by-word fuzzy match against recipe name
    final queryWords =
        q.split(RegExp(r'\s+')).where((w) => w.length >= 2).toList();
    final nameWords = recipe.name.toLowerCase().split(' ');

    bool allQueryWordsFound = queryWords.every((qWord) {
      return nameWords.any((nWord) {
        if (nWord.contains(qWord) || qWord.contains(nWord)) return true;
        final maxDist = qWord.length <= 4
            ? 1
            : qWord.length <= 7
                ? 2
                : 3;
        return _levenshtein(qWord, nWord) <= maxDist;
      });
    });

    return queryWords.isNotEmpty && allQueryWordsFound;
  }

  // Returns a score: lower is worse match
  int _matchScore(Recipe recipe, String query) {
    final q = query.toLowerCase();
    if (recipe.name.toLowerCase() == q) return 100;
    if (recipe.name.toLowerCase().startsWith(q)) return 80;
    if (recipe.name.toLowerCase().contains(q)) return 60;
    return 20;
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List.generate(t.length + 1, (i) => i);
    List<int> v1 = List.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce(min);
      }
      final temp = v0;
      v0 = v1;
      v1 = temp;
    }
    return v0[t.length];
  }
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text('Search Dishes',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF9E00),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: const Color(0xFFFF9E00),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                style: GoogleFonts.poppins(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Try "canji", "thandai", "rasam"...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFFF9E00)),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _ctrl.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  _ctrl.text.isEmpty
                      ? 'All recipes (${_allRecipes.length})'
                      : '${_results.length} result${_results.length == 1 ? '' : 's'} for "${_ctrl.text}"',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                if (_loading) ...[
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),

          // Recipe list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? _EmptyState(query: _ctrl.text)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: _results.length,
                        itemBuilder: (_, i) =>
                            _SearchResultCard(recipe: _results[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Recipe recipe;
  const _SearchResultCard({required this.recipe});

  static const Map<String, Color> _rasaColors = {
    'madhura': Color(0xFFFFBE0B),
    'amla': Color(0xFFFF6B35),
    'lavana': Color(0xFF3A86FF),
    'katu': Color(0xFFFF006E),
    'tikta': Color(0xFF38B000),
    'kasaya': Color(0xFF8338EC),
  };

  static const Map<String, String> _rasaLabel = {
    'madhura': 'Sweet',
    'amla': 'Sour',
    'lavana': 'Salty',
    'katu': 'Pungent',
    'tikta': 'Bitter',
    'kasaya': 'Astringent',
  };

  @override
  Widget build(BuildContext context) {
    final color = _rasaColors[recipe.rasa] ?? const Color(0xFFFF6B35);
    final rasaName = _rasaLabel[recipe.rasa] ?? recipe.rasa;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(recipe: recipe)),
        ),
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
              child: Image.asset(
                recipe.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: color.withOpacity(0.15),
                  child: Icon(Icons.restaurant, color: color, size: 36),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            rasaName,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            recipe.state,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recipe.ingredients.take(2).join(', '),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'No results for "$query"',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different spelling or ingredient name',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
