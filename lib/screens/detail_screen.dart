import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/recipe.dart';

class DetailScreen extends StatefulWidget {
  final Recipe recipe;
  const DetailScreen({super.key, required this.recipe});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;
  bool isGenerating = false;

  // TODO: Replace with your actual Gemini API key.
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';

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
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  Future<void> _speakRecipe() async {
    if (isPlaying) {
      await flutterTts.stop();
      setState(() => isPlaying = false);
      return;
    }

    setState(() => isGenerating = true);

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: geminiApiKey,
      );

      final prompt = '''
You are a helpful and enthusiastic culinary assistant for an Ayurvedic food app called VibeEats.
Read the following recipe naturally. Be conversational but cover all the details provided.

Recipe Name: ${widget.recipe.name}
Region: ${widget.recipe.state}
Ayurvedic Rasa: ${_rasaLabel[widget.recipe.rasa] ?? widget.recipe.rasa}
Ingredients: ${widget.recipe.ingredients.join(', ')}
Preparation: ${widget.recipe.process.join('. ')}
Health Benefits: ${widget.recipe.healthBenefits.join('. ')}
Classical Reference: ${widget.recipe.classicalReference.join('. ')}
Nutritional Analysis: ${widget.recipe.analysis.join(', ')}
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final textToSpeak =
          response.text ?? "Sorry, I couldn't generate the audio script.";

      setState(() {
        isGenerating = false;
        isPlaying = true;
      });

      await flutterTts.speak(textToSpeak);

      flutterTts.setCompletionHandler(() {
        if (mounted) setState(() => isPlaying = false);
      });
    } catch (e) {
      if (mounted) setState(() => isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e — Add your Gemini API key in detail_screen.dart'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
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
            icon: isGenerating
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Icon(isPlaying ? Icons.stop_circle : Icons.play_circle_fill),
            onPressed: _speakRecipe,
            tooltip: isPlaying ? 'Stop reading' : 'Read recipe aloud',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Stack(
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Image.asset(
                    widget.recipe.image,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 240,
                      color: color.withOpacity(0.15),
                      child: Center(
                        child: Text('🍽️', style: const TextStyle(fontSize: 80)),
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
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFFFFF8F0),
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
                          color: color.withOpacity(0.35),
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
            color: color.withOpacity(0.1),
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
                      color: color.withOpacity(0.15),
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
            color: color.withOpacity(0.1),
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