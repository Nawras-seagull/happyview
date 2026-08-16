
import '../l10n/app_localizations.dart';

List<Map<String, dynamic>> getCategories(AppLocalizations localizations) {
  return [
    {
      'name': localizations.category_animals,
      'query': 'animals',
      'image': 'lib/assets/images/animals.webp',
    },
    {
      'name': localizations.category_nature,
      'query': 'nature',
      'image': 'lib/assets/images/nature.webp',
    },
       {
      'name': localizations.category_space,
      'query': 'space',
      'image': 'lib/assets/images/space.webp',
    },
       {
      'name': localizations.category_food_drink,
      'query': 'food-drink',
      'image': 'lib/assets/images/food.webp',
    },
       {
      'name': localizations.category_shapes,
      'query': 'shapes',
      'image': 'lib/assets/images/shapes.webp',
    },
       {
      'name': localizations.category_vehicles,
      'query': 'vehicles',
      'image': 'lib/assets/images/vehicles.webp',
    },
   /*     {
      'name': localizations.category_architecture,
      'query': 'architecture',
      'image': 'lib/assets/images/architecture.webp',
    } */
  ];
}



