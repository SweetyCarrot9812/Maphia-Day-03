import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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
    Locale('ko')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AreumFit'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @navRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get navRecommendation;

  /// No description provided for @navWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get navWorkout;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @recommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout'**
  String get recommendationTitle;

  /// No description provided for @analyzingWorkout.
  ///
  /// In en, this message translates to:
  /// **'Analyzing today\'s workout...'**
  String get analyzingWorkout;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @cannotLoadWorkout.
  ///
  /// In en, this message translates to:
  /// **'Cannot load workout plan'**
  String get cannotLoadWorkout;

  /// No description provided for @restDay.
  ///
  /// In en, this message translates to:
  /// **'Today is a rest day'**
  String get restDay;

  /// No description provided for @restDayMessage.
  ///
  /// In en, this message translates to:
  /// **'Take enough rest for muscle recovery and growth.'**
  String get restDayMessage;

  /// No description provided for @targetMuscleGroups.
  ///
  /// In en, this message translates to:
  /// **'Target Muscle Groups'**
  String get targetMuscleGroups;

  /// No description provided for @recommendedExercises.
  ///
  /// In en, this message translates to:
  /// **'Recommended Exercises'**
  String get recommendedExercises;

  /// No description provided for @todaysTips.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Tips'**
  String get todaysTips;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @startExercise.
  ///
  /// In en, this message translates to:
  /// **'Start Exercise'**
  String get startExercise;

  /// No description provided for @dailyReasoning.
  ///
  /// In en, this message translates to:
  /// **'Daily Analysis'**
  String get dailyReasoning;

  /// No description provided for @restTime.
  ///
  /// In en, this message translates to:
  /// **'Rest: {seconds} seconds'**
  String restTime(int seconds);

  /// No description provided for @exerciseStarted.
  ///
  /// In en, this message translates to:
  /// **'Started {exerciseName}!'**
  String exerciseStarted(String exerciseName);

  /// No description provided for @workoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Tracker'**
  String get workoutTitle;

  /// No description provided for @currentSession.
  ///
  /// In en, this message translates to:
  /// **'Current Session'**
  String get currentSession;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get startSession;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'End Session'**
  String get endSession;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseName;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @rpe.
  ///
  /// In en, this message translates to:
  /// **'RPE'**
  String get rpe;

  /// No description provided for @logSet.
  ///
  /// In en, this message translates to:
  /// **'Log Set'**
  String get logSet;

  /// No description provided for @sessionNotes.
  ///
  /// In en, this message translates to:
  /// **'Session Notes'**
  String get sessionNotes;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get totalVolume;

  /// No description provided for @totalSets.
  ///
  /// In en, this message translates to:
  /// **'Total Sets'**
  String get totalSets;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Calendar'**
  String get calendarTitle;

  /// No description provided for @workoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutHistory;

  /// No description provided for @noWorkoutsOnDate.
  ///
  /// In en, this message translates to:
  /// **'No workouts on this date'**
  String get noWorkoutsOnDate;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get chatTitle;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @quickQuestions.
  ///
  /// In en, this message translates to:
  /// **'Quick Questions'**
  String get quickQuestions;

  /// No description provided for @howToImproveForm.
  ///
  /// In en, this message translates to:
  /// **'How can I improve my form?'**
  String get howToImproveForm;

  /// No description provided for @whatToEatPostWorkout.
  ///
  /// In en, this message translates to:
  /// **'What should I eat post-workout?'**
  String get whatToEatPostWorkout;

  /// No description provided for @howToIncreaseStrength.
  ///
  /// In en, this message translates to:
  /// **'How to increase strength?'**
  String get howToIncreaseStrength;

  /// No description provided for @restDayActivities.
  ///
  /// In en, this message translates to:
  /// **'What to do on rest days?'**
  String get restDayActivities;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @fitnessGoals.
  ///
  /// In en, this message translates to:
  /// **'Fitness Goals'**
  String get fitnessGoals;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @currentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get currentWeight;

  /// No description provided for @targetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target Weight'**
  String get targetWeight;

  /// No description provided for @experienceLevel.
  ///
  /// In en, this message translates to:
  /// **'Experience Level'**
  String get experienceLevel;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @primaryGoal.
  ///
  /// In en, this message translates to:
  /// **'Primary Goal'**
  String get primaryGoal;

  /// No description provided for @muscleGain.
  ///
  /// In en, this message translates to:
  /// **'Muscle Gain'**
  String get muscleGain;

  /// No description provided for @weightLoss.
  ///
  /// In en, this message translates to:
  /// **'Weight Loss'**
  String get weightLoss;

  /// No description provided for @strengthBuilding.
  ///
  /// In en, this message translates to:
  /// **'Strength Building'**
  String get strengthBuilding;

  /// No description provided for @enduranceImprovement.
  ///
  /// In en, this message translates to:
  /// **'Endurance Improvement'**
  String get enduranceImprovement;

  /// No description provided for @workoutFrequency.
  ///
  /// In en, this message translates to:
  /// **'Workout Frequency'**
  String get workoutFrequency;

  /// No description provided for @timesPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{times} times per week'**
  String timesPerWeek(int times);

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection'**
  String get networkError;

  /// No description provided for @aiServiceError.
  ///
  /// In en, this message translates to:
  /// **'AI service connection issue'**
  String get aiServiceError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @pleaseEnterExerciseName.
  ///
  /// In en, this message translates to:
  /// **'Please enter exercise name'**
  String get pleaseEnterExerciseName;

  /// No description provided for @pleaseEnterValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid weight'**
  String get pleaseEnterValidWeight;

  /// No description provided for @pleaseEnterValidReps.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid reps'**
  String get pleaseEnterValidReps;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @lbs.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get lbs;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @ft.
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get ft;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;
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
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
