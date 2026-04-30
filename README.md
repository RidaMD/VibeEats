# VibeEats 🍲

VibeEats is a premium Flutter-based culinary application designed to bridge traditional Indian dietary wisdom (IKS - Indian Knowledge Systems) with modern technology. It features a rich, interactive experience for exploring regional recipes, nutritional analysis, and Ayurvedic insights.

## 📊 System Architecture Flowchart

![VibeEats Architecture](assets/architecture.png)

## 🏗️ Project Architecture

The project follows a clean, modular architecture separating concerns into distinct layers:

### 1. Presentation Layer (`lib/screens` & `lib/widgets`)
- **Main Screen**: Interactive India map and category-based recipe discovery.
- **Detail Screen**: Comprehensive view of recipes including ingredients, preparation steps, health benefits, and nutritional analysis.
- **Widgets**: Reusable components like `ZoomDialog` for high-fidelity image inspection.
- **Animations**: Uses `Hero` transitions for cinematic navigation and `InteractiveViewer` for smooth zooming.

### 2. Data Layer (`lib/models` & `assets`)
- **Recipe Model**: Typed Dart classes for safe data handling.
- **Local Data**: `recipes.json` serves as the primary source of truth, containing rich metadata for each dish (Rasa, Dosha, State, etc.).

### 3. Service Layer
- **Text-to-Speech (TTS)**: Integrated `flutter_tts` for high-performance, client-side audio playback on web and mobile.

## 🚀 Key Features

- **Ayurvedic Integration**: Recipes are categorized by *Rasa* (taste) and *Dosha* (body type) balancing properties.
- **Interactive India Map**: Explore regional delicacies by clicking on different states.
- **Voice Assistant**: Hear recipe details read aloud with a single click.
- **Cinematic Zoom**: High-resolution image preview with full pan/zoom capabilities.
- **Nutritional Analysis**: Detailed breakdown of identified nutrients and compounds for each recipe.

## 🛠️ Tech Stack

- **Frontend**: Flutter (3.11+)
- **Styling**: Material 3, Google Fonts (Poppins)
- **Voice**: flutter_tts (Web Speech API)

## 🏃 How to Run

### Prerequisites
- Flutter SDK installed
- Chrome (for web testing)

### Commands
```powershell
# 1. Clean the project
flutter clean

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome
flutter run -d chrome
```

## 🔮 Future Scope

- **Personalized Nutrition**: Integrating a *Prakriti* (body type) assessment tool to provide personalized recipe recommendations.
- **Offline Persistence**: Moving from flat JSON to a robust local database (SQFlite) for handling thousands of recipes efficiently.
- **Multilingual Support**: Adding regional Indian languages to make traditional knowledge accessible to everyone.
- **AR Ingredient Discovery**: Using Augmented Reality to help users identify and learn about Ayurvedic herbs and spices in real-time.

## 📁 Directory Structure

```text
vibeeats/
├── assets/             # Images, JSON data, and environment configs
├── lib/
│   ├── models/         # Data models (Recipe, etc.)
│   ├── screens/        # UI Pages (Detail, Map, Search, etc.)
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # App entry point
└── pubspec.yaml        # Project dependencies
```

---
*Developed as part of the RTRP VibeEats initiative.*
