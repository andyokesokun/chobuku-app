// To parse this JSON data, do
//
//     final responseCheckModel = responseCheckModelFromJson(jsonString);

import 'dart:convert';

ResponseCheckModel responseCheckModelFromJson(String str) => ResponseCheckModel.fromJson(json.decode(str));

String responseCheckModelToJson(ResponseCheckModel data) => json.encode(data.toJson());

class ResponseCheckModel { 
  ResponseCheckModel({
    required this.result,
    required this.message,
    required this.resultKey,
   });

  bool result;
  String message;
  String resultKey;

  factory ResponseCheckModel.fromJson(Map<String, dynamic> json) => ResponseCheckModel(
    result: json["result"],
    message: json["message"],
    resultKey: json["result_key"],
  );

  Map<String, dynamic> toJson() => { 
    "result": result,
    "message": message,
    "result_key": resultKey,
   };
}
