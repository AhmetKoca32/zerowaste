// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Atıksız Mutfak';

  @override
  String get navRecipes => 'Tarifler';

  @override
  String get navCreate => 'Oluştur';

  @override
  String get navEcoChef => 'EcoChef';

  @override
  String get navPoints => 'Puan';

  @override
  String get homeTitle => 'Atıksız Mutfak';

  @override
  String get homeEmpty =>
      'Henüz tarif yok. Malzeme ekleyip bir tarif oluşturun!';

  @override
  String get homeCreateRecipe => 'Tarif Oluştur';

  @override
  String get homeLoading => 'Tarifler yükleniyor…';

  @override
  String homeError(String error) {
    return 'Tarifler yüklenemedi.\n$error';
  }

  @override
  String get homeRetry => 'Tekrar Dene';

  @override
  String get homeClearFilter => 'Temizle';

  @override
  String get homeSearchHint => 'Tariflerde arayın';

  @override
  String recipeCardMatchCount(int count, int total) {
    return '$count/$total malzeme elinizde';
  }

  @override
  String recipeCardStatSummary(int ingredientCount, int stepCount) {
    return '$ingredientCount malzeme · $stepCount adım';
  }

  @override
  String get recipeCardIngredients => 'Malzemeler';

  @override
  String get recipeCardInspect => 'Tarifi İncele';

  @override
  String recipeDetailIngredientCount(int count) {
    return '$count adet';
  }

  @override
  String recipeDetailStepCount(int count) {
    return '$count adım';
  }

  @override
  String get recipeDetailIngredient => 'Malzeme';

  @override
  String get recipeDetailStep => 'Adım';

  @override
  String get recipeDetailIngredients => 'Malzemeler';

  @override
  String get recipeDetailInstructions => 'Yapılış';

  @override
  String get recipeDetailSave => 'Kaydet';

  @override
  String get recipeDetailSaved => 'Tarif kaydedildi!';

  @override
  String get recipeDetailClose => 'Kapat';

  @override
  String get recipeDetailDelete => 'Tarifi sil';

  @override
  String get recipeDetailDeleteConfirm =>
      'Bu tarifi kaydettiğiniz listeden silmek istediğinize emin misiniz?';

  @override
  String get recipeDetailCancel => 'İptal';

  @override
  String get recipeDetailDeleteAction => 'Sil';

  @override
  String get recipeDetailAddPhoto => 'Fotoğraf ekle';

  @override
  String get recipeDetailGallery => 'Galeriden seç';

  @override
  String get recipeDetailCamera => 'Fotoğraf çek';

  @override
  String get filterTitle => 'Malzeme Filtresi';

  @override
  String filterSelected(int count) {
    return '$count seçili';
  }

  @override
  String get filterSearchHint => 'Malzeme ara...';

  @override
  String get filterSelectedSection => 'Seçili malzemeler';

  @override
  String get filterAllSection => 'Tüm malzemeler';

  @override
  String get filterNoResults => 'Sonuç bulunamadı.';

  @override
  String get filterClear => 'Temizle';

  @override
  String get filterApply => 'Uygula';

  @override
  String filterApplyWithCount(int count) {
    return 'Uygula ($count)';
  }

  @override
  String get recipeGeneratorHeading => 'Elinizdeki malzemeleri ekleyin';

  @override
  String get recipeGeneratorInstruction =>
      'En az bir malzeme ekleyin, ardından Tarif Oluştur\'a dokunun.';

  @override
  String get recipeGeneratorInputHint => 'örn. domates, fesleğen';

  @override
  String get recipeGeneratorRecent => 'Son eklenenler';

  @override
  String get recipeGeneratorCuisine => 'Mutfak (isteğe bağlı)';

  @override
  String get recipeGeneratorNoCuisine => 'Fark etmez';

  @override
  String get recipeGeneratorCreate => 'Tarif Oluştur';

  @override
  String get recipeGeneratorSaved => 'Kaydettiğim Tarifler';

  @override
  String get recipeGeneratorSeeAll => 'Tümünü gör';

  @override
  String recipeGeneratorSeeAllCount(int count) {
    return 'Tümünü gör ($count)';
  }

  @override
  String recipeGeneratorCount(int count) {
    return '$count tarif';
  }

  @override
  String get recipeGeneratorMinIngredients =>
      'Lütfen tarif oluşturmadan önce en az bir malzeme ekleyin.';

  @override
  String get chefLoading => 'EcoChef pişiriyor';

  @override
  String get chatDailyLimit =>
      'Bugünlük 20 mesaj hakkın doldu! Detaylı tarifler için yarın tekrar gel.';

  @override
  String get chatInputHint => 'EcoChef\'e yazın...';

  @override
  String get chatClear => 'Sohbeti Temizle';

  @override
  String get chatBack => 'Geri';

  @override
  String get chatConnectionError =>
      'Sunucuya ulaşılamıyor. İnternet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get chatTimeoutError =>
      'Sunucu yanıt vermekte gecikti. Birkaç saniye sonra tekrar deneyin.';

  @override
  String get chatAuthError =>
      'Doğrulama hatası. API anahtarı eksik veya geçersiz görünüyor.';

  @override
  String chatApiError(String code) {
    return 'Servis bir hata döndürdü (kod: $code).';
  }

  @override
  String get chatGenericError =>
      'Beklenmedik bir sorun oldu. Lütfen tekrar deneyin.';

  @override
  String get chatStartButton => 'Sohbete Başla';

  @override
  String get chatWelcomeSubtitle => 'Atıksız mutfak yardımcınız';

  @override
  String get chatWelcomeDescription =>
      'Tarif önerileri, gıda israfını azaltma ipuçları ve sürdürülebilir mutfak pratikleri hakkında benimle sohbet edebilirsiniz! 🌿';

  @override
  String get chatDailyLimitInfo => 'Günlük 20 mesaj hakkınız bulunmaktadır';

  @override
  String get chatOrAskDirectly => 'Ya da direkt sorun';

  @override
  String get chatEmptyPrompt => 'Size nasıl yardımcı olabilirim?';

  @override
  String get chatEmptyInstruction => 'Aşağıdan mesajınızı yazabilirsiniz';

  @override
  String get chatEmptyResponse =>
      'Atıksız mutfak veya ipuçları hakkında ne olursa olsun sorabilirsiniz!';

  @override
  String get generatorResultSheetTitle => 'Tarifiniz';

  @override
  String get generatorResultSheetError => 'Bir hata oluştu';

  @override
  String get savedRecipesTitle => 'Kaydettiğim Tarifler';

  @override
  String get savedRecipesEmpty => 'Henüz kaydedilmiş tarif yok.';

  @override
  String get savedRecipesError => 'Tarifler yüklenirken hata oluştu.';

  @override
  String get pointsMissionFridge => 'Dolabını paylaş';

  @override
  String get pointsMissionFridgeDesc =>
      'Buzdolabı veya kiler fotoğrafı yükle, sıfır atık alışkanlığına puan kazan.';

  @override
  String get pointsMissionCooking => 'Yemek anını paylaş';

  @override
  String get pointsMissionCookingDesc =>
      'Malzemelerinle yemek yaparken çektiğin fotoğrafı gönder.';

  @override
  String get pointsMissionLeftovers => 'Artıklardan ne yaptın?';

  @override
  String get pointsMissionLeftoversDesc =>
      'Kalan malzemelerden yaptığın tarifi veya değerlendirmeyi anlat.';

  @override
  String get pointsCategoryFridge => 'Dolap';

  @override
  String get pointsCategoryCooking => 'Yemek Anı';

  @override
  String get pointsCategoryLeftovers => 'Artık Değerlendirme';

  @override
  String get pointsCategoryOther => 'Diğer';

  @override
  String get pointsLevelLegend => 'Efsane+';

  @override
  String get pointsLevelEfsane => 'Efsane';

  @override
  String get pointsLevelUsta => 'Usta';

  @override
  String get pointsLevelMerakli => 'Meraklı';

  @override
  String get pointsLevelCaylak => 'Çaylak';

  @override
  String get pointsNicknameDialogTitle => 'Takma Adın Nedir?';

  @override
  String get pointsNicknameDialogSubtitle =>
      'Gönderilerinin ve sıralamadaki görünen adını belirle.';

  @override
  String get pointsNicknameHint => 'Örn. Atıksız Şef';

  @override
  String get pointsNicknameValidationEmpty => 'Lütfen bir takma ad girin';

  @override
  String get pointsLeaderboardOptIn =>
      'Sıralamada (leaderboard) takma adımın görüntülenmesine izin veriyorum.';

  @override
  String get pointsPrivacyDisclaimer =>
      'KVKK kapsamında bu bilgi yalnızca uygulama içi sıralamada gösterilir, üçüncü taraflarla paylaşılmaz.';

  @override
  String get pointsSave => 'Kaydet';

  @override
  String get pointsAddPhoto => 'Fotoğraf Ekle';

  @override
  String get pointsPhotoSource => 'Gönderin için fotoğraf kaynağını seç';

  @override
  String get pointsCamera => 'Kameradan Çek';

  @override
  String get pointsGallery => 'Galeriden Seç';

  @override
  String get pointsAnonymous => 'Anonim';

  @override
  String pointsPostSent(String category) {
    return '⏳ $category gönderin incelemeye gönderildi!';
  }

  @override
  String get pointsLevelUpTitle => 'Tebrikler! 🎉';

  @override
  String get pointsLevelUpDesc =>
      'Gönderin admin tarafından onaylandı ve kazandığın yeni puanlar hesabına eklendi. Sıfır atık yolculuğunda ilham vermeye devam et!';

  @override
  String get pointsKeepGoing => 'Harika! Devam Et';

  @override
  String get pointsShareTitle => 'Ne paylaşmak istersin?';

  @override
  String get pointsShareSubtitle => 'Bir kategori seç ve fotoğraf ekle';

  @override
  String get pointsShareHint => 'Fotoğraf çek veya galeriden seç';

  @override
  String get pointsLeaderboardTitle => 'Sıralama';

  @override
  String get pointsLevelComplete => 'Seviye tamamlandı!';

  @override
  String pointsNextLevel(String emoji, String level, int remaining) {
    return '$emoji $level seviyesine $remaining puan kaldı';
  }

  @override
  String get pointsMaxLevel => '🏆 En yüksek seviyedesin!';

  @override
  String pointsStreak(int days) {
    return '$days gün';
  }

  @override
  String get pointsRecentTitle => 'Son Gönderilerin';

  @override
  String pointsPostCount(int count) {
    return '$count gönderi';
  }

  @override
  String get pointsEmptyTitle => 'İlk gönderini paylaş!';

  @override
  String get pointsEmptySubtitle =>
      'Atıksız mutfağınla neler yaptığını göster\nve puan kazanmaya başla';

  @override
  String get pointsAddPost => 'Gönderi Ekle';

  @override
  String get pointsStatusPending => 'İnceleniyor';

  @override
  String get pointsStatusApproved => 'Onaylandı';

  @override
  String get pointsEarned => 'Kazanılan Puan:';

  @override
  String get pointsDailyMissions => 'Günlük Görevler';

  @override
  String get monthAbbrJan => 'Oca';

  @override
  String get monthAbbrFeb => 'Şub';

  @override
  String get monthAbbrMar => 'Mar';

  @override
  String get monthAbbrApr => 'Nis';

  @override
  String get monthAbbrMay => 'May';

  @override
  String get monthAbbrJun => 'Haz';

  @override
  String get monthAbbrJul => 'Tem';

  @override
  String get monthAbbrAug => 'Ağu';

  @override
  String get monthAbbrSep => 'Eyl';

  @override
  String get monthAbbrOct => 'Eki';

  @override
  String get monthAbbrNov => 'Kas';

  @override
  String get monthAbbrDec => 'Ara';

  @override
  String get adminLoginTitle => 'Admin Girişi';

  @override
  String get adminLoginSubtitle => 'Atıksız Mutfak Admin Paneli';

  @override
  String get adminLoginEmailLabel => 'Email';

  @override
  String get adminLoginPasswordLabel => 'Şifre';

  @override
  String get adminLoginButton => 'Giriş Yap';

  @override
  String get adminLoginBackToHome => 'Ana Sayfaya Dön';

  @override
  String get adminLoginErrorInvalidEmail => 'Geçerli bir email girin';

  @override
  String get adminLoginErrorPasswordRequired => 'Şifre gerekli';

  @override
  String get adminLoginErrorPasswordMin => 'Şifre en az 6 karakter olmalı';

  @override
  String get adminDashboardTitle => 'Tarifler';

  @override
  String get adminDashboardEmpty => 'Henüz tarif yok';

  @override
  String get adminDashboardEmptyHint =>
      'Yeni tarif eklemek için sağ alttaki butonu kullanın';

  @override
  String get adminDashboardDeleteTitle => 'Tarifi Sil';

  @override
  String adminDashboardDeleteConfirm(Object title) {
    return '\"$title\" tarifini silmek istediğinize emin misiniz?';
  }

  @override
  String get adminDashboardDeleted => 'Tarif silindi';

  @override
  String get adminSidebarBrand => 'Atıksız Admin';

  @override
  String get adminSidebarRecipes => 'Tarifler';

  @override
  String get adminSidebarNewRecipe => 'Yeni Tarif';

  @override
  String get adminSidebarPosts => 'Gönderiler';

  @override
  String get adminSidebarLogout => 'Çıkış Yap';

  @override
  String get adminSidebarApprove => 'Onayla';

  @override
  String get adminSidebarReject => 'Reddet';

  @override
  String get adminFormTitle => 'Tarif Başlığı *';

  @override
  String get adminFormTitleRequired => 'Başlık gerekli';

  @override
  String get adminFormDescription => 'Açıklama (Opsiyonel)';

  @override
  String get adminFormPhotoUrl => 'Fotoğraf URL (Opsiyonel)';

  @override
  String get adminFormIngredientsHint => 'Her satıra bir malzeme yazın';

  @override
  String get adminFormStepsLabel => 'Yapılış Adımları *';

  @override
  String get adminFormStepsHint => 'Her satıra bir adım yazın';

  @override
  String get adminFormStepsRequired => 'En az bir adım gerekli';

  @override
  String get adminFormSave => 'Kaydet';

  @override
  String get adminFormUpdate => 'Güncelle';

  @override
  String get adminPostsTitle => 'Bekleyen Gönderiler';

  @override
  String get adminPostsEmpty => 'Bekleyen gönderi yok';

  @override
  String get adminPostsEmptySubtitle => 'Her şey yolunda!';

  @override
  String get adminPostsApproveDialog => 'Gönderiyi Onayla';

  @override
  String get adminPostsAdminNote => 'Admin notu (isteğe bağlı)';

  @override
  String get adminPostsRejectDialog => 'Gönderiyi Reddet';

  @override
  String adminPostsRejectConfirm(Object nickname) {
    return '$nickname kullanıcısının gönderisini reddetmek istediğinize emin misiniz?';
  }

  @override
  String get cuisineMediterranean => 'Akdeniz mutfağı';

  @override
  String get cuisineAegean => 'Ege mutfağı';

  @override
  String get cuisineBlackSea => 'Karadeniz mutfağı';

  @override
  String get cuisineSoutheastern => 'Güneydoğu Anadolu mutfağı';

  @override
  String get cuisineCentralAnatolia => 'İç Anadolu mutfağı';

  @override
  String get cuisineMarmara => 'Marmara mutfağı';

  @override
  String get cuisineEasternAnatolia => 'Doğu Anadolu mutfağı';

  @override
  String get cuisineTurkish => 'Türk mutfağı (genel)';

  @override
  String get cuisineItalian => 'İtalyan mutfağı';

  @override
  String get cuisineFrench => 'Fransız mutfağı';

  @override
  String get cuisineJapanese => 'Japon mutfağı';

  @override
  String get cuisineMexican => 'Meksika mutfağı';

  @override
  String get cuisineIndian => 'Hint mutfağı';

  @override
  String get cuisineArabic => 'Arap mutfağı';

  @override
  String get cuisineUzbek => 'Özbek mutfağı';

  @override
  String get cuisineGreek => 'Yunan mutfağı';

  @override
  String get cuisineMiddleEastern => 'Orta Doğu mutfağı';

  @override
  String get cuisineAsian => 'Asya mutfağı';
}
