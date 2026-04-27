// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Mutlu Görünüm';

  @override
  String get hello => 'Merhaba';

  @override
  String get welcome => 'Uygulamama hoş geldiniz';

  @override
  String get changeLanguage => 'Dil Değiştir';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get profileTitle => 'Profil';

  @override
  String get homeTitle => 'Ana Sayfa';

  @override
  String greeting(String name) {
    return 'Merhaba, $name';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe',
      one: '1 öğe',
      zero: 'Öğe yok',
    );
    return '$_temp0';
  }

  @override
  String currentDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Bugün $dateString';
  }

  @override
  String get category_animals => 'Hayvanlar';

  @override
  String get category_nature => 'Doğa';

  @override
  String get category_space => 'Uzay';

  @override
  String get category_food_drink => 'Yiyecek ve İçecek';

  @override
  String get category_shapes => 'Şekiller';

  @override
  String get category_vehicles => 'Taşıtlar';

  @override
  String get suprise => '🎉 Beni şaşırt!';

  @override
  String get flowers => '🌸 Çiçekler';

  @override
  String get category_architecture => 'Mimarlık';

  @override
  String get suggestion_message => 'Önerileriniz için teşekkür ederiz';

  @override
  String get suggestionTitle => 'Öneriler';

  @override
  String get suggestion_placeholder => 'Önerinizi buraya yazın';

  @override
  String get suggestionValidationEmpty => 'Lütfen bir öneri yazın';

  @override
  String get suggestionValidationLength =>
      'Öneriniz en az 10 karakter olmalıdır';

  @override
  String get emailLabel => 'E-posta adresiniz (isteğe bağlı)';

  @override
  String get emailHint =>
      'Cevabınızı almak için e-posta adresinizi bırakabilirsiniz';

  @override
  String get categoryLabel => 'Kategori seçin (isteğe bağlı)';

  @override
  String get categoryHint =>
      'Önerinizin hangi kategoriye ait olduğunu belirtin';

  @override
  String get submit => 'öneri gönder';

  @override
  String get cancel => 'İptal';

  @override
  String get confirm => 'Onayla';

  @override
  String get close => 'Kapat';

  @override
  String get suggestion_error => 'Lütfen bir öneri yazın';

  @override
  String get suggestion_subtitle =>
      'Bize önerilerinizi ve sorularınızı gönderin';

  @override
  String get verification => 'Sadece ebeveynler için';

  @override
  String whatIsSum(Object num1, Object num2) {
    return 'Toplamı ne kadar $num1 + $num2?';
  }

  @override
  String get incorrect => 'Yanlış cevap';

  @override
  String imageIndex(int index, int total) {
    return 'Resim $index / $total';
  }

  @override
  String get storagePermissionDenied => 'Depolama izni reddedildi';

  @override
  String get imageSavedToGallery => 'Resim galeriye kaydedildi!';

  @override
  String get error => 'Hata';

  @override
  String get failedToDecodeImage => 'Resim çözümlenemedi';

  @override
  String get saveToGallery => 'Galeriye Kaydet';

  @override
  String get privacyPolicyTitle => 'Gizlilik Politikası';

  @override
  String get privacyPolicySubTitle =>
      'Gizlilik politikamızı görüntüleyin ve veri paylaşımı';

  @override
  String get viewPrivacyPolicy => 'Gizlilik Politikasını Görüntüle';

  @override
  String get openPrivacyPolicyOnline => 'Gizlilik Politikasını Çevrimiçi Aç';

  @override
  String get privacyPolicyContent =>
      'Happy View için Gizlilik Politikası\n\n1. Kullanıcı Kaydı Yok\n- Uygulamamız kullanıcı kaydı gerektirmez\n- Kişisel tanımlayıcı bilgi toplanmaz\n\n2. Veri Toplama\n- Firebase aracılığıyla minimum, anonim veri toplama\n- İsteğe bağlı analiz ve performans takibi\n- Zorunlu kullanıcı bilgisi gerekmez\n\n3. Üçüncü Taraf Hizmetler\n- Görseller için Pixabay API\n- Analiz için Firebase\n- Kişisel veriler satılmaz veya paylaşılmaz\n\n4. Kullanıcı Onayı\n- Uygulamayı kullanarak, isteğe bağlı veri toplamayı kabul etmiş olursunuz\n- Cihaz ayarlarından analizleri devre dışı bırakabilirsiniz\n\n5. İletişim\nGizlilik ile ilgili sorular için: developer@nawras.pro';

  @override
  String get mammals => 'Memeliler';

  @override
  String get birds => 'Kuşlar';

  @override
  String get reptiles => 'Sürüngenler';

  @override
  String get seaCreatures => 'Deniz canlıları';

  @override
  String get insects => 'Böcekler';

  @override
  String get amphibians => 'Amfibi hayvanlar';

  @override
  String get wildlife => 'Yaban hayatı';

  @override
  String get pets => 'Evcil hayvanlar';

  @override
  String get farmAnimals => 'Çiftlik hayvanları';

  @override
  String get babyAnimals => 'Bebek hayvanlar';

  @override
  String get trees => 'Ağaçlar';

  @override
  String get flower => 'Çiçekler';

  @override
  String get forests => 'Ormanlar';

  @override
  String get mountains => 'Dağlar';

  @override
  String get oceans => 'Okyanuslar';

  @override
  String get snow => 'Kar';

  @override
  String get sunsets => 'Gün batımları';

  @override
  String get waterfalls => 'Şelaleler';

  @override
  String get rivers => 'Nehirler';

  @override
  String get lakes => 'Göller';

  @override
  String get leaf => 'Yaprak';

  @override
  String get planets => 'Gezegenler';

  @override
  String get stars => 'Yıldızlar';

  @override
  String get galaxies => 'Galaksiler';

  @override
  String get astronauts => 'Astronotlar';

  @override
  String get buildings => 'Binalar';

  @override
  String get bridges => 'Köprüler';

  @override
  String get skyscrapers => 'Gökdelenler';

  @override
  String get houses => 'Evler';

  @override
  String get furniture => 'Mobilyalar';

  @override
  String get exteriors => 'Dış mekanlar';

  @override
  String get landmarks => 'Simgeler';

  @override
  String get monuments => 'Anıtlar';

  @override
  String get towers => 'Kuleler';

  @override
  String get castles => 'Kaleler';

  @override
  String get fruits => 'Meyveler';

  @override
  String get vegetables => 'Sebzeler';

  @override
  String get desserts => 'Tatlılar';

  @override
  String get beverages => 'İçecekler';

  @override
  String get fastFood => 'Hızlı yiyecekler';

  @override
  String get seafood => 'Deniz ürünleri';

  @override
  String get meat => 'Et';

  @override
  String get dairy => 'Süt ürünleri';

  @override
  String get bakedGoods => 'Fırın ürünleri';

  @override
  String get healthyFood => 'Sağlıklı yiyecekler';

  @override
  String get circles => 'Daireler';

  @override
  String get squares => 'Kareler';

  @override
  String get triangles => 'Üçgenler';

  @override
  String get rectangles => 'Dikdörtgenler';

  @override
  String get hexagons => 'Altıgenler';

  @override
  String get hearts => 'Kalpler';

  @override
  String get spirals => 'Sarmallar';

  @override
  String get diamonds => 'Elmaslar';

  @override
  String get ovals => 'Oval şekiller';

  @override
  String get cars => 'Arabalar';

  @override
  String get motorcycles => 'Motosikletler';

  @override
  String get trucks => 'Kamyonlar';

  @override
  String get bicycles => 'Bisikletler';

  @override
  String get buses => 'Otobüsler';

  @override
  String get trains => 'Trenler';

  @override
  String get airplanes => 'Uçaklar';

  @override
  String get boats => 'Tekneler';

  @override
  String get helicopters => 'Helikopterler';

  @override
  String get scooters => 'Scooterlar';

  @override
  String get excavators => 'Ekskavatörler';

  @override
  String get dinosaurs => 'Dinozorlar';

  @override
  String get serviceVehicles => 'Acil araçları';

  @override
  String get subcategories => 'Alt kategoriler';

  @override
  String get loadError => 'Yükleme hatası';

  @override
  String get loadErrorRetry => 'Yeniden dene';

  @override
  String get search => 'Ara';

  @override
  String get searchResults => 'Arama sonuçları';

  @override
  String get safeSearch => 'Güvenli arama';

  @override
  String get safeSearchText => 'lutfen güvenli arama seçeneğini açın';

  @override
  String get translated => 'Çevirildi';

  @override
  String get safeSearchEnabled => 'Güvenli arama etkinleştirildi 🔒';

  @override
  String get photoBy => 'Fotoğraf: ';

  @override
  String get unknownPhotographer => 'Bilinmeyen fotoğrafçı';

  @override
  String get on => 'üzerinde bulundu';

  @override
  String get download => 'İndir';

  @override
  String get downloadStarted => 'İndirme başladı';

  @override
  String get downloadFailed => 'İndirme başarısız oldu';

  @override
  String get favorites => 'Favoriler';

  @override
  String get noFavorites => 'Favori yok';

  @override
  String get browseImages => 'Resimleri gez';

  @override
  String get clearFavorites => 'Favorileri temizle';

  @override
  String get clearFavoritesConfirmation =>
      'Favorileri temizlemek istediğinize emin misiniz?';

  @override
  String get clear => 'Temizle';

  @override
  String get addToFavorites => 'Favorilere ekle';

  @override
  String get setAsWallpaper => 'Duvar kağıdı olarak ayarla';

  @override
  String get chooseWallpaperType => 'Duvar kağıdı türünü seçin';

  @override
  String get homeScreen => 'Ana ekran';

  @override
  String get lockScreen => 'Kilitleme ekranı';

  @override
  String get bothScreens => 'Her iki ekran';

  @override
  String get wallpaperSetSuccessfully => 'Duvar kağıdı başarıyla ayarlandı';

  @override
  String get failedToSetWallpaper => 'Duvar kağıdı ayarlanamadı';

  @override
  String get noImagesFound => 'Hiçbir resim bulunamadı';

  @override
  String get endOfResults => 'Sonuçların sonu';

  @override
  String get exploreMore => 'Daha fazla keşfet';
}
