class Recipe {
  final String id, name, image, type, rasa, panchabaksha, state;
  final String prepTime, dosha;
  final List<String> ingredients;
  final List<String> ingredientsList;
  final List<String> healthBenefits;
  final List<String> process;
  final List<String> analysis;
  final List<String> classicalReference;

  Recipe.fromJson(Map<String, dynamic> json)
      : id = json['id']?.toString() ?? '',
        name = json['name'] ?? '',
        image = json['image'] ?? 'assets/placeholder.png',
        type = json['type'] ?? '',
        rasa = json['rasa'] ?? '',
        panchabaksha = json['panchabaksha'] ?? '',
        state = json['state'] ?? '',
        prepTime = json['prepTime'] ?? '30 mins',
        dosha = json['dosha'] ?? 'Tridoshic',
        ingredients = List<String>.from(json['ingredients'] ?? []),
        ingredientsList = List<String>.from(json['ingredientsList'] ?? []),
        process = List<String>.from(json['process'] ?? []),
        healthBenefits = List<String>.from(json['healthBenefits'] ?? []),
        classicalReference = List<String>.from(json['classicalReference'] ?? []),
        analysis = List<String>.from(json['analysis'] ?? []);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'type': type,
        'rasa': rasa,
        'panchabaksha': panchabaksha,
        'state': state,
        'prepTime': prepTime,
        'dosha': dosha,
        'ingredients': ingredients,
        'ingredientsList': ingredientsList,
        'process': process,
        'healthBenefits': healthBenefits,
        'classicalReference': classicalReference,
        'analysis': analysis,
      };
}