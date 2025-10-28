// To parse this JSON data, do
//
//     final offlinePaymentSubmitResponse = offlinePaymentSubmitResponseFromJson(jsonString);

import 'dart:convert';

OfflinePaymentSubmitResponse offlinePaymentSubmitResponseFromJson(String str) => OfflinePaymentSubmitResponse.fromJson(json.decode(str));

String offlinePaymentSubmitResponseToJson(OfflinePaymentSubmitResponse data) => json.encode(data.toJson());

class OfflinePaymentSubmitResponse { 
  OfflinePaymentSubmitResponse({
    required this.result,
    required this.message,
   });

  bool result;
  String message;

  factory OfflinePaymentSubmitResponse.fromJson(Map<String, dynamic> json) => OfflinePaymentSubmitResponse(
    result: json["result"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => { 
    "result": result,
    "message": message,
   };
}