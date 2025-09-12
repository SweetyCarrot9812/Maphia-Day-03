// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AreumFit';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get navRecommendation => 'Recommendation';

  @override
  String get navWorkout => 'Workout';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get recommendationTitle => 'Today\'s Workout';

  @override
  String get analyzingWorkout => 'Analyzing today\'s workout...';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get cannotLoadWorkout => 'Cannot load workout plan';

  @override
  String get restDay => 'Today is a rest day';

  @override
  String get restDayMessage =>
      'Take enough rest for muscle recovery and growth.';

  @override
  String get targetMuscleGroups => 'Target Muscle Groups';

  @override
  String get recommendedExercises => 'Recommended Exercises';

  @override
  String get todaysTips => 'Today\'s Tips';

  @override
  String get viewDetails => 'View Details';

  @override
  String get startExercise => 'Start Exercise';

  @override
  String get dailyReasoning => 'Daily Analysis';

  @override
  String restTime(int seconds) {
    return 'Rest: $seconds seconds';
  }

  @override
  String exerciseStarted(String exerciseName) {
    return 'Started $exerciseName!';
  }

  @override
  String get workoutTitle => 'Workout Tracker';

  @override
  String get currentSession => 'Current Session';

  @override
  String get startSession => 'Start Session';

  @override
  String get endSession => 'End Session';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get exerciseName => 'Exercise Name';

  @override
  String get weight => 'Weight';

  @override
  String get reps => 'Reps';

  @override
  String get sets => 'Sets';

  @override
  String get rpe => 'RPE';

  @override
  String get logSet => 'Log Set';

  @override
  String get sessionNotes => 'Session Notes';

  @override
  String get totalVolume => 'Total Volume';

  @override
  String get totalSets => 'Total Sets';

  @override
  String get calendarTitle => 'Workout Calendar';

  @override
  String get workoutHistory => 'Workout History';

  @override
  String get noWorkoutsOnDate => 'No workouts on this date';

  @override
  String get chatTitle => 'AI Coach';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get send => 'Send';

  @override
  String get quickQuestions => 'Quick Questions';

  @override
  String get howToImproveForm => 'How can I improve my form?';

  @override
  String get whatToEatPostWorkout => 'What should I eat post-workout?';

  @override
  String get howToIncreaseStrength => 'How to increase strength?';

  @override
  String get restDayActivities => 'What to do on rest days?';

  @override
  String get profileTitle => 'Profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get fitnessGoals => 'Fitness Goals';

  @override
  String get preferences => 'Preferences';

  @override
  String get settings => 'Settings';

  @override
  String get name => 'Name';

  @override
  String get age => 'Age';

  @override
  String get height => 'Height';

  @override
  String get currentWeight => 'Current Weight';

  @override
  String get targetWeight => 'Target Weight';

  @override
  String get experienceLevel => 'Experience Level';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get primaryGoal => 'Primary Goal';

  @override
  String get muscleGain => 'Muscle Gain';

  @override
  String get weightLoss => 'Weight Loss';

  @override
  String get strengthBuilding => 'Strength Building';

  @override
  String get enduranceImprovement => 'Endurance Improvement';

  @override
  String get workoutFrequency => 'Workout Frequency';

  @override
  String timesPerWeek(int times) {
    return '$times times per week';
  }

  @override
  String get networkError => 'Please check your internet connection';

  @override
  String get aiServiceError => 'AI service connection issue';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get pleaseEnterExerciseName => 'Please enter exercise name';

  @override
  String get pleaseEnterValidWeight => 'Please enter valid weight';

  @override
  String get pleaseEnterValidReps => 'Please enter valid reps';

  @override
  String get kg => 'kg';

  @override
  String get lbs => 'lbs';

  @override
  String get cm => 'cm';

  @override
  String get ft => 'ft';

  @override
  String get seconds => 'seconds';

  @override
  String get minutes => 'minutes';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';
}
