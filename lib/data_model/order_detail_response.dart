// To parse this JSON data, do
//
//     final orderDetailResponse = orderDetailResponseFromJson(jsonString);
//https://app.quicktype.io/
import 'dart:convert';

OrderDetailResponse orderDetailResponseFromJson(String str) => OrderDetailResponse.fromJson(json.decode(str));

String orderDetailResponseToJson(OrderDetailResponse data) => json.encode(data.toJson());

class OrderDetailResponse { 
  OrderDetailResponse({
    required this.detailed_orders,
    required this.success,
    required this.status,
   });

  List<DetailedOrder> detailed_orders;
  bool success;
  int status;

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) => OrderDetailResponse(
    detailed_orders: List<DetailedOrder>.from(json["data"].map((x) => DetailedOrder.fromJson(x))),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => { 
    "data": List<dynamic>.from(detailed_orders.map((x) => x.toJson())),
    "success": success,
    "status": status,
   };
}

class DetailedOrder { 
  DetailedOrder({
    required this.id,
    required this.code,
    required this.user_id,
    required this.manually_payable,
    required this.shipping_address,
    required this.pickupPoint,
    required this.shipping_type,
    required this.shipping_type_string,
    required this.payment_type,
    required this.payment_status,
    required this.payment_status_string,
    required this.delivery_status,
    required this.delivery_status_string,
    required this.grand_total,
    required this.plane_grand_total,
    required this.coupon_discount,
    required this.shipping_cost,
    required this.subtotal,
    required this.tax,
    required this.date,
    required this.links,
    this.cancelRequest
   });

  int id;
  String code;
  int user_id;
  bool manually_payable;
  ShippingAddress shipping_address;
  PickupPoint pickupPoint;
  String shipping_type;
  String shipping_type_string;
  String payment_type;
  String payment_status;
  String payment_status_string;
  String delivery_status;
  String delivery_status_string;
  String grand_total;
  var plane_grand_total;
  String coupon_discount;
  String shipping_cost;
  String subtotal;
  String tax;
  String date;
  Links links;
  bool? cancelRequest;

  factory DetailedOrder.fromJson(Map<String, dynamic> json) => DetailedOrder(
    id: json["id"],
    code: json["code"],
    user_id: json["user_id"],
    manually_payable: json["manually_payable"],
    //shipping_address: ShippingAddress.fromJson(json["shipping_address"]),
    shipping_address: ShippingAddress.fromJson(json["shipping_address"]),
    pickupPoint: PickupPoint.fromJson(json["pickup_point"]),
    shipping_type: json["shipping_type"],
    shipping_type_string: json["shipping_type_string"],
    payment_type: json["payment_type"],
    payment_status: json["payment_status"],
    payment_status_string: json["payment_status_string"],
    delivery_status: json["delivery_status"],
    delivery_status_string: json["delivery_status_string"],
    grand_total: json["grand_total"],
    plane_grand_total: json["plane_grand_total"],
    coupon_discount: json["coupon_discount"],
    shipping_cost: json["shipping_cost"],
    subtotal: json["subtotal"],
    tax: json["tax"],
    date: json["date"],
    links: Links.fromJson(json["links"]),
  );

  Map<String, dynamic> toJson() => { 
    "id": id,
    "code": code,
    "user_id": user_id,
    "manually_payable": manually_payable,
    "shipping_address": shipping_address.toJson(),
    "pickup_point":  pickupPoint.toJson(),
    "shipping_type": shipping_type,
    "shipping_type_string": shipping_type_string,
    "payment_type": payment_type,
    "payment_status": payment_status,
    "payment_status_string": payment_status_string,
    "delivery_status": delivery_status,
    "delivery_status_string": delivery_status_string,
    "grand_total": grand_total,
    "plane_grand_total": plane_grand_total,
    "coupon_discount": coupon_discount,
    "shipping_cost": shipping_cost,
    "subtotal": subtotal,
    "tax": tax,
    "date": date,
    "links": links.toJson(),
   };
}

class Links { 
  Links({
    required this.details,
   });

  String details;

  factory Links.fromJson(Map<String, dynamic> json) => Links(
    details: json["details"],
  );

  Map<String, dynamic> toJson() => { 
    "details": details,
   };
}

class ShippingAddress { 
  ShippingAddress({
    required this.name,
    required this.email,
    required this.address,
    required this.country,
    required this.state,
    required this.city,
    required this.postal_code,
    required this.phone,
    required this.checkout_type,
   });

  String name;
  String email;
  String address;
  String country;
  String state;
  String city;
  String postal_code;
  String phone;
  String checkout_type;

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => ShippingAddress(
    name: json["name"] == null ? null : json["name"],
    email: json["email"] == null ? null : json["email"],
    address: json["address"] == null ? null : json["address"],
    country: json["country"] == null ? null : json["country"],
    state: json["state"] == null ? null : json["state"],
    city: json["city"] == null ? null : json["city"],
    postal_code: json["postal_code"] == null ? null : json["postal_code"],
    phone: json["phone"] == null ? null : json["phone"],
    checkout_type: json["checkout_type"] == null ? null : json["checkout_type"],
  );

  Map<String, dynamic> toJson() => { 
    "name": name,
    "email": email,
    "address": address,
    "country": country,
    "state": state,
    "city": city,
    "postal_code": postal_code,
    "phone":  phone,
    "checkout_type": checkout_type,
   };
}

class PickupPoint { 
  PickupPoint({
    required this.id,
    required this.staffId,
    required this.name,
    required this.address,
    required this.phone,
    required this.pickUpStatus,
    required this.cashOnPickupStatus,
    required this.createdAt,
    required this.updatedAt,
   });

  int id;
  int staffId;
  String name;
  String address;
  String phone;
  int pickUpStatus;
  dynamic cashOnPickupStatus;
  DateTime createdAt;
  DateTime updatedAt;

  factory PickupPoint.fromJson(Map<String, dynamic> json) => PickupPoint(
    id: json["id"] == null ? null : json["id"],
    staffId: json["staff_id"] == null ? null : json["staff_id"],
    name: json["name"] == null ? null : json["name"],
    address: json["address"] == null ? null : json["address"],
    phone: json["phone"] == null ? null : json["phone"],
    pickUpStatus: json["pick_up_status"] == null ? null : json["pick_up_status"],
    cashOnPickupStatus: json["cash_on_pickup_status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => { 
    "id": id,
    "staff_id": staffId,
    "name":  name,
    "address": address,
    "phone": phone,
    "pick_up_status": pickUpStatus,
    "cash_on_pickup_status": cashOnPickupStatus,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
   };
}
