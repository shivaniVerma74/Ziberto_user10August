// import 'Data.dart';
// import 'FreeProductModel.dart';
//
// class ProductModel {
//   ProductModel({
//       required this.error,
//       required this.message,
//       required this.minPrice,
//       required this.maxPrice,
//       this.search,
//       required this.filters,
//       required this.tags,
//       required this.total,
//       required this.offset,
//       required this.data,});
//
//   ProductModel.fromJson(dynamic json) {
//     error = json['error'];
//     message = json['message'];
//     minPrice = json['min_price'];
//     maxPrice = json['max_price'];
//     search = json['search'];
//     if (json['filters'] != null) {
//       filters = [];
//       json['filters'].forEach((v) {
//         filters.add(Filters.fromJson(v));
//       });
//     }
//     if (json['tags'] != null) {
//       tags = [];
//       json['tags'].forEach((v) {
//         tags.add(v.fromJson(v));
//       });
//     }
//     total = json['total'];
//     offset = json['offset'];
//     if (json['data'] != null) {
//       data = [];
//       json['data'].forEach((v) {
//         data.add(Data.fromJson(v));
//       });
//     }
//   }
//   bool error;
//   String message;
//   String minPrice;
//   String maxPrice;
//   dynamic search;
//   List<Filters> filters;
//   List<dynamic> tags;
//   String total;
//   String offset;
//   List<Data> data;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['error'] = error;
//     map['message'] = message;
//     map['min_price'] = minPrice;
//     map['max_price'] = maxPrice;
//     map['search'] = search;
//     if (filters != null) {
//       map['filters'] = filters.map((v) => v.toJson()).toList();
//     }
//     if (tags != null) {
//       map['tags'] = tags.map((v) => v.toJson()).toList();
//     }
//     map['total'] = total;
//     map['offset'] = offset;
//     if (data != null) {
//       map['data'] = data.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }
//
// }