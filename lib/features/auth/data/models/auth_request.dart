import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_request.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  final String name;
  const RegisterRequest(
      {required this.email, required this.password, required this.name});
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
