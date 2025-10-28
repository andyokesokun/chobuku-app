// To parse this JSON data, do
//
//     final cartSummaryResponse = cartSummaryResponseFromJson(jsonString);

import 'dart:convert';

CartSummaryResponse cartSummaryResponseFromJson(String str) => CartSummaryResponse.fromJson(json.decode(str));

String cartSummaryResponseToJson(CartSummaryResponse data) => json.encode(data.toJson());

class CartSummaryResponse { 
  CartSummaryResponse({
    required this.sub_total,
    required this.tax,
    required this.shipping_cost,
    required this.discount,
    required this.grand_total,
    required this.grand_total_value,
    required this.coupon_code,
    required this.coupon_applied
   });

  String sub_total;
  String tax;
  String shipping_cost;
  String discount;
  String grand_total;
  double grand_total_value;
  String coupon_code;
  bool coupon_applied;

  factory CartSummaryResponse.fromJson(Map<String, dynamic> json) => CartSummaryResponse(
    sub_total: json["sub_total"],
    tax: json["tax"],
    shipping_cost: json["shipping_cost"],
    discount: json["discount"],
    grand_total: json["grand_total"],
    grand_total_value:double.parse(json["grand_total_value"].toString()) ,
    coupon_code: json["coupon_code"],
    coupon_applied: json["coupon_applied"],
  );

  Map<String, dynamic> toJson() => { 
    "sub_total": sub_total,
    "tax": tax,
    "shipping_cost": shipping_cost,
    "discount": discount,
    "grand_total": grand_total,
    "grand_total_value": grand_total_value,
    "coupon_code": coupon_code,
    "coupon_applied": coupon_applied,
   };
}