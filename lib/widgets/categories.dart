
import '../l10n/app_localizations.dart';

List<Map<String, dynamic>> getCategories(AppLocalizations localizations) {
  return [
    {
      'name': localizations.category_animals,
      'query': 'animals',
      'image': 'lib/assets/images/animals.png',
    },
    {
      'name': localizations.category_nature,
      'query': 'nature',
      'image': 'lib/assets/images/nature.png',
    },
       {
      'name': localizations.category_space,
      'query': 'space',
      'image': 'lib/assets/images/space.png',
    },
       {
      'name': localizations.category_food_drink,
      'query': 'food-drink',
      'image': 'lib/assets/images/science.png',
    },
       {
      'name': localizations.category_shapes,
      'query': 'shapes',
      'image': 'lib/assets/images/shapes.png',
    },
       {
      'name': localizations.category_vehicles,
      'query': 'vehicles',
      'image': 'lib/assets/images/vehicles.png',
    },
   /*     {
      'name': localizations.category_architecture,
      'query': 'architecture',
      'image': 'lib/assets/images/architecture.png',
    } */
  ];
}



