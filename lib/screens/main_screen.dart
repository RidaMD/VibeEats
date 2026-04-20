import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_screen.dart';
import 'search_screen.dart';
import 'explore_screen.dart';
import 'state_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with gradient overlay
          Image.asset('assets/background.jpg', fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCCFFF8F0),
                  Color(0xF5FFF8F0),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // App Logo & Title
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFFBE0B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🍲', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'VibeEats',
                    style: GoogleFonts.poppins(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  Text(
                    'PANCHABAKSHA',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      letterSpacing: 4,
                      color: const Color(0xFFFF6B35),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ancient Indian Food Wisdom, Reimagined',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Navigation Cards
                  _NavCard(
                    emoji: '🏺',
                    title: 'About',
                    subtitle: 'Indian Knowledge Systems & IKS integration',
                    gradient: const [Color(0xFF7209B7), Color(0xFF3A0CA3)],
                    onTap: () => Navigator.push(
                      context,
                      _buildRoute(const AboutScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _NavCard(
                    emoji: '🔍',
                    title: 'Search',
                    subtitle: 'Find dishes by name — smart typo-friendly search',
                    gradient: const [Color(0xFFFF6B35), Color(0xFFFF9E00)],
                    onTap: () => Navigator.push(
                      context,
                      _buildRoute(const SearchScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _NavCard(
                    emoji: '🌿',
                    title: 'Explore',
                    subtitle: 'Browse by Panchabaksha rasas & filter by ingredients',
                    gradient: const [Color(0xFF38B000), Color(0xFF70E000)],
                    onTap: () => Navigator.push(
                      context,
                      _buildRoute(const ExploreScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _NavCard(
                    emoji: '🗺️',
                    title: 'India Map',
                    subtitle: 'Discover regional recipes state by state',
                    gradient: const [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                    onTap: () => Navigator.push(
                      context,
                      _buildRoute(const StateScreen()),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Six Rasas preview strip
                  Text(
                    'Panchabaksha — Five Food Groups',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Every food classified by how you consume it',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RasaDot('🍪', 'Baksham\nBite', const Color(0xFFFF9F1C)),
                      _RasaDot('🍛', 'Bojyam\nChew', const Color(0xFF2EC4B6)),
                      _RasaDot('🥣', 'Choshyam\nSlurp', const Color(0xFF3A86FF)),
                      _RasaDot('🍯', 'Lehyam\nLick', const Color(0xFFFFBE0B)),
                      _RasaDot('🥛', 'Paaniyam\nDrink', const Color(0xFF4CC9F0)),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PageRoute _buildRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }
}

class _NavCard extends StatefulWidget {
  final String emoji, title, subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _NavCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_NavCard> createState() => _NavCardState();
}

class _NavCardState extends State<_NavCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 44)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RasaDot extends StatelessWidget {
  final String emoji, label;
  final Color color;

  const _RasaDot(this.emoji, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 8, color: Colors.grey[600]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}