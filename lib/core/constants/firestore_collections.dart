/// Single source of truth for Firestore top-level collection names.
/// Import this wherever a collection path is written as a string literal.
abstract final class FirestoreCollections {
  static const String users              = 'users';
  static const String pendingUsers       = 'pending_users';
  static const String coaches            = 'coaches';
  static const String clients            = 'clients';
  static const String trainingRelationships = 'training_relationships';
  static const String plans              = 'plans';
  static const String chats              = 'chats';
  static const String challenges         = 'challenges';
  static const String calls              = 'calls';
  static const String sessions           = 'sessions';
  static const String config             = 'config';

  // chats/{chatId} subcollection.
  static const String chatMessages       = 'messages';

  // coaches/{coachUid}/client_notes/{clientUid}: private notes, readable only by the coach.
  static const String coachClientNotes   = 'client_notes';

  // users/{uid} subcollections that YeetFit reads plans from.
  static const String userDiets          = 'diets';
  static const String userWorkouts       = 'workouts';

  // YeetFit's daily logs: users/{uid}/progress/{metric}/{metric}/{yyyy-MM-dd}.
  // Food entries are users/{uid}/progress/food/food/{entryId}, filtered by `date`.
  static const String userProgress       = 'progress';
  static const String progressSleep      = 'sleep';
  static const String progressWater      = 'water';
  static const String progressSteps      = 'steps';
  static const String progressWorkout    = 'workout';
  static const String progressFood       = 'food';
}
