import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class WebTTSDemo extends StatefulWidget {
  const WebTTSDemo({super.key});

  @override
  State<WebTTSDemo> createState() => _WebTTSDemoState();
}

class _WebTTSDemoState extends State<WebTTSDemo> {
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    flutterTts.setCompletionHandler(() {
      setState(() => isSpeaking = false);
    });
    flutterTts.setStartHandler(() {
      setState(() => isSpeaking = true);
    });
  }

  Future<void> _speakJsonContent() async {
    try {
      // 1. Load your JSON from assets
      // Ensure data.json is in assets/ and pubspec.yaml
      // For this demo, we fallback to a hardcoded string if file is missing
      String textToSpeak = "Welcome to Vibe Eats. Let's explore some healthy recipes together!";
      
      try {
        final String response = await rootBundle.loadString('assets/data.json');
        final data = json.decode(response);
        textToSpeak = data['content'] ?? textToSpeak;
      } catch (e) {
        debugPrint("Note: assets/data.json not found, using default text.");
      }

      // 2. Web-specific settings
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5); // Web speed varies, 0.5 is safe
      await flutterTts.setVolume(1.0);
      
      // 3. Speak
      if (isSpeaking) {
        await flutterTts.stop();
        setState(() => isSpeaking = false);
      } else {
        await flutterTts.speak(textToSpeak);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text("Chrome TTS Demo", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.record_voice_over_rounded, size: 80, color: Color(0xFFFF6B35)),
              const SizedBox(height: 24),
              Text(
                "Test Voice Synthesis",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Click below to read JSON content",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: Icon(isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded),
                label: Text(
                  isSpeaking ? "Stop Speaking" : "Read JSON Content",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                onPressed: _speakJsonContent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
