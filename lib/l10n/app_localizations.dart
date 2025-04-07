import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Happy View'**
  String get appTitle;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Welcome message displayed on home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to my app'**
  String get welcome;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Personal greeting with name
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String greeting(String name);

  /// Number of items message
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// Current date message
  ///
  /// In en, this message translates to:
  /// **'Today is {date}'**
  String currentDate(DateTime date);

  /// Animals category name
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get category_animals;

  /// Nature category name
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get category_nature;

  /// Space category name
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get category_space;

  /// Food and drink category name
  ///
  /// In en, this message translates to:
  /// **'Food & Drink'**
  String get category_food_drink;

  /// Shapes category name
  ///
  /// In en, this message translates to:
  /// **'Shapes'**
  String get category_shapes;

  /// Vehicles category name
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get category_vehicles;

  /// Surprise me button
  ///
  /// In en, this message translates to:
  /// **'Surprise me! 🎉'**
  String get suprise;

  /// flowers category name
  ///
  /// In en, this message translates to:
  /// **'flowers'**
  String get flowers;

  /// Architecture category name
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get category_architecture;

  /// Suggestion message
  ///
  /// In en, this message translates to:
  /// **'Thank you for your suggestion!'**
  String get suggestion_message;

  /// suggestionTitle
  ///
  /// In en, this message translates to:
  /// **'Your Suggestion'**
  String get suggestionTitle;

  /// Suggestion placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your suggestion here...'**
  String get suggestion_placeholder;

  /// Suggestion validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a suggestion'**
  String get suggestionValidationEmpty;

  /// Suggestion validation length error message
  ///
  /// In en, this message translates to:
  /// **'Suggestion must be less than 10 characters'**
  String get suggestionValidationLength;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailLabel;

  /// Email hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email if you want a response'**
  String get emailHint;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get categoryLabel;

  /// Category hint
  ///
  /// In en, this message translates to:
  /// **'E.g., Feature Request, Bug Report, etc.'**
  String get categoryHint;

  /// Submit button
  ///
  /// In en, this message translates to:
  /// **'Send Suggestions'**
  String get submit;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Suggestion error message
  ///
  /// In en, this message translates to:
  /// **'Enter your suggestion...'**
  String get suggestion_error;

  /// Suggestion subtitle
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts with us'**
  String get suggestion_subtitle;

  /// Verification title
  ///
  /// In en, this message translates to:
  /// **'For parents only'**
  String get verification;

  /// Math question to verify human
  ///
  /// In en, this message translates to:
  /// **'What is {num1} + {num2}?'**
  String whatIsSum(Object num1, Object num2);

  /// Incorrect answer message
  ///
  /// In en, this message translates to:
  /// **'Incorrect answer. Try again.'**
  String get incorrect;

  /// Image index message
  ///
  /// In en, this message translates to:
  /// **'Image {index} of {total}'**
  String imageIndex(int index, int total);

  /// No description provided for @storagePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Storage permission denied'**
  String get storagePermissionDenied;

  /// No description provided for @imageSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Image saved to gallery!'**
  String get imageSavedToGallery;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @failedToDecodeImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to decode image'**
  String get failedToDecodeImage;

  /// No description provided for @saveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get saveToGallery;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubTitle.
  ///
  /// In en, this message translates to:
  /// **'View our data collection and usage policy'**
  String get privacyPolicySubTitle;

  /// No description provided for @viewPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'View Privacy Policy'**
  String get viewPrivacyPolicy;

  /// No description provided for @openPrivacyPolicyOnline.
  ///
  /// In en, this message translates to:
  /// **'Open Privacy Policy Online'**
  String get openPrivacyPolicyOnline;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy for Happy View\n\n1. No User Registration\n- Our app does not require user registration\n- No personal identifying information is collected\n\n2. Data Collection\n- Minimal, anonymized data collection via Firebase\n- Optional analytics and performance tracking\n- No mandatory user information required\n\n3. Third-Party Services\n- Unsplash API for images\n- Firebase for analytics\n- No personal data sold or shared\n\n4. User Consent\n- By using the app, you agree to optional data collection\n- You can disable analytics in device settings\n\n5. Contact\nFor privacy inquiries:developer@nawras.pro'**
  String get privacyPolicyContent;

  /// Mammals category name
  ///
  /// In en, this message translates to:
  /// **'Mammals'**
  String get mammals;

  /// Birds category name
  ///
  /// In en, this message translates to:
  /// **'Birds'**
  String get birds;

  /// Reptiles category name
  ///
  /// In en, this message translates to:
  /// **'Reptiles'**
  String get reptiles;

  /// Sea Creatures category name
  ///
  /// In en, this message translates to:
  /// **'Sea Creatures'**
  String get seaCreatures;

  /// Insects category name
  ///
  /// In en, this message translates to:
  /// **'Insects'**
  String get insects;

  /// Amphibians category name
  ///
  /// In en, this message translates to:
  /// **'Amphibians'**
  String get amphibians;

  /// Wildlife category name
  ///
  /// In en, this message translates to:
  /// **'Wildlife'**
  String get wildlife;

  /// Pets category name
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pets;

  /// Farm Animals category name
  ///
  /// In en, this message translates to:
  /// **'Farm Animals'**
  String get farmAnimals;

  /// Baby Animals category name
  ///
  /// In en, this message translates to:
  /// **'Baby Animals'**
  String get babyAnimals;

  /// Trees category name
  ///
  /// In en, this message translates to:
  /// **'Trees'**
  String get trees;

  /// Flowers category name
  ///
  /// In en, this message translates to:
  /// **'Flowers'**
  String get flower;

  /// Forests category name
  ///
  /// In en, this message translates to:
  /// **'Forests'**
  String get forests;

  /// Mountains category name
  ///
  /// In en, this message translates to:
  /// **'Mountains'**
  String get mountains;

  /// Oceans category name
  ///
  /// In en, this message translates to:
  /// **'Oceans'**
  String get oceans;

  /// Snow category name
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get snow;

  /// Sunsets category name
  ///
  /// In en, this message translates to:
  /// **'Sunsets'**
  String get sunsets;

  /// Waterfalls category name
  ///
  /// In en, this message translates to:
  /// **'Waterfalls'**
  String get waterfalls;

  /// Rivers category name
  ///
  /// In en, this message translates to:
  /// **'Rivers'**
  String get rivers;

  /// Lakes category name
  ///
  /// In en, this message translates to:
  /// **'Lakes'**
  String get lakes;

  /// Leaf category name
  ///
  /// In en, this message translates to:
  /// **'Leaf'**
  String get leaf;

  /// Planets category name
  ///
  /// In en, this message translates to:
  /// **'Planets'**
  String get planets;

  /// Stars category name
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get stars;

  /// Galaxies category name
  ///
  /// In en, this message translates to:
  /// **'Galaxies'**
  String get galaxies;

  /// Astronauts category name
  ///
  /// In en, this message translates to:
  /// **'Astronauts'**
  String get astronauts;

  /// Buildings category name
  ///
  /// In en, this message translates to:
  /// **'Buildings'**
  String get buildings;

  /// Bridges category name
  ///
  /// In en, this message translates to:
  /// **'Bridges'**
  String get bridges;

  /// Skyscrapers category name
  ///
  /// In en, this message translates to:
  /// **'Skyscrapers'**
  String get skyscrapers;

  /// Houses category name
  ///
  /// In en, this message translates to:
  /// **'Houses'**
  String get houses;

  /// Furniture category name
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get furniture;

  /// Exteriors category name
  ///
  /// In en, this message translates to:
  /// **'Exteriors'**
  String get exteriors;

  /// Landmarks category name
  ///
  /// In en, this message translates to:
  /// **'Landmarks'**
  String get landmarks;

  /// Monuments category name
  ///
  /// In en, this message translates to:
  /// **'Monuments'**
  String get monuments;

  /// Towers category name
  ///
  /// In en, this message translates to:
  /// **'Towers'**
  String get towers;

  /// Castles category name
  ///
  /// In en, this message translates to:
  /// **'Castles'**
  String get castles;

  /// Fruits category name
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get fruits;

  /// Vegetables category name
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// Desserts category name
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get desserts;

  /// Beverages category name
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get beverages;

  /// Fast Food category name
  ///
  /// In en, this message translates to:
  /// **'Fast Food'**
  String get fastFood;

  /// Seafood category name
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get seafood;

  /// Meat category name
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get meat;

  /// Dairy category name
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get dairy;

  /// Baked Goods category name
  ///
  /// In en, this message translates to:
  /// **'Baked Goods'**
  String get bakedGoods;

  /// Healthy Food category name
  ///
  /// In en, this message translates to:
  /// **'Healthy Food'**
  String get healthyFood;

  /// Circles category name
  ///
  /// In en, this message translates to:
  /// **'Circles'**
  String get circles;

  /// Squares category name
  ///
  /// In en, this message translates to:
  /// **'Squares'**
  String get squares;

  /// Triangles category name
  ///
  /// In en, this message translates to:
  /// **'Triangles'**
  String get triangles;

  /// Rectangles category name
  ///
  /// In en, this message translates to:
  /// **'Rectangles'**
  String get rectangles;

  /// Hexagons category name
  ///
  /// In en, this message translates to:
  /// **'Hexagons'**
  String get hexagons;

  /// Hearts category name
  ///
  /// In en, this message translates to:
  /// **'Hearts'**
  String get hearts;

  /// Spirals category name
  ///
  /// In en, this message translates to:
  /// **'Spirals'**
  String get spirals;

  /// Diamonds category name
  ///
  /// In en, this message translates to:
  /// **'Diamonds'**
  String get diamonds;

  /// Ovals category name
  ///
  /// In en, this message translates to:
  /// **'Ovals'**
  String get ovals;

  /// Cars category name
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get cars;

  /// Motorcycles category name
  ///
  /// In en, this message translates to:
  /// **'Motorcycles'**
  String get motorcycles;

  /// Trucks category name
  ///
  /// In en, this message translates to:
  /// **'Trucks'**
  String get trucks;

  /// Bicycles category name
  ///
  /// In en, this message translates to:
  /// **'Bicycles'**
  String get bicycles;

  /// Buses category name
  ///
  /// In en, this message translates to:
  /// **'Buses'**
  String get buses;

  /// Trains category name
  ///
  /// In en, this message translates to:
  /// **'Trains'**
  String get trains;

  /// Airplanes category name
  ///
  /// In en, this message translates to:
  /// **'Airplanes'**
  String get airplanes;

  /// Boats category name
  ///
  /// In en, this message translates to:
  /// **'Boats'**
  String get boats;

  /// Helicopters category name
  ///
  /// In en, this message translates to:
  /// **'Helicopters'**
  String get helicopters;

  /// Scooters category name
  ///
  /// In en, this message translates to:
  /// **'Scooters'**
  String get scooters;

  /// Excavators category name
  ///
  /// In en, this message translates to:
  /// **'Excavators'**
  String get excavators;

  /// Dinosaurs category name
  ///
  /// In en, this message translates to:
  /// **'Dinosaurs'**
  String get dinosaurs;

  /// Service Vehicles category name
  ///
  /// In en, this message translates to:
  /// **'Emergency Vehicles'**
  String get serviceVehicles;

  /// Subcategories title
  ///
  /// In en, this message translates to:
  /// **'Subcategories'**
  String get subcategories;

  /// Error message when data fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get loadError;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get loadErrorRetry;

  /// Search bar placeholder
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// Safe search error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a safe search term.'**
  String get safeSearch;

  /// Safe search text
  ///
  /// In en, this message translates to:
  /// **'Please enter a safe search term.'**
  String get safeSearchText;

  /// Translated label
  ///
  /// In en, this message translates to:
  /// **'Translated: '**
  String get translated;

  /// Safe search enabled message
  ///
  /// In en, this message translates to:
  /// **'🔒 Safe search is ON'**
  String get safeSearchEnabled;

  /// Photo by label
  ///
  /// In en, this message translates to:
  /// **'Photo by '**
  String get photoBy;

  /// Unknown photographer label
  ///
  /// In en, this message translates to:
  /// **'Unknown Photographer'**
  String get unknownPhotographer;

  /// On label
  ///
  /// In en, this message translates to:
  /// **' on '**
  String get on;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
