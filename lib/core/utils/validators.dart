class Validators {
  Validators._();

  static final RegExp _usernameRegex =
      RegExp(r'^[a-z0-9_]{3,20}$');

  static bool isValidUsername(String username) {
    return _usernameRegex.hasMatch(username);
  }

  static bool isValidEmail(String email) {
    return RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8;
  }
}