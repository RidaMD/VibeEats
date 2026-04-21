import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'detail_screen.dart';

// ─── State Info ───────────────────────────────────────────────────────────────
class _StateInfo {
  final String name;
  final double lat; 
  final double lng; 
  final Color color;
  final String abbr;
  const _StateInfo(this.name, this.lat, this.lng, this.color, [this.abbr = '']);
}

const List<_StateInfo> _indianStates = [
  // — North —
  _StateInfo('Jammu & Kashmir',  33.73, 76.77, Color(0xFF4361EE), 'J&K'),
  _StateInfo('Ladakh',           34.17, 77.58, Color(0xFF7209B7), 'Leh'),
  _StateInfo('Himachal Pradesh', 31.10, 77.17, Color(0xFF3A0CA3), 'HP'),
  _StateInfo('Punjab',           31.14, 75.34, Color(0xFF560BAD), 'PB'),
  _StateInfo('Haryana',          29.06, 76.09, Color(0xFF4361EE), 'HR'),
  _StateInfo('Delhi',            28.70, 77.10, Color(0xFFFF6B35),  'DL'),
  _StateInfo('Uttarakhand',      30.07, 79.01, Color(0xFF06D6A0), 'UK'),
  _StateInfo('Uttar Pradesh',    27.57, 80.10, Color(0xFF4CC9F0), 'UP'),
  _StateInfo('Rajasthan',        27.02, 74.22, Color(0xFFFF9F1C), 'RJ'),
  // — Central —
  _StateInfo('Madhya Pradesh',   23.47, 77.95, Color(0xFF38B000), 'MP'),
  _StateInfo('Gujarat',          22.31, 71.19, Color(0xFFF72585), 'GJ'),
  _StateInfo('Maharashtra',      19.75, 75.71, Color(0xFFFF9500), 'MH'),
  _StateInfo('Chhattisgarh',     21.28, 81.87, Color(0xFF2EC4B6), 'CG'),
  _StateInfo('Jharkhand',        23.61, 85.28, Color(0xFF4CC9F0), 'JH'),
  _StateInfo('Bihar',            25.09, 85.31, Color(0xFFFF9F1C), 'BR'),
  // — East —
  _StateInfo('West Bengal',      22.98, 87.85, Color(0xFF4361EE), 'WB'),
  _StateInfo('Odisha',           20.52, 84.67, Color(0xFFFF6B35), 'OD'),
  _StateInfo('Sikkim',           27.53, 88.51, Color(0xFF7209B7), 'SK'),
  _StateInfo('Arunachal Pradesh',28.22, 94.73, Color(0xFF38B000), 'AR'),
  _StateInfo('Assam',            26.14, 91.77, Color(0xFF3A0CA3), 'AS'),
  _StateInfo('Meghalaya',        25.47, 91.37, Color(0xFF560BAD), 'ML'),
  _StateInfo('Nagaland',         26.16, 94.56, Color(0xFFF72585), 'NL'),
  _StateInfo('Manipur',          24.66, 93.91, Color(0xFF4CC9F0), 'MN'),
  _StateInfo('Mizoram',          23.16, 92.94, Color(0xFFFF4800), 'MZ'),
  _StateInfo('Tripura',          23.94, 91.99, Color(0xFFFF9500), 'TR'),
  // — South —
  _StateInfo('Telangana',        17.36, 79.01, Color(0xFF7209B7), 'TS'),
  _StateInfo('Andhra Pradesh',   15.91, 79.74, Color(0xFF4361EE), 'AP'),
  _StateInfo('Karnataka',        15.32, 75.73, Color(0xFFFF4800), 'KA'),
  _StateInfo('Goa',              15.30, 74.12, Color(0xFFF72585), 'GA'),
  _StateInfo('Kerala',           10.85, 76.27, Color(0xFF38B000), 'KL'),
  _StateInfo('Tamil Nadu',       11.13, 78.66, Color(0xFFF72585), 'TN'),
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
                  child: Container(
                    height: 500, // Explicit height constraint for the map
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: const LatLng(22.0, 78.9629), // Center on India
                          initialZoom: 4.5,
                          minZoom: 3.5,
                          maxZoom: 8.0,
                          interactionOptions: const InteractionOptions(
                            flags: ~InteractiveFlag.rotate, // Disable rotation
                          ),
                          cameraConstraint: CameraConstraint.contain(
                            bounds: LatLngBounds(
                              const LatLng(6.5, 68.0), // SW
                              const LatLng(36.0, 97.4), // NE
                            ),
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.vibeeats',
                            retinaMode: true,
                          ),
                          MarkerLayer(
                            markers: _indianStates.map((state) {
                              final hasRecipes = _statesWithRecipes
                                  .contains(state.name.toLowerCase());
                              final isHighlighted =
                                  _highlighted?.name == state.name;
                              return Marker(
                                point: LatLng(state.lat, state.lng),
                                width: 52,
                                height: 52,
                                child: _StatePinWidget(
                                  state: state,
                                  hasRecipes: hasRecipes,
                                  isHighlighted: isHighlighted,
                                  pulseAnimation: _pulseCtrl,
                                  onTap: () => _showStateRecipes(context, state),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
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
class _StatePinWidget extends StatefulWidget {
  final _StateInfo state;
  final bool hasRecipes, isHighlighted;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;

  const _StatePinWidget({
    required this.state,
    required this.hasRecipes,
    required this.isHighlighted,
    required this.pulseAnimation,
    required this.onTap,
  });

  @override
  State<_StatePinWidget> createState() => _StatePinWidgetState();
}

class _StatePinWidgetState extends State<_StatePinWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.state.abbr.isNotEmpty
        ? widget.state.abbr
        : widget.state.name.split(' ').first.substring(0, 2);

    final baseColor = widget.hasRecipes
        ? widget.state.color
        : widget.state.color.withOpacity(0.45);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Pulse ring for states with recipes
            if (widget.hasRecipes)
              AnimatedBuilder(
                animation: widget.pulseAnimation,
                builder: (_, __) {
                  return Container(
                    width: 48,
                    height: 38,
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
                  );
                },
              ),
            // Main pin
            AnimatedScale(
              scale: _hovered || widget.isHighlighted ? 1.18 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
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
                        height: 1.1,
                      ),
                    ),
                    if (widget.hasRecipes)
                      const Text('●',
                          style: TextStyle(
                              color: Color(0xFFFFD700), fontSize: 5, height: 1.0)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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