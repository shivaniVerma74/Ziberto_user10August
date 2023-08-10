import 'dart:convert';
/// error : false
/// message : "get successfully!"
/// date : {"error":false,"message":"Seller retrieved successfully","total":"1","data":[{"seller_id":"228","average_rating":null,"seller_name":"alpha store","email":"alpha1589@gmail.com","mobile":"7856954259","slug":"alpha-store-1","seller_rating":"0.00","no_of_ratings":"0","store_name":"alpha store","store_url":"","store_description":"sjde","shop_type":"1","veg_nonveg":"1","seller_profile":"https://alphawizztest.tk/Ziberto1/","balance":"0","estimated_time":"","food_person":"300","address":"Chhoti Gwaltoli, Indore, Madhya Pradesh 452007, India","open_close_status":"1","cover_image":""}]}

WeekendSellerModel weekendSellerModelFromJson(String str) => WeekendSellerModel.fromJson(json.decode(str));
String weekendSellerModelToJson(WeekendSellerModel data) => json.encode(data.toJson());
class WeekendSellerModel {
  WeekendSellerModel({
      bool? error, 
      String? message, 
      Date? date,}){
    _error = error;
    _message = message;
    _date = date;
}

  WeekendSellerModel.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
    _date = json['date'] != null ? Date.fromJson(json['date']) : null;
  }
  bool? _error;
  String? _message;
  Date? _date;
WeekendSellerModel copyWith({  bool? error,
  String? message,
  Date? date,
}) => WeekendSellerModel(  error: error ?? _error,
  message: message ?? _message,
  date: date ?? _date,
);
  bool? get error => _error;
  String? get message => _message;
  Date? get date => _date;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    if (_date != null) {
      map['date'] = _date?.toJson();
    }
    return map;
  }

}

/// error : false
/// message : "Seller retrieved successfully"
/// total : "1"
/// data : [{"seller_id":"228","average_rating":null,"seller_name":"alpha store","email":"alpha1589@gmail.com","mobile":"7856954259","slug":"alpha-store-1","seller_rating":"0.00","no_of_ratings":"0","store_name":"alpha store","store_url":"","store_description":"sjde","shop_type":"1","veg_nonveg":"1","seller_profile":"https://alphawizztest.tk/Ziberto1/","balance":"0","estimated_time":"","food_person":"300","address":"Chhoti Gwaltoli, Indore, Madhya Pradesh 452007, India","open_close_status":"1","cover_image":""}]

Date dateFromJson(String str) => Date.fromJson(json.decode(str));
String dateToJson(Date data) => json.encode(data.toJson());
class Date {
  Date({
      bool? error, 
      String? message, 
      String? total, 
      List<Data>? data,}){
    _error = error;
    _message = message;
    _total = total;
    _data = data;
}

  Date.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
    _total = json['total'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _error;
  String? _message;
  String? _total;
  List<Data>? _data;
Date copyWith({  bool? error,
  String? message,
  String? total,
  List<Data>? data,
}) => Date(  error: error ?? _error,
  message: message ?? _message,
  total: total ?? _total,
  data: data ?? _data,
);
  bool? get error => _error;
  String? get message => _message;
  String? get total => _total;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    map['total'] = _total;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// seller_id : "228"
/// average_rating : null
/// seller_name : "alpha store"
/// email : "alpha1589@gmail.com"
/// mobile : "7856954259"
/// slug : "alpha-store-1"
/// seller_rating : "0.00"
/// no_of_ratings : "0"
/// store_name : "alpha store"
/// store_url : ""
/// store_description : "sjde"
/// shop_type : "1"
/// veg_nonveg : "1"
/// seller_profile : "https://alphawizztest.tk/Ziberto1/"
/// balance : "0"
/// estimated_time : ""
/// food_person : "300"
/// address : "Chhoti Gwaltoli, Indore, Madhya Pradesh 452007, India"
/// open_close_status : "1"
/// cover_image : ""

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      String? sellerId, 
      dynamic averageRating, 
      String? sellerName, 
      String? email, 
      String? mobile, 
      String? slug, 
      String? sellerRating, 
      String? noOfRatings, 
      String? storeName, 
      String? storeUrl, 
      String? storeDescription, 
      String? shopType, 
      String? vegNonveg, 
      String? sellerProfile, 
      String? balance, 
      String? estimatedTime, 
      String? foodPerson, 
      String? address, 
      String? openCloseStatus, 
      String? coverImage,}){
    _sellerId = sellerId;
    _averageRating = averageRating;
    _sellerName = sellerName;
    _email = email;
    _mobile = mobile;
    _slug = slug;
    _sellerRating = sellerRating;
    _noOfRatings = noOfRatings;
    _storeName = storeName;
    _storeUrl = storeUrl;
    _storeDescription = storeDescription;
    _shopType = shopType;
    _vegNonveg = vegNonveg;
    _sellerProfile = sellerProfile;
    _balance = balance;
    _estimatedTime = estimatedTime;
    _foodPerson = foodPerson;
    _address = address;
    _openCloseStatus = openCloseStatus;
    _coverImage = coverImage;
}

  Data.fromJson(dynamic json) {
    _sellerId = json['seller_id'];
    _averageRating = json['average_rating'];
    _sellerName = json['seller_name'];
    _email = json['email'];
    _mobile = json['mobile'];
    _slug = json['slug'];
    _sellerRating = json['seller_rating'];
    _noOfRatings = json['no_of_ratings'];
    _storeName = json['store_name'];
    _storeUrl = json['store_url'];
    _storeDescription = json['store_description'];
    _shopType = json['shop_type'];
    _vegNonveg = json['veg_nonveg'];
    _sellerProfile = json['seller_profile'];
    _balance = json['balance'];
    _estimatedTime = json['estimated_time'];
    _foodPerson = json['food_person'];
    _address = json['address'];
    _openCloseStatus = json['open_close_status'];
    _coverImage = json['cover_image'];
  }
  String? _sellerId;
  dynamic _averageRating;
  String? _sellerName;
  String? _email;
  String? _mobile;
  String? _slug;
  String? _sellerRating;
  String? _noOfRatings;
  String? _storeName;
  String? _storeUrl;
  String? _storeDescription;
  String? _shopType;
  String? _vegNonveg;
  String? _sellerProfile;
  String? _balance;
  String? _estimatedTime;
  String? _foodPerson;
  String? _address;
  String? _openCloseStatus;
  String? _coverImage;
Data copyWith({  String? sellerId,
  dynamic averageRating,
  String? sellerName,
  String? email,
  String? mobile,
  String? slug,
  String? sellerRating,
  String? noOfRatings,
  String? storeName,
  String? storeUrl,
  String? storeDescription,
  String? shopType,
  String? vegNonveg,
  String? sellerProfile,
  String? balance,
  String? estimatedTime,
  String? foodPerson,
  String? address,
  String? openCloseStatus,
  String? coverImage,
}) => Data(  sellerId: sellerId ?? _sellerId,
  averageRating: averageRating ?? _averageRating,
  sellerName: sellerName ?? _sellerName,
  email: email ?? _email,
  mobile: mobile ?? _mobile,
  slug: slug ?? _slug,
  sellerRating: sellerRating ?? _sellerRating,
  noOfRatings: noOfRatings ?? _noOfRatings,
  storeName: storeName ?? _storeName,
  storeUrl: storeUrl ?? _storeUrl,
  storeDescription: storeDescription ?? _storeDescription,
  shopType: shopType ?? _shopType,
  vegNonveg: vegNonveg ?? _vegNonveg,
  sellerProfile: sellerProfile ?? _sellerProfile,
  balance: balance ?? _balance,
  estimatedTime: estimatedTime ?? _estimatedTime,
  foodPerson: foodPerson ?? _foodPerson,
  address: address ?? _address,
  openCloseStatus: openCloseStatus ?? _openCloseStatus,
  coverImage: coverImage ?? _coverImage,
);
  String? get sellerId => _sellerId;
  dynamic get averageRating => _averageRating;
  String? get sellerName => _sellerName;
  String? get email => _email;
  String? get mobile => _mobile;
  String? get slug => _slug;
  String? get sellerRating => _sellerRating;
  String? get noOfRatings => _noOfRatings;
  String? get storeName => _storeName;
  String? get storeUrl => _storeUrl;
  String? get storeDescription => _storeDescription;
  String? get shopType => _shopType;
  String? get vegNonveg => _vegNonveg;
  String? get sellerProfile => _sellerProfile;
  String? get balance => _balance;
  String? get estimatedTime => _estimatedTime;
  String? get foodPerson => _foodPerson;
  String? get address => _address;
  String? get openCloseStatus => _openCloseStatus;
  String? get coverImage => _coverImage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['seller_id'] = _sellerId;
    map['average_rating'] = _averageRating;
    map['seller_name'] = _sellerName;
    map['email'] = _email;
    map['mobile'] = _mobile;
    map['slug'] = _slug;
    map['seller_rating'] = _sellerRating;
    map['no_of_ratings'] = _noOfRatings;
    map['store_name'] = _storeName;
    map['store_url'] = _storeUrl;
    map['store_description'] = _storeDescription;
    map['shop_type'] = _shopType;
    map['veg_nonveg'] = _vegNonveg;
    map['seller_profile'] = _sellerProfile;
    map['balance'] = _balance;
    map['estimated_time'] = _estimatedTime;
    map['food_person'] = _foodPerson;
    map['address'] = _address;
    map['open_close_status'] = _openCloseStatus;
    map['cover_image'] = _coverImage;
    return map;
  }

}