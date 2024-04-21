class ErrorMessages {
  static const String sendAndSaveFailed =
      'Error while managing sending operations';
  static const String fetchFailed =
      'Error fetching messages from local storage';
  static const String saveLocallyFailed = 'Error saving message locally';
  static const String sendNetworkFailed = 'Error sending message to network';

  static const String fetchMessagesFailed = 'Failed to fetch messages';
  static const String sendMessageFailed = 'Failed to send message';

  static const String fetchUserProfileFailed = 'Failed to fetch user profile';
  static const String loginUserFailed = 'Failed to login user';
  static const String registerUserFailed = 'Failed to register user';
  static const String updateUserProfileFailed = 'Failed to update user profile';

  // Add getters for the error messages
  static String get sendAndSaveFailedErrorMessage => sendAndSaveFailed;
  static String get fetchFailedErrorMessage => fetchFailed;
  static String get saveLocallyFailedErrorMessage => saveLocallyFailed;
  static String get sendNetworkFailedErrorMessage => sendNetworkFailed;

  static String get fetchMessagesFailedErrorMessage => fetchMessagesFailed;
  static String get sendMessageFailedErrorMessage => sendMessageFailed;

  static String get fetchUserProfileFailedErrorMessage =>
      fetchUserProfileFailed;
  static String get loginUserFailedErrorMessage => loginUserFailed;
  static String get registerUserFailedErrorMessage => registerUserFailed;
  static String get updateUserProfileFailedErrorMessage =>
      updateUserProfileFailed;
}
