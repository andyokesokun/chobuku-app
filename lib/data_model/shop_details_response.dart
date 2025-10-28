// To parse this JSON data, do
//
//     final shopDetailsResponse = shopDetailsResponseFromJson(jsonString);
// https://app.quicktype.io/
import 'dart:convert';

ShopDetailsResponse shopDetailsResponseFromJson(String str) => ShopDetailsResponse.fromJson(json.decode(str));

String shopDetailsResponseToJson(ShopDetailsResponse data) => json.encode(data.toJson());

class ShopDetailsResponse { 
  ShopDetailsResponse({
    required this.shop,
    required this.success,
    required this.status,
   });

  Shop shop;
  bool success;
  int status;

  factory ShopDetailsResponse.fromJson(Map<String, dynamic> json) => ShopDetailsResponse(
    shop:  Shop.fromJson(json["data"]),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => { 
    "data": shop.toJson(),
    "success": success,
    "status": status,
   };
}

class Shop { 
  Shop({
    required this.id,
    required this.user_id,
    required this.name,
    required this.logo,
    required this.sliders,
    required this.address,
    required this.facebook,
    required this.google,
    required this.twitter,
    required this.true_rating,
    required this.rating,
   });

  int id;
  int user_id;
  String name;
  String logo;
  List<String> sliders;
  String address;
  String facebook;
  String google;
  String twitter;
  int true_rating;
  int rating;

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
    id: json["id"],
    user_id: json["user_id"],
    name: json["name"],
    logo: json["logo"],
    sliders: List<String>.from(json["sliders"].map((x) => x)),
    address: json["address"] == null ? null : json["address"],
    facebook: json["facebook"] == null ? null : json["facebook"],
    google: json["google"] == null ? null : json["google"],
    twitter: json["twitter"] == null ? null : json["twitter"],
    true_rating: json["true_rating"],
    rating: json["rating"],
  );

  Map<String, dynamic> toJson() => { 
    "id": id,
    "user_id": user_id,
    "name": name,
    "logo": logo,
    "sliders": List<dynamic>.from(sliders.map((x) => x)),
    "address": address,
    "facebook": facebook,
    "google": google,
    "twitter": twitter,
    "true_rating": true_rating,
    "rating": rating,
   };
}
