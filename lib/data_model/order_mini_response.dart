// To parse this JSON data, do
//
//     final orderMiniResponse = orderMiniResponseFromJson(jsonString);
// https://app.quicktype.io/
import 'dart:convert';

OrderMiniResponse orderMiniResponseFromJson(String str) => OrderMiniResponse.fromJson(json.decode(str));

String orderMiniResponseToJson(OrderMiniResponse data) => json.encode(data.toJson());

class OrderMiniResponse { 
  OrderMiniResponse({
    required this.orders,
    required this.links,
    required this.meta,
    required this.success,
    required this.status,
   });

  List<Order> orders;
  OrderMiniResponseLinks links;
  Meta meta;
  bool success;
  int status;

  factory OrderMiniResponse.fromJson(Map<String, dynamic> json) => OrderMiniResponse(
    orders: List<Order>.from(json["data"].map((x) => Order.fromJson(x))),
    links: OrderMiniResponseLinks.fromJson(json["links"]),
    meta: Meta.fromJson(json["meta"]),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => { 
    "data": List<dynamic>.from(orders.map((x) => x.toJson())),
    "links": links.toJson(),
    "meta":  meta.toJson(),
    "success": success,
    "status": status,
   };
}

class Order { 
  Order({
    required this.id,
    required this.code,
    required this.user_id,
    required this.payment_type,
    required this.payment_status,
    required this.payment_status_string,
    required this.delivery_status,
    required this.delivery_status_string,
    required this.grand_total,
    required this.date,
    required this.links,
   });

  int id;
  String code;
  int user_id;
  String  payment_type;
  String payment_status;
  String  payment_status_string;
  String delivery_status;
  String delivery_status_string;
  String grand_total;
  String date;
  OrderLinks links;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    code: json["code"],
    user_id: json["user_id"],
    payment_type: json["payment_type"],
    payment_status: json["payment_status"],
    payment_status_string: json["payment_status_string"],
    delivery_status: json["delivery_status"],
    delivery_status_string: json["delivery_status_string"],
    grand_total: json["grand_total"],
    date: json["date"],
    links: OrderLinks.fromJson(json["links"]),
  );

  Map<String, dynamic> toJson() => { 
    "id": id,
    "code": code,
    "user_id": user_id,
    "payment_type":payment_type,
    "payment_status": payment_status,
    "payment_status_string": payment_status_string,
    "delivery_status": delivery_status,
    "delivery_status_string": delivery_status_string,
    "grand_total": grand_total,
    "date": date,
    "links": links.toJson(),
   };
}

class OrderLinks { 
  OrderLinks({
    required this.details,
   });

  String details;

  factory OrderLinks.fromJson(Map<String, dynamic> json) => OrderLinks(
    details: json["details"],
  );

  Map<String, dynamic> toJson() => { 
    "details": details,
   };
}



class OrderMiniResponseLinks { 
  OrderMiniResponseLinks({
    required this.first,
    required this.last,
    required this.prev,
    required this.next,
   });

  dynamic first;
  dynamic last;
  dynamic prev;
  dynamic next;

  factory OrderMiniResponseLinks.fromJson(Map<String, dynamic> json) => OrderMiniResponseLinks(
    first: json["first"],
    last: json["last"],
    prev: json["prev"],
    next: json["next"],
  );

  Map<String, dynamic> toJson() => { 
    "first": first,
    "last": last,
    "prev": prev,
    "next": next,
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

