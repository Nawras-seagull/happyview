// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Happy View';

  @override
  String get hello => 'Hello';

  @override
  String get welcome => 'Welcome to my app';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileTitle => 'Profile';

  @override
  String get homeTitle => 'Home';

  @override
  String greeting(String name) {
    return 'Hello, $name';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String currentDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Today is $dateString';
  }

  @override
  String get category_animals => 'Animals';

  @override
  String get category_nature => 'Nature';

  @override
  String get category_space => 'Space';

  @override
  String get category_food_drink => 'Food & Drink';

  @override
  String get category_shapes => 'Shapes';

  @override
  String get category_vehicles => 'Vehicles';

  @override
  String get suprise => 'Surprise me! 🎉';

  @override
  String get flowers => 'flowers';

  @override
  String get category_architecture => 'Architecture';

  @override
  String get suggestion_message => 'Thank you for your suggestion!';

  @override
  String get suggestionTitle => 'Your Suggestion';

  @override
  String get suggestion_placeholder => 'Enter your suggestion here...';

  @override
  String get suggestionValidationEmpty => 'Please enter a suggestion';

  @override
  String get suggestionValidationLength => 'Suggestion must be less than 10 characters';

  @override
  String get emailLabel => 'Email (optional)';

  @override
  String get emailHint => 'Enter your email if you want a response';

  @override
  String get categoryLabel => 'Category (optional)';

  @override
  String get categoryHint => 'E.g., Feature Request, Bug Report, etc.';

  @override
  String get submit => 'Send Suggestions';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get suggestion_error => 'Enter your suggestion...';

  @override
  String get suggestion_subtitle => 'Share your thoughts with us';

  @override
  String get verification => 'For parents only';

  @override
  String whatIsSum(Object num1, Object num2) {
    return 'What is $num1 + $num2?';
  }

  @override
  String get incorrect => 'Incorrect answer. Try again.';

  @override
  String imageIndex(int index, int total) {
    return 'Image $index of $total';
  }

  @override
  String get storagePermissionDenied => 'Storage permission denied';

  @override
  String get imageSavedToGallery => 'Image saved to gallery!';

  @override
  String get error => 'Error';

  @override
  String get failedToDecodeImage => 'Failed to decode image';

  @override
  String get saveToGallery => 'Save to gallery';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicySubTitle => 'View our data collection and usage policy';

  @override
  String get viewPrivacyPolicy => 'View Privacy Policy';

  @override
  String get openPrivacyPolicyOnline => 'Open Privacy Policy Online';

  @override
  String get privacyPolicyContent => 'Privacy Policy for Happy View\n\n1. No User Registration\n- Our app does not require user registration\n- No personal identifying information is collected\n\n2. Data Collection\n- Minimal, anonymized data collection via Firebase\n- Optional analytics and performance tracking\n- No mandatory user information required\n\n3. Third-Party Services\n- Unsplash API for images\n- Firebase for analytics\n- No personal data sold or shared\n\n4. User Consent\n- By using the app, you agree to optional data collection\n- You can disable analytics in device settings\n\n5. Contact\nFor privacy inquiries:developer@nawras.pro';

  @override
  String get mammals => 'Mammals';

  @override
  String get birds => 'Birds';

  @override
  String get reptiles => 'Reptiles';

  @override
  String get seaCreatures => 'Sea Creatures';

  @override
  String get insects => 'Insects';

  @override
  String get amphibians => 'Amphibians';

  @override
  String get wildlife => 'Wildlife';

  @override
  String get pets => 'Pets';

  @override
  String get farmAnimals => 'Farm Animals';

  @override
  String get babyAnimals => 'Baby Animals';

  @override
  String get trees => 'Trees';

  @override
  String get flower => 'Flowers';

  @override
  String get forests => 'Forests';

  @override
  String get mountains => 'Mountains';

  @override
  String get oceans => 'Oceans';

  @override
  String get snow => 'Snow';

  @override
  String get sunsets => 'Sunsets';

  @override
  String get waterfalls => 'Waterfalls';

  @override
  String get rivers => 'Rivers';

  @override
  String get lakes => 'Lakes';

  @override
  String get leaf => 'Leaf';

  @override
  String get planets => 'Planets';

  @override
  String get stars => 'Stars';

  @override
  String get galaxies => 'Galaxies';

  @override
  String get astronauts => 'Astronauts';

  @override
  String get buildings => 'Buildings';

  @override
  String get bridges => 'Bridges';

  @override
  String get skyscrapers => 'Skyscrapers';

  @override
  String get houses => 'Houses';

  @override
  String get furniture => 'Furniture';

  @override
  String get exteriors => 'Exteriors';

  @override
  String get landmarks => 'Landmarks';

  @override
  String get monuments => 'Monuments';

  @override
  String get towers => 'Towers';

  @override
  String get castles => 'Castles';

  @override
  String get fruits => 'Fruits';

  @override
  String get vegetables => 'Vegetables';

  @override
  String get desserts => 'Desserts';

  @override
  String get beverages => 'Beverages';

  @override
  String get fastFood => 'Fast Food';

  @override
  String get seafood => 'Seafood';

  @override
  String get meat => 'Meat';

  @override
  String get dairy => 'Dairy';

  @override
  String get bakedGoods => 'Baked Goods';

  @override
  String get healthyFood => 'Healthy Food';

  @override
  String get circles => 'Circles';

  @override
  String get squares => 'Squares';

  @override
  String get triangles => 'Triangles';

  @override
  String get rectangles => 'Rectangles';

  @override
  String get hexagons => 'Hexagons';

  @override
  String get hearts => 'Hearts';

  @override
  String get spirals => 'Spirals';

  @override
  String get diamonds => 'Diamonds';

  @override
  String get ovals => 'Ovals';

  @override
  String get cars => 'Cars';

  @override
  String get motorcycles => 'Motorcycles';

  @override
  String get trucks => 'Trucks';

  @override
  String get bicycles => 'Bicycles';

  @override
  String get buses => 'Buses';

  @override
  String get trains => 'Trains';

  @override
  String get airplanes => 'Airplanes';

  @override
  String get boats => 'Boats';

  @override
  String get helicopters => 'Helicopters';

  @override
  String get scooters => 'Scooters';

  @override
  String get excavators => 'Excavators';

  @override
  String get dinosaurs => 'Dinosaurs';

  @override
  String get serviceVehicles => 'Emergency Vehicles';

  @override
  String get subcategories => 'Subcategories';

  @override
  String get loadError => 'Failed to load data';

  @override
  String get loadErrorRetry => 'Retry';

  @override
  String get search => 'Search...';

  @override
  String get safeSearch => 'Please enter a safe search term.';

  @override
  String get safeSearchText => 'Please enter a safe search term.';

  @override
  String get translated => 'Translated: ';

  @override
  String get safeSearchEnabled => '🔒 Safe search is ON';

  @override
  String get photoBy => 'Photo by ';

  @override
  String get unknownPhotographer => 'Unknown Photographer';

  @override
  String get on => ' on ';
}
