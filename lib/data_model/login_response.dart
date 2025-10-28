// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse { 
  LoginResponse({
    required this.result,
    required this.message,
    required this.access_token,
    required this.token_type,
    required this.expires_at,
    required this.user,
   });

  bool result;
  String message;
  String access_token;
  String token_type;
  DateTime expires_at;
  User user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    result: json["result"],
    message: json["message"],
    access_token: json["access_token"],
    token_type: json["token_type"],
    expires_at: DateTime.parse(json["expires_at"]),
    user:  User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => { 
    "result": result,
    "message": message,
    "access_token":  access_token,
    "token_type": token_type,
    "expires_at":  expires_at.toIso8601String(),
    "user":  user.toJson(),
   };
}

class User { 
  User({
    required this.id,
    required this.type,
    required this.name,
    required this.email,
    required this.avatar,
    required this.avatar_original,
    required this.phone,
   });

  int id;
  String type;
  String name;
  String email;
  String avatar;
  String avatar_original;
  String phone;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    type: json["type"],
    name: json["name"],
    email: json["email"],
    avatar: json["avatar"],
    avatar_original: json["avatar_original"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => { 
    "id": id,
    "type": type,
    "name": name,
    "email": email,
    "avatar": avatar,
    "avatar_original": avatar_original,
    "phone": phone,
   };
}
