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

// error messages for local storage
  static const String initializationLocalStorageFailed =
      "Failed to initialize local storage.";
  static const String initializationLocalStorageFailedDetails =
      "No additional details available.";
  static const String saveDataLocallyFailed = "Failed to save data locally.";
  static const String fetchDataLocalltyFailed =
      "Failed to fetch data from local storage.";
  static const String closeDataLocallyFailed = "Failed to close data resource.";

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
