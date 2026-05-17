import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Uygulama adı
  ///
  /// In tr, this message translates to:
  /// **'Atıksız Mutfak'**
  String get appName;

  /// Alt navigasyon - Tarifler sekmesi
  ///
  /// In tr, this message translates to:
  /// **'Tarifler'**
  String get navRecipes;

  /// Alt navigasyon - Oluştur sekmesi
  ///
  /// In tr, this message translates to:
  /// **'Oluştur'**
  String get navCreate;

  /// Alt navigasyon - Sohbet sekmesi
  ///
  /// In tr, this message translates to:
  /// **'EcoChef'**
  String get navEcoChef;

  /// Alt navigasyon - Puan sekmesi
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get navPoints;

  /// Ana sayfa başlığı
  ///
  /// In tr, this message translates to:
  /// **'Atıksız Mutfak'**
  String get homeTitle;

  /// Tarif listesi boşken gösterilen mesaj
  ///
  /// In tr, this message translates to:
  /// **'Henüz tarif yok. Malzeme ekleyip bir tarif oluşturun!'**
  String get homeEmpty;

  /// Tarif oluşturma butonu
  ///
  /// In tr, this message translates to:
  /// **'Tarif Oluştur'**
  String get homeCreateRecipe;

  /// Tarifler yüklenirken gösterilen metin
  ///
  /// In tr, this message translates to:
  /// **'Tarifler yükleniyor…'**
  String get homeLoading;

  /// Tarif yükleme hatası
  ///
  /// In tr, this message translates to:
  /// **'Tarifler yüklenemedi.\n{error}'**
  String homeError(String error);

  /// Yeniden deneme butonu
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get homeRetry;

  /// Filtre temizleme chip'i
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get homeClearFilter;

  /// Arama çubuğu ipucu metni
  ///
  /// In tr, this message translates to:
  /// **'Tariflerde arayın'**
  String get homeSearchHint;

  /// Karttaki eşleşen malzeme sayısı
  ///
  /// In tr, this message translates to:
  /// **'{count}/{total} malzeme elinizde'**
  String recipeCardMatchCount(int count, int total);

  /// Karttaki malzeme/adım özeti
  ///
  /// In tr, this message translates to:
  /// **'{ingredientCount} malzeme · {stepCount} adım'**
  String recipeCardStatSummary(int ingredientCount, int stepCount);

  /// Malzemeler bölüm başlığı
  ///
  /// In tr, this message translates to:
  /// **'Malzemeler'**
  String get recipeCardIngredients;

  /// Tarif detay butonu
  ///
  /// In tr, this message translates to:
  /// **'Tarifi İncele'**
  String get recipeCardInspect;

  /// Malzeme sayısı etiketi
  ///
  /// In tr, this message translates to:
  /// **'{count} adet'**
  String recipeDetailIngredientCount(int count);

  /// Adım sayısı etiketi
  ///
  /// In tr, this message translates to:
  /// **'{count} adım'**
  String recipeDetailStepCount(int count);

  /// Tekil malzeme etiketi
  ///
  /// In tr, this message translates to:
  /// **'Malzeme'**
  String get recipeDetailIngredient;

  /// Tekil adım etiketi
  ///
  /// In tr, this message translates to:
  /// **'Adım'**
  String get recipeDetailStep;

  /// Malzemeler bölüm başlığı
  ///
  /// In tr, this message translates to:
  /// **'Malzemeler'**
  String get recipeDetailIngredients;

  /// Yapılış bölüm başlığı
  ///
  /// In tr, this message translates to:
  /// **'Yapılış'**
  String get recipeDetailInstructions;

  /// Tarif kaydetme butonu
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get recipeDetailSave;

  /// Tarif kaydedildi bildirimi
  ///
  /// In tr, this message translates to:
  /// **'Tarif kaydedildi!'**
  String get recipeDetailSaved;

  /// Kapat butonu
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get recipeDetailClose;

  /// Tarif silme butonu / diyalog başlığı
  ///
  /// In tr, this message translates to:
  /// **'Tarifi sil'**
  String get recipeDetailDelete;

  /// Silme onay mesajı
  ///
  /// In tr, this message translates to:
  /// **'Bu tarifi kaydettiğiniz listeden silmek istediğinize emin misiniz?'**
  String get recipeDetailDeleteConfirm;

  /// İptal butonu
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get recipeDetailCancel;

  /// Sil butonu
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get recipeDetailDeleteAction;

  /// Fotoğraf ekle butonu
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf ekle'**
  String get recipeDetailAddPhoto;

  /// Galeri seçeneği
  ///
  /// In tr, this message translates to:
  /// **'Galeriden seç'**
  String get recipeDetailGallery;

  /// Kamera seçeneği
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf çek'**
  String get recipeDetailCamera;

  /// Filtre sayfası başlığı
  ///
  /// In tr, this message translates to:
  /// **'Malzeme Filtresi'**
  String get filterTitle;

  /// Seçili malzeme sayısı
  ///
  /// In tr, this message translates to:
  /// **'{count} seçili'**
  String filterSelected(int count);

  /// Filtre arama ipucu
  ///
  /// In tr, this message translates to:
  /// **'Malzeme ara...'**
  String get filterSearchHint;

  /// Seçili malzemeler bölümü
  ///
  /// In tr, this message translates to:
  /// **'Seçili malzemeler'**
  String get filterSelectedSection;

  /// Tüm malzemeler bölümü
  ///
  /// In tr, this message translates to:
  /// **'Tüm malzemeler'**
  String get filterAllSection;

  /// Filtre sonuç bulunamadı
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı.'**
  String get filterNoResults;

  /// Filtre temizleme butonu
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get filterClear;

  /// Filtre uygulama butonu
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get filterApply;

  /// Seçimli uygulama butonu
  ///
  /// In tr, this message translates to:
  /// **'Uygula ({count})'**
  String filterApplyWithCount(int count);

  /// Tarif oluşturma sayfası başlığı
  ///
  /// In tr, this message translates to:
  /// **'Elinizdeki malzemeleri ekleyin'**
  String get recipeGeneratorHeading;

  /// Kullanım talimatı
  ///
  /// In tr, this message translates to:
  /// **'En az bir malzeme ekleyin, ardından Tarif Oluştur\'a dokunun.'**
  String get recipeGeneratorInstruction;

  /// Malzeme giriş ipucu
  ///
  /// In tr, this message translates to:
  /// **'örn. domates, fesleğen'**
  String get recipeGeneratorInputHint;

  /// Son eklenen malzemeler başlığı
  ///
  /// In tr, this message translates to:
  /// **'Son eklenenler'**
  String get recipeGeneratorRecent;

  /// Mutfak stili seçimi başlığı
  ///
  /// In tr, this message translates to:
  /// **'Mutfak (isteğe bağlı)'**
  String get recipeGeneratorCuisine;

  /// Mutfak seçilmedi varsayılanı
  ///
  /// In tr, this message translates to:
  /// **'Fark etmez'**
  String get recipeGeneratorNoCuisine;

  /// Oluştur butonu
  ///
  /// In tr, this message translates to:
  /// **'Tarif Oluştur'**
  String get recipeGeneratorCreate;

  /// Kaydedilen tarifler başlığı
  ///
  /// In tr, this message translates to:
  /// **'Kaydettiğim Tarifler'**
  String get recipeGeneratorSaved;

  /// Tümünü gör bağlantısı
  ///
  /// In tr, this message translates to:
  /// **'Tümünü gör'**
  String get recipeGeneratorSeeAll;

  /// Sayılı tümünü gör bağlantısı
  ///
  /// In tr, this message translates to:
  /// **'Tümünü gör ({count})'**
  String recipeGeneratorSeeAllCount(int count);

  /// Tarif sayısı etiketi
  ///
  /// In tr, this message translates to:
  /// **'{count} tarif'**
  String recipeGeneratorCount(int count);

  /// En az malzeme uyarısı
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tarif oluşturmadan önce en az bir malzeme ekleyin.'**
  String get recipeGeneratorMinIngredients;

  /// Yükleniyor metni
  ///
  /// In tr, this message translates to:
  /// **'EcoChef pişiriyor'**
  String get chefLoading;

  /// Günlük mesaj limiti uyarısı
  ///
  /// In tr, this message translates to:
  /// **'Bugünlük 20 mesaj hakkın doldu! Detaylı tarifler için yarın tekrar gel.'**
  String get chatDailyLimit;

  /// Sohbet giriş ipucu
  ///
  /// In tr, this message translates to:
  /// **'EcoChef\'e yazın...'**
  String get chatInputHint;

  /// Sohbet temizleme menü öğesi
  ///
  /// In tr, this message translates to:
  /// **'Sohbeti Temizle'**
  String get chatClear;

  /// Geri butonu tooltip
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get chatBack;

  /// Bağlantı hatası mesajı
  ///
  /// In tr, this message translates to:
  /// **'Sunucuya ulaşılamıyor. İnternet bağlantınızı kontrol edip tekrar deneyin.'**
  String get chatConnectionError;

  /// Zaman aşımı hatası
  ///
  /// In tr, this message translates to:
  /// **'Sunucu yanıt vermekte gecikti. Birkaç saniye sonra tekrar deneyin.'**
  String get chatTimeoutError;

  /// Kimlik doğrulama hatası
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama hatası. API anahtarı eksik veya geçersiz görünüyor.'**
  String get chatAuthError;

  /// API hata mesajı
  ///
  /// In tr, this message translates to:
  /// **'Servis bir hata döndürdü (kod: {code}).'**
  String chatApiError(String code);

  /// Genel hata mesajı
  ///
  /// In tr, this message translates to:
  /// **'Beklenmedik bir sorun oldu. Lütfen tekrar deneyin.'**
  String get chatGenericError;

  /// Sohbet başlatma butonu
  ///
  /// In tr, this message translates to:
  /// **'Sohbete Başla'**
  String get chatStartButton;

  /// Karşılama alt başlığı
  ///
  /// In tr, this message translates to:
  /// **'Atıksız mutfak yardımcınız'**
  String get chatWelcomeSubtitle;

  /// Karşılama açıklaması
  ///
  /// In tr, this message translates to:
  /// **'Tarif önerileri, gıda israfını azaltma ipuçları ve sürdürülebilir mutfak pratikleri hakkında benimle sohbet edebilirsiniz! 🌿'**
  String get chatWelcomeDescription;

  /// Günlük limit bilgisi
  ///
  /// In tr, this message translates to:
  /// **'Günlük 20 mesaj hakkınız bulunmaktadır'**
  String get chatDailyLimitInfo;

  /// Öneri bölümü başlığı
  ///
  /// In tr, this message translates to:
  /// **'Ya da direkt sorun'**
  String get chatOrAskDirectly;

  /// Boş sohbet metni
  ///
  /// In tr, this message translates to:
  /// **'Size nasıl yardımcı olabilirim?'**
  String get chatEmptyPrompt;

  /// Boş sohbet talimatı
  ///
  /// In tr, this message translates to:
  /// **'Aşağıdan mesajınızı yazabilirsiniz'**
  String get chatEmptyInstruction;

  /// Boş mesaj gönderilince yanıt
  ///
  /// In tr, this message translates to:
  /// **'Atıksız mutfak veya ipuçları hakkında ne olursa olsun sorabilirsiniz!'**
  String get chatEmptyResponse;

  /// Oluşturulan tarif sheet başlığı
  ///
  /// In tr, this message translates to:
  /// **'Tarifiniz'**
  String get generatorResultSheetTitle;

  /// Hata sheet başlığı
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get generatorResultSheetError;

  /// Kayıtlı tarifler sheet başlığı
  ///
  /// In tr, this message translates to:
  /// **'Kaydettiğim Tarifler'**
  String get savedRecipesTitle;

  /// Kayıtlı tarif yok mesajı
  ///
  /// In tr, this message translates to:
  /// **'Henüz kaydedilmiş tarif yok.'**
  String get savedRecipesEmpty;

  /// Yükleme hatası
  ///
  /// In tr, this message translates to:
  /// **'Tarifler yüklenirken hata oluştu.'**
  String get savedRecipesError;

  /// Görev adı - dolap paylaş
  ///
  /// In tr, this message translates to:
  /// **'Dolabını paylaş'**
  String get pointsMissionFridge;

  /// Görev açıklaması
  ///
  /// In tr, this message translates to:
  /// **'Buzdolabı veya kiler fotoğrafı yükle, sıfır atık alışkanlığına puan kazan.'**
  String get pointsMissionFridgeDesc;

  /// Görev adı - yemek anı
  ///
  /// In tr, this message translates to:
  /// **'Yemek anını paylaş'**
  String get pointsMissionCooking;

  /// Görev açıklaması
  ///
  /// In tr, this message translates to:
  /// **'Malzemelerinle yemek yaparken çektiğin fotoğrafı gönder.'**
  String get pointsMissionCookingDesc;

  /// Görev adı - artık değerlendirme
  ///
  /// In tr, this message translates to:
  /// **'Artıklardan ne yaptın?'**
  String get pointsMissionLeftovers;

  /// Görev açıklaması
  ///
  /// In tr, this message translates to:
  /// **'Kalan malzemelerden yaptığın tarifi veya değerlendirmeyi anlat.'**
  String get pointsMissionLeftoversDesc;

  /// Kategori etiketi
  ///
  /// In tr, this message translates to:
  /// **'Dolap'**
  String get pointsCategoryFridge;

  /// Kategori etiketi
  ///
  /// In tr, this message translates to:
  /// **'Yemek Anı'**
  String get pointsCategoryCooking;

  /// Kategori etiketi
  ///
  /// In tr, this message translates to:
  /// **'Artık Değerlendirme'**
  String get pointsCategoryLeftovers;

  /// Kategori etiketi
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get pointsCategoryOther;

  /// En yüksek seviye adı
  ///
  /// In tr, this message translates to:
  /// **'Efsane+'**
  String get pointsLevelLegend;

  /// Seviye adı
  ///
  /// In tr, this message translates to:
  /// **'Efsane'**
  String get pointsLevelEfsane;

  /// Seviye adı
  ///
  /// In tr, this message translates to:
  /// **'Usta'**
  String get pointsLevelUsta;

  /// Seviye adı
  ///
  /// In tr, this message translates to:
  /// **'Meraklı'**
  String get pointsLevelMerakli;

  /// Seviye adı
  ///
  /// In tr, this message translates to:
  /// **'Çaylak'**
  String get pointsLevelCaylak;

  /// Nickname diyalog başlığı
  ///
  /// In tr, this message translates to:
  /// **'Takma Adın Nedir?'**
  String get pointsNicknameDialogTitle;

  /// Nickname diyalog alt metni
  ///
  /// In tr, this message translates to:
  /// **'Gönderilerinin ve sıralamadaki görünen adını belirle.'**
  String get pointsNicknameDialogSubtitle;

  /// Nickname giriş ipucu
  ///
  /// In tr, this message translates to:
  /// **'Örn. Atıksız Şef'**
  String get pointsNicknameHint;

  /// Boş nickname uyarısı
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir takma ad girin'**
  String get pointsNicknameValidationEmpty;

  /// Leaderboard izin etiketi
  ///
  /// In tr, this message translates to:
  /// **'Sıralamada (leaderboard) takma adımın görüntülenmesine izin veriyorum.'**
  String get pointsLeaderboardOptIn;

  /// KVKK açıklaması
  ///
  /// In tr, this message translates to:
  /// **'KVKK kapsamında bu bilgi yalnızca uygulama içi sıralamada gösterilir, üçüncü taraflarla paylaşılmaz.'**
  String get pointsPrivacyDisclaimer;

  /// Kaydet butonu
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get pointsSave;

  /// Fotoğraf ekle diyalog başlığı
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Ekle'**
  String get pointsAddPhoto;

  /// Fotoğraf kaynağı seçimi
  ///
  /// In tr, this message translates to:
  /// **'Gönderin için fotoğraf kaynağını seç'**
  String get pointsPhotoSource;

  /// Kamera seçeneği
  ///
  /// In tr, this message translates to:
  /// **'Kameradan Çek'**
  String get pointsCamera;

  /// Galeri seçeneği
  ///
  /// In tr, this message translates to:
  /// **'Galeriden Seç'**
  String get pointsGallery;

  /// Varsayılan nickname
  ///
  /// In tr, this message translates to:
  /// **'Anonim'**
  String get pointsAnonymous;

  /// Gönderi gönderildi bildirimi
  ///
  /// In tr, this message translates to:
  /// **'⏳ {category} gönderin incelemeye gönderildi!'**
  String pointsPostSent(String category);

  /// Seviye atlama başlığı
  ///
  /// In tr, this message translates to:
  /// **'Tebrikler! 🎉'**
  String get pointsLevelUpTitle;

  /// Seviye atlama açıklaması
  ///
  /// In tr, this message translates to:
  /// **'Gönderin admin tarafından onaylandı ve kazandığın yeni puanlar hesabına eklendi. Sıfır atık yolculuğunda ilham vermeye devam et!'**
  String get pointsLevelUpDesc;

  /// Devam et butonu
  ///
  /// In tr, this message translates to:
  /// **'Harika! Devam Et'**
  String get pointsKeepGoing;

  /// Paylaşım sheet başlığı
  ///
  /// In tr, this message translates to:
  /// **'Ne paylaşmak istersin?'**
  String get pointsShareTitle;

  /// Paylaşım sheet alt metni
  ///
  /// In tr, this message translates to:
  /// **'Bir kategori seç ve fotoğraf ekle'**
  String get pointsShareSubtitle;

  /// Kategori kartı alt metni
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf çek veya galeriden seç'**
  String get pointsShareHint;

  /// Leaderboard başlığı
  ///
  /// In tr, this message translates to:
  /// **'Sıralama'**
  String get pointsLeaderboardTitle;

  /// Seviye tamamlama metni
  ///
  /// In tr, this message translates to:
  /// **'Seviye tamamlandı!'**
  String get pointsLevelComplete;

  /// Sonraki seviye bilgisi
  ///
  /// In tr, this message translates to:
  /// **'{emoji} {level} seviyesine {remaining} puan kaldı'**
  String pointsNextLevel(String emoji, String level, int remaining);

  /// Maksimum seviye mesajı
  ///
  /// In tr, this message translates to:
  /// **'🏆 En yüksek seviyedesin!'**
  String get pointsMaxLevel;

  /// Gün sayısı etiketi
  ///
  /// In tr, this message translates to:
  /// **'{days} gün'**
  String pointsStreak(int days);

  /// Son gönderiler başlığı
  ///
  /// In tr, this message translates to:
  /// **'Son Gönderilerin'**
  String get pointsRecentTitle;

  /// Gönderi sayısı
  ///
  /// In tr, this message translates to:
  /// **'{count} gönderi'**
  String pointsPostCount(int count);

  /// Boş gönderi başlığı
  ///
  /// In tr, this message translates to:
  /// **'İlk gönderini paylaş!'**
  String get pointsEmptyTitle;

  /// Boş gönderi alt metni
  ///
  /// In tr, this message translates to:
  /// **'Atıksız mutfağınla neler yaptığını göster\nve puan kazanmaya başla'**
  String get pointsEmptySubtitle;

  /// Gönderi ekle butonu
  ///
  /// In tr, this message translates to:
  /// **'Gönderi Ekle'**
  String get pointsAddPost;

  /// Gönderi durumu - beklemede
  ///
  /// In tr, this message translates to:
  /// **'İnceleniyor'**
  String get pointsStatusPending;

  /// Gönderi durumu - onaylandı
  ///
  /// In tr, this message translates to:
  /// **'Onaylandı'**
  String get pointsStatusApproved;

  /// Kazanılan puan etiketi
  ///
  /// In tr, this message translates to:
  /// **'Kazanılan Puan:'**
  String get pointsEarned;

  /// Günlük görevler başlığı
  ///
  /// In tr, this message translates to:
  /// **'Günlük Görevler'**
  String get pointsDailyMissions;

  /// No description provided for @monthAbbrJan.
  ///
  /// In tr, this message translates to:
  /// **'Oca'**
  String get monthAbbrJan;

  /// No description provided for @monthAbbrFeb.
  ///
  /// In tr, this message translates to:
  /// **'Şub'**
  String get monthAbbrFeb;

  /// No description provided for @monthAbbrMar.
  ///
  /// In tr, this message translates to:
  /// **'Mar'**
  String get monthAbbrMar;

  /// No description provided for @monthAbbrApr.
  ///
  /// In tr, this message translates to:
  /// **'Nis'**
  String get monthAbbrApr;

  /// No description provided for @monthAbbrMay.
  ///
  /// In tr, this message translates to:
  /// **'May'**
  String get monthAbbrMay;

  /// No description provided for @monthAbbrJun.
  ///
  /// In tr, this message translates to:
  /// **'Haz'**
  String get monthAbbrJun;

  /// No description provided for @monthAbbrJul.
  ///
  /// In tr, this message translates to:
  /// **'Tem'**
  String get monthAbbrJul;

  /// No description provided for @monthAbbrAug.
  ///
  /// In tr, this message translates to:
  /// **'Ağu'**
  String get monthAbbrAug;

  /// No description provided for @monthAbbrSep.
  ///
  /// In tr, this message translates to:
  /// **'Eyl'**
  String get monthAbbrSep;

  /// No description provided for @monthAbbrOct.
  ///
  /// In tr, this message translates to:
  /// **'Eki'**
  String get monthAbbrOct;

  /// No description provided for @monthAbbrNov.
  ///
  /// In tr, this message translates to:
  /// **'Kas'**
  String get monthAbbrNov;

  /// No description provided for @monthAbbrDec.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get monthAbbrDec;

  /// No description provided for @adminLoginTitle.
  ///
  /// In tr, this message translates to:
  /// **'Admin Girişi'**
  String get adminLoginTitle;

  /// No description provided for @adminLoginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Atıksız Mutfak Admin Paneli'**
  String get adminLoginSubtitle;

  /// No description provided for @adminLoginEmailLabel.
  ///
  /// In tr, this message translates to:
  /// **'Email'**
  String get adminLoginEmailLabel;

  /// No description provided for @adminLoginPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get adminLoginPasswordLabel;

  /// No description provided for @adminLoginButton.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get adminLoginButton;

  /// No description provided for @adminLoginBackToHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfaya Dön'**
  String get adminLoginBackToHome;

  /// No description provided for @adminLoginErrorInvalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir email girin'**
  String get adminLoginErrorInvalidEmail;

  /// No description provided for @adminLoginErrorPasswordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şifre gerekli'**
  String get adminLoginErrorPasswordRequired;

  /// No description provided for @adminLoginErrorPasswordMin.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalı'**
  String get adminLoginErrorPasswordMin;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tarifler'**
  String get adminDashboardTitle;

  /// No description provided for @adminDashboardEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tarif yok'**
  String get adminDashboardEmpty;

  /// No description provided for @adminDashboardEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Yeni tarif eklemek için sağ alttaki butonu kullanın'**
  String get adminDashboardEmptyHint;

  /// No description provided for @adminDashboardDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tarifi Sil'**
  String get adminDashboardDeleteTitle;

  /// No description provided for @adminDashboardDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" tarifini silmek istediğinize emin misiniz?'**
  String adminDashboardDeleteConfirm(Object title);

  /// No description provided for @adminDashboardDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Tarif silindi'**
  String get adminDashboardDeleted;

  /// No description provided for @adminSidebarBrand.
  ///
  /// In tr, this message translates to:
  /// **'Atıksız Admin'**
  String get adminSidebarBrand;

  /// No description provided for @adminSidebarRecipes.
  ///
  /// In tr, this message translates to:
  /// **'Tarifler'**
  String get adminSidebarRecipes;

  /// No description provided for @adminSidebarNewRecipe.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Tarif'**
  String get adminSidebarNewRecipe;

  /// No description provided for @adminSidebarPosts.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiler'**
  String get adminSidebarPosts;

  /// No description provided for @adminSidebarLogout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get adminSidebarLogout;

  /// No description provided for @adminSidebarApprove.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get adminSidebarApprove;

  /// No description provided for @adminSidebarReject.
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get adminSidebarReject;

  /// No description provided for @adminFormTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tarif Başlığı *'**
  String get adminFormTitle;

  /// No description provided for @adminFormTitleRequired.
  ///
  /// In tr, this message translates to:
  /// **'Başlık gerekli'**
  String get adminFormTitleRequired;

  /// No description provided for @adminFormDescription.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama (Opsiyonel)'**
  String get adminFormDescription;

  /// No description provided for @adminFormPhotoUrl.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf URL (Opsiyonel)'**
  String get adminFormPhotoUrl;

  /// No description provided for @adminFormIngredientsHint.
  ///
  /// In tr, this message translates to:
  /// **'Her satıra bir malzeme yazın'**
  String get adminFormIngredientsHint;

  /// No description provided for @adminFormStepsLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yapılış Adımları *'**
  String get adminFormStepsLabel;

  /// No description provided for @adminFormStepsHint.
  ///
  /// In tr, this message translates to:
  /// **'Her satıra bir adım yazın'**
  String get adminFormStepsHint;

  /// No description provided for @adminFormStepsRequired.
  ///
  /// In tr, this message translates to:
  /// **'En az bir adım gerekli'**
  String get adminFormStepsRequired;

  /// No description provided for @adminFormSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get adminFormSave;

  /// No description provided for @adminFormUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get adminFormUpdate;

  /// No description provided for @adminPostsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen Gönderiler'**
  String get adminPostsTitle;

  /// No description provided for @adminPostsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen gönderi yok'**
  String get adminPostsEmpty;

  /// No description provided for @adminPostsEmptySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Her şey yolunda!'**
  String get adminPostsEmptySubtitle;

  /// No description provided for @adminPostsApproveDialog.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiyi Onayla'**
  String get adminPostsApproveDialog;

  /// No description provided for @adminPostsAdminNote.
  ///
  /// In tr, this message translates to:
  /// **'Admin notu (isteğe bağlı)'**
  String get adminPostsAdminNote;

  /// No description provided for @adminPostsRejectDialog.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiyi Reddet'**
  String get adminPostsRejectDialog;

  /// No description provided for @adminPostsRejectConfirm.
  ///
  /// In tr, this message translates to:
  /// **'{nickname} kullanıcısının gönderisini reddetmek istediğinize emin misiniz?'**
  String adminPostsRejectConfirm(Object nickname);

  /// No description provided for @cuisineMediterranean.
  ///
  /// In tr, this message translates to:
  /// **'Akdeniz mutfağı'**
  String get cuisineMediterranean;

  /// No description provided for @cuisineAegean.
  ///
  /// In tr, this message translates to:
  /// **'Ege mutfağı'**
  String get cuisineAegean;

  /// No description provided for @cuisineBlackSea.
  ///
  /// In tr, this message translates to:
  /// **'Karadeniz mutfağı'**
  String get cuisineBlackSea;

  /// No description provided for @cuisineSoutheastern.
  ///
  /// In tr, this message translates to:
  /// **'Güneydoğu Anadolu mutfağı'**
  String get cuisineSoutheastern;

  /// No description provided for @cuisineCentralAnatolia.
  ///
  /// In tr, this message translates to:
  /// **'İç Anadolu mutfağı'**
  String get cuisineCentralAnatolia;

  /// No description provided for @cuisineMarmara.
  ///
  /// In tr, this message translates to:
  /// **'Marmara mutfağı'**
  String get cuisineMarmara;

  /// No description provided for @cuisineEasternAnatolia.
  ///
  /// In tr, this message translates to:
  /// **'Doğu Anadolu mutfağı'**
  String get cuisineEasternAnatolia;

  /// No description provided for @cuisineTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türk mutfağı (genel)'**
  String get cuisineTurkish;

  /// No description provided for @cuisineItalian.
  ///
  /// In tr, this message translates to:
  /// **'İtalyan mutfağı'**
  String get cuisineItalian;

  /// No description provided for @cuisineFrench.
  ///
  /// In tr, this message translates to:
  /// **'Fransız mutfağı'**
  String get cuisineFrench;

  /// No description provided for @cuisineJapanese.
  ///
  /// In tr, this message translates to:
  /// **'Japon mutfağı'**
  String get cuisineJapanese;

  /// No description provided for @cuisineMexican.
  ///
  /// In tr, this message translates to:
  /// **'Meksika mutfağı'**
  String get cuisineMexican;

  /// No description provided for @cuisineIndian.
  ///
  /// In tr, this message translates to:
  /// **'Hint mutfağı'**
  String get cuisineIndian;

  /// No description provided for @cuisineArabic.
  ///
  /// In tr, this message translates to:
  /// **'Arap mutfağı'**
  String get cuisineArabic;

  /// No description provided for @cuisineUzbek.
  ///
  /// In tr, this message translates to:
  /// **'Özbek mutfağı'**
  String get cuisineUzbek;

  /// No description provided for @cuisineGreek.
  ///
  /// In tr, this message translates to:
  /// **'Yunan mutfağı'**
  String get cuisineGreek;

  /// No description provided for @cuisineMiddleEastern.
  ///
  /// In tr, this message translates to:
  /// **'Orta Doğu mutfağı'**
  String get cuisineMiddleEastern;

  /// No description provided for @cuisineAsian.
  ///
  /// In tr, this message translates to:
  /// **'Asya mutfağı'**
  String get cuisineAsian;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
