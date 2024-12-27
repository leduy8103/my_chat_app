class AppConstants {
  // App Information
  static const String appName = "Flutter Chat App";
  static const String appVersion = "1.0.0";
  
  // Route Names
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String splashRoute = "/splash";
  static const String chatRoute = "/chat";
  
  // Firebase Collections
  static const String usersCollection = "users";
  static const String chatsCollection = "chats";
  static const String messagesCollection = "messages";
  
  // Storage Paths
  static const String userAvatarPath = "avatars";
  static const String chatImagesPath = "chat_images";
  
  // Error Messages
  static const String errorEmailEmpty = "Email cannot be empty";
  static const String errorPasswordEmpty = "Password cannot be empty";
  static const String errorInvalidEmail = "Please enter a valid email";
  static const String errorWeakPassword = "Password must be at least 6 characters";
  static const String errorLoginFailed = "Login failed. Please try again";
  static const String errorSignUpFailed = "Sign up failed. Please try again";
  
  // API Status Codes
  static const int statusSuccess = 200;
  static const int statusError = 400;
  static const int statusUnauthorized = 401;
  
  // Shared Preferences Keys
  static const String keyUserId = "user_id";
  static const String keyUserEmail = "user_email";
  static const String keyUserName = "user_name";
  static const String keyIsLoggedIn = "is_logged_in";
}