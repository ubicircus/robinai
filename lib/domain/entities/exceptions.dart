import '../../../../core/error_messages.dart';

class InitializationException implements Exception {
  final String message;
  final String? details;

  InitializationException({
    this.message = ErrorMessages.initializationLocalStorageFailed,
    this.details,
  });

  @override
  String toString() => '$message${details != null ? ": $details" : ""}';
}

class SaveDataException implements Exception {
  final String message;
  SaveDataException([this.message = ErrorMessages.saveDataLocallyFailed]);
  @override
  String toString() => message;
}

class FetchDataException implements Exception {
  final String message;
  FetchDataException([this.message = ErrorMessages.fetchDataLocalltyFailed]);
  @override
  String toString() => message;
}

class CloseDataException implements Exception {
  final String message;
  CloseDataException([this.message = ErrorMessages.closeDataLocallyFailed]);
  @override
  String toString() => message;
}

class ThreadDetailsNotFoundException implements Exception {
  final String message;
  ThreadDetailsNotFoundException(
      [this.message = ErrorMessages.threadDetailsNotFoundException]);
  @override
  String toString() => message;
}

class FetchThreadDetailsFailed implements Exception {
  final String message;
  FetchThreadDetailsFailed([this.message = ErrorMessages.threadDetailsFailed]);
  @override
  String toString() => message;
}
