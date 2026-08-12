class RegisterResponse {
  const RegisterResponse({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.mobile,
  });

  final String userId;
  final String fullName;
  final String email;
  final String mobile;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
    );
  }
}