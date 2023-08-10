// import 'Data.dart';
//
// class OrdersModel {
//   OrdersModel({
//       required this.error,
//       required this.message,
//       required this.total,
//       required this.data,});
//
//   OrdersModel.fromJson(dynamic json) {
//     error = json['error'];
//     message = json['message'];
//     total = json['total'];
//     if (json['data'] != null) {
//       data = [];
//       json['data'].forEach((v) {
//         data.add(Data.fromJson(v));
//       });
//     }
//   }
//   bool error;
//   String message;
//   String total;
//   List<Data> data;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['error'] = error;
//     map['message'] = message;
//     map['total'] = total;
//     if (data != null) {
//       map['data'] = data.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }
//
// }