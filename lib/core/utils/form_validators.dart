class FormValidators {
  // Matches watch, youtu.be, embed, shorts and live URLs with an 11-char video id.
  static final RegExp _youTubeUrlPattern = RegExp(
    r'^(https?://)?(www\.|m\.|music\.)?(youtube\.com/(watch\?(.*&)?v=|embed/|shorts/|live/|v/)|youtu\.be/)[A-Za-z0-9_-]{11}([?&#/].*)?$',
  );

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter an email address.';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email (e.g., user@example.com).';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password.';
    if (value.length < 6) return 'Password must be at least 6 characters long.';
    return null;
  }

  static String? validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name (e.g., John Doe).';
    }
    return null;
  }

  static String? validateName(String? value, String fieldType) {
    if (value == null || value.isEmpty) {
      return fieldType == 'meal'
          ? 'Please enter a name for the meal (e.g., Breakfast).'
          : 'Please enter a name for the exercise (e.g., Push-ups).';
    }
    return null;
  }

  static String? validateCalories(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a calorie count (e.g., 200).';
    }
    if (int.tryParse(value) == null || int.parse(value) < 0) {
      return 'Please enter a valid calorie count (e.g., 200).';
    }
    return null;
  }

  static String? validateYouTubeUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!_youTubeUrlPattern.hasMatch(value.trim())) {
      return 'Please enter a valid YouTube URL (e.g., https://youtu.be/xyz).';
    }
    return null;
  }
}
