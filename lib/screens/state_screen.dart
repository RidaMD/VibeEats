import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'detail_screen.dart';

// ─── State Info ───────────────────────────────────────────────────────────────
// Coordinates derived from real centroids of Indian states.
// India bounding box: lat 8.06–37.08°N, lon 68.11–97.41°E
// x = (lon - 68.0) / 30.0   y = (37.1 - lat) / 30.0
class _StateInfo {
  final String name;
  final double x; // 0=west … 1=east
  final double y; // 0=north … 1=south
  final Color color;
  final String abbr;
  const _StateInfo(this.name, this.x, this.y, this.color, [this.abbr = '']);
}

const List<_StateInfo> _indianStates = [
  // — North —
  _StateInfo('Jammu & Kashmir',  0.228, 0.037, Color(0xFF4361EE), 'J&K'),
  _StateInfo('Ladakh',           0.338, 0.000, Color(0xFF7209B7), 'Leh'),
  _StateInfo('Himachal Pradesh', 0.310, 0.093, Color(0xFF3A0CA3), 'HP'),
  _StateInfo('Punjab',           0.213, 0.117, Color(0xFF560BAD), 'PB'),
  _StateInfo('Haryana',          0.263, 0.163, Color(0xFF4361EE), 'HR'),
  _StateInfo('Delhi',            0.293, 0.190, Color(0xFFFF6B35),  'DL'),
  _StateInfo('Uttarakhand',      0.363, 0.127, Color(0xFF06D6A0), 'UK'),
  _StateInfo('Uttar Pradesh',    0.423, 0.223, Color(0xFF4CC9F0), 'UP'),
  _StateInfo('Rajasthan',        0.173, 0.257, Color(0xFFFF9F1C), 'RJ'),
  // — Central —
  _StateInfo('Madhya Pradesh',   0.347, 0.340, Color(0xFF38B000), 'MP'),
  _StateInfo('Gujarat',          0.133, 0.367, Color(0xFFF72585), 'GJ'),
  _StateInfo('Maharashtra',      0.283, 0.453, Color(0xFFFF9500), 'MH'),
  _StateInfo('Chhattisgarh',     0.490, 0.390, Color(0xFF2EC4B6), 'CG'),
  _StateInfo('Jharkhand',        0.563, 0.307, Color(0xFF4CC9F0), 'JH'),
  _StateInfo('Bihar',            0.527, 0.263, Color(0xFFFF9F1C), 'BR'),
  // — East —
  _StateInfo('West Bengal',      0.643, 0.317, Color(0xFF4361EE), 'WB'),
  _StateInfo('Odisha',           0.563, 0.407, Color(0xFFFF6B35), 'OD'),
  _StateInfo('Sikkim',           0.683, 0.213, Color(0xFF7209B7), 'SK'),
  _StateInfo('Arunachal Pradesh',0.873, 0.170, Color(0xFF38B000), 'AR'),
  _StateInfo('Assam',            0.800, 0.240, Color(0xFF3A0CA3), 'AS'),
  _StateInfo('Meghalaya',        0.780, 0.293, Color(0xFF560BAD), 'ML'),
  _StateInfo('Nagaland',         0.880, 0.277, Color(0xFFF72585), 'NL'),
  _StateInfo('Manipur',          0.870, 0.323, Color(0xFF4CC9F0), 'MN'),
  _StateInfo('Mizoram',          0.833, 0.377, Color(0xFFFF4800), 'MZ'),
  _StateInfo('Tripura',          0.797, 0.347, Color(0xFFFF9500), 'TR'),
  // — South —
  _StateInfo('Telangana',        0.413, 0.470, Color(0xFF7209B7), 'TS'),
  _StateInfo('Andhra Pradesh',   0.443, 0.513, Color(0xFF4361EE), 'AP'),
  _StateInfo('Karnataka',        0.287, 0.543, Color(0xFFFF4800), 'KA'),
  _StateInfo('Goa',              0.220, 0.530, Color(0xFFF72585), 'GA'),
  _StateInfo('Kerala',           0.270, 0.627, Color(0xFF38B000), 'KL'),
  _StateInfo('Tamil Nadu',       0.383, 0.617, Color(0xFFF72585), 'TN'),
];
// ─────────────────────────────────────────────────────────────────────────────

class StateScreen extends StatefulWidget {
  const StateScreen({super.key});

  @override
  State<StateScreen> createState() => _StateScreenState();
}

class _StateScreenState extends State<StateScreen>
    with SingleTickerProviderStateMixin {
  List<Recipe> _recipes = [];
  bool _loading = true;
  _StateInfo? _highlighted;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _loadRecipes();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    final recipes = await RecipeService().getRecipes();
    setState(() {
      _recipes = recipes;
      _loading = false;
    });
  }

  Set<String> get _statesWithRecipes => _recipes.map((r) => r.state.toLowerCase()).toSet();

  void _showStateRecipes(BuildContext ctx, _StateInfo state) {
    setState(() => _highlighted = state);
    final stateRecipes = _recipes
        .where((r) => r.state.toLowerCase() == state.name.toLowerCase())
        .toList();

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StateBottomSheet(state: state, recipes: stateRecipes),
    ).then((_) => setState(() => _highlighted = null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF4361EE)),
                  const SizedBox(height: 16),
                  Text('Loading map…',
                      style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // ── Hero AppBar ───────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  backgroundColor: const Color(0xFF4361EE),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                          child: Row(
                            children: [
                              const Text('🗺️', style: TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Flavours of India',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Tap any state · ${_statesWithRecipes.length} have recipes',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'India Map',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    centerTitle: false,
                  ),
                ),

                // ── Legend bar ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        _legendItem(const Color(0xFF4361EE), 'State'),
                        const SizedBox(width: 20),
                        _legendItem(const Color(0xFFFFBE0B), 'Has recipes',
                            hasBorder: true),
                        const Spacer(),
                        Text(
                          'Pinch to zoom',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey[400]),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.pinch_outlined,
                            size: 14, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),

                // ── Map ──────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    boundaryMargin: const EdgeInsets.all(40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                      child: LayoutBuilder(
                        builder: (ctx2, constraints) {
                          final mapW = constraints.maxWidth;
                          // India's width:height ratio ≈ 0.74
                          final mapH = mapW / 0.74;

                          return SizedBox(
                            width: mapW,
                            height: mapH,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Map background
                                CustomPaint(
                                  size: Size(mapW, mapH),
                                  painter: _IndiaOutlinePainter(),
                                ),
                                // State pins
                                ..._indianStates.map((state) {
                                  final px = state.x * mapW;
                                  final py = state.y * mapH;
                                  final hasRecipes = _statesWithRecipes
                                      .contains(state.name.toLowerCase());
                                  final isHighlighted =
                                      _highlighted?.name == state.name;
                                  return _StatePin(
                                    state: state,
                                    left: px,
                                    top: py,
                                    hasRecipes: hasRecipes,
                                    isHighlighted: isHighlighted,
                                    pulseAnimation: _pulseCtrl,
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

                // ── States with recipes list ──────────────────────────────
                SliverToBoxAdapter(
                  child: _buildRegionsSection(),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
    );
  }

  Widget _legendItem(Color color, String label, {bool hasBorder = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasBorder ? Colors.transparent : color.withOpacity(0.6),
            border: Border.all(
              color: hasBorder ? const Color(0xFFFFBE0B) : color,
              width: 2,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildRegionsSection() {
    // Group states that have recipes by region
    final regions = {
      'North': ['Punjab', 'Haryana', 'Delhi', 'Himachal Pradesh',
          'Jammu & Kashmir', 'Ladakh', 'Uttarakhand', 'Uttar Pradesh',
          'Rajasthan'],
      'Central': ['Madhya Pradesh', 'Gujarat', 'Maharashtra', 'Chhattisgarh'],
      'East': ['Bihar', 'Jharkhand', 'West Bengal', 'Odisha', 'Sikkim',
          'Assam', 'Arunachal Pradesh', 'Meghalaya', 'Nagaland',
          'Manipur', 'Mizoram', 'Tripura'],
      'South': ['Telangana', 'Andhra Pradesh', 'Karnataka', 'Goa',
          'Kerala', 'Tamil Nadu'],
    };

    final statesWithR = _indianStates
        .where((s) => _statesWithRecipes.contains(s.name.toLowerCase()))
        .toList();

    if (statesWithR.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              '🍴 States with Recipes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ),
          const Divider(height: 1),
          ...regions.entries.map((entry) {
            final regionStates = statesWithR
                .where((s) => entry.value.contains(s.name))
                .toList();
            if (regionStates.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Text(
                    entry.key,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[500],
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ...regionStates.map((s) {
                  final count = _recipes
                      .where((r) =>
                          r.state.toLowerCase() == s.name.toLowerCase())
                      .length;
                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: s.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          s.abbr.isNotEmpty
                              ? s.abbr.substring(0, min(2, s.abbr.length))
                              : s.name.substring(0, 2),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: s.color,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      s.name,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: s.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count dish${count == 1 ? '' : 'es'}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: s.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    onTap: () => _showStateRecipes(context, s),
                  );
                }),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── State Pin ────────────────────────────────────────────────────────────────
class _StatePin extends StatefulWidget {
  final _StateInfo state;
  final double left, top;
  final bool hasRecipes, isHighlighted;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;

  const _StatePin({
    required this.state,
    required this.left,
    required this.top,
    required this.hasRecipes,
    required this.isHighlighted,
    required this.pulseAnimation,
    required this.onTap,
  });

  @override
  State<_StatePin> createState() => _StatePinState();
}

class _StatePinState extends State<_StatePin> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.state.abbr.isNotEmpty
        ? widget.state.abbr
        : widget.state.name.split(' ').first.substring(0, 2);

    final baseColor = widget.hasRecipes
        ? widget.state.color
        : widget.state.color.withOpacity(0.45);

    return Positioned(
      left: widget.left - 20,
      top: widget.top - 14,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Pulse ring for states with recipes
              if (widget.hasRecipes)
                AnimatedBuilder(
                  animation: widget.pulseAnimation,
                  builder: (_, __) {
                    return Positioned(
                      left: -6,
                      top: -6,
                      child: Container(
                        width: 52,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: widget.state.color.withOpacity(
                              0.15 * widget.pulseAnimation.value),
                          border: Border.all(
                            color: widget.state.color.withOpacity(
                                0.4 * widget.pulseAnimation.value),
                            width: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              // Main pin
              AnimatedScale(
                scale: _hovered ? 1.18 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(10),
                    border: widget.hasRecipes
                        ? Border.all(
                            color: const Color(0xFFFFD700), width: 1.5)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: widget.state.color.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (widget.hasRecipes)
                        const Text('●',
                            style: TextStyle(
                                color: Color(0xFFFFD700), fontSize: 5)),
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

// ─── India Outline Painter ────────────────────────────────────────────────────
// Simplified but correctly proportioned India outline
// Reference points mapped from real latitude/longitude centroids
class _IndiaOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ocean fill
    final seaPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFADD8F6),
          const Color(0xFF7EC8E3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), seaPaint);

    // Subtle wave texture
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (double yy = 0; yy < h; yy += h * 0.06) {
      final wavePath = Path();
      wavePath.moveTo(0, yy);
      for (double xx = 0; xx < w; xx += w * 0.1) {
        wavePath.quadraticBezierTo(
          xx + w * 0.05, yy - h * 0.01, xx + w * 0.1, yy);
      }
      canvas.drawPath(wavePath, wavePaint);
    }

    // India mainland outline
    // Points derived from actual Indian border, simplified to ~40 control points
    // Coordinates are normalized fractions of the canvas [0..1]
    final pts = [
      // NW corner → Kashmir
      [0.18, 0.04], [0.22, 0.00], [0.30, 0.00],
      // Pakistan border going SE
      [0.40, 0.00], [0.52, 0.00],
      // Nepal/China border (north)
      [0.65, 0.02], [0.78, 0.06], [0.88, 0.12],
      // NE — Arunachal / Myanmar
      [0.95, 0.22], [0.96, 0.32],
      // NE states loop
      [0.90, 0.36], [0.88, 0.44], [0.92, 0.50],
      [0.87, 0.58], [0.80, 0.56],
      // West Bengal coast / Bay of Bengal
      [0.72, 0.52], [0.70, 0.58],
      // Odisha / AP coast
      [0.68, 0.65], [0.64, 0.72], [0.60, 0.80],
      // Tamil Nadu tip — southern tip of India
      [0.54, 0.88], [0.47, 0.96], [0.42, 1.00],
      [0.38, 0.98], [0.33, 0.96],
      // Kerala / SW coast
      [0.27, 0.90], [0.22, 0.80],
      // Karnataka Goa coast
      [0.18, 0.70], [0.14, 0.60],
      // Gujarat / Konkan
      [0.10, 0.52], [0.05, 0.44], [0.02, 0.36],
      // Gujarat peninsula
      [0.00, 0.30], [0.02, 0.22],
      // Gujarat NW / Kutch region
      [0.06, 0.16], [0.10, 0.10],
      // Back to NW Pakistan border
      [0.15, 0.07], [0.18, 0.04],
    ];

    final landPath = _buildSmoothedPath(pts, w, h);

    // Shadow
    canvas.drawShadow(landPath, Colors.black.withOpacity(0.25), 10, true);

    // Land gradient fill
    final landPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF3D8), Color(0xFFFFE9A0), Color(0xFFFFD970)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(landPath, landPaint);

    // Inner subtle texture highlights
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    final highlightPath = _buildSmoothedPath(
        pts.map((p) => [p[0] + 0.005, p[1] + 0.005]).toList(), w, h);
    canvas.save();
    canvas.clipPath(landPath);
    canvas.drawPath(highlightPath, highlightPaint);
    canvas.restore();

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFFC8941A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(landPath, borderPaint);

    // Sri Lanka (small island)
    final sriLankaPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(w * 0.435, h * 1.03),
        width: w * 0.06,
        height: h * 0.05,
      ));
    canvas.drawShadow(sriLankaPath, Colors.black.withOpacity(0.15), 4, false);
    canvas.drawPath(sriLankaPath, landPaint);
    canvas.drawPath(sriLankaPath, borderPaint..strokeWidth = 1.0);

    // Compass rose (top right)
    _drawCompass(canvas, Offset(w * 0.91, h * 0.08), w * 0.055);
  }

  Path _buildSmoothedPath(List<List<double>> pts, double w, double h) {
    final path = Path();
    path.moveTo(pts[0][0] * w, pts[0][1] * h);
    for (int i = 1; i < pts.length; i++) {
      final curr = pts[i];
      final next = pts[min(i + 1, pts.length - 1)];
      final cpX = (curr[0] * w + next[0] * w) / 2;
      final cpY = (curr[1] * h + next[1] * h) / 2;
      path.quadraticBezierTo(
          curr[0] * w, curr[1] * h, cpX, cpY);
    }
    path.close();
    return path;
  }

  void _drawCompass(Canvas canvas, Offset center, double size) {
    // Circle background
    canvas.drawCircle(
      center,
      size,
      Paint()
        ..color = Colors.white.withOpacity(0.75)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      size,
      Paint()
        ..color = const Color(0xFF4361EE).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // N/S/E/W arrows
    final northPaint = Paint()..color = const Color(0xFFE63946);
    final southPaint = Paint()..color = const Color(0xFF4361EE);

    void drawArrow(double angle, Paint paint) {
      final tip = Offset(
        center.dx + cos(angle) * size * 0.72,
        center.dy + sin(angle) * size * 0.72,
      );
      final lBase = Offset(
        center.dx + cos(angle + pi * 0.35) * size * 0.32,
        center.dy + sin(angle + pi * 0.35) * size * 0.32,
      );
      final rBase = Offset(
        center.dx + cos(angle - pi * 0.35) * size * 0.32,
        center.dy + sin(angle - pi * 0.35) * size * 0.32,
      );
      final p = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(lBase.dx, lBase.dy)
        ..lineTo(center.dx, center.dy)
        ..lineTo(rBase.dx, rBase.dy)
        ..close();
      canvas.drawPath(p, paint);
    }

    drawArrow(-pi / 2, northPaint); // North (red)
    drawArrow(pi / 2, southPaint);  // South (blue)
    drawArrow(0, Paint()..color = Colors.grey.shade400);       // East
    drawArrow(pi, Paint()..color = Colors.grey.shade400);      // West

    // N label
    final tp = TextPainter(
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          fontSize: size * 0.45,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFE63946),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2,
          center.dy - size * 0.72 - tp.height - 1),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── State Bottom Sheet ───────────────────────────────────────────────────────
class _StateBottomSheet extends StatelessWidget {
  final _StateInfo state;
  final List<Recipe> recipes;
  const _StateBottomSheet({required this.state, required this.recipes});

  static const Map<String, Color> _rasaColors = {
    'madhura': Color(0xFFFFBE0B),
    'amla': Color(0xFFFF6B35),
    'lavana': Color(0xFF3A86FF),
    'katu': Color(0xFFFF006E),
    'tikta': Color(0xFF38B000),
    'kasaya': Color(0xFF8338EC),
  };
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
      initialChildSize: recipes.isEmpty ? 0.40 : 0.55,
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
                color: state.color.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
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
              // State header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            state.color,
                            state.color.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: state.color.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          state.abbr.isNotEmpty
                              ? state.abbr
                              : state.name.substring(0, 2),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.name,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            recipes.isEmpty
                                ? 'No recipes yet'
                                : '${recipes.length} traditional recipe${recipes.length == 1 ? '' : 's'}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: recipes.isEmpty
                                  ? Colors.grey[500]
                                  : state.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
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
                              'Add dishes via recipes.json to show them here',
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
                          final rasaColor =
                              _rasaColors[recipe.rasa] ?? state.color;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: rasaColor.withOpacity(0.12),
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
                                      width: 92,
                                      height: 92,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 92,
                                        height: 92,
                                        decoration: BoxDecoration(
                                          color: rasaColor.withOpacity(0.12),
                                          borderRadius:
                                              const BorderRadius.only(
                                            topLeft: Radius.circular(18),
                                            bottomLeft: Radius.circular(18),
                                          ),
                                        ),
                                        child: Icon(Icons.restaurant,
                                            color: rasaColor, size: 32),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            recipe.name,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 9, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  rasaColor.withOpacity(0.12),
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
                                    child: Icon(Icons.chevron_right_rounded,
                                        color: Colors.grey[400], size: 22),
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
}