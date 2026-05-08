import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AgriScan'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Plant Intelligence Platform'**
  String get tagline;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT TYPE'**
  String get accountType;

  /// No description provided for @credentials.
  ///
  /// In en, this message translates to:
  /// **'CREDENTIALS'**
  String get credentials;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL INFO'**
  String get personalInfo;

  /// No description provided for @farmDetails.
  ///
  /// In en, this message translates to:
  /// **'FARM DETAILS'**
  String get farmDetails;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @altPhone.
  ///
  /// In en, this message translates to:
  /// **'Alt Phone'**
  String get altPhone;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'other'**
  String get other;

  /// No description provided for @farmName.
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmName;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get registrationNumber;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @registeredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get registeredSuccess;

  /// No description provided for @detection.
  ///
  /// In en, this message translates to:
  /// **'Detection'**
  String get detection;

  /// No description provided for @planning.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get planning;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @aiPowered.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered'**
  String get aiPowered;

  /// No description provided for @plantIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Plant Intelligence'**
  String get plantIntelligence;

  /// No description provided for @plantIntelligenceDesc.
  ///
  /// In en, this message translates to:
  /// **'Identify diseases and maximize your crop yield through advanced AI analysis.'**
  String get plantIntelligenceDesc;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'TOOLS'**
  String get tools;

  /// No description provided for @diseaseDetection.
  ///
  /// In en, this message translates to:
  /// **'Diseases Detection'**
  String get diseaseDetection;

  /// No description provided for @diseaseDetectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload or capture a leaf image a disease and instantly receive advice.'**
  String get diseaseDetectionDesc;

  /// No description provided for @fertilizerRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Recommendations'**
  String get fertilizerRecommendation;

  /// No description provided for @fertilizerRecommendationDesc.
  ///
  /// In en, this message translates to:
  /// **'Get personalized fertilizer advice based on your crop type and soil conditions.'**
  String get fertilizerRecommendationDesc;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @diseases.
  ///
  /// In en, this message translates to:
  /// **'Diseases'**
  String get diseases;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get available;

  /// No description provided for @leafAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Leaf Analysis'**
  String get leafAnalysis;

  /// No description provided for @leafAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Take or upload a photo of your plant to detect possible diseases using AI.'**
  String get leafAnalysisDesc;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// No description provided for @useCamera.
  ///
  /// In en, this message translates to:
  /// **'Use your camera'**
  String get useCamera;

  /// No description provided for @chooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Import an image'**
  String get chooseGallery;

  /// No description provided for @browsePhotos.
  ///
  /// In en, this message translates to:
  /// **'Choose from your gallery'**
  String get browsePhotos;

  /// No description provided for @analysisInProgress.
  ///
  /// In en, this message translates to:
  /// **'Analyzing leaf...'**
  String get analysisInProgress;

  /// No description provided for @aiProcessing.
  ///
  /// In en, this message translates to:
  /// **'AI is processing your image'**
  String get aiProcessing;

  /// No description provided for @newAnalysis.
  ///
  /// In en, this message translates to:
  /// **'New Analysis'**
  String get newAnalysis;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis Failed'**
  String get analysisFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @tipText.
  ///
  /// In en, this message translates to:
  /// **'For optimal results, make sure the leaf is clear and well-lit.'**
  String get tipText;

  /// No description provided for @detectionResults.
  ///
  /// In en, this message translates to:
  /// **'Detection Results'**
  String get detectionResults;

  /// No description provided for @treatmentAdvice.
  ///
  /// In en, this message translates to:
  /// **'Treatment Advice'**
  String get treatmentAdvice;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence:'**
  String get confidence;

  /// No description provided for @marketPrices.
  ///
  /// In en, this message translates to:
  /// **'Market Prices'**
  String get marketPrices;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'products'**
  String get products;

  /// No description provided for @addPrice.
  ///
  /// In en, this message translates to:
  /// **'Add Price'**
  String get addPrice;

  /// No description provided for @plantName.
  ///
  /// In en, this message translates to:
  /// **'Plant name'**
  String get plantName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price (DT)'**
  String get price;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noDataToday.
  ///
  /// In en, this message translates to:
  /// **'No prices available today'**
  String get noDataToday;

  /// No description provided for @priceAdded.
  ///
  /// In en, this message translates to:
  /// **'Price added successfully'**
  String get priceAdded;

  /// No description provided for @priceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Price deleted'**
  String get priceDeleted;

  /// No description provided for @errorAdding.
  ///
  /// In en, this message translates to:
  /// **'Error adding price'**
  String get errorAdding;

  /// No description provided for @errorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting price'**
  String get errorDeleting;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @priceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Price updated successfully'**
  String get priceUpdated;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search city...'**
  String get searchCity;

  /// No description provided for @daysForecast.
  ///
  /// In en, this message translates to:
  /// **'3-DAY FORECAST'**
  String get daysForecast;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @cropLibrary.
  ///
  /// In en, this message translates to:
  /// **'Crop Library'**
  String get cropLibrary;

  /// No description provided for @noCropsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No crops available'**
  String get noCropsAvailable;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @noPlanningYet.
  ///
  /// In en, this message translates to:
  /// **'No planning records yet'**
  String get noPlanningYet;

  /// No description provided for @createFirstPlan.
  ///
  /// In en, this message translates to:
  /// **'Create First Plan'**
  String get createFirstPlan;

  /// No description provided for @createCropPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Crop Plan'**
  String get createCropPlan;

  /// No description provided for @selectCrop.
  ///
  /// In en, this message translates to:
  /// **'Select Crop'**
  String get selectCrop;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select Start Date'**
  String get selectStartDate;

  /// No description provided for @selectHarvestDate.
  ///
  /// In en, this message translates to:
  /// **'Select Harvest Date'**
  String get selectHarvestDate;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notes;

  /// No description provided for @irrigationReminder.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Reminder'**
  String get irrigationReminder;

  /// No description provided for @fertilizerReminder.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Reminder'**
  String get fertilizerReminder;

  /// No description provided for @createPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Plan'**
  String get createPlan;

  /// No description provided for @planCreated.
  ///
  /// In en, this message translates to:
  /// **'Plan created!'**
  String get planCreated;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start:'**
  String get start;

  /// No description provided for @harvest.
  ///
  /// In en, this message translates to:
  /// **'Harvest:'**
  String get harvest;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'TASKS'**
  String get tasks;

  /// No description provided for @noTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasksYet;

  /// No description provided for @addFirstTask.
  ///
  /// In en, this message translates to:
  /// **'Add First Task'**
  String get addFirstTask;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// No description provided for @taskType.
  ///
  /// In en, this message translates to:
  /// **'Task Type'**
  String get taskType;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @taskCreated.
  ///
  /// In en, this message translates to:
  /// **'Task created!'**
  String get taskCreated;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark Completed'**
  String get markCompleted;

  /// No description provided for @markPending.
  ///
  /// In en, this message translates to:
  /// **'Mark Pending'**
  String get markPending;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get deleteTaskConfirm;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark modes'**
  String get darkModeDesc;

  /// No description provided for @imageQuality.
  ///
  /// In en, this message translates to:
  /// **'IMAGE QUALITY'**
  String get imageQuality;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @lowDesc.
  ///
  /// In en, this message translates to:
  /// **'Faster download, reduced resolution'**
  String get lowDesc;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @mediumDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced speed and quality'**
  String get mediumDesc;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @highDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum accuracy for analysis'**
  String get highDesc;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get data;

  /// No description provided for @detectionHistory.
  ///
  /// In en, this message translates to:
  /// **'Detection History'**
  String get detectionHistory;

  /// No description provided for @detectionHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'View analysis history'**
  String get detectionHistoryDesc;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get about;

  /// No description provided for @appNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Application Name'**
  String get appNameLabel;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'Detection History'**
  String get history;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No detection history yet'**
  String get noHistoryYet;

  /// No description provided for @noHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Your analyses will appear here'**
  String get noHistoryDesc;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all detection history?'**
  String get clearHistoryConfirm;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @loadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history'**
  String get loadingHistory;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'CHANGE PASSWORD'**
  String get changePassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password (leave blank to keep)'**
  String get newPassword;

  /// No description provided for @leaveBlank.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep current password'**
  String get leaveBlank;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveChanges;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT INFO'**
  String get accountInfo;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @confirmDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete this user permanently?'**
  String get confirmDeleteUser;

  /// No description provided for @userDeleted.
  ///
  /// In en, this message translates to:
  /// **'User deleted'**
  String get userDeleted;

  /// No description provided for @userCreated.
  ///
  /// In en, this message translates to:
  /// **'User created'**
  String get userCreated;

  /// No description provided for @userUpdated.
  ///
  /// In en, this message translates to:
  /// **'User updated'**
  String get userUpdated;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search by name, username, email, role...'**
  String get searchUsers;

  /// No description provided for @registeredOn.
  ///
  /// In en, this message translates to:
  /// **'Registered:'**
  String get registeredOn;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @defaultPassword.
  ///
  /// In en, this message translates to:
  /// **'Password (default: agriscan123)'**
  String get defaultPassword;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'username already exists'**
  String get usernameRequired;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get nameRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'at least 8 digits'**
  String get phoneInvalid;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidCredentials;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginWithQr.
  ///
  /// In en, this message translates to:
  /// **'Sign in with QR Code'**
  String get loginWithQr;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @farmNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Farm name is required'**
  String get farmNameRequired;

  /// No description provided for @regNoRequired.
  ///
  /// In en, this message translates to:
  /// **'Registration number is required'**
  String get regNoRequired;

  /// No description provided for @regNoInvalid.
  ///
  /// In en, this message translates to:
  /// **'Registration number must contain at least 5 digits'**
  String get regNoInvalid;

  /// No description provided for @passwordMin.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordMin;

  /// No description provided for @usernameMin.
  ///
  /// In en, this message translates to:
  /// **'At least 3 characters'**
  String get usernameMin;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Smart Disease Detection'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Scan any plant leaf and instantly identify diseases using advanced AI technology'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Intelligence'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Get personalized fertilizer recommendations based on your soil and crop type'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Market & Planning'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Track real-time crop prices and plan your agricultural calendar efficiently'**
  String get onboardingDesc3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @cropInformation.
  ///
  /// In en, this message translates to:
  /// **'Crop Information'**
  String get cropInformation;

  /// No description provided for @soilProperties.
  ///
  /// In en, this message translates to:
  /// **'Soil Properties'**
  String get soilProperties;

  /// No description provided for @weatherConditions.
  ///
  /// In en, this message translates to:
  /// **'Weather Conditions'**
  String get weatherConditions;

  /// No description provided for @crop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get crop;

  /// No description provided for @stage.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get stage;

  /// No description provided for @soilType.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get soilType;

  /// No description provided for @nitrogenLabel.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen (N) kg/ha'**
  String get nitrogenLabel;

  /// No description provided for @phosphorusLabel.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus (P) kg/ha'**
  String get phosphorusLabel;

  /// No description provided for @potassiumLabel.
  ///
  /// In en, this message translates to:
  /// **'Potassium (K) kg/ha'**
  String get potassiumLabel;

  /// No description provided for @soilPh.
  ///
  /// In en, this message translates to:
  /// **'Soil pH'**
  String get soilPh;

  /// No description provided for @organicCarbon.
  ///
  /// In en, this message translates to:
  /// **'Organic Carbon (%)'**
  String get organicCarbon;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature (°C)'**
  String get temperature;

  /// No description provided for @rainfall.
  ///
  /// In en, this message translates to:
  /// **'Rainfall (mm)'**
  String get rainfall;

  /// No description provided for @getRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Get Recommendation'**
  String get getRecommendation;

  /// No description provided for @fertilizerResult.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Recommendation'**
  String get fertilizerResult;

  /// No description provided for @fertilizerDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your soil and crop details to get personalized fertilizer recommendations.'**
  String get fertilizerDesc;

  /// No description provided for @selectStage.
  ///
  /// In en, this message translates to:
  /// **'Please select a stage'**
  String get selectStage;

  /// No description provided for @selectSoil.
  ///
  /// In en, this message translates to:
  /// **'Please select a soil type'**
  String get selectSoil;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @nitrogenRange.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen must be between 0 and 80 kg/ha'**
  String get nitrogenRange;

  /// No description provided for @phosphorusRange.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus must be between 0 and 50 kg/ha'**
  String get phosphorusRange;

  /// No description provided for @potassiumRange.
  ///
  /// In en, this message translates to:
  /// **'Potassium must be between 0 and 50 kg/ha'**
  String get potassiumRange;

  /// No description provided for @phRange.
  ///
  /// In en, this message translates to:
  /// **'pH must be between 5.5 and 8.0'**
  String get phRange;

  /// No description provided for @carbonRange.
  ///
  /// In en, this message translates to:
  /// **'Organic carbon must be between 0 and 1.5%'**
  String get carbonRange;

  /// No description provided for @tempRange.
  ///
  /// In en, this message translates to:
  /// **'Temperature must be between 18 and 38°C'**
  String get tempRange;

  /// No description provided for @rainfallRange.
  ///
  /// In en, this message translates to:
  /// **'Rainfall must be between 0 and 120 mm'**
  String get rainfallRange;

  /// No description provided for @failedDropdowns.
  ///
  /// In en, this message translates to:
  /// **'Failed to load crop data. Check your connection.'**
  String get failedDropdowns;

  /// No description provided for @failedRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Failed to get recommendation. Check your connection.'**
  String get failedRecommendation;

  /// No description provided for @ureaLabel.
  ///
  /// In en, this message translates to:
  /// **'Urea'**
  String get ureaLabel;

  /// No description provided for @dapLabel.
  ///
  /// In en, this message translates to:
  /// **'DAP'**
  String get dapLabel;

  /// No description provided for @mopLabel.
  ///
  /// In en, this message translates to:
  /// **'MOP'**
  String get mopLabel;

  /// No description provided for @sspLabel.
  ///
  /// In en, this message translates to:
  /// **'SSP'**
  String get sspLabel;

  /// No description provided for @compostLabel.
  ///
  /// In en, this message translates to:
  /// **'Compost'**
  String get compostLabel;

  /// No description provided for @perAcre.
  ///
  /// In en, this message translates to:
  /// **'per hectare'**
  String get perAcre;

  /// No description provided for @fertilizerGuide.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Guide'**
  String get fertilizerGuide;

  /// No description provided for @abbreviation.
  ///
  /// In en, this message translates to:
  /// **'Abbrev.'**
  String get abbreviation;

  /// No description provided for @mainElement.
  ///
  /// In en, this message translates to:
  /// **'Main Element'**
  String get mainElement;

  /// No description provided for @usage.
  ///
  /// In en, this message translates to:
  /// **'What it does'**
  String get usage;

  /// No description provided for @ureFullName.
  ///
  /// In en, this message translates to:
  /// **'Urea'**
  String get ureFullName;

  /// No description provided for @ureElement.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen (N) 46%'**
  String get ureElement;

  /// No description provided for @ureUsage.
  ///
  /// In en, this message translates to:
  /// **'Promotes leaf growth and green color. Concentrated nitrogen fertilizer for rapid growth.'**
  String get ureUsage;

  /// No description provided for @dapFullName.
  ///
  /// In en, this message translates to:
  /// **'Di-Ammonium Phosphate'**
  String get dapFullName;

  /// No description provided for @dapElement.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen (N) 18% + Phosphorus (P) 46%'**
  String get dapElement;

  /// No description provided for @dapUsage.
  ///
  /// In en, this message translates to:
  /// **'Starter fertilizer. Phosphorus supports root development and flowering.'**
  String get dapUsage;

  /// No description provided for @mopFullName.
  ///
  /// In en, this message translates to:
  /// **'Muriate of Potash'**
  String get mopFullName;

  /// No description provided for @mopElement.
  ///
  /// In en, this message translates to:
  /// **'Potassium (K) 60%'**
  String get mopElement;

  /// No description provided for @mopUsage.
  ///
  /// In en, this message translates to:
  /// **'Improves fruit size, taste, disease resistance and drought tolerance.'**
  String get mopUsage;

  /// No description provided for @sspFullName.
  ///
  /// In en, this message translates to:
  /// **'Single Super Phosphate'**
  String get sspFullName;

  /// No description provided for @sspElement.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus (P) 16-20% + Sulfur + Calcium'**
  String get sspElement;

  /// No description provided for @sspUsage.
  ///
  /// In en, this message translates to:
  /// **'Less concentrated than DAP. Also provides sulfur and calcium for sulfur-deficient soils.'**
  String get sspUsage;

  /// No description provided for @compostFullName.
  ///
  /// In en, this message translates to:
  /// **'Compost (Organic Matter)'**
  String get compostFullName;

  /// No description provided for @compostElement.
  ///
  /// In en, this message translates to:
  /// **'Organic carbon + NPK micro-nutrients'**
  String get compostElement;

  /// No description provided for @compostUsage.
  ///
  /// In en, this message translates to:
  /// **'Improves soil structure, water retention and microbial activity. Long-term soil health.'**
  String get compostUsage;

  /// No description provided for @cropLimitNote.
  ///
  /// In en, this message translates to:
  /// **'Available crops are limited to the training dataset (5 crops).'**
  String get cropLimitNote;

  /// No description provided for @chipPlantSpecies.
  ///
  /// In en, this message translates to:
  /// **'Plant species'**
  String get chipPlantSpecies;

  /// No description provided for @chipAccuracy.
  ///
  /// In en, this message translates to:
  /// **'AI accuracy'**
  String get chipAccuracy;

  /// No description provided for @chipAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get chipAnalysis;

  /// No description provided for @chipCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get chipCustom;

  /// No description provided for @chipCropPlans.
  ///
  /// In en, this message translates to:
  /// **'Crop plans'**
  String get chipCropPlans;

  /// No description provided for @chipDosing.
  ///
  /// In en, this message translates to:
  /// **'Dosing'**
  String get chipDosing;

  /// No description provided for @chipLive.
  ///
  /// In en, this message translates to:
  /// **' Live prices'**
  String get chipLive;

  /// No description provided for @chipCalendar.
  ///
  /// In en, this message translates to:
  /// **'Cultural agenda'**
  String get chipCalendar;

  /// No description provided for @chipProducts.
  ///
  /// In en, this message translates to:
  /// **'Product catalog'**
  String get chipProducts;

  /// No description provided for @chipSoilAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Soil analysis'**
  String get chipSoilAnalysis;

  /// No description provided for @chipNpk.
  ///
  /// In en, this message translates to:
  /// **'N·P·K'**
  String get chipNpk;

  /// No description provided for @myQrCode.
  ///
  /// In en, this message translates to:
  /// **'My QR Code'**
  String get myQrCode;

  /// No description provided for @scanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scanner;

  /// No description provided for @yourPersonalQr.
  ///
  /// In en, this message translates to:
  /// **'Your personal QR Code'**
  String get yourPersonalQr;

  /// No description provided for @scanToLogin.
  ///
  /// In en, this message translates to:
  /// **'Have someone scan this code to log in'**
  String get scanToLogin;

  /// No description provided for @saveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to Gallery'**
  String get saveToGallery;

  /// No description provided for @qrSaved.
  ///
  /// In en, this message translates to:
  /// **'QR code saved to gallery!'**
  String get qrSaved;

  /// No description provided for @qrSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving QR code'**
  String get qrSaveError;

  /// No description provided for @pointCamera.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at an AgriScan QR code'**
  String get pointCamera;

  /// No description provided for @importFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Import from Gallery'**
  String get importFromGallery;

  /// No description provided for @noQrFound.
  ///
  /// In en, this message translates to:
  /// **'No QR code found in this image'**
  String get noQrFound;

  /// No description provided for @invalidQr.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code'**
  String get invalidQr;

  /// No description provided for @qrSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'This QR code is unique to your account. Do not share it with strangers.'**
  String get qrSecurityNote;

  /// No description provided for @retryLoad.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLoad;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to see your QR code'**
  String get loginRequired;

  /// No description provided for @qrLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load QR code'**
  String get qrLoadError;

  /// No description provided for @yourQrCode.
  ///
  /// In en, this message translates to:
  /// **'Your QR Code'**
  String get yourQrCode;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreated;

  /// No description provided for @saveYourQr.
  ///
  /// In en, this message translates to:
  /// **'Save your personal QR code'**
  String get saveYourQr;

  /// No description provided for @qrWarning.
  ///
  /// In en, this message translates to:
  /// **'This QR code is shown only once. Download it now to use it for login.'**
  String get qrWarning;

  /// No description provided for @downloadToGallery.
  ///
  /// In en, this message translates to:
  /// **'Download to Gallery'**
  String get downloadToGallery;

  /// No description provided for @qrDownloaded.
  ///
  /// In en, this message translates to:
  /// **'QR code saved!'**
  String get qrDownloaded;

  /// No description provided for @continueToLogin.
  ///
  /// In en, this message translates to:
  /// **'Continue to login'**
  String get continueToLogin;

  /// No description provided for @qrProfileNote.
  ///
  /// In en, this message translates to:
  /// **'You can find this QR code in your profile after logging in.'**
  String get qrProfileNote;

  /// No description provided for @stockAvailable.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get stockAvailable;

  /// No description provided for @stockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get stockUnavailable;

  /// No description provided for @toggleStock.
  ///
  /// In en, this message translates to:
  /// **'Toggle stock status'**
  String get toggleStock;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted successfully'**
  String get taskDeleted;

  /// No description provided for @planDeleted.
  ///
  /// In en, this message translates to:
  /// **'Plan deleted successfully'**
  String get planDeleted;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This email address is already associated with an account'**
  String get emailAlreadyExists;

  /// No description provided for @usernameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get usernameAlreadyExists;

  /// No description provided for @failedToLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products'**
  String get failedToLoadProducts;

  /// No description provided for @failedToLoadPrices.
  ///
  /// In en, this message translates to:
  /// **'Failed to load prices'**
  String get failedToLoadPrices;

  /// No description provided for @failedToLoadUsers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load users'**
  String get failedToLoadUsers;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// No description provided for @failedToLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history'**
  String get failedToLoadHistory;

  /// No description provided for @farmerAccessOnly.
  ///
  /// In en, this message translates to:
  /// **'Access reserved for farmers'**
  String get farmerAccessOnly;

  /// No description provided for @adminAccessOnly.
  ///
  /// In en, this message translates to:
  /// **'Access reserved for administrators'**
  String get adminAccessOnly;

  /// No description provided for @planName.
  ///
  /// In en, this message translates to:
  /// **'Plan name'**
  String get planName;

  /// No description provided for @administrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administrator;

  /// No description provided for @techStack.
  ///
  /// In en, this message translates to:
  /// **'Flutter + Node.js + AI'**
  String get techStack;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
