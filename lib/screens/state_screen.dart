import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'detail_screen.dart';

// ─── State Info ───────────────────────────────────────────────────────────────
class _StateInfo {
  final String name;
  final double x; // normalized 0–1 (west→east)
  final double y; // normalized 0–1 (north→south)
  final Color color;
  final String abbr;

  const _StateInfo(this.name, this.x, this.y, this.color, [this.abbr = '']);
}

// Normalized positions: India spans lat 8–37°N, lon 68–97°E
// x = (lon - 68) / 29,  y = (37 - lat) / 29
const List<_StateInfo> _indianStates = [
  _StateInfo('Jammu & Kashmir', 0.28, 0.07, Color(0xFF4361EE), 'J&K'),
  _StateInfo('Himachal Pradesh', 0.33, 0.20, Color(0xFF7209B7), 'HP'),
  _StateInfo('Punjab', 0.20, 0.23, Color(0xFF3A0CA3), 'Punjab'),
  _StateInfo('Haryana', 0.29, 0.30, Color(0xFF560BAD), 'Haryana'),
  _StateInfo('Delhi', 0.33, 0.33, Color(0xFFFF6B35), 'Delhi'),
  _StateInfo('Uttarakhand', 0.44, 0.23, Color(0xFF4361EE), 'UK'),
  _StateInfo('Uttar Pradesh', 0.47, 0.38, Color(0xFF4CC9F0), 'UP'),
  _StateInfo('Rajasthan', 0.17, 0.39, Color(0xFFFF6B35), 'Rajasthan'),
  _StateInfo('Gujarat', 0.11, 0.53, Color(0xFFF72585), 'Gujarat'),
  _StateInfo('Madhya Pradesh', 0.38, 0.50, Color(0xFF38B000), 'MP'),
  _StateInfo('Maharashtra', 0.28, 0.62, Color(0xFFFF9500), 'Maharashtra'),
  _StateInfo('Chhattisgarh', 0.51, 0.57, Color(0xFF38B000), 'CG'),
  _StateInfo('Goa', 0.20, 0.75, Color(0xFFF72585), 'Goa'),
  _StateInfo('Karnataka', 0.27, 0.79, Color(0xFFFF4800), 'Karnataka'),
  _StateInfo('Andhra Pradesh', 0.46, 0.73, Color(0xFF4361EE), 'AP'),
  _StateInfo('Telangana', 0.43, 0.66, Color(0xFF7209B7), 'Telangana'),
  _StateInfo('Kerala', 0.24, 0.90, Color(0xFF38B000), 'Kerala'),
  _StateInfo('Tamil Nadu', 0.40, 0.91, Color(0xFFF72585), 'TN'),
  _StateInfo('Odisha', 0.59, 0.58, Color(0xFFFF6B35), 'Odisha'),
  _StateInfo('Jharkhand', 0.59, 0.47, Color(0xFF4CC9F0), 'JH'),
  _StateInfo('Bihar', 0.55, 0.40, Color(0xFFFF9500), 'Bihar'),
  _StateInfo('West Bengal', 0.69, 0.49, Color(0xFF4361EE), 'WB'),
  _StateInfo('Assam', 0.85, 0.37, Color(0xFF3A0CA3), 'Assam'),
  _StateInfo('Arunachal Pradesh', 0.92, 0.28, Color(0xFF38B000), 'AR'),
  _StateInfo('Sikkim', 0.73, 0.32, Color(0xFF7209B7), 'Sikkim'),
  _StateInfo('Meghalaya', 0.83, 0.44, Color(0xFF560BAD), 'ML'),
  _StateInfo('Manipur', 0.90, 0.50, Color(0xFF4CC9F0), 'MN'),
  _StateInfo('Nagaland', 0.93, 0.43, Color(0xFFF72585), 'NL'),
  _StateInfo('Tripura', 0.83, 0.53, Color(0xFFFF9500), 'TR'),
  _StateInfo('Mizoram', 0.85, 0.59, Color(0xFFFF4800), 'MZ'),
];
// ──────────────────────────────────────────────────────────────────────────────

class StateScreen extends StatefulWidget {
  const StateScreen({super.key});

  @override
  State<StateScreen> createState() => _StateScreenState();
}

class _StateScreenState extends State<StateScreen> {
  List<Recipe> _recipes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final recipes = await RecipeService().getRecipes();
    setState(() {
      _recipes = recipes;
      _loading = false;
    });
  }

  void _showStateRecipes(BuildContext ctx, _StateInfo state) {
    final stateRecipes = _recipes
        .where((r) => r.state.toLowerCase() == state.name.toLowerCase())
        .toList();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StateBottomSheet(
        state: state,
        recipes: stateRecipes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text('India Map',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4361EE),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: const Color(0xFF4361EE),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    'Tap a state to explore its traditional recipes',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 3.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: LayoutBuilder(
                        builder: (ctx2, constraints) {
                          // Use 0.78 aspect ratio (India's approximate shape)
                          final mapWidth = constraints.maxWidth;
                          final mapHeight = mapWidth / 0.78;

                          return SizedBox(
                            width: mapWidth,
                            height: mapHeight,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Map background
                                CustomPaint(
                                  size: Size(mapWidth, mapHeight),
                                  painter: _IndiaMapPainter(),
                                ),
                                // State markers
                                ..._indianStates.map((state) {
                                  final px = state.x * mapWidth;
                                  final py = state.y * mapHeight;
                                  final hasRecipes = _recipes.any((r) =>
                                      r.state.toLowerCase() ==
                                      state.name.toLowerCase());
                                  return _StateMarker(
                                    state: state,
                                    left: px,
                                    top: py,
                                    hasRecipes: hasRecipes,
                                    onTap: () =>
                                        _showStateRecipes(context, state),
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Legend
                _buildLegend(),
              ],
            ),
    );
  }

  Widget _buildLegend() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendDot(
              color: const Color(0xFF4361EE), label: 'State — tap to explore'),
          const SizedBox(width: 20),
          _LegendDot(
              color: const Color(0xFFFFBE0B),
              filled: true,
              label: 'Has recipes'),
        ],
      ),
    );
  }
}

// ─── State Marker Widget ──────────────────────────────────────────────────────
class _StateMarker extends StatefulWidget {
  final _StateInfo state;
  final double left, top;
  final bool hasRecipes;
  final VoidCallback onTap;

  const _StateMarker({
    required this.state,
    required this.left,
    required this.top,
    required this.hasRecipes,
    required this.onTap,
  });

  @override
  State<_StateMarker> createState() => _StateMarkerState();
}

class _StateMarkerState extends State<_StateMarker> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.state.abbr.isNotEmpty
        ? widget.state.abbr
        : widget.state.name.split(' ').first;

    return Positioned(
      left: widget.left - 28,
      top: widget.top - 14,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _hovered ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 160),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: widget.hasRecipes
                    ? widget.state.color
                    : widget.state.color.withOpacity(0.55),
                borderRadius: BorderRadius.circular(10),
                border: widget.hasRecipes
                    ? Border.all(color: const Color(0xFFFFBE0B), width: 1.5)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: widget.state.color.withOpacity(0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── India Map CustomPainter ──────────────────────────────────────────────────
class _IndiaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ocean background
    final seaPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFBDE0FE), Color(0xFF90E0EF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), seaPaint);

    // India landmass (simplified outline, clockwise from NW)
    final landPath = Path();
    final pts = [
      [0.18, 0.02], [0.26, 0.0], [0.40, 0.0], [0.55, 0.0],
      [0.68, 0.05], [0.80, 0.08], [0.98, 0.30],
      [0.90, 0.38], [0.88, 0.48], [0.92, 0.55],
      [0.85, 0.60], [0.78, 0.58],
      [0.72, 0.55], [0.73, 0.65],
      [0.68, 0.72], [0.60, 0.82],
      [0.52, 0.90], [0.45, 0.97],
      [0.40, 1.00], [0.35, 0.98],
      [0.26, 0.95], [0.20, 0.88],
      [0.14, 0.80], [0.10, 0.72],
      [0.04, 0.62], [0.0, 0.55],
      [0.08, 0.48], [0.04, 0.40],
      [0.0, 0.34], [0.0, 0.22],
      [0.08, 0.12], [0.14, 0.06],
      [0.18, 0.02],
    ];

    landPath.moveTo(pts[0][0] * w, pts[0][1] * h);
    for (int i = 1; i < pts.length; i++) {
      // Use smooth bezier-like transitions
      if (i < pts.length - 1) {
        final x1 = pts[i][0] * w;
        final y1 = pts[i][1] * h;
        final x2 = pts[min(i + 1, pts.length - 1)][0] * w;
        final y2 = pts[min(i + 1, pts.length - 1)][1] * h;
        final cpx = (x1 + x2) / 2;
        final cpy = (y1 + y2) / 2;
        landPath.quadraticBezierTo(x1, y1, cpx, cpy);
      } else {
        landPath.lineTo(pts[i][0] * w, pts[i][1] * h);
      }
    }
    landPath.close();

    // Drop shadow
    canvas.drawShadow(landPath, Colors.black.withOpacity(0.3), 8, true);

    // Land fill
    final landPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF0D0), Color(0xFFFFE4A0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(landPath, landPaint);

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFFD4A017)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(landPath, borderPaint);

    // Compass rose (top-right corner)
    _drawCompass(canvas, Offset(w * 0.92, h * 0.08), w * 0.06);
  }

  void _drawCompass(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = const Color(0xFF4361EE).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF4361EE).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, size, Paint()..color = Colors.white.withOpacity(0.5));
    canvas.drawCircle(center, size, strokePaint);

    // N-S-E-W arrows
    final arrowSize = size * 0.65;
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2 - pi / 2;
      final tipX = center.dx + cos(angle) * arrowSize;
      final tipY = center.dy + sin(angle) * arrowSize;
      final path = Path()
        ..moveTo(tipX, tipY)
        ..lineTo(center.dx + cos(angle + pi / 8) * size * 0.3,
            center.dy + sin(angle + pi / 8) * size * 0.3)
        ..lineTo(center.dx, center.dy)
        ..lineTo(center.dx + cos(angle - pi / 8) * size * 0.3,
            center.dy + sin(angle - pi / 8) * size * 0.3)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── State Bottom Sheet ───────────────────────────────────────────────────────
class _StateBottomSheet extends StatelessWidget {
  final _StateInfo state;
  final List<Recipe> recipes;

  const _StateBottomSheet({required this.state, required this.recipes});

  static const Map<String, String> _rasaLabel = {
    'madhura': '🟡 Sweet',
    'amla': '🟠 Sour',
    'lavana': '🔵 Salty',
    'katu': '🔴 Pungent',
    'tikta': '🟢 Bitter',
    'kasaya': '🟤 Astringent',
  };

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, ctrl) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: state.color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
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
              // State header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: state.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: state.color.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🗺️', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.name,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                        Text(
                          recipes.isEmpty
                              ? 'No recipes yet'
                              : '${recipes.length} recipe${recipes.length == 1 ? '' : 's'} found',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              // Recipe list
              Expanded(
                child: recipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🍳',
                                style: TextStyle(fontSize: 52)),
                            const SizedBox(height: 12),
                            Text(
                              'No recipes for ${state.name} yet',
                              style: GoogleFonts.poppins(
                                  fontSize: 15, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Add dishes via recipes.json to populate this state',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey[400]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: ctrl,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: recipes.length,
                        itemBuilder: (_, i) {
                          final recipe = recipes[i];
                          final rasaColor = _stateRasaColor(recipe.rasa);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: rasaColor.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailScreen(recipe: recipe),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      bottomLeft: Radius.circular(18),
                                    ),
                                    child: Image.asset(
                                      recipe.image,
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 88,
                                        height: 88,
                                        color: rasaColor.withOpacity(0.15),
                                        child: Icon(Icons.restaurant,
                                            color: rasaColor, size: 32),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            recipe.name,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: rasaColor.withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              _rasaLabel[recipe.rasa] ??
                                                  recipe.rasa,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: rasaColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Icon(Icons.chevron_right,
                                        color: Colors.grey[400]),
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
      },
    );
  }

  Color _stateRasaColor(String rasa) {
    const Map<String, Color> colors = {
      'madhura': Color(0xFFFFBE0B),
      'amla': Color(0xFFFF6B35),
      'lavana': Color(0xFF3A86FF),
      'katu': Color(0xFFFF006E),
      'tikta': Color(0xFF38B000),
      'kasaya': Color(0xFF8338EC),
    };
    return colors[rasa] ?? const Color(0xFF4361EE);
  }
}

// ─── Legend Dot ───────────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool filled;

  const _LegendDot(
      {required this.color, required this.label, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}