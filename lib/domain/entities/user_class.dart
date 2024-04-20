class User {
  final String id; // Unique identifier for the user
  final String username; // Username of the user
  final String?
      profilePictureUrl; // Optional URL for the user's profile picture

  User({
    required this.id,
    required this.username,
    this.profilePictureUrl,
  });
}
