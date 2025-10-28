// To parse this JSON data, do
//
//     final addressResponse = addressResponseFromJson(jsonString);

import 'dart:convert';

AddressResponse addressResponseFromJson(String str) => AddressResponse.fromJson(json.decode(str));

String addressResponseToJson(AddressResponse data) => json.encode(data.toJson());

class AddressResponse { 
  AddressResponse({
    required this.addresses,
    required this.success,
    required this.status,
   });

  List<Address> addresses;
  bool success;
  int status;

  factory AddressResponse.fromJson(Map<String, dynamic> json) => AddressResponse(
    addresses: List<Address>.from(json["data"].map((x) => Address.fromJson(x))),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => { 
    "data": List<dynamic>.from(addresses.map((x) => x.toJson())),
    "success": success,
    "status": status,
   };
}

class Address { 
  Address({
    required this.id,
    required this.user_id,
    required this.address,
    required this.country_id,
    required this.state_id,
    required this.city_id,
    required this.country_name,
    required this.state_name,
    required this.city_name,
    required this.postal_code,
    required this.phone,
    required this.set_default,
    required this.location_available,
    required this.lat,
    required this.lang
   });

  int id;
  int user_id;
  String address;
  int country_id;
  int state_id;
  int city_id;
  String country_name;
  String state_name;
  String city_name;
  String postal_code;
  String phone;
  int set_default;
  bool location_available;
  double lat;
  double lang;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json["id"],
    user_id: json["user_id"],
    address: json["address"],
    country_id: json["country_id"],
    state_id: json["state_id"],
    city_id: json["city_id"],
    country_name: json["country_name"],
    state_name: json["state_name"],
    city_name: json["city_name"],
    postal_code: json["postal_code"] == null ? "" :  json["postal_code"],
    phone: json["phone"]== null ? "" :  json["phone"],
    set_default: json["set_default"],
    location_available: json["location_available"],
    lat: json["lat"],
    lang: json["lang"],
  );

  Map<String, dynamic> toJson() => { 
    "id": id,
    "user_id": user_id,
    "address": address,
    "country_id": country_id,
    "state_id": state_id,
    "city_id": city_id,
    "country_name": country_name,
    "state_name": state_name,
    "city_name": city_name,
    "postal_code": postal_code,
    "phone": phone,
    "set_default": set_default,
    "location_available": location_available,
    "lat": lat,
    "lang": lang,
   };
}
