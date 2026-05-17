// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ZeroWaste Kitchen';

  @override
  String get navRecipes => 'Recipes';

  @override
  String get navCreate => 'Create';

  @override
  String get navEcoChef => 'EcoChef';

  @override
  String get navPoints => 'Points';

  @override
  String get homeTitle => 'ZeroWaste Kitchen';

  @override
  String get homeEmpty =>
      'No recipes yet. Add ingredients and create a recipe!';

  @override
  String get homeCreateRecipe => 'Create Recipe';

  @override
  String get homeLoading => 'Loading recipes…';

  @override
  String homeError(String error) {
    return 'Failed to load recipes.\n$error';
  }

  @override
  String get homeRetry => 'Retry';

  @override
  String get homeClearFilter => 'Clear';

  @override
  String get homeSearchHint => 'Search recipes';

  @override
  String recipeCardMatchCount(int count, int total) {
    return '$count/$total ingredients you have';
  }

  @override
  String recipeCardStatSummary(int ingredientCount, int stepCount) {
    return '$ingredientCount ingredients · $stepCount steps';
  }

  @override
  String get recipeCardIngredients => 'Ingredients';

  @override
  String get recipeCardInspect => 'View Recipe';

  @override
  String recipeDetailIngredientCount(int count) {
    return '$count items';
  }

  @override
  String recipeDetailStepCount(int count) {
    return '$count steps';
  }

  @override
  String get recipeDetailIngredient => 'Ingredient';

  @override
  String get recipeDetailStep => 'Step';

  @override
  String get recipeDetailIngredients => 'Ingredients';

  @override
  String get recipeDetailInstructions => 'Instructions';

  @override
  String get recipeDetailSave => 'Save';

  @override
  String get recipeDetailSaved => 'Recipe saved!';

  @override
  String get recipeDetailClose => 'Close';

  @override
  String get recipeDetailDelete => 'Delete recipe';

  @override
  String get recipeDetailDeleteConfirm =>
      'Are you sure you want to remove this recipe from your saved list?';

  @override
  String get recipeDetailCancel => 'Cancel';

  @override
  String get recipeDetailDeleteAction => 'Delete';

  @override
  String get recipeDetailAddPhoto => 'Add photo';

  @override
  String get recipeDetailGallery => 'Choose from gallery';

  @override
  String get recipeDetailCamera => 'Take a photo';

  @override
  String get filterTitle => 'Ingredient Filter';

  @override
  String filterSelected(int count) {
    return '$count selected';
  }

  @override
  String get filterSearchHint => 'Search ingredients...';

  @override
  String get filterSelectedSection => 'Selected ingredients';

  @override
  String get filterAllSection => 'All ingredients';

  @override
  String get filterNoResults => 'No results found.';

  @override
  String get filterClear => 'Clear';

  @override
  String get filterApply => 'Apply';

  @override
  String filterApplyWithCount(int count) {
    return 'Apply ($count)';
  }

  @override
  String get recipeGeneratorHeading => 'Enter your ingredients';

  @override
  String get recipeGeneratorInstruction =>
      'Add at least one ingredient, then tap Create Recipe.';

  @override
  String get recipeGeneratorInputHint => 'e.g. tomato, basil';

  @override
  String get recipeGeneratorRecent => 'Recent ingredients';

  @override
  String get recipeGeneratorCuisine => 'Cuisine (optional)';

  @override
  String get recipeGeneratorNoCuisine => 'No preference';

  @override
  String get recipeGeneratorCreate => 'Create Recipe';

  @override
  String get recipeGeneratorSaved => 'Saved Recipes';

  @override
  String get recipeGeneratorSeeAll => 'See all';

  @override
  String recipeGeneratorSeeAllCount(int count) {
    return 'See all ($count)';
  }

  @override
  String recipeGeneratorCount(int count) {
    return '$count recipes';
  }

  @override
  String get recipeGeneratorMinIngredients =>
      'Please add at least one ingredient before creating a recipe.';

  @override
  String get chefLoading => 'EcoChef is cooking';

  @override
  String get chatDailyLimit =>
      'You\'ve reached your daily limit of 20 messages! Come back tomorrow for more recipes.';

  @override
  String get chatInputHint => 'Ask EcoChef...';

  @override
  String get chatClear => 'Clear Chat';

  @override
  String get chatBack => 'Back';

  @override
  String get chatConnectionError =>
      'Cannot reach the server. Please check your internet connection and try again.';

  @override
  String get chatTimeoutError =>
      'The server is taking too long. Please try again in a moment.';

  @override
  String get chatAuthError =>
      'Authentication error. The API key appears to be missing or invalid.';

  @override
  String chatApiError(String code) {
    return 'The service returned an error (code: $code).';
  }

  @override
  String get chatGenericError =>
      'Something unexpected happened. Please try again.';

  @override
  String get chatStartButton => 'Start Chatting';

  @override
  String get chatWelcomeSubtitle => 'Your zero-waste kitchen assistant';

  @override
  String get chatWelcomeDescription =>
      'Chat with me about recipe ideas, food waste reduction tips, and sustainable kitchen practices! 🌿';

  @override
  String get chatDailyLimitInfo => 'You have 20 messages per day';

  @override
  String get chatOrAskDirectly => 'Or ask directly';

  @override
  String get chatEmptyPrompt => 'How can I help you?';

  @override
  String get chatEmptyInstruction => 'Type your message below';

  @override
  String get chatEmptyResponse =>
      'Feel free to ask anything about zero-waste cooking or tips!';

  @override
  String get generatorResultSheetTitle => 'Your Recipe';

  @override
  String get generatorResultSheetError => 'Something went wrong';

  @override
  String get savedRecipesTitle => 'Saved Recipes';

  @override
  String get savedRecipesEmpty => 'No saved recipes yet.';

  @override
  String get savedRecipesError => 'Failed to load recipes.';

  @override
  String get pointsMissionFridge => 'Share Your Fridge';

  @override
  String get pointsMissionFridgeDesc =>
      'Upload a photo of your fridge or pantry and earn points for your zero-waste habit.';

  @override
  String get pointsMissionCooking => 'Share a Cooking Moment';

  @override
  String get pointsMissionCookingDesc =>
      'Send a photo you took while cooking with your ingredients.';

  @override
  String get pointsMissionLeftovers => 'What Did You Make from Leftovers?';

  @override
  String get pointsMissionLeftoversDesc =>
      'Tell us about the recipe or how you used your leftover ingredients.';

  @override
  String get pointsCategoryFridge => 'Fridge';

  @override
  String get pointsCategoryCooking => 'Cooking Moment';

  @override
  String get pointsCategoryLeftovers => 'Leftover Use';

  @override
  String get pointsCategoryOther => 'Other';

  @override
  String get pointsLevelLegend => 'Legend+';

  @override
  String get pointsLevelEfsane => 'Legend';

  @override
  String get pointsLevelUsta => 'Master';

  @override
  String get pointsLevelMerakli => 'Curious';

  @override
  String get pointsLevelCaylak => 'Novice';

  @override
  String get pointsNicknameDialogTitle => 'What\'s Your Nickname?';

  @override
  String get pointsNicknameDialogSubtitle =>
      'Set the display name for your posts and the leaderboard.';

  @override
  String get pointsNicknameHint => 'e.g. EcoChef Fan';

  @override
  String get pointsNicknameValidationEmpty => 'Please enter a nickname';

  @override
  String get pointsLeaderboardOptIn =>
      'I allow my nickname to be displayed on the leaderboard.';

  @override
  String get pointsPrivacyDisclaimer =>
      'This information is only shown within the app\'s leaderboard and is not shared with third parties.';

  @override
  String get pointsSave => 'Save';

  @override
  String get pointsAddPhoto => 'Add Photo';

  @override
  String get pointsPhotoSource => 'Choose a photo source for your post';

  @override
  String get pointsCamera => 'Take from Camera';

  @override
  String get pointsGallery => 'Choose from Gallery';

  @override
  String get pointsAnonymous => 'Anonymous';

  @override
  String pointsPostSent(String category) {
    return '⏳ Your $category post has been submitted for review!';
  }

  @override
  String get pointsLevelUpTitle => 'Congratulations! 🎉';

  @override
  String get pointsLevelUpDesc =>
      'Your post was approved by the admin and the points have been added to your account. Keep inspiring on your zero-waste journey!';

  @override
  String get pointsKeepGoing => 'Great! Keep Going';

  @override
  String get pointsShareTitle => 'What would you like to share?';

  @override
  String get pointsShareSubtitle => 'Choose a category and add a photo';

  @override
  String get pointsShareHint => 'Take a photo or choose from gallery';

  @override
  String get pointsLeaderboardTitle => 'Leaderboard';

  @override
  String get pointsLevelComplete => 'Level complete!';

  @override
  String pointsNextLevel(String emoji, String level, int remaining) {
    return '$remaining points to $emoji $level level';
  }

  @override
  String get pointsMaxLevel => '🏆 You\'re at the highest level!';

  @override
  String pointsStreak(int days) {
    return '$days days';
  }

  @override
  String get pointsRecentTitle => 'Recent Posts';

  @override
  String pointsPostCount(int count) {
    return '$count posts';
  }

  @override
  String get pointsEmptyTitle => 'Share your first post!';

  @override
  String get pointsEmptySubtitle =>
      'Show what you\'re doing in your zero-waste kitchen\nand start earning points';

  @override
  String get pointsAddPost => 'Add Post';

  @override
  String get pointsStatusPending => 'Pending Review';

  @override
  String get pointsStatusApproved => 'Approved';

  @override
  String get pointsEarned => 'Points Earned:';

  @override
  String get pointsDailyMissions => 'Daily Missions';

  @override
  String get monthAbbrJan => 'Jan';

  @override
  String get monthAbbrFeb => 'Feb';

  @override
  String get monthAbbrMar => 'Mar';

  @override
  String get monthAbbrApr => 'Apr';

  @override
  String get monthAbbrMay => 'May';

  @override
  String get monthAbbrJun => 'Jun';

  @override
  String get monthAbbrJul => 'Jul';

  @override
  String get monthAbbrAug => 'Aug';

  @override
  String get monthAbbrSep => 'Sep';

  @override
  String get monthAbbrOct => 'Oct';

  @override
  String get monthAbbrNov => 'Nov';

  @override
  String get monthAbbrDec => 'Dec';

  @override
  String get adminLoginTitle => 'Admin Login';

  @override
  String get adminLoginSubtitle => 'Atıksız Mutfak Admin Panel';

  @override
  String get adminLoginEmailLabel => 'Email';

  @override
  String get adminLoginPasswordLabel => 'Password';

  @override
  String get adminLoginButton => 'Sign In';

  @override
  String get adminLoginBackToHome => 'Back to Home';

  @override
  String get adminLoginErrorInvalidEmail => 'Enter a valid email';

  @override
  String get adminLoginErrorPasswordRequired => 'Password is required';

  @override
  String get adminLoginErrorPasswordMin =>
      'Password must be at least 6 characters';

  @override
  String get adminDashboardTitle => 'Recipes';

  @override
  String get adminDashboardEmpty => 'No recipes yet';

  @override
  String get adminDashboardEmptyHint =>
      'Use the button at the bottom right to add a new recipe';

  @override
  String get adminDashboardDeleteTitle => 'Delete Recipe';

  @override
  String adminDashboardDeleteConfirm(Object title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get adminDashboardDeleted => 'Recipe deleted';

  @override
  String get adminSidebarBrand => 'Atıksız Admin';

  @override
  String get adminSidebarRecipes => 'Recipes';

  @override
  String get adminSidebarNewRecipe => 'New Recipe';

  @override
  String get adminSidebarPosts => 'Posts';

  @override
  String get adminSidebarLogout => 'Log Out';

  @override
  String get adminSidebarApprove => 'Approve';

  @override
  String get adminSidebarReject => 'Reject';

  @override
  String get adminFormTitle => 'Recipe Title *';

  @override
  String get adminFormTitleRequired => 'Title is required';

  @override
  String get adminFormDescription => 'Description (Optional)';

  @override
  String get adminFormPhotoUrl => 'Photo URL (Optional)';

  @override
  String get adminFormIngredientsHint => 'Write one ingredient per line';

  @override
  String get adminFormStepsLabel => 'Instructions *';

  @override
  String get adminFormStepsHint => 'Write one step per line';

  @override
  String get adminFormStepsRequired => 'At least one step is required';

  @override
  String get adminFormSave => 'Save';

  @override
  String get adminFormUpdate => 'Update';

  @override
  String get adminPostsTitle => 'Pending Posts';

  @override
  String get adminPostsEmpty => 'No pending posts';

  @override
  String get adminPostsEmptySubtitle => 'All clear!';

  @override
  String get adminPostsApproveDialog => 'Approve Post';

  @override
  String get adminPostsAdminNote => 'Admin note (optional)';

  @override
  String get adminPostsRejectDialog => 'Reject Post';

  @override
  String adminPostsRejectConfirm(Object nickname) {
    return 'Are you sure you want to reject $nickname\'s post?';
  }

  @override
  String get cuisineMediterranean => 'Mediterranean cuisine';

  @override
  String get cuisineAegean => 'Aegean cuisine';

  @override
  String get cuisineBlackSea => 'Black Sea cuisine';

  @override
  String get cuisineSoutheastern => 'Southeastern Anatolian cuisine';

  @override
  String get cuisineCentralAnatolia => 'Central Anatolian cuisine';

  @override
  String get cuisineMarmara => 'Marmara cuisine';

  @override
  String get cuisineEasternAnatolia => 'Eastern Anatolian cuisine';

  @override
  String get cuisineTurkish => 'Turkish cuisine (general)';

  @override
  String get cuisineItalian => 'Italian cuisine';

  @override
  String get cuisineFrench => 'French cuisine';

  @override
  String get cuisineJapanese => 'Japanese cuisine';

  @override
  String get cuisineMexican => 'Mexican cuisine';

  @override
  String get cuisineIndian => 'Indian cuisine';

  @override
  String get cuisineArabic => 'Arabic cuisine';

  @override
  String get cuisineUzbek => 'Uzbek cuisine';

  @override
  String get cuisineGreek => 'Greek cuisine';

  @override
  String get cuisineMiddleEastern => 'Middle Eastern cuisine';

  @override
  String get cuisineAsian => 'Asian cuisine';
}
