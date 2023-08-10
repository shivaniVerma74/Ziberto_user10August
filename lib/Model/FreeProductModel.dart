class FreeProductModel {
  FreeProductModel({
    required this.error,
    required this.message,
    required this.minPrice,
    required this.maxPrice,
    this.search,
    required this.filters,
    required this.tags,
    required this.total,
    required this.offset,
    required this.data,
  });
  late final bool error;
  late final String message;
  late final String minPrice;
  late final String maxPrice;
  late final Null search;
  late final List<Filters> filters;
  late final List<dynamic> tags;
  late final String total;
  late final String offset;
  late final List<Data> data;

   FreeProductModel.fromJson(Map<String, dynamic> json){
    error = json['error'];
    message = json['message'];
    minPrice = json['min_price'];
    maxPrice = json['max_price'];
    search = null;
    filters = List.from(json['filters']).map((e)=>Filters.fromJson(e)).toList();
    tags = List.castFrom<dynamic, dynamic>(json['tags']);
    total = json['total'];
    offset = json['offset'];
    data = List.from(json['data']).map((e)=>Data.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['error'] = error;
    _data['message'] = message;
    _data['min_price'] = minPrice;
    _data['max_price'] = maxPrice;
    _data['search'] = search;
    _data['filters'] = filters.map((e)=>e.toJson()).toList();
    _data['tags'] = tags;
    _data['total'] = total;
    _data['offset'] = offset;
    _data['data'] = data.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Filters {
  Filters({
    required this.attributeValues,
    required this.attributeValuesId,
    required this.name,
    required this.swatcheType,
    required this.swatcheValue,
  });
  late final String attributeValues;
  late final String attributeValuesId;
  late final String name;
  late final String swatcheType;
  late final String swatcheValue;

  Filters.fromJson(Map<String, dynamic> json){
    attributeValues = json['attribute_values'];
    attributeValuesId = json['attribute_values_id'];
    name = json['name'];
    swatcheType = json['swatche_type'];
    swatcheValue = json['swatche_value'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['attribute_values'] = attributeValues;
    _data['attribute_values_id'] = attributeValuesId;
    _data['name'] = name;
    _data['swatche_type'] = swatcheType;
    _data['swatche_value'] = swatcheValue;
    return _data;
  }
}

class Data {
  Data({
    required this.total,
    required this.sales,
    this.stockType,
    required this.isPricesInclusiveTax,
    required this.type,
    required this.attrValueIds,
    required this.sellerRating,
    required this.sellerSlug,
    required this.sellerNoOfRatings,
    required this.sellerProfile,
    required this.storeName,
    required this.storeDescription,
    required this.sellerId,
    required this.sellerName,
    required this.id,
    this.stock,
    required this.name,
    required this.categoryId,
    required this.shortDescription,
    required this.slug,
    required this.description,
    required this.totalAllowedQuantity,
    required this.deliverableType,
    this.deliverableZipcodes,
    required this.minimumOrderQuantity,
    required this.quantityStepSize,
    required this.codAllowed,
    required this.rowOrder,
    required this.rating,
    required this.noOfRatings,
    required this.image,
    required this.isReturnable,
    required this.isCancelable,
    this.cancelableTill,
    this.indicator,
    required this.otherImages,
    required this.videoType,
    required this.video,
    required this.tags,
    required this.warrantyPeriod,
    required this.guaranteePeriod,
    required this.madeIn,
    this.availability,
    required this.categoryName,
    required this.taxPercentage,
    required this.reviewImages,
    required this.attributes,
    required this.variants,
    required this.minMaxPrice,
    this.deliverableZipcodesIds,
    required this.isDeliverable,
    required this.isPurchased,
    required this.isFavorite,
    required this.imageMd,
    required this.imageSm,
    required this.otherImagesSm,
    required this.otherImagesMd,
    required this.variantAttributes,
  });
  late final String total;
  late final String sales;
  late final Null stockType;
  late final String isPricesInclusiveTax;
  late final String type;
  late final String attrValueIds;
  late final String sellerRating;
  late final String sellerSlug;
  late final String sellerNoOfRatings;
  late final String sellerProfile;
  late final String storeName;
  late final String storeDescription;
  late final String sellerId;
  late final String sellerName;
  late final String id;
  late final Null stock;
  late final String name;
  late final String categoryId;
  late final String shortDescription;
  late final String slug;
  late final String description;
  late final String totalAllowedQuantity;
  late final String deliverableType;
  late final Null deliverableZipcodes;
  late final String minimumOrderQuantity;
  late final String quantityStepSize;
  late final String codAllowed;
  late final String rowOrder;
  late final String rating;
  late final String noOfRatings;
  late final String image;
  late final String isReturnable;
  late final String isCancelable;
  late final Null cancelableTill;
  late final Null indicator;
  late final List<dynamic> otherImages;
  late final String videoType;
  late final String video;
  late final List<dynamic> tags;
  late final String warrantyPeriod;
  late final String guaranteePeriod;
  late final String madeIn;
  late final Null availability;
  late final String categoryName;
  late final String taxPercentage;
  late final List<dynamic> reviewImages;
  late final List<Attributes> attributes;
  late final List<Variants> variants;
  late final MinMaxPrice minMaxPrice;
  late final Null deliverableZipcodesIds;
  late final bool isDeliverable;
  late final bool isPurchased;
  late final String isFavorite;
  late final String imageMd;
  late final String imageSm;
  late final List<dynamic> otherImagesSm;
  late final List<dynamic> otherImagesMd;
  late final List<dynamic> variantAttributes;

  Data.fromJson(Map<String, dynamic> json){
    total = json['total'];
    sales = json['sales'];
    stockType = null;
    isPricesInclusiveTax = json['is_prices_inclusive_tax'];
    type = json['type'];
    attrValueIds = json['attr_value_ids'];
    sellerRating = json['seller_rating'];
    sellerSlug = json['seller_slug'];
    sellerNoOfRatings = json['seller_no_of_ratings'];
    sellerProfile = json['seller_profile'];
    storeName = json['store_name'];
    storeDescription = json['store_description'];
    sellerId = json['seller_id'];
    sellerName = json['seller_name'];
    id = json['id'];
    stock = null;
    name = json['name'];
    categoryId = json['category_id'];
    shortDescription = json['short_description'];
    slug = json['slug'];
    description = json['description'];
    totalAllowedQuantity = json['total_allowed_quantity'];
    deliverableType = json['deliverable_type'];
    deliverableZipcodes = null;
    minimumOrderQuantity = json['minimum_order_quantity'];
    quantityStepSize = json['quantity_step_size'];
    codAllowed = json['cod_allowed'];
    rowOrder = json['row_order'];
    rating = json['rating'];
    noOfRatings = json['no_of_ratings'];
    image = json['image'];
    isReturnable = json['is_returnable'];
    isCancelable = json['is_cancelable'];
    cancelableTill = null;
    indicator = null;
    otherImages = List.castFrom<dynamic, dynamic>(json['other_images']);
    videoType = json['video_type'];
    video = json['video'];
    tags = List.castFrom<dynamic, dynamic>(json['tags']);
    warrantyPeriod = json['warranty_period'];
    guaranteePeriod = json['guarantee_period'];
    madeIn = json['made_in'];
    availability = null;
    categoryName = json['category_name'];
    taxPercentage = json['tax_percentage'];
    reviewImages = List.castFrom<dynamic, dynamic>(json['review_images']);
    attributes = List.from(json['attributes']).map((e)=>Attributes.fromJson(e)).toList();
    variants = List.from(json['variants']).map((e)=>Variants.fromJson(e)).toList();
    minMaxPrice = MinMaxPrice.fromJson(json['min_max_price']);
    deliverableZipcodesIds = null;
    isDeliverable = json['is_deliverable'];
    isPurchased = json['is_purchased'];
    isFavorite = json['is_favorite'];
    imageMd = json['image_md'];
    imageSm = json['image_sm'];
    otherImagesSm = List.castFrom<dynamic, dynamic>(json['other_images_sm']);
    otherImagesMd = List.castFrom<dynamic, dynamic>(json['other_images_md']);
    variantAttributes = List.castFrom<dynamic, dynamic>(json['variant_attributes']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['total'] = total;
    _data['sales'] = sales;
    _data['stock_type'] = stockType;
    _data['is_prices_inclusive_tax'] = isPricesInclusiveTax;
    _data['type'] = type;
    _data['attr_value_ids'] = attrValueIds;
    _data['seller_rating'] = sellerRating;
    _data['seller_slug'] = sellerSlug;
    _data['seller_no_of_ratings'] = sellerNoOfRatings;
    _data['seller_profile'] = sellerProfile;
    _data['store_name'] = storeName;
    _data['store_description'] = storeDescription;
    _data['seller_id'] = sellerId;
    _data['seller_name'] = sellerName;
    _data['id'] = id;
    _data['stock'] = stock;
    _data['name'] = name;
    _data['category_id'] = categoryId;
    _data['short_description'] = shortDescription;
    _data['slug'] = slug;
    _data['description'] = description;
    _data['total_allowed_quantity'] = totalAllowedQuantity;
    _data['deliverable_type'] = deliverableType;
    _data['deliverable_zipcodes'] = deliverableZipcodes;
    _data['minimum_order_quantity'] = minimumOrderQuantity;
    _data['quantity_step_size'] = quantityStepSize;
    _data['cod_allowed'] = codAllowed;
    _data['row_order'] = rowOrder;
    _data['rating'] = rating;
    _data['no_of_ratings'] = noOfRatings;
    _data['image'] = image;
    _data['is_returnable'] = isReturnable;
    _data['is_cancelable'] = isCancelable;
    _data['cancelable_till'] = cancelableTill;
    _data['indicator'] = indicator;
    _data['other_images'] = otherImages;
    _data['video_type'] = videoType;
    _data['video'] = video;
    _data['tags'] = tags;
    _data['warranty_period'] = warrantyPeriod;
    _data['guarantee_period'] = guaranteePeriod;
    _data['made_in'] = madeIn;
    _data['availability'] = availability;
    _data['category_name'] = categoryName;
    _data['tax_percentage'] = taxPercentage;
    _data['review_images'] = reviewImages;
    _data['attributes'] = attributes.map((e)=>e.toJson()).toList();
    _data['variants'] = variants.map((e)=>e.toJson()).toList();
    _data['min_max_price'] = minMaxPrice.toJson();
    _data['deliverable_zipcodes_ids'] = deliverableZipcodesIds;
    _data['is_deliverable'] = isDeliverable;
    _data['is_purchased'] = isPurchased;
    _data['is_favorite'] = isFavorite;
    _data['image_md'] = imageMd;
    _data['image_sm'] = imageSm;
    _data['other_images_sm'] = otherImagesSm;
    _data['other_images_md'] = otherImagesMd;
    _data['variant_attributes'] = variantAttributes;
    return _data;
  }
}

class Attributes {
  Attributes({
    required this.ids,
    required this.value,
    required this.attrName,
    required this.name,
    required this.swatcheType,
    required this.swatcheValue,
  });
  late final String ids;
  late final String value;
  late final String attrName;
  late final String name;
  late final String swatcheType;
  late final String swatcheValue;

  Attributes.fromJson(Map<String, dynamic> json){
    ids = json['ids'];
    value = json['value'];
    attrName = json['attr_name'];
    name = json['name'];
    swatcheType = json['swatche_type'];
    swatcheValue = json['swatche_value'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['ids'] = ids;
    _data['value'] = value;
    _data['attr_name'] = attrName;
    _data['name'] = name;
    _data['swatche_type'] = swatcheType;
    _data['swatche_value'] = swatcheValue;
    return _data;
  }
}

class Variants {
  Variants({
    required this.id,
    required this.productId,
    required this.attributeValueIds,
    required this.attributeSet,
    required this.price,
    required this.specialPrice,
    required this.sku,
    this.stock,
    required this.images,
    required this.availability,
    required this.status,
    required this.dateAdded,
    required this.variantIds,
    required this.attrName,
    required this.variantValues,
    required this.swatcheType,
    required this.swatcheValue,
    required this.imagesMd,
    required this.imagesSm,
    required this.cartCount,
  });
  late final String id;
  late final String productId;
  late final String attributeValueIds;
  late final String attributeSet;
  late final String price;
  late final String specialPrice;
  late final String sku;
  late final Null stock;
  late final List<dynamic> images;
  late final String availability;
  late final String status;
  late final String dateAdded;
  late final String variantIds;
  late final String attrName;
  late final String variantValues;
  late final String swatcheType;
  late final String swatcheValue;
  late final List<dynamic> imagesMd;
  late final List<dynamic> imagesSm;
  late final String cartCount;

  Variants.fromJson(Map<String, dynamic> json){
    id = json['id'];
    productId = json['product_id'];
    attributeValueIds = json['attribute_value_ids'];
    attributeSet = json['attribute_set'];
    price = json['price'];
    specialPrice = json['special_price'];
    sku = json['sku'];
    stock = null;
    images = List.castFrom<dynamic, dynamic>(json['images']);
    availability = json['availability'];
    status = json['status'];
    dateAdded = json['date_added'];
    variantIds = json['variant_ids'];
    attrName = json['attr_name'];
    variantValues = json['variant_values'];
    swatcheType = json['swatche_type'];
    swatcheValue = json['swatche_value'];
    imagesMd = List.castFrom<dynamic, dynamic>(json['images_md']);
    imagesSm = List.castFrom<dynamic, dynamic>(json['images_sm']);
    cartCount = json['cart_count'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['product_id'] = productId;
    _data['attribute_value_ids'] = attributeValueIds;
    _data['attribute_set'] = attributeSet;
    _data['price'] = price;
    _data['special_price'] = specialPrice;
    _data['sku'] = sku;
    _data['stock'] = stock;
    _data['images'] = images;
    _data['availability'] = availability;
    _data['status'] = status;
    _data['date_added'] = dateAdded;
    _data['variant_ids'] = variantIds;
    _data['attr_name'] = attrName;
    _data['variant_values'] = variantValues;
    _data['swatche_type'] = swatcheType;
    _data['swatche_value'] = swatcheValue;
    _data['images_md'] = imagesMd;
    _data['images_sm'] = imagesSm;
    _data['cart_count'] = cartCount;
    return _data;
  }
}

class MinMaxPrice {
  MinMaxPrice({
    required this.minPrice,
    required this.maxPrice,
    required this.specialPrice,
    required this.maxSpecialPrice,
    required this.discountInPercentage,
  });
  late final int minPrice;
  late final int maxPrice;
  late final int specialPrice;
  late final int maxSpecialPrice;
  late final int discountInPercentage;

  MinMaxPrice.fromJson(Map<String, dynamic> json){
    minPrice = json['min_price'];
    maxPrice = json['max_price'];
    specialPrice = json['special_price'];
    maxSpecialPrice = json['max_special_price'];
    discountInPercentage = json['discount_in_percentage'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['min_price'] = minPrice;
    _data['max_price'] = maxPrice;
    _data['special_price'] = specialPrice;
    _data['max_special_price'] = maxSpecialPrice;
    _data['discount_in_percentage'] = discountInPercentage;
    return _data;
  }
}