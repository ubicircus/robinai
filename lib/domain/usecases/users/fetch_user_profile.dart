// import '/domain/entities/user_class.dart';
// import '/data/repository/user_repository.dart';
// import '../../../core/error_messages.dart';

// class FetchUserProfileUseCase {
//   final UserRepository userRepository;

//   FetchUserProfileUseCase({required this.userRepository});

//   Future<User> call(String userId) async {
//     try {
//       final user = await userRepository.fetchUserProfile(userId);
//       return user;
//     } catch (e) {
//       print('Error fetching user profile: $e');
//       throw Exception(ErrorMessages.fetchUserProfileFailed);
//     }
//   }
// }
