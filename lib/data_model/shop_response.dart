// To parse this JSON data, do
//
//     final shopResponse = shopResponseFromJson(jsonString);
// https://app.quicktype.io/

import 'dart:convert';

ShopResponse shopResponseFromJson(String str) => ShopResponse.fromJson(json.decode(str));

String shopResponseToJson(ShopResponse data) => json.encode(data.toJson());

class ShopResponse { 
  ShopResponse({
    required this.shops,
    required this.meta,
    required this.success,
    required this.status,
   });

  List<Shop> shops;
  Meta meta;
  bool success;
  int status;

  factory ShopResponse.fromJson(Map<String, dynamic> json) => ShopResponse(
    shops: List<Shop>.from(json["data"].map((x) => Shop.fromJson(x))),
    meta:  Meta.fromJson(json["meta"]),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => { 
    "data": List<dynamic>.from(shops.map((x) => x.toJson())),
    "meta": meta.toJson(),
    "success": success,
    "status": status,
   };
}

class Shop { 
  Shop({
    required this.id,
    required this.name,
    required this.logo,
    required this.rating,
   });

  int id;
  String name;
  String logo;
  var rating;

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
    id: json["id"],
    name: json["name"],
    logo: json["logo"],
    rating: json["rating"],
  );

  Map<String, dynamic> toJson() => { 
    "id": id,
    "name": name,
    "logo": logo,
    "rating": rating,
   };
}

class Meta { 
  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
   });

  int currentPage;
  int from;
  int lastPage;
  String path;
  int perPage;
  int to;
  int total;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: json["current_page"],
    from: json["from"],
    lastPage: json["last_page"],
    path: json["path"],
    perPage: json["per_page"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => { 
    "current_page": currentPage,
    "from": from,
    "last_page": lastPage,
    "path": path,
    "per_page": perPage,
    "to": to,
    "total": total,
   };
}
