// To parse this JSON data, do
//
//     final userInfoResponse = userInfoResponseFromJson(jsonString);

import 'dart:convert';

UserInfoResponse userInfoResponseFromJson(String str) => UserInfoResponse.fromJson(json.decode(str));

String userInfoResponseToJson(UserInfoResponse data) => json.encode(data.toJson());

class UserInfoResponse { 
  UserInfoResponse({
    required this.data,
    required this.success,
    required this.status,
   });

  List<UserInformation> data;
  bool success;
  int status;

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) => UserInfoResponse(
    data: List<UserInformation>.from(json["data"].map((x) => UserInformation.fromJson(x))),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => { 
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "success": success,
    "status": status,
   };
}

class UserInformation { 
  UserInformation({
    required this.name,
    required this.email,
    required this.avatar,
    required this.address,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
    required this.phone,
    required this.balance,
    required this.remainingUploads,
    required this.packageId,
    required this.packageName,
   });

  String name;
  String email;
  String avatar;
  String address;
  String country;
  String state;
  String city;
  String postalCode;
  String phone;
  String balance;
  var remainingUploads;
  int packageId;
  String packageName;

  factory UserInformation.fromJson(Map<String, dynamic> json) => UserInformation(
    name: json["name"],
    email: json["email"],
    avatar: json["avatar"],
    address: json["address"],
    country: json["country"],
    state: json["state"],
    city: json["city"],
    postalCode: json["postal_code"],
    phone: json["phone"],
    balance: json["balance"],
    remainingUploads: json["remaining_uploads"],
    packageId: json["package_id"],
    packageName: json["package_name"],
  );

  Map<String, dynamic> toJson() => { 
    "name": name,
    "email": email,
    "avatar": avatar,
    "address": address,
    "country": country,
    "state": state,
    "city": city,
    "postal_code": postalCode,
    "phone": phone,
    "balance": balance,
    "remaining_uploads": remainingUploads,
    "package_id": packageId,
    "package_name": packageName,
   };
}
