class RegisterRequest {
  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.password,
  });

  final String fullName;
  final String email;
  final String mobile;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'password': password,
    };
  }
}