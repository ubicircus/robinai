// import '/domain/entities/user_class.dart';
// import '/data/repository/user_repository.dart';
// import '../../../core/error_messages.dart';

// class RegisterUserUseCase {
//   final UserRepository userRepository;

//   RegisterUserUseCase({required this.userRepository});

//   Future<User> call(User user) async {
//     try {
//       final registeredUser = await userRepository.registerUser(user);
//       return registeredUser;
//     } catch (e) {
//       print('Error registering user: $e');
//       throw Exception(ErrorMessages.registerUserFailed);
//     }
//   }
// }
// // 