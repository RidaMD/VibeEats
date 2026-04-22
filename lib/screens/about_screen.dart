import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text('About VibeEats',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF7209B7),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Text('🍲', style: TextStyle(fontSize: 20)),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            tooltip: 'Home',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7209B7), Color(0xFF3A0CA3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7209B7).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🏺', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'Indian Knowledge\nSystems',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Integrated into VibeEats — Panchabaksha',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _Section(
              icon: '📚',
              title: 'What is IKS?',
              color: const Color(0xFF7209B7),
              content:
                  'Indian Knowledge Systems (IKS) is an interdisciplinary initiative by the Government of India to document, preserve, and integrate the vast accumulated knowledge of the Indian subcontinent into modern education and applications.\n\nIKS spans Ayurveda, Yoga, Mathematics, Astronomy, Architecture (Vastu), Linguistics (Sanskrit), Music (Sangeet), Fine Arts, and Culinary Science. These systems are not mere historical curiosities — they represent lived, tested, and sophisticated frameworks for understanding nature, the human body, and the cosmos.',
            ),
            const SizedBox(height: 20),
            _Section(
              icon: '🌿',
              title: 'Ayurvedic Food Philosophy',
              color: const Color(0xFF38B000),
              content:
                  'Ayurveda — literally "the science of life" — places food (Ahara) at the centre of health. The Charaka Samhita declares: "Ahara (food) is Brahma" — it is the very source of life, vitality (Ojas), and consciousness (Prana).\n\nAyurvedic dietetics goes far beyond nutrition labels. It understands food through the lens of:\n\n• Rasa (taste) — the six flavours that shape our physiology\n• Virya (potency) — heating or cooling energy\n• Vipaka (post-digestive effect) — what the food becomes after digestion\n• Prabhava (special action) — unique properties beyond the above\n\nEvery food substance affects the three Doshas — Vata (air/ether), Pitta (fire/water), and Kapha (water/earth) — differently. Eating in harmony with your constitution (Prakriti) and the season is the cornerstone of Ayurvedic wellness.',
            ),
            const SizedBox(height: 20),
            _Section(
              icon: '🍽️',
              title: 'Panchabaksha — The Six Rasas',
              color: const Color(0xFFFF6B35),
              content:
                  'The word "Panchabaksha" (पञ्चभक्ष) refers to the five groups of food substances described in classical texts. In VibeEats, we organise every recipe under the six Ayurvedic Rasas (tastes) that form the foundation of Panchabaksha:\n\n🟡 Madhura (Sweet) — nourishing, building, calming. Balances Vata and Pitta. Examples: milk, ghee, rice, fruits.\n\n🟠 Amla (Sour) — stimulating digestion, warming. Balances Vata. Examples: fermented foods, tamarind, lemon.\n\n🔵 Lavana (Salty) — hydrating, grounding. Balances Vata. Examples: rock salt preparations, sea vegetables.\n\n🔴 Katu (Pungent) — heating, cleansing, decongestant. Balances Kapha. Examples: ginger, pepper, chili, garlic.\n\n🟢 Tikta (Bitter) — detoxifying, anti-inflammatory. Balances Pitta and Kapha. Examples: turmeric, neem, karela.\n\n🟤 Kasaya (Astringent) — drying, binding, cooling. Balances Pitta and Kapha. Examples: pomegranate, unripe banana, betel leaf.\n\nA balanced meal ideally contains all six rasas, ensuring all doshas are harmonised.',
            ),
            const SizedBox(height: 20),
            _Section(
              icon: '📜',
              title: 'Classical References',
              color: const Color(0xFF4361EE),
              content:
                  'VibeEats draws from three primary classical Ayurvedic texts:\n\n• Charaka Samhita — The foundational treatise on internal medicine (Kaya Chikitsa). The Sutra Sthana chapters on dietetics (anna panavidhi) classify foods into 12 groups including liquids (pana), roots (mula), and fermented preparations (sandhana kalpana).\n\n• Sushruta Samhita — The surgical medicine classic that also extensively discusses diet for healing, wound recovery, and constitution-based eating.\n\n• Ashtanga Hridaya (Vagbhata) — A synthesis of both the above, widely used in clinical Ayurveda today. Its Ahara Vidhi (dietary protocol) chapters describe meal timing, food combination rules, and seasonal eating.\n\nEvery recipe in VibeEats includes a "Classical Reference" section citing the relevant Samhita chapter that describes the key ingredient or preparation method.',
            ),
            const SizedBox(height: 20),
            _Section(
              icon: '🔬',
              title: 'How IKS is Integrated Here',
              color: const Color(0xFFFF006E),
              content:
                  'VibeEats is built as an IKS-integrated food knowledge platform:\n\n1. Rasa Classification — Every recipe is tagged with its primary Ayurvedic rasa. The Explore screen organises recipes by these taste categories, making Ayurvedic food selection intuitive.\n\n2. Classical References — Each recipe card links the dish or its key ingredients to the specific Samhita and chapter that describes it, creating a bridge between ancient texts and modern kitchens.\n\n3. Health Benefits — Described through both modern nutritional science (vitamins, minerals, antioxidants) and Ayurvedic property language (deepana, brimhana, rasayana).\n\n4. Geographic Mapping — The interactive India map draws connections between states, their traditional foods, and regional Ayurvedic practices, preserving the geo-cultural context of food heritage.\n\n5. Quantitative Analysis — Each recipe lists identified bioactive nutrients, aligning traditional claims with modern validation.',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String icon, title, content;
  final Color color;

  const _Section({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(color: color, width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: const Color(0xFF444444),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
