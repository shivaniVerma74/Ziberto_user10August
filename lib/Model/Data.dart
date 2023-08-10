import 'OrderItems.dart';

class Data {
  Data({
       this.id,
     this.userId,
     this.addressId,
     this.mobile,
     this.total,
     this.deliveryCharge,
     this.isDeliveryChargeReturnable,
     this.walletBalance,
     this.promoCode,
      this.promoDiscount,
      this.discount,
     this.totalPayable,
     this.finalTotal,
     this.paymentMethod,
      this.latitude,
      this.longitude,
      this.address,
      this.deliveryTime,
      this.deliveryDate,
     this.dateAdded,
     this.otp,
      this.notes,
     this.packingCharge,
     this.username,
     this.countryCode,
     this.name,
     this.attachments,
      this.courierAgency,
     this.trackingId,
      this.url,
     this.isReturnable,
     this.isCancelable,
     this.isAlreadyReturned,
     this.isAlreadyCancelled,
      this.returnRequestSubmitted,
     this.totalTaxPercent,
      this.totalTaxAmount,
      this.invoiceHtml,
      this.orderItems});

  Data.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    addressId = json['address_id'];
    mobile = json['mobile'];
    total = json['total'];
    deliveryCharge = json['delivery_charge'];
    isDeliveryChargeReturnable = json['is_delivery_charge_returnable'];
    walletBalance = json['wallet_balance'];
    promoCode = json['promo_code'];
    promoDiscount = json['promo_discount'];
    discount = json['discount'];
    totalPayable = json['total_payable'];
    finalTotal = json['final_total'];
    paymentMethod = json['payment_method'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    deliveryTime = json['delivery_time'];
    deliveryDate = json['delivery_date'];
    dateAdded = json['date_added'];
    otp = json['otp'];
    notes = json['notes'];
    packingCharge = json['packing_charge'];
    username = json['username'];
    countryCode = json['country_code'];
    name = json['name'];
    if (json['attachments'] != null) {
      attachments = [];
      json['attachments'].forEach((v) {
        attachments?.add((v));
      });
    }
    courierAgency = json['courier_agency'];
    trackingId = json['tracking_id'];
    url = json['url'];
    isReturnable = json['is_returnable'];
    isCancelable = json['is_cancelable'];
    isAlreadyReturned = json['is_already_returned'];
    isAlreadyCancelled = json['is_already_cancelled'];
    returnRequestSubmitted = json['return_request_submitted'];
    totalTaxPercent = json['total_tax_percent'];
    totalTaxAmount = json['total_tax_amount'];
    invoiceHtml = json['invoice_html'];
    if (json['order_items'] != null) {
      orderItems = [];
      json['order_items'].forEach((v) {
        orderItems!.add(OrderItems.fromJson(v));
      });
    }
  }
  String? id;
  String? userId;
  String? addressId;
  String? mobile;
  String? total;
  String? deliveryCharge;
  String? isDeliveryChargeReturnable;
  String? walletBalance;
  String? promoCode;
  String? promoDiscount;
  String? discount;
  String? totalPayable;
  String? finalTotal;
  String? paymentMethod;
  String? latitude;
  String? longitude;
  String? address;
  dynamic deliveryTime;
  dynamic deliveryDate;
  String? dateAdded;
  String? otp;
  String? notes;
  String? packingCharge;
  String? username;
  String? countryCode;
  String? name;
  List<dynamic>? attachments;
  String? courierAgency;
  String? trackingId;
  String? url;
  String? isReturnable;
  String? isCancelable;
  String? isAlreadyReturned;
  String? isAlreadyCancelled;
  dynamic returnRequestSubmitted;
  String? totalTaxPercent;
  String? totalTaxAmount;
  String? invoiceHtml;
  List<OrderItems>? orderItems;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['address_id'] = addressId;
    map['mobile'] = mobile;
    map['total'] = total;
    map['delivery_charge'] = deliveryCharge;
    map['is_delivery_charge_returnable'] = isDeliveryChargeReturnable;
    map['wallet_balance'] = walletBalance;
    map['promo_code'] = promoCode;
    map['promo_discount'] = promoDiscount;
    map['discount'] = discount;
    map['total_payable'] = totalPayable;
    map['final_total'] = finalTotal;
    map['payment_method'] = paymentMethod;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['address'] = address;
    map['delivery_time'] = deliveryTime;
    map['delivery_date'] = deliveryDate;
    map['date_added'] = dateAdded;
    map['otp'] = otp;
    map['notes'] = notes;
    map['packing_charge'] = packingCharge;
    map['username'] = username;
    map['country_code'] = countryCode;
    map['name'] = name;
    if (attachments != null) {
      map['attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    map['courier_agency'] = courierAgency;
    map['tracking_id'] = trackingId;
    map['url'] = url;
    map['is_returnable'] = isReturnable;
    map['is_cancelable'] = isCancelable;
    map['is_already_returned'] = isAlreadyReturned;
    map['is_already_cancelled'] = isAlreadyCancelled;
    map['return_request_submitted'] = returnRequestSubmitted;
    map['total_tax_percent'] = totalTaxPercent;
    map['total_tax_amount'] = totalTaxAmount;
    map['invoice_html'] = invoiceHtml;
    if (orderItems != null) {
      map['order_items'] = orderItems!.map((v) => v.toJson()).toList();
    }
    return map;
  }

}