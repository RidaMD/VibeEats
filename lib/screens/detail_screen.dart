import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/recipe.dart';

class DetailScreen extends StatefulWidget {
  final Recipe recipe;
  const DetailScreen({super.key, required this.recipe});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TransformationController _transformationController = TransformationController();
  
  bool isPlaying = false;
  bool isGenerating = false;

  static const Map<String, Color> _rasaColors = {
    'madhura': Color(0xFFFFBE0B),
    'amla': Color(0xFFFF6B35),
    'lavana': Color(0xFF3A86FF),
    'katu': Color(0xFFFF006E),
    'tikta': Color(0xFF38B000),
    'kasaya': Color(0xFF8338EC),
  };

  static const Map<String, String> _rasaLabel = {
    'madhura': 'Madhura (Sweet)',
    'amla': 'Amla (Sour)',
    'lavana': 'Lavana (Salty)',
    'katu': 'Katu (Pungent)',
    'tikta': 'Tikta (Bitter)',
    'kasaya': 'Kasaya (Astringent)',
  };

  Color get _themeColor =>
      _rasaColors[widget.recipe.rasa] ?? const Color(0xFFFF6B35);

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });
  }


  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final targetScale = (currentScale + 0.5).clamp(1.0, 4.0);
    _applyZoom(targetScale);
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final targetScale = (currentScale - 0.5).clamp(1.0, 4.0);
    _applyZoom(targetScale);
  }

  void _handleDoubleTap() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 1.0) {
      _applyZoom(1.0);
    } else {
      _applyZoom(2.0);
    }
  }

  void _applyZoom(double targetScale) {
    final currentMatrix = _transformationController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    if (currentScale == targetScale) return;

    final double scaleFactor = targetScale / currentScale;

    // Get the center of the viewport (approximate for the image container)
    final Offset center = Offset(MediaQuery.of(context).size.width / 2, 140);
    final Offset scenePoint = _transformationController.toScene(center);

    final Matrix4 newMatrix = currentMatrix.clone()
      ..translate(scenePoint.dx, scenePoint.dy)
      ..scale(scaleFactor, scaleFactor, 1.0)
      ..translate(-scenePoint.dx, -scenePoint.dy);

    _transformationController.value = newMatrix;
  }

  Future<void> _speakRecipe() async {
    if (isPlaying) {
      await _audioPlayer.stop();
      setState(() => isPlaying = false);
      return;
    }

    setState(() => isGenerating = true);

    try {
      final String token = dotenv.env['HF_API_KEY'] ?? '';
      if (token.isEmpty) {
        throw Exception("Hugging Face API Key is missing in .env");
      }

      final textToSpeak = "Here is the recipe for ${widget.recipe.name}. "
          "It is a ${widget.recipe.dosha} balancing dish from ${widget.recipe.state}. "
          "Ingredients include ${widget.recipe.ingredientsList.join(', ')}. "
          "Preparation: ${widget.recipe.process.join('. ')}.";

      // Using a fast TTS model suitable for English
      final url = Uri.parse(
          'https://api-inference.huggingface.co/models/facebook/mms-tts-eng');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"inputs": textToSpeak}),
      );

      if (response.statusCode == 200) {
        final audioBytes = response.bodyBytes;
        // On Web, using a data URI is often more reliable than BytesSource for some formats
        final base64Audio = base64Encode(audioBytes);
        final dataUri = 'data:audio/flac;base64,$base64Audio';
        
        await _audioPlayer.play(UrlSource(dataUri));
        setState(() {
          isGenerating = false;
          isPlaying = true;
        });
      } else if (response.statusCode == 503) {
        throw Exception("AI Voice Model is currently loading. Please try again in 15 seconds.");
      } else {
        throw Exception("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (mounted) setState(() => isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _themeColor;
    final rasaLabel = _rasaLabel[widget.recipe.rasa] ?? widget.recipe.rasa;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(
          widget.recipe.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Text('🍲', style: TextStyle(fontSize: 20)),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            tooltip: 'Home',
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {},
            tooltip: 'Share recipe',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isGenerating ? null : _speakRecipe,
        backgroundColor: color,
        foregroundColor: Colors.white,
        icon: isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Icon(isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded),
        label: Text(
          isPlaying ? "Stop" : "Listen",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Stack(
              children: [
                GestureDetector(
                  onDoubleTap: _handleDoubleTap,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    panEnabled: true,
                    minScale: 1.0,
                    maxScale: 4.0,
                    clipBehavior: Clip.hardEdge,
                    child: Image.asset(
                      widget.recipe.image,
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 280,
                        color: color.withValues(alpha: 0.15),
                        child: const Center(
                          child: Text('🍽️', style: TextStyle(fontSize: 80)),
                        ),
                      ),
                    ),
                  ),
                ),
                // Elegant Glassmorphic Zoom Controls
                Positioned(
                  bottom: 20,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(30)),
                            onTap: _zoomOut,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Icon(Icons.remove, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
                            onTap: _zoomIn,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Gradient overlay at bottom of image
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xFFFFF8F0),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Rasa + State badge row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      rasaLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.location_on, size: 15, color: Colors.grey),
                  Text(
                    widget.recipe.state,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                widget.recipe.name,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D2D2D),
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(text: '🥘 Ingredients', color: color),
                  _CardList(
                      items: widget.recipe.ingredients, bullet: true, color: color),
                  _SectionTitle(text: '👨‍🍳 Preparation', color: color),
                  _CardList(
                      items: widget.recipe.process, numbered: true, color: color),
                  _SectionTitle(text: '💚 Health Benefits', color: color),
                  _CardList(
                      items: widget.recipe.healthBenefits, bullet: true, color: color),
                  _SectionTitle(text: '📜 Classical Reference', color: color),
                  _CardList(
                      items: widget.recipe.classicalReference, bullet: true, color: color),
                  _SectionTitle(text: '🔬 Nutritional Analysis', color: color),
                  _AnalysisTable(nutrients: widget.recipe.analysis, color: color),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionTitle({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _CardList extends StatelessWidget {
  final List<String> items;
  final Color color;
  final bool bullet, numbered;

  const _CardList({
    required this.items,
    required this.color,
    this.bullet = false,
    this.numbered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (i) {
          final prefix = bullet ? '• ' : (numbered ? '${i + 1}.  ' : '');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (numbered)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                if (numbered) const SizedBox(width: 10),
                if (bullet)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 8),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    numbered ? items[i] : items[i],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.6,
                      color: const Color(0xFF444444),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _AnalysisTable extends StatelessWidget {
  final List<String> nutrients;
  final Color color;

  const _AnalysisTable({required this.nutrients, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Identified Nutrient / Compound',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          ...nutrients.map(
            (n) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    n,
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: const Color(0xFF444444)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}