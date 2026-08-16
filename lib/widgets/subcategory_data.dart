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
          'square-shapes',
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
      //    'Emergency-Vehicles'
        ],
      };

  static List<String> getCategoryTopics(String category) {
    return categoryTopicsMap[category.toLowerCase()] ?? [];
  }

  static String getTopicAsset(String topic) {
    final normalized = topic.trim().toLowerCase();
    final assetMap = {
      'mammals': 'lib/assets/images/mammals.webp',
      'birds': 'lib/assets/images/birds.webp',
      'reptiles': 'lib/assets/images/reptiles.webp',
      'sea-creatures': 'lib/assets/images/sea-creatures.webp',
      'insects': 'lib/assets/images/insects.webp',
      'amphibians': 'lib/assets/images/amphibians.webp',
      'wildlife': 'lib/assets/images/wildlife.webp',
      'pets': 'lib/assets/images/pets.webp',
      'farm-animals': 'lib/assets/images/farm-animals.webp',
      'baby-animals': 'lib/assets/images/baby-animals.webp',
      'dinosaurs': 'lib/assets/images/dinosaurs.webp',
      'fruits': 'lib/assets/images/fruits.webp',
      'vegetables': 'lib/assets/images/vegetables.webp',
      'desserts': 'lib/assets/images/desserts.webp',
      'beverages': 'lib/assets/images/beverages.webp',
      'fast-food': 'lib/assets/images/fast-food.webp',
      'seafood': 'lib/assets/images/seafood.webp',
      'dairy': 'lib/assets/images/dairy.webp',
      'baked-goods': 'lib/assets/images/baked-goods.webp',
      'healthy-food': 'lib/assets/images/healthy-food.webp',
      'circles': 'lib/assets/images/circles.webp',
      'square-shapes': 'lib/assets/images/square-shapes.webp',
      'triangles': 'lib/assets/images/triangles.webp',
      'rectangles': 'lib/assets/images/rectangles.webp',
      'hexagons': 'lib/assets/images/hexagons.webp',
      'hearts': 'lib/assets/images/hearts.webp',
      'spirals': 'lib/assets/images/spirals.webp',
      'diamonds': 'lib/assets/images/diamonds.webp',
      'ovals': 'lib/assets/images/ovals.webp',
      'trees': 'lib/assets/images/trees.webp',
      'flower': 'lib/assets/images/flower.webp',
      'forests': 'lib/assets/images/forests.webp',
      'mountains': 'lib/assets/images/mountains.webp',
      'oceans': 'lib/assets/images/oceans.webp',
      'snow': 'lib/assets/images/snow.webp',
      'sunsets': 'lib/assets/images/sunsets.webp',
      'waterfalls': 'lib/assets/images/waterfalls.webp',
      'rivers': 'lib/assets/images/rivers.webp',
      'lakes': 'lib/assets/images/lakes.webp',
      'leaf': 'lib/assets/images/leaf.webp',
      'cars': 'lib/assets/images/cars.webp',
      'motorcycles': 'lib/assets/images/motorcycles.webp',
      'trucks': 'lib/assets/images/trucks.webp',
      'bicycles': 'lib/assets/images/bicycles.webp',
      'buses': 'lib/assets/images/buses.webp',
      'trains': 'lib/assets/images/trains.webp',
      'airplanes': 'lib/assets/images/airplanes.webp',
      'boats': 'lib/assets/images/boats.webp',
      'helicopters': 'lib/assets/images/helicopters.webp',
      'scooters': 'lib/assets/images/scooters.webp',
      'excavators': 'lib/assets/images/excavators.webp',
      'service-vehicles': 'lib/assets/images/service-vehicles.webp',
      'planets': 'lib/assets/images/planets.webp',
      'stars': 'lib/assets/images/stars.webp',
      'galaxies': 'lib/assets/images/galaxies.webp',
      'astronauts': 'lib/assets/images/astronauts.webp',
    };

    return assetMap[normalized] ?? 'lib/assets/images/panda_peek.webp';
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