import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Short label used in ad widgets.
  ///
  /// In en, this message translates to:
  /// **'Ad'**
  String get adsAd;

  /// No description provided for @reviewRateThis.
  ///
  /// In en, this message translates to:
  /// **'Rate this app'**
  String get reviewRateThis;

  /// No description provided for @appUpdateANewer.
  ///
  /// In en, this message translates to:
  /// **'a newer version of Android'**
  String get appUpdateANewer;

  /// No description provided for @appUpdateOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings > System > System update. Menu names may differ by brand.'**
  String get appUpdateOpenSettings;

  /// No description provided for @appUpdateOpenSettingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'Open Settings > General > Software Update.'**
  String get appUpdateOpenSettingsGeneral;

  /// No description provided for @appUpdateUpdateBahasa.
  ///
  /// In en, this message translates to:
  /// **'Update Bahasa Master'**
  String get appUpdateUpdateBahasa;

  /// No description provided for @appUpdateYourDevice.
  ///
  /// In en, this message translates to:
  /// **'Your device does not support the new version'**
  String get appUpdateYourDevice;

  /// No description provided for @appUpdateYouCan.
  ///
  /// In en, this message translates to:
  /// **'You can keep using the installed version. Update your OS before installing a new app version.'**
  String get appUpdateYouCan;

  /// No description provided for @appUpdateIfNo.
  ///
  /// In en, this message translates to:
  /// **'If no OS update is available, use another compatible device. For help: rabih@codeverta.com.'**
  String get appUpdateIfNo;

  /// No description provided for @appUpdateIfThe.
  ///
  /// In en, this message translates to:
  /// **'If the update does not appear in the store, check your store account and whether the release is available for your device. Contact rabih@codeverta.com if your device is reported as incompatible.'**
  String get appUpdateIfThe;

  /// Short label used in app update gate.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get appUpdateChecking;

  /// No description provided for @appUpdateContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with this version'**
  String get appUpdateContinueWith;

  /// Short label used in app update gate.
  ///
  /// In en, this message translates to:
  /// **'Opening store…'**
  String get appUpdateOpeningStore;

  /// Short label used in app update gate.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get appUpdateUpdateNow;

  /// No description provided for @xpCouldNot.
  ///
  /// In en, this message translates to:
  /// **'Could not claim 2× XP. Check your connection and try again.'**
  String get xpCouldNot;

  /// No description provided for @xpTheAd.
  ///
  /// In en, this message translates to:
  /// **'The ad was closed early. Watch it to the end to get 2× XP.'**
  String get xpTheAd;

  /// No description provided for @xpNoAd.
  ///
  /// In en, this message translates to:
  /// **'No ad is available right now. Try again in a moment.'**
  String get xpNoAd;

  /// No description provided for @xpYouWatched.
  ///
  /// In en, this message translates to:
  /// **'You watched the ad, but Google\'s confirmation hasn\'t arrived yet. Check again.'**
  String get xpYouWatched;

  /// No description provided for @xpClaim2.
  ///
  /// In en, this message translates to:
  /// **'Claim 2× XP'**
  String get xpClaim2;

  /// Short label used in double xp button.
  ///
  /// In en, this message translates to:
  /// **'Review again'**
  String get xpReviewAgain;

  /// Short label used in notification settings screen.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsNotifications;

  /// No description provided for @notificationsBahasaMaster.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Master announcements'**
  String get notificationsBahasaMaster;

  /// No description provided for @notificationsReceiveApp.
  ///
  /// In en, this message translates to:
  /// **'Receive app news and study information. You can change this choice at any time. Announcements never include your personal account data.'**
  String get notificationsReceiveApp;

  /// Short label used in notification settings screen.
  ///
  /// In en, this message translates to:
  /// **'Receive announcements'**
  String get notificationsReceiveAnnouncements;

  /// No description provided for @notificationsEnabledOn.
  ///
  /// In en, this message translates to:
  /// **'Enabled on this device'**
  String get notificationsEnabledOn;

  /// No description provided for @notificationsTurnedOn.
  ///
  /// In en, this message translates to:
  /// **'Turned on; check device permission and connection'**
  String get notificationsTurnedOn;

  /// Short label used in notification settings screen.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get notificationsOff;

  /// No description provided for @notificationsAndroidNotification.
  ///
  /// In en, this message translates to:
  /// **'Android notification settings'**
  String get notificationsAndroidNotification;

  /// No description provided for @notificationsTryConnecting.
  ///
  /// In en, this message translates to:
  /// **'Try connecting again'**
  String get notificationsTryConnecting;

  /// Short label used in display settings screen.
  ///
  /// In en, this message translates to:
  /// **'Display settings'**
  String get settingsDisplaySettings;

  /// No description provided for @settingsAdjustReading.
  ///
  /// In en, this message translates to:
  /// **'Adjust reading aids throughout the app.'**
  String get settingsAdjustReading;

  /// Short label used in display settings screen.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsChooseLight.
  ///
  /// In en, this message translates to:
  /// **'Choose light, dark, or follow your phone setting.'**
  String get settingsChooseLight;

  /// Short label used in display settings screen.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystem;

  /// Short label used in display settings screen.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsLight;

  /// Short label used in display settings screen.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsDark;

  /// No description provided for @settingsStudyTime.
  ///
  /// In en, this message translates to:
  /// **'Study time zone'**
  String get settingsStudyTime;

  /// No description provided for @settingsThisTime.
  ///
  /// In en, this message translates to:
  /// **'This time zone sets the day boundary for streaks and study progress.'**
  String get settingsThisTime;

  /// Short label used in display settings screen.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get commonTranslation;

  /// No description provided for @settingsShowMeanings.
  ///
  /// In en, this message translates to:
  /// **'Show meanings for examples and reading passages.'**
  String get settingsShowMeanings;

  /// Short label used in settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsSettings;

  /// Short label used in settings screen.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get settingsNotificationSettings;

  /// Short label used in settings screen.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// Short label used in settings screen.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// Short label used in settings screen.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsSignOutOf.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account?'**
  String get settingsSignOutOf;

  /// No description provided for @settingsPersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal data on this device will be deleted. Unsynced progress and offline ratings will also be lost. Connect to the internet before signing out to sync them.'**
  String get settingsPersonalData;

  /// Short label used in settings screen.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @settingsPermanentlyDelete.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account?'**
  String get settingsPermanentlyDelete;

  /// No description provided for @settingsYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile, progress, achievements, and login session will be deleted. Store payments are not automatically refunded. A minimum transaction record is retained to support restores and prevent abuse. After creating a new account, use Restore with the purchasing store account.'**
  String get settingsYourProfile;

  /// No description provided for @settingsYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account has not been deleted. Check your connection and try again.'**
  String get settingsYourAccount;

  /// No description provided for @settingsHelpImprove.
  ///
  /// In en, this message translates to:
  /// **'Help improve the app'**
  String get settingsHelpImprove;

  /// No description provided for @settingsShareAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage data (which features you open). No personal data is included.'**
  String get settingsShareAnonymous;

  /// No description provided for @settingsYourLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Your leaderboard setting was not saved. Check your connection and try again.'**
  String get settingsYourLeaderboard;

  /// No description provided for @settingsHideMe.
  ///
  /// In en, this message translates to:
  /// **'Hide me from the leaderboard'**
  String get settingsHideMe;

  /// No description provided for @settingsYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name and XP are not shown on the leaderboard. XP and level still count.'**
  String get settingsYourName;

  /// No description provided for @settingsAdPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy choices'**
  String get settingsAdPrivacy;

  /// No description provided for @settingsSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your study time zone.'**
  String get settingsSignIn;

  /// No description provided for @settingsStudyTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Study time zone could not be loaded.'**
  String get settingsStudyTimeZone;

  /// No description provided for @settingsAccountTime.
  ///
  /// In en, this message translates to:
  /// **'Account time zone'**
  String get settingsAccountTime;

  /// No description provided for @settingsChooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose time zone'**
  String get settingsChooseTime;

  /// No description provided for @settingsSaveTime.
  ///
  /// In en, this message translates to:
  /// **'Save time zone'**
  String get settingsSaveTime;

  /// No description provided for @settingsATime.
  ///
  /// In en, this message translates to:
  /// **'A time zone change takes effect only after you save it.'**
  String get settingsATime;

  /// No description provided for @settingsStudyTimeZoneUpdated.
  ///
  /// In en, this message translates to:
  /// **'Study time zone updated.'**
  String get settingsStudyTimeZoneUpdated;

  /// No description provided for @settingsCouldNot.
  ///
  /// In en, this message translates to:
  /// **'Could not update study time zone.'**
  String get settingsCouldNot;

  /// Short label used in study timezone settings screen.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @unlockThisContent.
  ///
  /// In en, this message translates to:
  /// **'This content is locked'**
  String get unlockThisContent;

  /// No description provided for @unlockThisContentRequires.
  ///
  /// In en, this message translates to:
  /// **'This content requires Lifetime Access.'**
  String get unlockThisContentRequires;

  /// No description provided for @unlockUnlockIt.
  ///
  /// In en, this message translates to:
  /// **'Unlock it by watching one ad, or get Lifetime Access to unlock everything.'**
  String get unlockUnlockIt;

  /// Short label used in locked content.
  ///
  /// In en, this message translates to:
  /// **'See Lifetime'**
  String get unlockSeeLifetime;

  /// No description provided for @unlockUnlockThis.
  ///
  /// In en, this message translates to:
  /// **'Unlock this content'**
  String get unlockUnlockThis;

  /// Short label used in locked content.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get unlockLocked;

  /// No description provided for @unlockTheAd.
  ///
  /// In en, this message translates to:
  /// **'The ad was closed early. Watch it to the end to unlock.'**
  String get unlockTheAd;

  /// No description provided for @unlockNoAd.
  ///
  /// In en, this message translates to:
  /// **'No ad is available right now. Try again in a moment.'**
  String get unlockNoAd;

  /// No description provided for @unlockYouWatched.
  ///
  /// In en, this message translates to:
  /// **'You watched the ad, but Google\'s confirmation hasn\'t arrived yet. Check again.'**
  String get unlockYouWatched;

  /// No description provided for @unlockCouldNot.
  ///
  /// In en, this message translates to:
  /// **'Could not unlock. Check your connection and try again.'**
  String get unlockCouldNot;

  /// No description provided for @unlockWatchOne.
  ///
  /// In en, this message translates to:
  /// **'Watch one short ad to unlock this, or get Lifetime Access to unlock everything without ads.'**
  String get unlockWatchOne;

  /// Short label used in unlock sheet.
  ///
  /// In en, this message translates to:
  /// **'Review again'**
  String get unlockReviewAgain;

  /// No description provided for @unlockWatchAn.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad (free)'**
  String get unlockWatchAn;

  /// Short label used in unlock sheet.
  ///
  /// In en, this message translates to:
  /// **'Get Lifetime'**
  String get unlockGetLifetime;

  /// No description provided for @legalThePage.
  ///
  /// In en, this message translates to:
  /// **'The page could not be opened. Try again.'**
  String get legalThePage;

  /// Short label used in skeleton.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// Short label used in ai chat sheet.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get aiChatAskAi;

  /// No description provided for @aiChatTodaysAsk.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Ask AI limit is reached'**
  String get aiChatTodaysAsk;

  /// No description provided for @aiChatTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again tomorrow, or get Lifetime Access for more questions every day.'**
  String get aiChatTryAgain;

  /// Short label used in ai chat sheet.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get aiChatLater;

  /// Short label used in ai chat sheet.
  ///
  /// In en, this message translates to:
  /// **'See Lifetime'**
  String get aiChatSeeLifetime;

  /// No description provided for @aiChatDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached'**
  String get aiChatDailyLimit;

  /// No description provided for @aiChatDailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached, please try again tomorrow.'**
  String get aiChatDailyLimitReached;

  /// Short label used in ai chat sheet.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get aiChatOk;

  /// Short label used in ai chat sheet.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation?'**
  String get aiChatDeleteConversation;

  /// No description provided for @aiChatTheConversation.
  ///
  /// In en, this message translates to:
  /// **'The conversation for this lesson will be removed from the app.'**
  String get aiChatTheConversation;

  /// Short label used in ai chat sheet.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get aiChatClear;

  /// No description provided for @aiChatCouldNot.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the conversation.'**
  String get aiChatCouldNot;

  /// Short label used in ai chat sheet.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get aiChatOptions;

  /// Short label used in ai chat sheet.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get aiChatDeleteConversation2;

  /// No description provided for @aiChatInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Internet connection required'**
  String get aiChatInternetConnection;

  /// No description provided for @aiChatAskAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about this lesson, or pick a quick action below.'**
  String get aiChatAskAnything;

  /// Short label used in ai chat sheet.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get aiChatSend;

  /// No description provided for @aiChatTodaysAskAi.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Ask AI messages are used'**
  String get aiChatTodaysAskAi;

  /// No description provided for @aiChatTodaysFree.
  ///
  /// In en, this message translates to:
  /// **'Today\'s free questions are used up'**
  String get aiChatTodaysFree;

  /// No description provided for @aiChatWatchAShort.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to send this question.'**
  String get aiChatWatchAShort;

  /// Short label used in ai chat sheet.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get aiChatWatch;

  /// No description provided for @ankiCouldNot.
  ///
  /// In en, this message translates to:
  /// **'Could not load media.'**
  String get ankiCouldNot;

  /// No description provided for @ankiCouldNotPlay.
  ///
  /// In en, this message translates to:
  /// **'Could not play audio. Check your connection and try again.'**
  String get ankiCouldNotPlay;

  /// Short label used in anki import screen.
  ///
  /// In en, this message translates to:
  /// **'Import deck'**
  String get ankiImportDeck;

  /// No description provided for @ankiBringYour.
  ///
  /// In en, this message translates to:
  /// **'Bring your flashcards here'**
  String get ankiBringYour;

  /// No description provided for @ankiChooseAn.
  ///
  /// In en, this message translates to:
  /// **'Choose an Anki APKG, CSV, or Bahasa Master JSON file. Maximum 20 MB and 10,000 cards per deck. Preview the file before saving.'**
  String get ankiChooseAn;

  /// Short label used in anki import screen.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get ankiDeckName;

  /// No description provided for @ankiPersonalDecks.
  ///
  /// In en, this message translates to:
  /// **'Personal decks are saved to your account without replacing built-in decks. Review schedules start fresh; Anki progress is not transferred.'**
  String get ankiPersonalDecks;

  /// No description provided for @ankiImportAs.
  ///
  /// In en, this message translates to:
  /// **'Import as a personal deck'**
  String get ankiImportAs;

  /// No description provided for @ankiFileFormats.
  ///
  /// In en, this message translates to:
  /// **'File formats & media'**
  String get ankiFileFormats;

  /// No description provided for @ankiCsvColumns.
  ///
  /// In en, this message translates to:
  /// **'CSV columns: front, answers, meaning, imageUrl, audio. Answers accepts text or a JSON array. APKG/JSON includes bundled media; external media URLs remain links. HTML is converted to text. Cloze or unsupported card templates are rejected with an explanation.'**
  String get ankiCsvColumns;

  /// No description provided for @ankiReviewA.
  ///
  /// In en, this message translates to:
  /// **'REVIEW A LITTLE, REMEMBER MORE'**
  String get ankiReviewA;

  /// No description provided for @ankiChooseA.
  ///
  /// In en, this message translates to:
  /// **'Choose a deck and build a vocabulary review habit'**
  String get ankiChooseA;

  /// No description provided for @ankiDataSources.
  ///
  /// In en, this message translates to:
  /// **'Data sources & licenses'**
  String get ankiDataSources;

  /// No description provided for @ankiALittle.
  ///
  /// In en, this message translates to:
  /// **'A little today.\nRemember more tomorrow.'**
  String get ankiALittle;

  /// No description provided for @ankiChooseADeck.
  ///
  /// In en, this message translates to:
  /// **'Choose a deck topic, flip each card to reveal the answer, then rate how easily you remembered it.'**
  String get ankiChooseADeck;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Search decks'**
  String get ankiSearchDecks;

  /// No description provided for @ankiGreetingsFood.
  ///
  /// In en, this message translates to:
  /// **'Greetings, food, numbers...'**
  String get ankiGreetingsFood;

  /// No description provided for @ankiNoDecks.
  ///
  /// In en, this message translates to:
  /// **'No decks found. Try another name or category.'**
  String get ankiNoDecks;

  /// No description provided for @ankiSavedData.
  ///
  /// In en, this message translates to:
  /// **'Saved data · Not available yet'**
  String get ankiSavedData;

  /// No description provided for @ankiReadyTo.
  ///
  /// In en, this message translates to:
  /// **'Ready to study'**
  String get ankiReadyTo;

  /// No description provided for @ankiAboutThis.
  ///
  /// In en, this message translates to:
  /// **'About this deck'**
  String get ankiAboutThis;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Personal deck'**
  String get ankiPersonalDeck;

  /// No description provided for @ankiDeletePersonal.
  ///
  /// In en, this message translates to:
  /// **'Delete personal deck'**
  String get ankiDeletePersonal;

  /// No description provided for @ankiHowTo.
  ///
  /// In en, this message translates to:
  /// **'How to study'**
  String get ankiHowTo;

  /// No description provided for @ankiEachSession.
  ///
  /// In en, this message translates to:
  /// **'Each session has up to 20 cards. Due reviews come first, followed by new cards. Your ratings determine the next review schedule.'**
  String get ankiEachSession;

  /// No description provided for @ankiYourStudy.
  ///
  /// In en, this message translates to:
  /// **'Your study progress'**
  String get ankiYourStudy;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Studied'**
  String get ankiStudied;

  /// No description provided for @ankiDueFor.
  ///
  /// In en, this message translates to:
  /// **'Due for review'**
  String get ankiDueFor;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'New cards'**
  String get ankiNewCards;

  /// No description provided for @ankiYourSchedule.
  ///
  /// In en, this message translates to:
  /// **'Your schedule and progress are saved to your account.'**
  String get ankiYourSchedule;

  /// No description provided for @ankiSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save your progress and review schedule.'**
  String get ankiSignIn;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Deck availability'**
  String get ankiDeckAvailability;

  /// No description provided for @ankiSignInTo.
  ///
  /// In en, this message translates to:
  /// **'Sign in to study'**
  String get ankiSignInTo;

  /// No description provided for @ankiUnlockWith.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Lifetime Access'**
  String get ankiUnlockWith;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Start review'**
  String get ankiStartReview;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get commonStartLearning;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Deck preview'**
  String get ankiDeckPreview;

  /// No description provided for @ankiThePreview.
  ///
  /// In en, this message translates to:
  /// **'The preview shows sample questions and answers.'**
  String get ankiThePreview;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Data source'**
  String get ankiDataSource;

  /// No description provided for @ankiCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open the source link.'**
  String get ankiCouldNotOpen;

  /// No description provided for @ankiViewDeck.
  ///
  /// In en, this message translates to:
  /// **'View deck source data'**
  String get ankiViewDeck;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Flashcard study'**
  String get ankiFlashcardStudy;

  /// No description provided for @ankiStudySession.
  ///
  /// In en, this message translates to:
  /// **'Study session is unavailable.'**
  String get ankiStudySession;

  /// No description provided for @ankiNoCards.
  ///
  /// In en, this message translates to:
  /// **'No cards are due to study.'**
  String get ankiNoCards;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Session complete!'**
  String get ankiSessionComplete;

  /// No description provided for @ankiCheckThe.
  ///
  /// In en, this message translates to:
  /// **'Check the next card'**
  String get ankiCheckThe;

  /// No description provided for @ankiBackTo.
  ///
  /// In en, this message translates to:
  /// **'Back to deck details'**
  String get ankiBackTo;

  /// No description provided for @ankiRatingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Ratings saved on this device · waiting to sync'**
  String get ankiRatingsSaved;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ankiGood;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get ankiAgain;

  /// No description provided for @ankiSwipeRight.
  ///
  /// In en, this message translates to:
  /// **'Swipe right if you remembered it, left to study it again.'**
  String get ankiSwipeRight;

  /// No description provided for @ankiTapThe.
  ///
  /// In en, this message translates to:
  /// **'Tap the card to flip it.'**
  String get ankiTapThe;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get ankiShowAnswer;

  /// No description provided for @ankiHowEasily.
  ///
  /// In en, this message translates to:
  /// **'How easily did you remember it?'**
  String get ankiHowEasily;

  /// No description provided for @ankiTrySaving.
  ///
  /// In en, this message translates to:
  /// **'Try saving again'**
  String get ankiTrySaving;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get ankiHard;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get ankiEasy;

  /// No description provided for @ankiRateEach.
  ///
  /// In en, this message translates to:
  /// **'Rate each card based on what you remembered before revealing the answer. You can leave at any time; each successful rating is saved.'**
  String get ankiRateEach;

  /// No description provided for @ankiCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load the deck. Try again.'**
  String get ankiCouldNotLoad;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get commonSignIn;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Access'**
  String get commonLifetimeAccess;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Reload session'**
  String get ankiReloadSession;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @ankiQuestionAnswer.
  ///
  /// In en, this message translates to:
  /// **'QUESTION & ANSWER'**
  String get ankiQuestionAnswer;

  /// No description provided for @ankiTryTo.
  ///
  /// In en, this message translates to:
  /// **'TRY TO REMEMBER FIRST'**
  String get ankiTryTo;

  /// Short label used in anki screens.
  ///
  /// In en, this message translates to:
  /// **'Content license'**
  String get ankiContentLicense;

  /// Short label used in anki transfer actions.
  ///
  /// In en, this message translates to:
  /// **'Export deck'**
  String get ankiExportDeck;

  /// No description provided for @ankiExportIncludes.
  ///
  /// In en, this message translates to:
  /// **'Export includes all cards, up to 10,000 per deck, without review schedules. APKG/JSON includes bundled images/audio; external media remains linked.'**
  String get ankiExportIncludes;

  /// No description provided for @ankiDeletePersonalDeck.
  ///
  /// In en, this message translates to:
  /// **'Delete personal deck?'**
  String get ankiDeletePersonalDeck;

  /// No description provided for @ankiThisDeck.
  ///
  /// In en, this message translates to:
  /// **'This deck’s cards, media, and review schedules will be deleted from your account. Export a backup first if needed.'**
  String get ankiThisDeck;

  /// Short label used in anki transfer actions.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get ankiClear;

  /// No description provided for @ankiChooseAnAnki.
  ///
  /// In en, this message translates to:
  /// **'Choose an Anki deck'**
  String get ankiChooseAnAnki;

  /// No description provided for @ankiPracticeWith.
  ///
  /// In en, this message translates to:
  /// **'Practice with Anki cards'**
  String get ankiPracticeWith;

  /// Short label used in login screen.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get authClose;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to start learning'**
  String get authSignIn;

  /// No description provided for @authSaveYour.
  ///
  /// In en, this message translates to:
  /// **'Save your progress, take exams, and unlock achievements.'**
  String get authSaveYour;

  /// No description provided for @authContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWith;

  /// No description provided for @authOrWith.
  ///
  /// In en, this message translates to:
  /// **'or with email'**
  String get authOrWith;

  /// No description provided for @authEnterA.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authEnterA;

  /// No description provided for @authPasswordMust.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get authPasswordMust;

  /// No description provided for @authContinueAs.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authContinueAs;

  /// No description provided for @billingLifetimeAccess.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Access is active.'**
  String get billingLifetimeAccess;

  /// No description provided for @billingCheckingStore.
  ///
  /// In en, this message translates to:
  /// **'Checking store price…'**
  String get billingCheckingStore;

  /// No description provided for @billingStorePrice.
  ///
  /// In en, this message translates to:
  /// **'Store price unavailable'**
  String get billingStorePrice;

  /// No description provided for @billingContinueFor.
  ///
  /// In en, this message translates to:
  /// **'Continue for free'**
  String get billingContinueFor;

  /// No description provided for @billingAboutYour.
  ///
  /// In en, this message translates to:
  /// **'About your purchase'**
  String get billingAboutYour;

  /// No description provided for @billingCanceledOr.
  ///
  /// In en, this message translates to:
  /// **'Canceled or pending payments do not activate access. A refund or revocation by the store locks premium access again. Deleting your account does not issue a refund; you can restore a purchase with the purchasing store account after signing into a new app account.'**
  String get billingCanceledOr;

  /// No description provided for @billingGooglePlay.
  ///
  /// In en, this message translates to:
  /// **'Google Play refund help'**
  String get billingGooglePlay;

  /// No description provided for @billingAppStore.
  ///
  /// In en, this message translates to:
  /// **'App Store refund help'**
  String get billingAppStore;

  /// No description provided for @billingSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get billingSignIn;

  /// No description provided for @billingExploreMy.
  ///
  /// In en, this message translates to:
  /// **'Explore my access'**
  String get billingExploreMy;

  /// Short label used in premium screen.
  ///
  /// In en, this message translates to:
  /// **'Access active'**
  String get billingAccessActive;

  /// Short label used in premium screen.
  ///
  /// In en, this message translates to:
  /// **'Payment pending'**
  String get billingPaymentPending;

  /// No description provided for @billingGetLifetime.
  ///
  /// In en, this message translates to:
  /// **'Get Lifetime Access'**
  String get billingGetLifetime;

  /// Short label used in premium screen.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get billingRestorePurchases;

  /// No description provided for @billingTryVerification.
  ///
  /// In en, this message translates to:
  /// **'Try verification again'**
  String get billingTryVerification;

  /// No description provided for @billingCouldNot.
  ///
  /// In en, this message translates to:
  /// **'Could not open the help link.'**
  String get billingCouldNot;

  /// No description provided for @billingOnePayment.
  ///
  /// In en, this message translates to:
  /// **'One payment. No monthly fees.'**
  String get billingOnePayment;

  /// No description provided for @billingSignInWithAnother.
  ///
  /// In en, this message translates to:
  /// **'Sign in with another account'**
  String get billingSignInWithAnother;

  /// No description provided for @billingLearnIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Learn Indonesian for daily life, work and travel'**
  String get billingLearnIndonesian;

  /// Short label used in premium screen.
  ///
  /// In en, this message translates to:
  /// **'LIFETIME ACTIVE'**
  String get billingLifetimeActive;

  /// No description provided for @billingOnePaymentLifetime.
  ///
  /// In en, this message translates to:
  /// **'ONE PAYMENT · LIFETIME ACCESS'**
  String get billingOnePaymentLifetime;

  /// No description provided for @billingLifetimeAccessIs.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Access is active'**
  String get billingLifetimeAccessIs;

  /// No description provided for @billingUnlockMore.
  ///
  /// In en, this message translates to:
  /// **'Unlock more.\nGo further.'**
  String get billingUnlockMore;

  /// No description provided for @billingStudyRead.
  ///
  /// In en, this message translates to:
  /// **'Study, read, and practise Indonesian in one place.'**
  String get billingStudyRead;

  /// No description provided for @homeOfflineShowing.
  ///
  /// In en, this message translates to:
  /// **'Offline · showing saved data. Prepared lessons are still available.'**
  String get homeOfflineShowing;

  /// Short label used in dashboard screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get homeWelcome;

  /// No description provided for @homeExploreFree.
  ///
  /// In en, this message translates to:
  /// **'Explore free lessons, then sign in to save your progress.'**
  String get homeExploreFree;

  /// Short label used in dashboard screen.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get homeNotificationSettings;

  /// Short label used in dashboard screen.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get homeDayStreak;

  /// No description provided for @homeKeepYour.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak by finishing a quiz today.'**
  String get homeKeepYour;

  /// No description provided for @homeFinish1.
  ///
  /// In en, this message translates to:
  /// **'Finish 1 quiz or exam today to start a streak.'**
  String get homeFinish1;

  /// No description provided for @homeHomeCould.
  ///
  /// In en, this message translates to:
  /// **'Home could not be loaded'**
  String get homeHomeCould;

  /// No description provided for @homeTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications for announcements and new lessons'**
  String get homeTurnOn;

  /// Short label used in home notification card.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get homeMaybeLater;

  /// Short label used in home notification card.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get homeTurnOn2;

  /// No description provided for @leaderboardSeeThis.
  ///
  /// In en, this message translates to:
  /// **'See this week\'s leaderboard'**
  String get leaderboardSeeThis;

  /// No description provided for @leaderboardNotRanked.
  ///
  /// In en, this message translates to:
  /// **'Not ranked this week yet — finish 1 lesson to join the competition'**
  String get leaderboardNotRanked;

  /// Short label used in home leaderboard widgets.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get leaderboardClose;

  /// Short label used in leaderboard screen.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get leaderboardThisWeek;

  /// Short label used in leaderboard screen.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get leaderboardAllTime;

  /// No description provided for @leaderboardInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Internet connection required'**
  String get leaderboardInternetConnection;

  /// No description provided for @leaderboardTheLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'The leaderboard could not be loaded'**
  String get leaderboardTheLeaderboard;

  /// No description provided for @leaderboardYouAre.
  ///
  /// In en, this message translates to:
  /// **'You are hidden from the leaderboard. Change this in Settings.'**
  String get leaderboardYouAre;

  /// No description provided for @leaderboardNobodyHas.
  ///
  /// In en, this message translates to:
  /// **'Nobody has earned XP this week yet. Be the first!'**
  String get leaderboardNobodyHas;

  /// No description provided for @leaderboardNoRankings.
  ///
  /// In en, this message translates to:
  /// **'No rankings yet.'**
  String get leaderboardNoRankings;

  /// No description provided for @leaderboardTotalXp.
  ///
  /// In en, this message translates to:
  /// **'Total XP since joining'**
  String get leaderboardTotalXp;

  /// No description provided for @leaderboardEarnXp.
  ///
  /// In en, this message translates to:
  /// **'Earn XP to get ranked'**
  String get leaderboardEarnXp;

  /// No description provided for @leaderboardSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to get ranked'**
  String get leaderboardSignIn;

  /// No description provided for @learnThisLesson.
  ///
  /// In en, this message translates to:
  /// **'This lesson is no longer available. Choose another lesson in its course.'**
  String get learnThisLesson;

  /// Short label used in continue learning section.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get commonContinueLearning;

  /// No description provided for @learnReturnTo.
  ///
  /// In en, this message translates to:
  /// **'Return to the lesson you last opened.'**
  String get learnReturnTo;

  /// Short label used in continue learning section.
  ///
  /// In en, this message translates to:
  /// **'Open course'**
  String get learnOpenCourse;

  /// No description provided for @learnUnlockLearning.
  ///
  /// In en, this message translates to:
  /// **'Unlock learning access'**
  String get learnUnlockLearning;

  /// Short label used in continue learning section.
  ///
  /// In en, this message translates to:
  /// **'Study again'**
  String get learnStudyAgain;

  /// Short label used in continue learning section.
  ///
  /// In en, this message translates to:
  /// **'Previously studied'**
  String get learnPreviouslyStudied;

  /// Short label used in continue learning section.
  ///
  /// In en, this message translates to:
  /// **'Lesson unavailable'**
  String get learnLessonUnavailable;

  /// No description provided for @learnLifetimeAccess.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Access required'**
  String get learnLifetimeAccess;

  /// Short label used in continue learning section.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get learnCompleted;

  /// Short label used in continue learning section.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get learnToday;

  /// Short label used in continue learning section.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get learnYesterday;

  /// Short label used in grammar course screen.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get grammarLesson;

  /// Short label used in grammar course screen.
  ///
  /// In en, this message translates to:
  /// **'Pattern List'**
  String get grammarPatternList;

  /// No description provided for @grammarMasterAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Master advanced patterns to grasp nuance and implied meaning'**
  String get grammarMasterAdvanced;

  /// No description provided for @grammarMasterNuance.
  ///
  /// In en, this message translates to:
  /// **'Master nuance and complex relationships between ideas'**
  String get grammarMasterNuance;

  /// No description provided for @grammarUnderstandNuance.
  ///
  /// In en, this message translates to:
  /// **'Understand nuance, relationships, and sentence intent'**
  String get grammarUnderstandNuance;

  /// No description provided for @grammarExpressPlans.
  ///
  /// In en, this message translates to:
  /// **'Express plans, reasons, and opinions'**
  String get grammarExpressPlans;

  /// No description provided for @grammarBuildIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Build Indonesian sentences from the ground up'**
  String get grammarBuildIndonesian;

  /// No description provided for @grammarStudyThe.
  ///
  /// In en, this message translates to:
  /// **'Study the patterns, read the examples, then take the quiz. Score at least 80% to complete the lesson.'**
  String get grammarStudyThe;

  /// No description provided for @grammarAllLessons.
  ///
  /// In en, this message translates to:
  /// **'All lessons are complete! You can still review the material and retake the quizzes.'**
  String get grammarAllLessons;

  /// No description provided for @grammarSearchFor.
  ///
  /// In en, this message translates to:
  /// **'Search for a topic or pattern, e.g. sudah'**
  String get grammarSearchFor;

  /// No description provided for @grammarNoMatching.
  ///
  /// In en, this message translates to:
  /// **'No matching lessons. Try another title or chapter.'**
  String get grammarNoMatching;

  /// No description provided for @grammarHowTo.
  ///
  /// In en, this message translates to:
  /// **'How to form it'**
  String get grammarHowTo;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get grammarExplanation;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Example sentences'**
  String get grammarExampleSentences;

  /// No description provided for @grammarAvoidThis.
  ///
  /// In en, this message translates to:
  /// **'Avoid this mistake'**
  String get grammarAvoidThis;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Start quiz'**
  String get grammarStartQuiz;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Next pattern'**
  String get grammarNextPattern;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get commonQuestion;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get commonCorrect;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Not quite'**
  String get commonNotQuite;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get commonCheckAnswer;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'View results'**
  String get commonViewResults;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get commonNextQuestion;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Provisional result'**
  String get commonProvisionalResult;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Lesson mastered!'**
  String get commonLessonMastered;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Keep practicing!'**
  String get grammarKeepPracticing;

  /// No description provided for @commonAnswersAre.
  ///
  /// In en, this message translates to:
  /// **'Answers are saved on this device. Completion, XP, and achievements will be verified when you reconnect.'**
  String get commonAnswersAre;

  /// No description provided for @grammarLessonProgress.
  ///
  /// In en, this message translates to:
  /// **'Lesson progress has been saved. Continue to the next pattern.'**
  String get grammarLessonProgress;

  /// No description provided for @grammarThePassing.
  ///
  /// In en, this message translates to:
  /// **'The passing score is 80%. Review the explanations and try the quiz again.'**
  String get grammarThePassing;

  /// No description provided for @commonWaitingTo.
  ///
  /// In en, this message translates to:
  /// **'Waiting to sync'**
  String get commonWaitingTo;

  /// Short label used in grammar lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Retry quiz'**
  String get grammarRetryQuiz;

  /// No description provided for @grammarReviewThe.
  ///
  /// In en, this message translates to:
  /// **'Review the material'**
  String get grammarReviewThe;

  /// No description provided for @grammarBackTo.
  ///
  /// In en, this message translates to:
  /// **'Back to lesson list'**
  String get grammarBackTo;

  /// No description provided for @levelListSearchPatterns.
  ///
  /// In en, this message translates to:
  /// **'Search patterns or meanings'**
  String get levelListSearchPatterns;

  /// Short label used in grammar level list.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get levelListNoResults;

  /// No description provided for @levelListTheList.
  ///
  /// In en, this message translates to:
  /// **'The list could not be loaded. Check your connection and try again.'**
  String get levelListTheList;

  /// Short label used in learn hub screen.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnLearn;

  /// No description provided for @learnStartLearning.
  ///
  /// In en, this message translates to:
  /// **'Start learning for free. Sign in to begin.'**
  String get learnStartLearning;

  /// No description provided for @learnChooseA.
  ///
  /// In en, this message translates to:
  /// **'Choose a level'**
  String get learnChooseA;

  /// No description provided for @learnLifetimeAccessIs.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Access is required'**
  String get learnLifetimeAccessIs;

  /// No description provided for @learnStudyWords.
  ///
  /// In en, this message translates to:
  /// **'Study words and examples, then check your understanding'**
  String get learnStudyWords;

  /// No description provided for @learnAdvancedLessons.
  ///
  /// In en, this message translates to:
  /// **'Advanced lessons need Lifetime Access. Pay once, learn forever.'**
  String get learnAdvancedLessons;

  /// Short label used in learn hub screen.
  ///
  /// In en, this message translates to:
  /// **'View plans'**
  String get learnViewPlans;

  /// Short label used in learn hub screen.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get learnComingSoon;

  /// No description provided for @readingSmallStories.
  ///
  /// In en, this message translates to:
  /// **'Small stories, new worlds'**
  String get readingSmallStories;

  /// No description provided for @readingPracticeInference.
  ///
  /// In en, this message translates to:
  /// **'Practice inference, author intent, comparing opinions, and locating information. Use translation help when needed. Score at least 80% to complete the lesson.'**
  String get readingPracticeInference;

  /// No description provided for @readingPracticeReading.
  ///
  /// In en, this message translates to:
  /// **'Practice reading abstract arguments, judging the limits of evidence, understanding author intent, comparing opinions, and finding requirements in announcements. Use translation help when needed. Score at least 80% to complete the lesson.'**
  String get readingPracticeReading;

  /// No description provided for @readingUnderstandReasons.
  ///
  /// In en, this message translates to:
  /// **'Understand reasons, characters\' intentions, and conclusions in the story. Open translation help when needed. Score at least 80% to complete the lesson.'**
  String get readingUnderstandReasons;

  /// No description provided for @readingFollowA.
  ///
  /// In en, this message translates to:
  /// **'Follow a character through illustrated stories. Open translation help when needed. Score at least 80% to complete the lesson.'**
  String get readingFollowA;

  /// No description provided for @readingOpenThe.
  ///
  /// In en, this message translates to:
  /// **'Open the first story'**
  String get readingOpenThe;

  /// Short label used in reading course screen.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get readingContinueReading;

  /// No description provided for @readingAllStories.
  ///
  /// In en, this message translates to:
  /// **'All stories are complete! You can still review the material and retake the quizzes.'**
  String get readingAllStories;

  /// No description provided for @readingSearchFor.
  ///
  /// In en, this message translates to:
  /// **'Search for a story or title'**
  String get readingSearchFor;

  /// No description provided for @readingNoStories.
  ///
  /// In en, this message translates to:
  /// **'No stories found. Try another word or topic.'**
  String get readingNoStories;

  /// Short label used in reading lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Reading Story'**
  String get readingReadingStory;

  /// Short label used in reading lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Story meaning'**
  String get readingStoryMeaning;

  /// No description provided for @readingWordsTo.
  ///
  /// In en, this message translates to:
  /// **'Words to remember'**
  String get readingWordsTo;

  /// Short label used in reading lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Check understanding'**
  String get readingCheckUnderstanding;

  /// Short label used in reading lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Continue story'**
  String get readingContinueStory;

  /// No description provided for @readingReadThe.
  ///
  /// In en, this message translates to:
  /// **'Read the story again'**
  String get readingReadThe;

  /// Short label used in reading lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Keep practicing!'**
  String get readingKeepPracticing;

  /// No description provided for @readingStoryProgress.
  ///
  /// In en, this message translates to:
  /// **'Story progress is saved. Continue reading the next story.'**
  String get readingStoryProgress;

  /// No description provided for @readingThePassing.
  ///
  /// In en, this message translates to:
  /// **'The passing score is 80%. Review the explanations and try the quiz again.'**
  String get readingThePassing;

  /// Short label used in reading lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Retry quiz'**
  String get readingRetryQuiz;

  /// No description provided for @readingBackTo.
  ///
  /// In en, this message translates to:
  /// **'Back to story list'**
  String get readingBackTo;

  /// No description provided for @vocabNoMaterial.
  ///
  /// In en, this message translates to:
  /// **'No material is available yet.'**
  String get vocabNoMaterial;

  /// No description provided for @vocabSeeThe.
  ///
  /// In en, this message translates to:
  /// **'See the picture.\nRemember the words.'**
  String get vocabSeeThe;

  /// No description provided for @vocabTheSource.
  ///
  /// In en, this message translates to:
  /// **'The source could not be opened.'**
  String get vocabTheSource;

  /// No description provided for @vocabSearchTopics.
  ///
  /// In en, this message translates to:
  /// **'Search topics, such as food'**
  String get vocabSearchTopics;

  /// No description provided for @vocabNoTopics.
  ///
  /// In en, this message translates to:
  /// **'No topics found yet. Try another word.'**
  String get vocabNoTopics;

  /// No description provided for @vocabReadyTo.
  ///
  /// In en, this message translates to:
  /// **'Ready to study'**
  String get vocabReadyTo;

  /// Short label used in vocabulary lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get vocabAlmostThere;

  /// No description provided for @vocabYouHave.
  ///
  /// In en, this message translates to:
  /// **'You have mastered the vocabulary in this lesson.'**
  String get vocabYouHave;

  /// No description provided for @vocabTheMinimum.
  ///
  /// In en, this message translates to:
  /// **'The minimum passing score is 80%. Review the feedback and try again.'**
  String get vocabTheMinimum;

  /// Short label used in vocabulary lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Preparing quiz…'**
  String get vocabPreparingQuiz;

  /// Short label used in vocabulary lesson screen.
  ///
  /// In en, this message translates to:
  /// **'Retry lesson'**
  String get vocabRetryLesson;

  /// No description provided for @vocabBackTo.
  ///
  /// In en, this message translates to:
  /// **'Back to lesson list'**
  String get vocabBackTo;

  /// No description provided for @vocabUseIt.
  ///
  /// In en, this message translates to:
  /// **'Use it in a sentence'**
  String get vocabUseIt;

  /// No description provided for @vocabNoticeHow.
  ///
  /// In en, this message translates to:
  /// **'Notice how this word is used in different situations.'**
  String get vocabNoticeHow;

  /// Short label used in vocabulary study view.
  ///
  /// In en, this message translates to:
  /// **'Usage notes'**
  String get vocabUsageNotes;

  /// Short label used in vocabulary study view.
  ///
  /// In en, this message translates to:
  /// **'Comprehension practice'**
  String get vocabComprehensionPractice;

  /// Short label used in vocabulary study view.
  ///
  /// In en, this message translates to:
  /// **'Next word'**
  String get vocabNextWord;

  /// No description provided for @onboardingCouldNot.
  ///
  /// In en, this message translates to:
  /// **'Could not finish the guide. Try again.'**
  String get onboardingCouldNot;

  /// Short label used in onboarding screen.
  ///
  /// In en, this message translates to:
  /// **'Close guide'**
  String get onboardingCloseGuide;

  /// Short label used in onboarding screen.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Short label used in onboarding screen.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingStayIn.
  ///
  /// In en, this message translates to:
  /// **'STAY IN THE LOOP'**
  String get onboardingStayIn;

  /// No description provided for @onboardingNeverMiss.
  ///
  /// In en, this message translates to:
  /// **'Never miss important news'**
  String get onboardingNeverMiss;

  /// No description provided for @onboardingTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications to get announcements, new lessons and important info from Bahasa Master. No spam, and you can turn them off any time in Settings.'**
  String get onboardingTurnOn;

  /// No description provided for @onboardingTurnOnNotifications.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get onboardingTurnOnNotifications;

  /// Short label used in onboarding screen.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get onboardingMaybeLater;

  /// Short label used in achievements screen.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get profileAchievements;

  /// No description provided for @profileSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view achievements'**
  String get profileSignIn;

  /// No description provided for @profileThereAre.
  ///
  /// In en, this message translates to:
  /// **'There are no achievements in this category yet.'**
  String get profileThereAre;

  /// No description provided for @profileDataSources.
  ///
  /// In en, this message translates to:
  /// **'Data sources & attributions'**
  String get profileDataSources;

  /// No description provided for @profileBuiltWith.
  ///
  /// In en, this message translates to:
  /// **'Built with many sources'**
  String get profileBuiltWith;

  /// No description provided for @profileThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you to the publishers, dataset creators, and communities that provide content for Bahasa Master. Copyright remains with each respective owner.'**
  String get profileThankYou;

  /// No description provided for @profileOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open-source software licenses'**
  String get profileOpenSource;

  /// Short label used in profile screen.
  ///
  /// In en, this message translates to:
  /// **'Display settings'**
  String get profileDisplaySettings;

  /// Short label used in profile screen.
  ///
  /// In en, this message translates to:
  /// **'App guide'**
  String get profileAppGuide;

  /// No description provided for @profileSignInTo.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your profile.'**
  String get profileSignInTo;

  /// Short label used in profile screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileProfile;

  /// Short label used in profile screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profilePhotosAre.
  ///
  /// In en, this message translates to:
  /// **'Photos are compressed before upload. Anyone with the photo link can view them.'**
  String get profilePhotosAre;

  /// Short label used in profile screen.
  ///
  /// In en, this message translates to:
  /// **'Gamification'**
  String get profileGamification;

  /// No description provided for @profileSeeThis.
  ///
  /// In en, this message translates to:
  /// **'See this week\'s and all-time XP rankings'**
  String get profileSeeThis;

  /// No description provided for @profileChooseFrom.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profileChooseFrom;

  /// No description provided for @profileTakeA.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get profileTakeA;

  /// No description provided for @profileChangeProfile.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get profileChangeProfile;

  /// Short label used in profile screen.
  ///
  /// In en, this message translates to:
  /// **'Loading profile…'**
  String get profileLoadingProfile;

  /// No description provided for @profileOnePayment.
  ///
  /// In en, this message translates to:
  /// **'One payment, lifetime learning.'**
  String get profileOnePayment;

  /// Short label used in profile screen.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get profileView;

  /// Short label used in profile screen.
  ///
  /// In en, this message translates to:
  /// **'Learning statistics'**
  String get profileLearningStatistics;

  /// No description provided for @profilePlansPayments.
  ///
  /// In en, this message translates to:
  /// **'Plans & payments'**
  String get profilePlansPayments;

  /// Short label used in profile screen.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get profileHelp;

  /// Short label used in gamification widgets.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get profileDayStreak;

  /// Short label used in gamification widgets.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get profileBadges;

  /// No description provided for @profileEarn50.
  ///
  /// In en, this message translates to:
  /// **'Earn 50 XP the first time you pass a lesson and 100 XP the first time you score at least 80% on each exam type. Passing a lesson or exam again: +10 XP (up to 3 times a day). Reaching your daily study goal: +20 XP. Reviewing Anki cards: +1 XP per card (up to 30 XP a day). Streaks count completed quizzes and exams using your selected study timezone.'**
  String get profileEarn50;

  /// No description provided for @profileProgressCould.
  ///
  /// In en, this message translates to:
  /// **'Progress could not be loaded. Check your connection or sign in again if your session has expired.'**
  String get profileProgressCould;

  /// Short label used in main scaffold.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Short label used in main scaffold.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// Short label used in main scaffold.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Filter chip that shows decks of every category
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ankiCategoryAll;

  /// Number of Anki decks
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 deck} other{{count} decks}}'**
  String ankiDeckCount(int count);

  /// Total number of flashcards
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String ankiCardCount(int count);

  /// Deck category and card count under a deck title in the list
  ///
  /// In en, this message translates to:
  /// **'{category} · {count, plural, =1{1 card} other{{count} cards}}'**
  String ankiDeckListMeta(String category, int count);

  /// Tag showing how many cards can be studied
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card ready} other{{count} cards ready}}'**
  String ankiCardsReady(int count);

  /// Date of the next scheduled review
  ///
  /// In en, this message translates to:
  /// **'Next review: {date}'**
  String ankiNextReview(String date);

  /// Import summary for a built-in deck; both values are formatted numbers
  ///
  /// In en, this message translates to:
  /// **'Source entries saved: {source}. Entries that cannot be used as flashcards (empty data or an extra engine is required): {skipped}.'**
  String ankiSourceEntries(String source, String skipped);

  /// Name of the deck this one was created from
  ///
  /// In en, this message translates to:
  /// **'Original deck: {name}'**
  String ankiOriginalDeck(String name);

  /// Study session summary while ratings are queued offline
  ///
  /// In en, this message translates to:
  /// **'You rated {count, plural, =1{1 card} other{{count} cards}}. Ratings are saved on this device and wait to sync. The official schedule updates once you are back online.'**
  String ankiSessionRatedPending(int count);

  /// Study session summary after ratings are saved
  ///
  /// In en, this message translates to:
  /// **'You rated {count, plural, =1{1 card} other{{count} cards}}. Your next schedule is saved to your account. Cards you have not memorized yet come back in about 1 minute.'**
  String ankiSessionRatedSaved(int count);

  /// Position of the current flashcard in the session
  ///
  /// In en, this message translates to:
  /// **'CARD {current} / {total}'**
  String ankiCardPosition(int current, int total);

  /// Expands the remaining answers of a flashcard
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{See 1 more answer} other{See {count} more answers}}'**
  String ankiMoreAnswers(int count);

  /// Export format option
  ///
  /// In en, this message translates to:
  /// **'APKG · for Anki, with media'**
  String get ankiExportFormatApkg;

  /// Export format option
  ///
  /// In en, this message translates to:
  /// **'CSV · text and external links'**
  String get ankiExportFormatCsv;

  /// Export format option
  ///
  /// In en, this message translates to:
  /// **'JSON · backup of cards and media'**
  String get ankiExportFormatJson;

  /// Shown on the export button while the file is prepared
  ///
  /// In en, this message translates to:
  /// **'Preparing file…'**
  String get ankiExportPreparing;

  /// No description provided for @ankiExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save or share the file. Try again.'**
  String get ankiExportFailed;

  /// No description provided for @ankiDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the deck. Try again.'**
  String get ankiDeleteFailed;

  /// Name of the file type group in the file picker
  ///
  /// In en, this message translates to:
  /// **'Anki deck'**
  String get ankiDeckFileLabel;

  /// Button label
  ///
  /// In en, this message translates to:
  /// **'Stop audio'**
  String get ankiAudioStop;

  /// Button label while the audio loads
  ///
  /// In en, this message translates to:
  /// **'Loading audio…'**
  String get ankiAudioLoading;

  /// Button label
  ///
  /// In en, this message translates to:
  /// **'Play audio'**
  String get ankiAudioPlay;

  /// Button that opens the file picker
  ///
  /// In en, this message translates to:
  /// **'Choose deck file'**
  String get ankiImportChooseFile;

  /// No description provided for @ankiImportSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving deck…'**
  String get ankiImportSaving;

  /// No description provided for @ankiImportReading.
  ///
  /// In en, this message translates to:
  /// **'Reading and checking the file…'**
  String get ankiImportReading;

  /// No description provided for @ankiImportOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the file. Try choosing it again.'**
  String get ankiImportOpenFailed;

  /// No description provided for @ankiImportNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a deck name first.'**
  String get ankiImportNameRequired;

  /// No description provided for @ankiImportFailed.
  ///
  /// In en, this message translates to:
  /// **'The import did not finish. Try again with the same file.'**
  String get ankiImportFailed;

  /// Preview summary of a file being imported
  ///
  /// In en, this message translates to:
  /// **'{cards, plural, =1{1 card} other{{cards} cards}} · {media} media'**
  String ankiImportSummary(int cards, int media);

  /// No description provided for @ankiErrorSignInStudy.
  ///
  /// In en, this message translates to:
  /// **'Sign in to study and save your review schedule.'**
  String get ankiErrorSignInStudy;

  /// No description provided for @ankiErrorLifetimeRequired.
  ///
  /// In en, this message translates to:
  /// **'This deck requires Lifetime Access.'**
  String get ankiErrorLifetimeRequired;

  /// No description provided for @ankiErrorDeckNotFound.
  ///
  /// In en, this message translates to:
  /// **'Deck not found.'**
  String get ankiErrorDeckNotFound;

  /// No description provided for @ankiErrorScheduleChanged.
  ///
  /// In en, this message translates to:
  /// **'The card schedule has changed. Reload the session to continue.'**
  String get ankiErrorScheduleChanged;

  /// No description provided for @ankiErrorServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Try again.'**
  String get ankiErrorServerUnreachable;

  /// No description provided for @ankiErrorScheduleChangedElsewhere.
  ///
  /// In en, this message translates to:
  /// **'The card schedule changed on another device. Reload the session to use the latest schedule.'**
  String get ankiErrorScheduleChangedElsewhere;

  /// No description provided for @ankiErrorLifetimeVerify.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Access verification is required for this deck.'**
  String get ankiErrorLifetimeVerify;

  /// No description provided for @ankiErrorRatingNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Your rating was not saved. Try again.'**
  String get ankiErrorRatingNotSaved;

  /// No description provided for @ankiErrorMaterialLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load the study material. Try again.'**
  String get ankiErrorMaterialLoad;

  /// No description provided for @ankiErrorReviewUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'The review was not confirmed. Try saving again.'**
  String get ankiErrorReviewUnconfirmed;

  /// No description provided for @ankiErrorOfflineNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Your offline rating was not saved. Try again.'**
  String get ankiErrorOfflineNotSaved;

  /// No description provided for @ankiErrorSignInReview.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save reviews.'**
  String get ankiErrorSignInReview;

  /// No description provided for @ankiErrorAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'The account has changed.'**
  String get ankiErrorAccountChanged;

  /// No description provided for @ankiErrorQueueFull.
  ///
  /// In en, this message translates to:
  /// **'The review queue is full. Connect to the internet to sync.'**
  String get ankiErrorQueueFull;

  /// No description provided for @ankiTransferSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to import or export decks.'**
  String get ankiTransferSignIn;

  /// No description provided for @ankiTransferAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'The account has changed. Open this page again.'**
  String get ankiTransferAccountChanged;

  /// No description provided for @ankiTransferFileSize.
  ///
  /// In en, this message translates to:
  /// **'Choose a file no larger than 20 MB.'**
  String get ankiTransferFileSize;

  /// No description provided for @ankiTransferSignInManage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage personal decks.'**
  String get ankiTransferSignInManage;

  /// No description provided for @ankiTransferUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Transfers are not available on the server yet, or the deck was not found.'**
  String get ankiTransferUnavailable;

  /// No description provided for @ankiTransferTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The file is too large. The upload limit is 20 MB.'**
  String get ankiTransferTooLarge;

  /// No description provided for @ankiTransferInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'The deck file format is not supported or its contents are invalid.'**
  String get ankiTransferInvalidFormat;

  /// No description provided for @ankiTransferBusy.
  ///
  /// In en, this message translates to:
  /// **'Deck processing is busy. Try again in a few seconds.'**
  String get ankiTransferBusy;

  /// No description provided for @ankiTransferIncomplete.
  ///
  /// In en, this message translates to:
  /// **'The transfer did not finish. Check your connection and try again.'**
  String get ankiTransferIncomplete;

  /// Billing status message
  ///
  /// In en, this message translates to:
  /// **'Store connection lost. Try again.'**
  String get billingStoreConnectionLost;

  /// No description provided for @billingCheckOldPurchasesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check earlier purchases. Use Restore.'**
  String get billingCheckOldPurchasesFailed;

  /// No description provided for @billingSignInToBuy.
  ///
  /// In en, this message translates to:
  /// **'Sign in to buy or restore.'**
  String get billingSignInToBuy;

  /// No description provided for @billingCheckingAccess.
  ///
  /// In en, this message translates to:
  /// **'Checking access and store…'**
  String get billingCheckingAccess;

  /// No description provided for @billingStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store purchases are not available on this device.'**
  String get billingStoreUnavailable;

  /// No description provided for @billingProductUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The product is not available yet. Try again later.'**
  String get billingProductUnavailable;

  /// No description provided for @billingSharedDemoAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your own Google account to buy or restore. The demo account is shared.'**
  String get billingSharedDemoAccount;

  /// No description provided for @billingSessionProblem.
  ///
  /// In en, this message translates to:
  /// **'There is a problem with your session or connection. Sign in again if your session has expired.'**
  String get billingSessionProblem;

  /// No description provided for @billingAccessCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check access. Check your connection and try again.'**
  String get billingAccessCheckFailed;

  /// No description provided for @billingCompletePayment.
  ///
  /// In en, this message translates to:
  /// **'Complete your payment in the store.'**
  String get billingCompletePayment;

  /// No description provided for @billingStoreNoResult.
  ///
  /// In en, this message translates to:
  /// **'The store has not returned a result. Use Restore or try verification again before buying again.'**
  String get billingStoreNoResult;

  /// No description provided for @billingPlayDidNotContinue.
  ///
  /// In en, this message translates to:
  /// **'Google Play did not continue the payment. If you closed the dialog, you were not charged and your access is unchanged.'**
  String get billingPlayDidNotContinue;

  /// No description provided for @billingPaymentCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'The payment could not be started. Try Restore if you already bought it.'**
  String get billingPaymentCouldNotStart;

  /// No description provided for @billingRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring purchases…'**
  String get billingRestoring;

  /// No description provided for @billingRestoreNothingFound.
  ///
  /// In en, this message translates to:
  /// **'No purchase was restored. Make sure you are using the right store account.'**
  String get billingRestoreNothingFound;

  /// No description provided for @billingRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed. Check your store account and connection, then try again.'**
  String get billingRestoreFailed;

  /// No description provided for @billingCheckingExistingLifetime.
  ///
  /// In en, this message translates to:
  /// **'Checking your existing Lifetime purchase…'**
  String get billingCheckingExistingLifetime;

  /// No description provided for @billingPurchaseNotFinished.
  ///
  /// In en, this message translates to:
  /// **'The purchase is not finished. Try verification again or restore.'**
  String get billingPurchaseNotFinished;

  /// No description provided for @billingPaymentCanceledNoCharge.
  ///
  /// In en, this message translates to:
  /// **'Payment canceled. You were not charged and your access is unchanged.'**
  String get billingPaymentCanceledNoCharge;

  /// No description provided for @billingPlayOwnedNotFound.
  ///
  /// In en, this message translates to:
  /// **'Google Play shows that this Play account already owns Lifetime, but the purchase was not found. Use Restore.'**
  String get billingPlayOwnedNotFound;

  /// No description provided for @billingPlayCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'Google Play could not start the payment. Your access is unchanged; please try again.'**
  String get billingPlayCouldNotStart;

  /// No description provided for @billingPaymentAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Payment is waiting for approval. Access turns on once it is verified.'**
  String get billingPaymentAwaitingApproval;

  /// No description provided for @billingPaymentCanceledNoAccess.
  ///
  /// In en, this message translates to:
  /// **'Payment canceled. No new access was activated.'**
  String get billingPaymentCanceledNoAccess;

  /// No description provided for @billingPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Try again, or Restore if you already bought it.'**
  String get billingPaymentFailed;

  /// No description provided for @billingVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying purchase…'**
  String get billingVerifying;

  /// No description provided for @billingPaymentStillPending.
  ///
  /// In en, this message translates to:
  /// **'Payment is still pending in the store.'**
  String get billingPaymentStillPending;

  /// No description provided for @billingLifetimeActivated.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Access is now active.'**
  String get billingLifetimeActivated;

  /// No description provided for @billingPurchaseRevoked.
  ///
  /// In en, this message translates to:
  /// **'The purchase was revoked or refunded by the store.'**
  String get billingPurchaseRevoked;

  /// No description provided for @billingPurchaseOtherAccount.
  ///
  /// In en, this message translates to:
  /// **'This purchase belongs to another app account. Sign in to the buyer account, then Restore.'**
  String get billingPurchaseOtherAccount;

  /// No description provided for @billingVerificationUnfinished.
  ///
  /// In en, this message translates to:
  /// **'Verification is not finished. Do not buy again; try verification or Restore.'**
  String get billingVerificationUnfinished;

  /// Shown when the Play account owns Lifetime for another app account; owner is a masked email
  ///
  /// In en, this message translates to:
  /// **'Lifetime on this Google Play account is already used by {owner}. Sign in with that account, or switch accounts in the Play Store to buy again.'**
  String billingOwnedElsewhereNamed(String owner);

  /// No description provided for @billingOwnedElsewhereUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Lifetime on this Google Play account is already used by another app account. Sign in with that account, or switch accounts in the Play Store to buy again.'**
  String get billingOwnedElsewhereUnnamed;

  /// No description provided for @billingNoteSameAccount.
  ///
  /// In en, this message translates to:
  /// **'Access works with the same app account on Android and iOS'**
  String get billingNoteSameAccount;

  /// No description provided for @billingNoteOneTime.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase: pay once, learn forever. No subscription or auto-renewal.'**
  String get billingNoteOneTime;

  /// No description provided for @billingNotePrice.
  ///
  /// In en, this message translates to:
  /// **'The final price follows the store and your account region'**
  String get billingNotePrice;

  /// No description provided for @billingNoteFreeContent.
  ///
  /// In en, this message translates to:
  /// **'Free lessons stay free. Quizzes inside a lesson follow that lesson\'s access.'**
  String get billingNoteFreeContent;

  /// No description provided for @billingBenefitNoAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ad-free learning'**
  String get billingBenefitNoAdsTitle;

  /// No description provided for @billingBenefitNoAdsBody.
  ///
  /// In en, this message translates to:
  /// **'No ads in lessons'**
  String get billingBenefitNoAdsBody;

  /// No description provided for @billingBenefitAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask AI 15 messages/day'**
  String get billingBenefitAiTitle;

  /// No description provided for @billingBenefitAiBody.
  ///
  /// In en, this message translates to:
  /// **'Add more with an optional ad'**
  String get billingBenefitAiBody;

  /// No description provided for @billingBenefitOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Download offline'**
  String get billingBenefitOfflineTitle;

  /// No description provided for @billingBenefitOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Learn without internet'**
  String get billingBenefitOfflineBody;

  /// No description provided for @appUpdateStoreOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'The store could not be opened. Try again or contact rabih@codeverta.com.'**
  String get appUpdateStoreOpenFailed;

  /// No description provided for @appUpdateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check for the latest version. Check your connection and try again.'**
  String get appUpdateCheckFailed;

  /// Button in the app update dialog that re-checks the latest version.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get appUpdateCheckAgain;

  /// No description provided for @appUpdateRequirementAndroid.
  ///
  /// In en, this message translates to:
  /// **'Android {version} or later'**
  String appUpdateRequirementAndroid(String version);

  /// No description provided for @appUpdateRequirementIos.
  ///
  /// In en, this message translates to:
  /// **'iOS {version} or later'**
  String appUpdateRequirementIos(String version);

  /// No description provided for @appUpdateUnsupportedVersion.
  ///
  /// In en, this message translates to:
  /// **'This app version is no longer supported. Update through {store} to continue.'**
  String appUpdateUnsupportedVersion(String store);

  /// No description provided for @appUpdateRequirementNotMet.
  ///
  /// In en, this message translates to:
  /// **'The required app version needs {requirement}. Your device is running {platform} {osVersion}.'**
  String appUpdateRequirementNotMet(
    String requirement,
    String platform,
    String osVersion,
  );

  /// No description provided for @appUpdateVersions.
  ///
  /// In en, this message translates to:
  /// **'Installed version: {installed}\nLatest version: {latest}'**
  String appUpdateVersions(String installed, String latest);

  /// Android notification channel description.
  ///
  /// In en, this message translates to:
  /// **'App news and study information you turned on.'**
  String get notificationsChannelDescription;

  /// No description provided for @notificationsPushAndroidOnly.
  ///
  /// In en, this message translates to:
  /// **'Push notifications are available on Android. iPhone and iPad support is coming soon.'**
  String get notificationsPushAndroidOnly;

  /// No description provided for @notificationsConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Notifications could not be connected. You can still use the app. Close and reopen it to try again.'**
  String get notificationsConnectFailed;

  /// No description provided for @notificationsSubscribeRetry.
  ///
  /// In en, this message translates to:
  /// **'We will retry the subscription when the app is active again.'**
  String get notificationsSubscribeRetry;

  /// No description provided for @notificationsPermissionOff.
  ///
  /// In en, this message translates to:
  /// **'Android notification permission is off. Open Android settings to allow it.'**
  String get notificationsPermissionOff;

  /// No description provided for @notificationsWaitingToSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a connection to turn on the subscription. We will retry when the app is active again.'**
  String get notificationsWaitingToSubscribe;

  /// No description provided for @notificationsWaitingToUnsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a connection to turn off the subscription. You can also turn off notification permission in Android settings.'**
  String get notificationsWaitingToUnsubscribe;

  /// No description provided for @notificationsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission was not granted. Turn it on in Android settings if you want to receive announcements.'**
  String get notificationsPermissionDenied;

  /// No description provided for @notificationsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Settings could not be updated. Please try again.'**
  String get notificationsUpdateFailed;

  /// No description provided for @notificationsOpenSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Open Android Settings → Apps → Bahasa Master → Notifications.'**
  String get notificationsOpenSettingsHint;

  /// No description provided for @authSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Sign in again or continue as a guest.'**
  String get authSessionExpired;

  /// No description provided for @networkAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'The account has changed.'**
  String get networkAccountChanged;

  /// No description provided for @authGoogleCanceled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was canceled.'**
  String get authGoogleCanceled;

  /// No description provided for @authGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Check the OAuth configuration.'**
  String get authGoogleFailed;

  /// No description provided for @authSignInToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Sign in to change your profile photo.'**
  String get authSignInToChangePhoto;

  /// No description provided for @authInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid authentication response.'**
  String get authInvalidResponse;

  /// No description provided for @authServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Make sure the backend is running.'**
  String get authServerUnreachable;

  /// No description provided for @authGoogleClientIdMissing.
  ///
  /// In en, this message translates to:
  /// **'GOOGLE_SERVER_CLIENT_ID is not configured.'**
  String get authGoogleClientIdMissing;

  /// No description provided for @authGoogleUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Interactive Google sign-in is not supported on this platform.'**
  String get authGoogleUnsupported;

  /// No description provided for @authGoogleNoIdToken.
  ///
  /// In en, this message translates to:
  /// **'Google did not return an ID token.'**
  String get authGoogleNoIdToken;

  /// XP earned for a finished activity.
  ///
  /// In en, this message translates to:
  /// **'+{amount} XP'**
  String xpAwarded(int amount);

  /// No description provided for @xpStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day streak} other{{count} day streak}}'**
  String xpStreakDays(int count);

  /// No description provided for @xpBoostClaimed.
  ///
  /// In en, this message translates to:
  /// **'2× XP received (+{bonus} XP)'**
  String xpBoostClaimed(int bonus);

  /// No description provided for @xpWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad for 2× XP (+{bonus} XP)'**
  String xpWatchAd(int bonus);

  /// No description provided for @legalPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyPolicy;

  /// No description provided for @legalTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get legalTermsOfService;

  /// No description provided for @legalRefundPolicy.
  ///
  /// In en, this message translates to:
  /// **'Refunds'**
  String get legalRefundPolicy;

  /// No description provided for @legalDataDeletion.
  ///
  /// In en, this message translates to:
  /// **'Data Deletion'**
  String get legalDataDeletion;

  /// No description provided for @legalSupport.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get legalSupport;

  /// Screen reader label of the startup splash screen.
  ///
  /// In en, this message translates to:
  /// **'{appName}, opening the app'**
  String brandingOpening(String appName);

  /// Tagline shown under the app name on the startup splash screen.
  ///
  /// In en, this message translates to:
  /// **'One step closer to fluent Indonesian'**
  String get brandingTagline;

  /// No description provided for @appPageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found: {error}'**
  String appPageNotFound(String error);

  /// No description provided for @unlockFreeUnlocksLeft.
  ///
  /// In en, this message translates to:
  /// **'Free unlocks left today: {count}'**
  String unlockFreeUnlocksLeft(int count);

  /// Button; the number is how many ad-free unlocks remain.
  ///
  /// In en, this message translates to:
  /// **'Unlock without an ad ({count})'**
  String unlockWithoutAd(int count);

  /// No description provided for @settingsUseDeviceTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Use device time zone ({timezone})'**
  String settingsUseDeviceTimeZone(String timezone);

  /// Label of a course level (1 = beginner)
  ///
  /// In en, this message translates to:
  /// **'BIPA {level}'**
  String learnLevelLabel(int level);

  /// App bar title of the reading course; level is a level label like BIPA 1
  ///
  /// In en, this message translates to:
  /// **'Reading {level}'**
  String readingCourseTitle(String level);

  /// Filter chip that shows stories of every chapter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get readingFilterAll;

  /// Summary line of the reading course header
  ///
  /// In en, this message translates to:
  /// **'{lessons, plural, =1{1 lesson} other{{lessons} lessons}} • {scenes, plural, =1{1 illustrated scene} other{{scenes} illustrated scenes}} • {questions, plural, =1{1 question} other{{questions} questions}}'**
  String readingCourseSummary(int lessons, int scenes, int questions);

  /// Progress of the reading course
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} stories complete • {percent}%'**
  String readingProgressSummary(int done, int total, int percent);

  /// Screen reader label of a story picture
  ///
  /// In en, this message translates to:
  /// **'Illustration for {title}'**
  String readingIllustrationDescription(String title);

  /// Details line of a story in the list
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 min} other{{minutes} min}} • {scenes, plural, =1{1 scene} other{{scenes} scenes}} • Best {score}%'**
  String readingLessonDetails(int minutes, int scenes, int score);

  /// No description provided for @readingResultCorrectCount.
  ///
  /// In en, this message translates to:
  /// **'{correct}/{total} correct answers'**
  String readingResultCorrectCount(int correct, int total);

  /// No description provided for @readingResultBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best score {score}%'**
  String readingResultBestScore(int score);

  /// No description provided for @readingResultCourseProgress.
  ///
  /// In en, this message translates to:
  /// **'Course progress {percent}%'**
  String readingResultCourseProgress(int percent);

  /// No description provided for @readingInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'The reading response was invalid. Try reloading.'**
  String get readingInvalidResponse;

  /// No description provided for @readingSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get readingSessionExpired;

  /// No description provided for @readingLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Reading material could not be loaded. Check your connection and try again.'**
  String get readingLoadFailed;

  /// No description provided for @readingEmptyLesson.
  ///
  /// In en, this message translates to:
  /// **'This story has no material yet.'**
  String get readingEmptyLesson;

  /// No description provided for @readingQuizUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The quiz for this story is not available yet.'**
  String get readingQuizUnavailable;

  /// App bar title of the grammar course; level is a level label like BIPA 1
  ///
  /// In en, this message translates to:
  /// **'Grammar {level}'**
  String grammarCourseTitle(String level);

  /// Filter chip that shows lessons of every chapter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get grammarFilterAll;

  /// Summary line of the grammar course header
  ///
  /// In en, this message translates to:
  /// **'{lessons, plural, =1{1 lesson} other{{lessons} lessons}} • {patterns, plural, =1{1 pattern} other{{patterns} patterns}} • {questions, plural, =1{1 question} other{{questions} questions}}'**
  String grammarCourseSummary(int lessons, int patterns, int questions);

  /// Progress of the grammar course
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} lessons complete • {percent}%'**
  String grammarProgressSummary(int done, int total, int percent);

  /// Details line of a grammar lesson in the list
  ///
  /// In en, this message translates to:
  /// **'{patterns, plural, =1{1 pattern} other{{patterns} patterns}} • {questions, plural, =1{1 question} other{{questions} questions}} • Best {score}%'**
  String grammarLessonDetails(int patterns, int questions, int score);

  /// Line above a grammar pattern; level is a level label like BIPA 1
  ///
  /// In en, this message translates to:
  /// **'{level} • {chapter} • Pattern {current}/{total}'**
  String grammarPointCounter(
    String level,
    String chapter,
    int current,
    int total,
  );

  /// No description provided for @grammarResultCorrectCount.
  ///
  /// In en, this message translates to:
  /// **'{correct}/{total} correct answers'**
  String grammarResultCorrectCount(int correct, int total);

  /// No description provided for @grammarResultBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best score {score}%'**
  String grammarResultBestScore(int score);

  /// No description provided for @grammarResultCourseProgress.
  ///
  /// In en, this message translates to:
  /// **'Course progress {percent}%'**
  String grammarResultCourseProgress(int percent);

  /// No description provided for @grammarInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'The grammar response was invalid. Try reloading.'**
  String get grammarInvalidResponse;

  /// No description provided for @grammarSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get grammarSessionExpired;

  /// No description provided for @grammarLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Grammar material could not be loaded. Check your connection and try again.'**
  String get grammarLoadFailed;

  /// No description provided for @grammarEmptyLesson.
  ///
  /// In en, this message translates to:
  /// **'This lesson has no material yet.'**
  String get grammarEmptyLesson;

  /// No description provided for @grammarQuizUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The quiz for this lesson is not available yet.'**
  String get grammarQuizUnavailable;

  /// Count above the grammar pattern list; level is a level label like BIPA 1
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 grammar pattern} other{{count} grammar patterns}} • {level}'**
  String levelListPatternCount(int count, String level);

  /// Which lesson a pattern belongs to
  ///
  /// In en, this message translates to:
  /// **'Lesson {number} · {title}'**
  String levelListItemLesson(int number, String title);

  /// No description provided for @levelListOpenLessonNumber.
  ///
  /// In en, this message translates to:
  /// **'Open lesson {number}'**
  String levelListOpenLessonNumber(int number);

  /// Section title: how the pattern is formed
  ///
  /// In en, this message translates to:
  /// **'Formation'**
  String get levelListFormation;

  /// No description provided for @levelListExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get levelListExplanation;

  /// No description provided for @levelListCommonMistake.
  ///
  /// In en, this message translates to:
  /// **'Common mistake'**
  String get levelListCommonMistake;

  /// No description provided for @levelListExamples.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get levelListExamples;

  /// No description provided for @readingSceneCounter.
  ///
  /// In en, this message translates to:
  /// **'{chapter} • Scene {current}/{total}'**
  String readingSceneCounter(String chapter, int current, int total);

  /// No description provided for @readingQuestionCounter.
  ///
  /// In en, this message translates to:
  /// **'Question {current}/{total}'**
  String readingQuestionCounter(int current, int total);

  /// No description provided for @grammarQuestionCounter.
  ///
  /// In en, this message translates to:
  /// **'Question {current}/{total}'**
  String grammarQuestionCounter(int current, int total);

  /// No description provided for @homeBannerLearnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn Indonesian, every day'**
  String get homeBannerLearnTitle;

  /// No description provided for @homeBannerLearnDescription.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary, grammar and reading to help you reach your Indonesian goals.'**
  String get homeBannerLearnDescription;

  /// No description provided for @homeBannerLearnButton.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get homeBannerLearnButton;

  /// No description provided for @homeBannerAnkiTitle.
  ///
  /// In en, this message translates to:
  /// **'Remember more with Anki'**
  String get homeBannerAnkiTitle;

  /// No description provided for @homeBannerAnkiDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick your favorite decks and build a habit of reviewing vocabulary.'**
  String get homeBannerAnkiDescription;

  /// No description provided for @homeBannerAnkiButton.
  ///
  /// In en, this message translates to:
  /// **'Explore decks'**
  String get homeBannerAnkiButton;

  /// No description provided for @homeBannerOfferDescription.
  ///
  /// In en, this message translates to:
  /// **'Your app store shows the local price at checkout.'**
  String get homeBannerOfferDescription;

  /// No description provided for @homeBannerOfferButton.
  ///
  /// In en, this message translates to:
  /// **'View plans'**
  String get homeBannerOfferButton;

  /// Small uppercase label above the premium banner title
  ///
  /// In en, this message translates to:
  /// **'BAHASA MASTER PREMIUM'**
  String get homeBannerEyebrowPremium;

  /// Small uppercase label above the Anki banner title
  ///
  /// In en, this message translates to:
  /// **'REVIEW A LITTLE, REMEMBER MORE'**
  String get homeBannerEyebrowAnki;

  /// Small uppercase label above the learn banner title
  ///
  /// In en, this message translates to:
  /// **'LEARN INDONESIAN'**
  String get homeBannerEyebrowLearn;

  /// No description provided for @homeInvalidData.
  ///
  /// In en, this message translates to:
  /// **'The home data format is invalid.'**
  String get homeInvalidData;

  /// No description provided for @homeNotSavedOffline.
  ///
  /// In en, this message translates to:
  /// **'Home is not saved on this device yet. Connect to the internet to set it up.'**
  String get homeNotSavedOffline;

  /// No description provided for @homeNotificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission was not granted. You can turn notifications on later in Android settings.'**
  String get homeNotificationPermissionDenied;

  /// No description provided for @homeNotificationEnableFailed.
  ///
  /// In en, this message translates to:
  /// **'Notifications could not be turned on right now. Try again later in Settings.'**
  String get homeNotificationEnableFailed;

  /// Accessibility label for a banner page indicator
  ///
  /// In en, this message translates to:
  /// **'Banner {index} of {total}: {title}'**
  String homeBannerSemantics(int index, int total, String title);

  /// Accessibility label of a premium quick menu item
  ///
  /// In en, this message translates to:
  /// **'{label} · Premium'**
  String homeQuickMenuPremiumLabel(String label);

  /// Small greeting above the user's name on the home screen
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreeting;

  /// Subject tile title in the learn hub
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get learnSubjectVocabularyTitle;

  /// No description provided for @learnSubjectVocabularySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Words, examples, quizzes & progress'**
  String get learnSubjectVocabularySubtitle;

  /// Subject tile title in the learn hub
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get learnSubjectGrammarTitle;

  /// No description provided for @learnSubjectGrammarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Patterns, example sentences, quizzes & progress'**
  String get learnSubjectGrammarSubtitle;

  /// Subject tile title in the learn hub
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get learnSubjectReadingTitle;

  /// No description provided for @learnSubjectReadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Illustrated stories, vocabulary & quizzes'**
  String get learnSubjectReadingSubtitle;

  /// Heading above the subject tiles; level is a level label like BIPA 1
  ///
  /// In en, this message translates to:
  /// **'Materials for {level}'**
  String learnMaterialsForLevel(String level);

  /// Title of the vocabulary callout card; level is a level label like BIPA 1
  ///
  /// In en, this message translates to:
  /// **'Vocabulary {level}'**
  String learnVocabularyForLevel(String level);

  /// Title of the locked level card; level is a level label like BIPA 4
  ///
  /// In en, this message translates to:
  /// **'Open {level} lessons'**
  String learnOpenLevelLessons(String level);

  /// App bar title of the vocabulary course
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabCourseTitle;

  /// Small uppercase label on the vocabulary course header; level is an uppercase level label
  ///
  /// In en, this message translates to:
  /// **'VOCABULARY / {level}'**
  String vocabLevelEyebrow(String level);

  /// Summary under the vocabulary course title
  ///
  /// In en, this message translates to:
  /// **'{lessons, plural, =1{1 lesson} other{{lessons} lessons}} • {entries, plural, =1{1 vocabulary entry} other{{entries} vocabulary entries}}'**
  String vocabCourseSummary(int lessons, int entries);

  /// Credit of the vocabulary data source
  ///
  /// In en, this message translates to:
  /// **'Source: {name} • {license}'**
  String vocabSourceCredit(String name, String license);

  /// Progress label on the vocabulary course
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} lessons mastered'**
  String vocabLessonsMastered(int done, int total);

  /// Progress hint on the vocabulary course
  ///
  /// In en, this message translates to:
  /// **'Practice progress {progress}% • pass a lesson with at least 80%'**
  String vocabPracticeProgress(int progress);

  /// Heading above the topic search; level is a level label
  ///
  /// In en, this message translates to:
  /// **'Explore {level} topics'**
  String vocabExploreTopics(String level);

  /// Accessibility label of a topic image
  ///
  /// In en, this message translates to:
  /// **'Illustration for topic {title}'**
  String vocabTopicIllustration(String title);

  /// Accessibility label of a vocabulary image
  ///
  /// In en, this message translates to:
  /// **'Vocabulary illustration'**
  String get vocabIllustration;

  /// Small uppercase label on a lesson card; number is zero-padded text
  ///
  /// In en, this message translates to:
  /// **'LESSON {number}'**
  String vocabLessonNumber(String number);

  /// Word and question counts of a lesson card
  ///
  /// In en, this message translates to:
  /// **'{words, plural, =1{1 word} other{{words} words}} • {questions, plural, =1{1 question} other{{questions} questions}}'**
  String vocabLessonStats(int words, int questions);

  /// Status of a mastered lesson card
  ///
  /// In en, this message translates to:
  /// **'Mastered • {score}%'**
  String vocabMasteredScore(int score);

  /// Status of a lesson card with a best score
  ///
  /// In en, this message translates to:
  /// **'Best {score}%'**
  String vocabBestScoreShort(int score);

  /// Question type label shown when the server sends none
  ///
  /// In en, this message translates to:
  /// **'Word meaning'**
  String get vocabQuestionKindMeaning;

  /// Position in the vocabulary quiz
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String vocabQuestionProgress(int current, int total);

  /// Quiz result summary
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct answers'**
  String vocabCorrectCount(int correct, int total);

  /// Quiz result summary line
  ///
  /// In en, this message translates to:
  /// **'Best score: {best}% • Overall progress: {progress}%'**
  String vocabScoreSummary(int best, int progress);

  /// Position in the vocabulary study view
  ///
  /// In en, this message translates to:
  /// **'WORD {current} / {total}'**
  String vocabWordCounter(int current, int total);

  /// Label above an example sentence
  ///
  /// In en, this message translates to:
  /// **'EXAMPLE {number}'**
  String vocabExampleNumber(int number);

  /// No description provided for @vocabLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary material could not be loaded. Check your connection.'**
  String get vocabLoadFailed;

  /// No description provided for @vocabInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'The vocabulary response from the server is invalid.'**
  String get vocabInvalidResponse;

  /// No description provided for @vocabLessonEmpty.
  ///
  /// In en, this message translates to:
  /// **'This lesson has no vocabulary yet.'**
  String get vocabLessonEmpty;

  /// Kind of learning activity
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get learnCategoryVocabulary;

  /// Kind of learning activity
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get learnCategoryGrammar;

  /// Kind of learning activity
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get learnCategoryReading;

  /// Kind and level of a recent learning activity
  ///
  /// In en, this message translates to:
  /// **'{category} · {level}'**
  String learnActivityCategoryLevel(String category, String level);

  /// Progress inside a vocabulary lesson
  ///
  /// In en, this message translates to:
  /// **'Word {position} of {total}'**
  String learnActivityWordPosition(int position, int total);

  /// Progress inside a grammar lesson
  ///
  /// In en, this message translates to:
  /// **'Pattern {position} of {total}'**
  String learnActivityPatternPosition(int position, int total);

  /// Progress inside a reading lesson
  ///
  /// In en, this message translates to:
  /// **'Page {position} of {total}'**
  String learnActivityPagePosition(int position, int total);

  /// Status and date line of a recent learning activity
  ///
  /// In en, this message translates to:
  /// **'{status} · {date}'**
  String learnActivityDetail(String status, String date);

  /// No description provided for @learnOfflineQuizNotPrepared.
  ///
  /// In en, this message translates to:
  /// **'This quiz is not ready for offline use. Connect to the internet and open it while online to save it.'**
  String get learnOfflineQuizNotPrepared;

  /// No description provided for @learnOfflineSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save practice.'**
  String get learnOfflineSignInRequired;

  /// No description provided for @learnOfflineTooManyUnsynced.
  ///
  /// In en, this message translates to:
  /// **'There is too much practice waiting to sync.'**
  String get learnOfflineTooManyUnsynced;

  /// No description provided for @learnOfflinePackageInvalid.
  ///
  /// In en, this message translates to:
  /// **'The offline quiz package is invalid.'**
  String get learnOfflinePackageInvalid;

  /// No description provided for @learnOfflineAccountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Account unavailable.'**
  String get learnOfflineAccountUnavailable;

  /// No description provided for @learnOfflineNoLongerAccepting.
  ///
  /// In en, this message translates to:
  /// **'This practice no longer accepts answers.'**
  String get learnOfflineNoLongerAccepting;

  /// No description provided for @learnOfflineAnswerAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'The answer for this question is already saved.'**
  String get learnOfflineAnswerAlreadySaved;

  /// No description provided for @learnOfflinePracticeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Practice not found.'**
  String get learnOfflinePracticeNotFound;

  /// No description provided for @learnOfflineAnswerAll.
  ///
  /// In en, this message translates to:
  /// **'Answer all questions before finishing the practice.'**
  String get learnOfflineAnswerAll;

  /// No description provided for @learnOfflineServerResultInvalid.
  ///
  /// In en, this message translates to:
  /// **'The practice result from the server is invalid.'**
  String get learnOfflineServerResultInvalid;

  /// No description provided for @learnOfflineAccountChanged.
  ///
  /// In en, this message translates to:
  /// **'The account changed.'**
  String get learnOfflineAccountChanged;

  /// No description provided for @learnOfflineAccessGone.
  ///
  /// In en, this message translates to:
  /// **'Offline access to this practice is no longer available.'**
  String get learnOfflineAccessGone;

  /// No description provided for @learnOfflineQueueTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The practice queue is too large. Connect to the internet to sync pending practice.'**
  String get learnOfflineQueueTooLarge;

  /// No description provided for @learnOfflineAccountChangedDuring.
  ///
  /// In en, this message translates to:
  /// **'The account changed during the practice.'**
  String get learnOfflineAccountChangedDuring;

  /// No description provided for @learnOfflineResponseInvalid.
  ///
  /// In en, this message translates to:
  /// **'The offline practice response is invalid.'**
  String get learnOfflineResponseInvalid;

  /// Player level and XP progress toward the next level
  ///
  /// In en, this message translates to:
  /// **'Level {level} · {levelXp}/{nextLevelXp} XP'**
  String profileStatsLevel(int level, int levelXp, int nextLevelXp);

  /// Profile statistics: passed lessons and exam types taken
  ///
  /// In en, this message translates to:
  /// **'{lessons, plural, =1{1 lesson passed} other{{lessons} lessons passed}} · {exams, plural, =1{1 exam type taken} other{{exams} exam types taken}}'**
  String profileStatsCompleted(int lessons, int exams);

  /// Profile statistics: best streak and number of active days
  ///
  /// In en, this message translates to:
  /// **'Best streak: {best, plural, =1{1 day} other{{best} days}} · {active, plural, =1{1 active day} other{{active} active days}}'**
  String profileStatsStreak(int best, int active);

  /// Achievement progress for an unlocked achievement
  ///
  /// In en, this message translates to:
  /// **'{progress}/{target} · Unlocked'**
  String profileAchievementUnlocked(int progress, int target);

  /// Achievement progress for a locked achievement
  ///
  /// In en, this message translates to:
  /// **'{progress}/{target} · Locked'**
  String profileAchievementLocked(int progress, int target);

  /// Date an achievement was earned
  ///
  /// In en, this message translates to:
  /// **'Earned {date}'**
  String profileAchievementEarned(String date);

  /// No description provided for @profileAchievementsUnlockedCount.
  ///
  /// In en, this message translates to:
  /// **'{unlocked}/{total} achievements unlocked'**
  String profileAchievementsUnlockedCount(int unlocked, int total);

  /// Achievements filter chip
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get profileFilterAll;

  /// Achievements filter chip
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get profileFilterUnlocked;

  /// Achievements filter chip
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get profileFilterLocked;

  /// No description provided for @profileViewAllAchievements.
  ///
  /// In en, this message translates to:
  /// **'View all achievements ({unlocked}/{total})'**
  String profileViewAllAchievements(int unlocked, int total);

  /// No description provided for @profilePhotoUnprocessable.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be processed. Choose another photo.'**
  String get profilePhotoUnprocessable;

  /// No description provided for @profilePhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The photo is still too large. Choose another photo.'**
  String get profilePhotoTooLarge;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated.'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be processed or uploaded. Check your connection and try again.'**
  String get profilePhotoFailed;

  /// Fallback display name when the user has none
  ///
  /// In en, this message translates to:
  /// **'Bahasa Learner'**
  String get profileDefaultName;

  /// Plan badge, uppercase
  ///
  /// In en, this message translates to:
  /// **'LIFETIME MEMBER'**
  String get profilePlanLifetime;

  /// Plan badge, uppercase
  ///
  /// In en, this message translates to:
  /// **'FREE MEMBER'**
  String get profilePlanFree;

  /// No description provided for @profileSignInToViewProgress.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view your progress.'**
  String get profileSignInToViewProgress;

  /// Leaderboard screen title and profile list item
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// Fallback name for a person without a display name
  ///
  /// In en, this message translates to:
  /// **'Learner #{tag}'**
  String leaderboardLearnerName(String tag);

  /// No description provided for @leaderboardRankOf.
  ///
  /// In en, this message translates to:
  /// **'#{rank} of {participants}'**
  String leaderboardRankOf(int rank, int participants);

  /// No description provided for @leaderboardXpValue.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String leaderboardXpValue(int xp);

  /// Weekly competition countdown
  ///
  /// In en, this message translates to:
  /// **'Ends in {days, plural, =1{1 day} other{{days} days}} {hours, plural, =1{1 hour} other{{hours} hours}}'**
  String leaderboardEndsInDaysHours(int days, int hours);

  /// Weekly competition countdown
  ///
  /// In en, this message translates to:
  /// **'Ends in {hours, plural, =1{1 hour} other{{hours} hours}} {minutes, plural, =1{1 minute} other{{minutes} minutes}}'**
  String leaderboardEndsInHoursMinutes(int hours, int minutes);

  /// Weekly competition countdown
  ///
  /// In en, this message translates to:
  /// **'Ends in {minutes, plural, =1{1 minute} other{{minutes} minutes}}'**
  String leaderboardEndsInMinutes(int minutes);

  /// Shown when the cached leaderboard is displayed; time is HH:mm
  ///
  /// In en, this message translates to:
  /// **'Last updated {time}'**
  String leaderboardLastUpdated(String time);

  /// No description provided for @leaderboardHomeLead.
  ///
  /// In en, this message translates to:
  /// **'#1 this week · You\'re in the lead!'**
  String get leaderboardHomeLead;

  /// No description provided for @leaderboardHomeRank.
  ///
  /// In en, this message translates to:
  /// **'#{rank} this week · {gap} XP more to reach #{next}'**
  String leaderboardHomeRank(int rank, int gap, int next);

  /// No description provided for @leaderboardHiddenRank.
  ///
  /// In en, this message translates to:
  /// **'Your position if shown: #{rank}'**
  String leaderboardHiddenRank(int rank);

  /// No description provided for @leaderboardLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week you finished #{rank} · {xp} XP. A new week has started!'**
  String leaderboardLastWeek(int rank, int xp);

  /// No description provided for @leaderboardShowingTop.
  ///
  /// In en, this message translates to:
  /// **'Showing the top {shown} of {total} learners'**
  String leaderboardShowingTop(int shown, int total);

  /// App name split over two lines in the onboarding header
  ///
  /// In en, this message translates to:
  /// **'Bahasa\nMaster'**
  String get onboardingBrandName;

  /// Onboarding page 1 eyebrow, uppercase
  ///
  /// In en, this message translates to:
  /// **'A NEW JOURNEY'**
  String get onboardingJourneyEyebrow;

  /// No description provided for @onboardingJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Master Bahasa Indonesia'**
  String get onboardingJourneyTitle;

  /// No description provided for @onboardingJourneyDescription.
  ///
  /// In en, this message translates to:
  /// **'From your first words to more confident conversations. Find your learning rhythm, from BIPA 1 to BIPA 7.'**
  String get onboardingJourneyDescription;

  /// Feature chip: level range
  ///
  /// In en, this message translates to:
  /// **'BIPA 1 → BIPA 7'**
  String get onboardingJourneyFeatureLevels;

  /// Feature chip
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get onboardingJourneyFeatureVocabulary;

  /// Feature chip
  ///
  /// In en, this message translates to:
  /// **'Grammar & reading'**
  String get onboardingJourneyFeatureGrammar;

  /// Screen reader description of the onboarding image
  ///
  /// In en, this message translates to:
  /// **'Illustration of a study book and a path leading toward a distant mountain'**
  String get onboardingJourneyImageLabel;

  /// Onboarding page 2 eyebrow, uppercase
  ///
  /// In en, this message translates to:
  /// **'A CLEAR PATH'**
  String get onboardingPathEyebrow;

  /// No description provided for @onboardingPathTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for\nthe next test.'**
  String get onboardingPathTitle;

  /// No description provided for @onboardingPathDescription.
  ///
  /// In en, this message translates to:
  /// **'Understand the material, try the practice questions, then measure your progress with mock tests.'**
  String get onboardingPathDescription;

  /// Feature chip
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get onboardingPathFeaturePractice;

  /// Feature chip
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get onboardingPathFeatureQuizzes;

  /// Feature chip
  ///
  /// In en, this message translates to:
  /// **'Mock tests'**
  String get onboardingPathFeatureMockTests;

  /// Screen reader description of the onboarding image
  ///
  /// In en, this message translates to:
  /// **'Illustration of a study desk, an exam sheet and an achievement medal'**
  String get onboardingPathImageLabel;

  /// Onboarding page 3 eyebrow, uppercase
  ///
  /// In en, this message translates to:
  /// **'A LITTLE, EVERY DAY'**
  String get onboardingAnywhereEyebrow;

  /// No description provided for @onboardingAnywhereTitle.
  ///
  /// In en, this message translates to:
  /// **'Your learning\ngoes with you.'**
  String get onboardingAnywhereTitle;

  /// No description provided for @onboardingAnywhereDescription.
  ///
  /// In en, this message translates to:
  /// **'Reopen saved lessons, even when you are offline. Keep going, one step at a time, every day.'**
  String get onboardingAnywhereDescription;

  /// Feature chip
  ///
  /// In en, this message translates to:
  /// **'Saved lessons'**
  String get onboardingAnywhereFeatureSaved;

  /// Feature chip
  ///
  /// In en, this message translates to:
  /// **'Learning progress'**
  String get onboardingAnywhereFeatureProgress;

  /// Screen reader description of the onboarding image
  ///
  /// In en, this message translates to:
  /// **'Illustration of a book and study cards on a train journey'**
  String get onboardingAnywhereImageLabel;

  /// Page counter with the page eyebrow, e.g. 01 / 03  ·  A NEW JOURNEY
  ///
  /// In en, this message translates to:
  /// **'0{page} / 0{total}  ·  {eyebrow}'**
  String onboardingPageCounter(int page, int total, String eyebrow);

  /// Screen reader label for a page dot
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String onboardingPageLabel(int page, int total);

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get onboardingStart;

  /// No description provided for @onboardingBackToApp.
  ///
  /// In en, this message translates to:
  /// **'Back to the app'**
  String get onboardingBackToApp;

  /// No description provided for @onboardingNotificationOn.
  ///
  /// In en, this message translates to:
  /// **'Notifications are on. Thank you!'**
  String get onboardingNotificationOn;

  /// No description provided for @onboardingNotificationDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission was not granted. You can turn notifications on later in your device settings.'**
  String get onboardingNotificationDenied;

  /// No description provided for @onboardingNotificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Notifications could not be turned on right now. Try again later in Settings.'**
  String get onboardingNotificationFailed;

  /// Feature chip
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get onboardingNotificationAnnouncements;

  /// Feature chip
  ///
  /// In en, this message translates to:
  /// **'New lessons'**
  String get onboardingNotificationNewLessons;

  /// Feature chip
  ///
  /// In en, this message translates to:
  /// **'Important info'**
  String get onboardingNotificationImportant;

  /// Quick action chip
  ///
  /// In en, this message translates to:
  /// **'Summarize'**
  String get aiChatChipSummary;

  /// Quick action chip
  ///
  /// In en, this message translates to:
  /// **'Explain the grammar'**
  String get aiChatChipExplain;

  /// Quick action chip
  ///
  /// In en, this message translates to:
  /// **'Give example sentences'**
  String get aiChatChipExamples;

  /// Quick action chip
  ///
  /// In en, this message translates to:
  /// **'Quiz me (5 questions)'**
  String get aiChatChipQuiz;

  /// Quick action chip
  ///
  /// In en, this message translates to:
  /// **'Correct my sentence'**
  String get aiChatChipCorrect;

  /// No description provided for @aiChatGenericError.
  ///
  /// In en, this message translates to:
  /// **'Ask AI is having trouble. Please try again in a moment.'**
  String get aiChatGenericError;

  /// No description provided for @aiChatAdUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The ad is not available. Please try again in a moment.'**
  String get aiChatAdUnavailable;

  /// Input hint in correction mode
  ///
  /// In en, this message translates to:
  /// **'Write the Indonesian sentence you want corrected'**
  String get aiChatCorrectionHint;

  /// Input hint
  ///
  /// In en, this message translates to:
  /// **'Write your question…'**
  String get aiChatQuestionHint;

  /// No description provided for @aiChatWatchAdForMessages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Watch a short ad to add 1 message. This question is sent right away.} other{Watch a short ad to add {count} messages. This question is sent right away.}}'**
  String aiChatWatchAdForMessages(int count);
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
