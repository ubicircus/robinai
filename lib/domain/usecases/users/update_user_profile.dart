// import '/domain/entities/user_class.dart';
// import '/data/repository/user_repository.dart';
// import '../../../core/error_messages.dart';

// class UpdateUserProfileUseCase {
//   final UserRepository userRepository;

//   UpdateUserProfileUseCase({required this.userRepository});

//   Future<User> call(User updatedUser) async {
//     try {
//       final user = await userRepository.updateUserProfile(updatedUser);
//       return user;
//     } catch (e) {
//       print('Error updating user profile: $e');
//       throw Exception(ErrorMessages.updateUserProfileFailed);
//     }
//   }
// }
