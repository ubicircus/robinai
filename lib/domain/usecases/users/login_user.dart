// import '/domain/entities/user_class.dart';
// import '/data/repository/user_repository.dart';
// import '../../../core/error_messages.dart';

// class LoginUserUseCase {
//   final UserRepository userRepository;

//   LoginUserUseCase({required this.userRepository});

//   Future<User> call(String email, String password) async {
//     try {
//       final user = await userRepository.loginUser(email, password);
//       return user;
//     } catch (e) {
//       print('Error logging in user: $e');
//       throw Exception(ErrorMessages.loginUserFailed);
//     }
//   }
// }
