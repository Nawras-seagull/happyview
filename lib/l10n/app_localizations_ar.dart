// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'المتصفح السعيد';

  @override
  String get hello => 'مرحبا';

  @override
  String get welcome => 'مرحبا بك في تطبيقي';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String greeting(String name) {
    return 'مرحبا، $name';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر',
      many: '$count عنصر',
      few: '$count عناصر',
      two: 'عنصران',
      one: 'عنصر واحد',
      zero: 'لا توجد عناصر',
    );
    return '$_temp0';
  }

  @override
  String currentDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'اليوم هو $dateString';
  }

  @override
  String get category_animals => 'حيوانات';

  @override
  String get category_nature => 'طبيعة';

  @override
  String get category_space => 'فضاء';

  @override
  String get category_food_drink => 'طعام ومشروبات';

  @override
  String get category_shapes => 'أشكال';

  @override
  String get category_vehicles => 'مركبات';

  @override
  String get suprise => '🎉 فاجئني!';

  @override
  String get flowers => '🌸 ورود';

  @override
  String get category_architecture => 'هندسة معمارية';

  @override
  String get suggestion_message => 'شكراً لاقتراحاتك';

  @override
  String get suggestionTitle => 'اقتراحات';

  @override
  String get suggestion_placeholder => 'اكتب اقتراحك هنا';

  @override
  String get suggestionValidationEmpty => 'الرجاء إدخال اقتراح';

  @override
  String get suggestionValidationLength => 'الرجاء إدخال اقتراح لا يقل عن 10 أحرف';

  @override
  String get emailLabel => 'البريد الإلكتروني (اختياري)';

  @override
  String get emailHint => 'أدخل بريدك الإلكتروني اذا كنت ترغب في تلقي رد';

  @override
  String get categoryLabel => 'الفئة (اختياري)';

  @override
  String get categoryHint => 'مثال: الحيوانات، الطبيعة، الفضاء';

  @override
  String get submit => 'إرسال اقتراح';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get suggestion_error => 'اكتب اقتراحك';

  @override
  String get suggestion_subtitle => 'أرسل لنا اقتراحاتك واستفساراتك';

  @override
  String get verification => 'للوالدين فقط';

  @override
  String whatIsSum(Object num1, Object num2) {
    return ' ما هو ناتج$num1 + $num2؟';
  }

  @override
  String get incorrect => 'اجابة خاطئة';

  @override
  String imageIndex(int index, int total) {
    return 'صورة $index من $total';
  }

  @override
  String get storagePermissionDenied => 'تم رفض إذن الوصول إلى التخزين';

  @override
  String get imageSavedToGallery => 'تم حفظ الصورة في المعرض!';

  @override
  String get error => 'خطأ';

  @override
  String get failedToDecodeImage => 'فشل في فك تشفير الصورة';

  @override
  String get saveToGallery => 'حفظ في المعرض';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get privacyPolicySubTitle => 'اعرض سياسة خصوصيتنا ومشاركة البيانات';

  @override
  String get viewPrivacyPolicy => 'عرض سياسة الخصوصية';

  @override
  String get openPrivacyPolicyOnline => 'فتح سياسة الخصوصية عبر الإنترنت';

  @override
  String get privacyPolicyContent => 'سياسة الخصوصية لتطبيق Happy View\n\n1. لا يوجد تسجيل مستخدم\n- تطبيقنا لا يتطلب تسجيل المستخدم\n- لا يتم جمع أي معلومات تعريف شخصية\n\n2. جمع البيانات\n- جمع بيانات مجهولة الهوية عبر Firebase\n- تتبع الأداء والتحليلات اختياري\n- لا توجد معلومات مستخدم إلزامية مطلوبة\n\n3. خدمات الطرف الثالث\n- واجهة برمجة التطبيقات Unsplash للصور\n- Firebase للتحليلات\n- لا يتم بيع أو مشاركة البيانات الشخصية\n\n4. موافقة المستخدم\n- باستخدام التطبيق، فإنك توافق على جمع البيانات الاختياري\n- يمكنك تعطيل التحليلات في إعدادات الجهاز\n\n5. الاتصال\nللاستفسارات المتعلقة بالخصوصية: developer@nawras.pro';

  @override
  String get mammals => 'ثدييات';

  @override
  String get birds => 'طيور';

  @override
  String get reptiles => 'زواحف';

  @override
  String get seaCreatures => 'كائنات بحرية';

  @override
  String get insects => 'حشرات';

  @override
  String get amphibians => 'برمائيات';

  @override
  String get wildlife => 'حياة برية';

  @override
  String get pets => 'حيوانات أليفة';

  @override
  String get farmAnimals => 'حيوانات المزرعة';

  @override
  String get babyAnimals => 'حيوانات صغيرة';

  @override
  String get trees => 'أشجار';

  @override
  String get flower => 'زهور';

  @override
  String get forests => 'غابات';

  @override
  String get mountains => 'جبال';

  @override
  String get oceans => 'محيطات';

  @override
  String get snow => 'ثلوج';

  @override
  String get sunsets => 'غروب الشمس';

  @override
  String get waterfalls => 'شلالات';

  @override
  String get rivers => 'أنهار';

  @override
  String get lakes => 'بحيرات';

  @override
  String get leaf => 'ورقة شجر';

  @override
  String get planets => 'كواكب';

  @override
  String get stars => 'نجوم';

  @override
  String get galaxies => 'مجرات';

  @override
  String get astronauts => 'رواد فضاء';

  @override
  String get buildings => 'مباني';

  @override
  String get bridges => 'جسور';

  @override
  String get skyscrapers => 'ناطحات سحاب';

  @override
  String get houses => 'منازل';

  @override
  String get furniture => 'أثاث';

  @override
  String get exteriors => 'الخارجيات';

  @override
  String get landmarks => 'معالم';

  @override
  String get monuments => 'آثار';

  @override
  String get towers => 'أبراج';

  @override
  String get castles => 'قلاع';

  @override
  String get fruits => 'فواكه';

  @override
  String get vegetables => 'خضروات';

  @override
  String get desserts => 'حلويات';

  @override
  String get beverages => 'مشروبات';

  @override
  String get fastFood => 'وجبات سريعة';

  @override
  String get seafood => 'مأكولات بحرية';

  @override
  String get meat => 'لحوم';

  @override
  String get dairy => 'ألبان';

  @override
  String get bakedGoods => 'مخبوزات';

  @override
  String get healthyFood => 'طعام صحي';

  @override
  String get circles => 'دوائر';

  @override
  String get squares => 'مربعات';

  @override
  String get triangles => 'مثلثات';

  @override
  String get rectangles => 'مستطيلات';

  @override
  String get hexagons => 'سداسيات';

  @override
  String get hearts => 'قلوب';

  @override
  String get spirals => 'لوالب';

  @override
  String get diamonds => 'ألماسات';

  @override
  String get ovals => 'أشكال بيضاوية';

  @override
  String get cars => 'سيارات';

  @override
  String get motorcycles => 'دراجات نارية';

  @override
  String get trucks => 'شاحنات';

  @override
  String get bicycles => 'دراجات';

  @override
  String get buses => 'حافلات';

  @override
  String get trains => 'قطارات';

  @override
  String get airplanes => 'طائرات';

  @override
  String get boats => 'قوارب';

  @override
  String get helicopters => 'مروحيات';

  @override
  String get scooters => 'دراجات سكوتر';

  @override
  String get excavators => 'حفارات';

  @override
  String get dinosaurs => 'ديناصورات';

  @override
  String get serviceVehicles => 'مركبات الطواريء ';

  @override
  String get subcategories => 'فئات فرعية';

  @override
  String get loadError => 'فشل تحميل البيانات';

  @override
  String get loadErrorRetry => 'فشل تحميل البيانات، اضغط لإعادة المحاولة';

  @override
  String get search => 'بحث';

  @override
  String get searchResults => 'نتائج البحث';

  @override
  String get safeSearch => 'البحث الآمن';

  @override
  String get safeSearchText => 'الرجاء ادخال كلمات آمنة';

  @override
  String get translated => 'ترجمة ';

  @override
  String get safeSearchEnabled => '🔒 تم تفعيل البحث الآمن';

  @override
  String get photoBy => 'صورة بواسطة';

  @override
  String get unknownPhotographer => 'مصور غير معروف';

  @override
  String get on => 'في ';

  @override
  String get download => 'تحميل';

  @override
  String get downloadStarted => 'بدأ التحميل';

  @override
  String get downloadFailed => 'فشل التحميل';

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get browseImages => 'Browse Images';

  @override
  String get clearFavorites => 'Clear Favorites';

  @override
  String get clearFavoritesConfirmation => 'Are you sure you want to remove all favorites?';

  @override
  String get favoritesCleared => 'All favorites have been removed';

  @override
  String get clear => 'Clear';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get setAsWallpaper => 'Set as Wallpaper';

  @override
  String get chooseWallpaperType => 'Where would you like to set this wallpaper?';

  @override
  String get homeScreen => 'Home Screen';

  @override
  String get lockScreen => 'Lock Screen';

  @override
  String get bothScreens => 'Both Screens';

  @override
  String get wallpaperSetSuccessfully => 'Wallpaper set successfully!';

  @override
  String get failedToSetWallpaper => 'Failed to set wallpaper';
}
