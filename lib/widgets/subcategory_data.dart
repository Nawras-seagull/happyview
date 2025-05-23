// subcategory_data.dart
class SubcategoryData {
  static Map<String, List<String>> get categoryTopicsMap => {
        'animals': [
          'mammals',
          'birds',
          'reptiles',
          'sea-creatures',
          'insects',
          'amphibians',
          'wildlife',
          'pets',
          'farm-animals',
          'baby-animals',
          'dinosaurs',
        ],
        'nature': [
          'trees',
          'flower',
          'forests',
          'mountains',
          'oceans',
          'snow',
          'sunsets',
          'waterfalls',
          'rivers',
          'lakes',
          'leaf'
        ],
        'space': ['planets', 'stars', 'galaxies', 'astronauts'],
        'architecture': [
          'buildings',
          'bridges',
          'skyscrapers',
          'houses',
          'furniture',
          'exteriors',
          'landmarks',
          'monuments',
          'towers',
          'castles'
        ],
        'food-drink': [
          'fruits',
          
          'vegetables',
          'desserts',
          'beverages',
          'fast-food',
          'seafood',
          'dairy',
          'baked-goods',
          'healthy-food'




        ],
        'shapes': [
          'circles',
          'squares',
          'triangles',
          'rectangles',
          'hexagons',
          'hearts',
          'spirals',
          'diamonds',
          'ovals'
        ],
        'vehicles': [
          'cars',
          'motorcycles',
          'trucks',
          'bicycles',
          'buses',
          'trains',
          'airplanes',
          'boats',
          'helicopters',
          'scooters',
          'excavators',
          'Emergency-Vehicles'
        ],
      };

  static List<String> getCategoryTopics(String category) {
    return categoryTopicsMap[category.toLowerCase()] ?? [];
  }

  static String getTranslatedCategory(dynamic localizations, String category) {
    final translations = {
      'animals': localizations?.category_animals,
      'nature': localizations?.category_nature,
      'space': localizations?.category_space,
      'architecture': localizations?.category_architecture,
      'food-drink': localizations?.category_food_drink,
      'shapes': localizations?.category_shapes,
      'vehicles': localizations?.category_vehicles,
    };

    return translations[category] ?? category.replaceAll('-', ' ').toUpperCase();
  }

  static String getTranslatedTopic(dynamic localizations, String topic) {
    final translations = _getTranslationMap(localizations);
    return translations[topic] ?? topic.replaceAll('-', ' ').toUpperCase();
  }

  static Map<String, String?> _getTranslationMap(dynamic localizations) {
    return {
      'mammals': localizations?.mammals,
      'birds': localizations?.birds,
      'reptiles': localizations?.reptiles,
      'sea-creatures': localizations?.seaCreatures,
      'insects': localizations?.insects,
      'amphibians': localizations?.amphibians,
      'wildlife': localizations?.wildlife,
      'pets': localizations?.pets,
      'farm-animals': localizations?.farmAnimals,
      'baby-animals': localizations?.babyAnimals,
      'trees': localizations?.trees,
      'flower': localizations?.flower,
      'forests': localizations?.forests,
      'mountains': localizations?.mountains,
      'oceans': localizations?.oceans,
      'snow': localizations?.snow,
      'sunsets': localizations?.sunsets,
      'waterfalls': localizations?.waterfalls,
      'rivers': localizations?.rivers,
      'lakes': localizations?.lakes,
      'leaf': localizations?.leaf,
      'planets': localizations?.planets,
      'stars': localizations?.stars,
      'galaxies': localizations?.galaxies,
      'astronauts': localizations?.astronauts,
      'buildings': localizations?.buildings,
      'bridges': localizations?.bridges,
      'skyscrapers': localizations?.skyscrapers,
      'houses': localizations?.houses,
      'furniture': localizations?.furniture,
      'exteriors': localizations?.exteriors,
      'landmarks': localizations?.landmarks,
      'monuments': localizations?.monuments,
      'towers': localizations?.towers,
      'castles': localizations?.castles,
      'fruits': localizations?.fruits,
      'vegetables': localizations?.vegetables,
      'desserts': localizations?.desserts,
      'beverages': localizations?.beverages,
      'fast-food': localizations?.fastFood,
      'seafood': localizations?.seafood,
      'meat': localizations?.meat,
      'dairy': localizations?.dairy,
      'baked-goods': localizations?.bakedGoods,
      'healthy-food': localizations?.healthyFood,
      'circles': localizations?.circles,
      'squares': localizations?.squares,
      'triangles': localizations?.triangles,
      'rectangles': localizations?.rectangles,
      'hexagons': localizations?.hexagons,
      'hearts': localizations?.hearts,
      'spirals': localizations?.spirals,
      'diamonds': localizations?.diamonds,
      'ovals': localizations?.ovals,
      'cars': localizations?.cars,
      'motorcycles': localizations?.motorcycles,
      'trucks': localizations?.trucks,
      'bicycles': localizations?.bicycles,
      'buses': localizations?.buses,
      'trains': localizations?.trains,
      'airplanes': localizations?.airplanes,
      'boats': localizations?.boats,
      'helicopters': localizations?.helicopters,
      'scooters': localizations?.scooters,
      'excavators': localizations?.excavators,
      'dinosaurs': localizations?.dinosaurs,
      'service-vehicles': localizations?.serviceVehicles,
    };
  }
}