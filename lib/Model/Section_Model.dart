
import 'package:agritungotest/Helper/String.dart';
import 'package:flutter/cupertino.dart';

import 'User.dart';

class Todo {
  final String id,
      title,
      varientId,
      qty,
      productId,
      perItemTotal,
      perItemPrice,
      singleItemNetAmount,
      singleItemTaxAmount,
      style,
      shortDesc;
  final List<Product>? productList;
  final List<Promo>? promoList;
  final List<Filter>? filterList;
  List<String>? selectedId = [];
  final int? offset, totalItem;

  Todo(
      this.id,
      this.title,
      this.shortDesc,
      this.productList,
      this.varientId,
      this.qty,
      this.productId,
      this.perItemTotal,
      this.perItemPrice,
      this.style,
      this.totalItem,
      this.offset,
      this.selectedId,
      this.filterList,
      this.singleItemTaxAmount,
      this.singleItemNetAmount,
      this.promoList
      );

}
class SectionModel {
  String? id,
      title,
      varientId,
      qty,
      productId,
      perItemTotal,
      perItemPrice,
      singleItemNetAmount,
      singleItemTaxAmount,
      style,
      shortDesc;
  double? perItemTaxPriceOnItemsTotal,
      perItemTaxPriceOnItemAmount,
      perItemTaxPercentage = 0.0;
  List<Product>? productList;
  List<Promo>? promoList;
  List<Filter>? filterList;
  List<String>? selectedId = [];
  int? offset, totalItem;

  SectionModel(
      {this.id,
        this.title,
        this.shortDesc,
        this.productList,
        this.varientId,
        this.qty,
        this.productId,
        this.perItemTotal,
        this.perItemPrice,
        this.style,
        this.totalItem,
        this.offset,
        this.selectedId,
        this.filterList,
        this.singleItemTaxAmount,
        this.singleItemNetAmount,
        this.promoList});

  factory SectionModel.fromJson(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => Product.fromJson(data))
        .toList();

    var flist = (parsedJson[FILTERS] as List?);
    List<Filter> filterList = [];
    if (flist == null || flist.isEmpty) {
      filterList = [];
    } else {
      filterList = flist.map((data) => Filter.fromJson(data)).toList();
    }
    List<String> selected = [];
    return SectionModel(
        id: parsedJson[ID],
        title: parsedJson[TITLE],
        shortDesc: parsedJson[SHORT_DESC],
        style: parsedJson[STYLE],
        productList: productList,
        offset: 0,
        totalItem: 0,
        filterList: filterList,
        selectedId: selected);
  }

  factory SectionModel.fromCart(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => Product.fromJson(data))
        .toList();

    return SectionModel(
        id: parsedJson[ID],
        varientId: parsedJson[PRODUCT_VARIENT_ID],
        qty: parsedJson[QTY],
        perItemTotal: '0',
        perItemPrice: '0',
        productList: productList,
        singleItemNetAmount: parsedJson['net_amount'].toString(),
        singleItemTaxAmount:parsedJson['tax_amount'].toString()
    );
  }

  factory SectionModel.fromFav(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => Product.fromJson(data))
        .toList();

    return SectionModel(
        id: parsedJson[ID],
        productId: parsedJson[PRODUCT_ID],
        productList: productList);
  }
}
class Product {
  String? id,
      name,
      desc,
      unit,
      price,
      image,
      catName,
      type,
      availability,
      // rating,
      noOfRating,
      attrIds,
      tax,
      categoryId,
      shortDescription,
      codAllowed,
      discPrice,
      qtyStepSize;
  Rating? rating;
  List<String>? itemsCounter;
  List<String>? otherImage;
  List<Product_Varient>? prVarientList;
  List<Attribute>? attributeList;
  List<String>? selectedId = [];
  List<String>? tagList = [];
  int? minOrderQuntity;
  String? isFav,
      isReturnable,
      isCancelable,
      isPurchased,
      madein,
      indicator,
      stockType,
      cancleTill,
      total,
      banner,
      totalAllow,
      video,
      videType,
      warranty,
      gurantee,
      is_attch_req;
  String? minPrice, maxPrice;
  String? totalImg;
  List<ReviewImg>? reviewList;

  bool? isFavLoading = false, isFromProd = false;
  int? offset, totalItem, selVarient;

  List<Product>? subList;
  List<Filter>? filterList;
  bool? history = false;
  String? store_description,
      seller_rating,
      noOfRatingsOnSeller,
      seller_profile,
      seller_name,
      seller_id,
      store_name,
      totalProductsOfSeller;
    Category? supplier;
    Category? category;

  // String historyList;

  Product(
      {this.id,
        this.name,
        this.desc,
        this.image,
        this.catName,
        this.unit,
        this.price,
        this.type,
        this.otherImage,
        this.prVarientList,
        this.attributeList,
        this.isFav,
        this.isCancelable,
        this.isReturnable,
        this.isPurchased,
        this.availability,
        this.noOfRating,
        this.attrIds,
        this.discPrice,
        this.selectedId,
        this.rating,
        this.isFavLoading,
        this.indicator,
        this.madein,
        this.tax,
        this.shortDescription,
        this.total,
        this.supplier,
        this.categoryId,
        this.subList,
        this.filterList,
        this.stockType,
        this.isFromProd,
        this.cancleTill,
        this.totalItem,
        this.offset,
        this.totalAllow,
        this.banner,
        this.selVarient,
        this.video,
        this.videType,
        this.tagList,
        this.warranty,
        this.qtyStepSize,
        this.minOrderQuntity,
        this.itemsCounter,
        this.reviewList,
        this.history,
        this.minPrice,
        this.maxPrice,
        this.totalProductsOfSeller,
        this.codAllowed,
        this.category,
        //  this.historyList,
        this.gurantee,
        this.store_description,
        this.seller_rating,
        this.noOfRatingsOnSeller,
        this.seller_profile,
        this.seller_name,
        this.seller_id,
        this.store_name,
        this.is_attch_req});

  factory Product.fromJson(Map<String, dynamic> json) {
    // List<Product_Varient> varientList = (json[PRODUCT_VARIENT] as List)
    //     .map((data) => Product_Varient.fromJson(data))
    //     .toList();

    // List<Attribute> attList = (json[ATTRIBUTES] as List)
    //     .map((data) => Attribute.fromJson(data))
    //     .toList();
    // List<Variant>? variant=[];
    //
    // if (json['variant'] != null) {
    //   variant = <Variant>[];
    //   json['variant'].forEach((v) {
    //     variant!.add(new Variant.fromJson(v));
    //   });
    // }
    var flist = (json[FILTERS] as List?);
    List<Filter> filterList = [];
    if (flist == null || flist.isEmpty) {
      filterList = [];
    } else {
      filterList = flist.map((data) => Filter.fromJson(data)).toList();
    }

    List<String> otherImage = List<String>.from(json[IMAGES]);
    List<String> selected = [];

    // List<String> tags = List<String>.from(json[TAG]);

    List<String> items = List<String>.generate(
     double.parse(json[TOTALALOOW])~/10 , (i) {
      return ((i + 1) * int.parse(json[QTYSTEP])).toString();
    }
    );
    var reviewImg = (json[REV_IMG] as List?);
    List<ReviewImg> reviewList = [];
    if (reviewImg == null || reviewImg.isEmpty) {
      reviewList = [];
    } else {
      reviewList = reviewImg.map((data) => ReviewImg.fromJson(data)).toList();
    }
   // rating json[RATING] != null ? new Rating.fromJson(json['rating']) : null;
    return Product(
      id: json[ID],
      name: json[NAME],
      unit: json[MEAS_UNIT_ID],
      desc: json[DESC],
      discPrice: json[DISCOUNT],
      price: json[PRICE],
      image: json[IMAGE],
      catName: json[CAT_NAME],
      rating: json[RATING] != null ? new Rating.fromJson(json['rating']) : null,
      noOfRating: json[NO_OF_RATE],
      type: json[TYPE],
      isFav: json[FAV].toString(),
      isCancelable: json[ISCANCLEABLE],
      // availability: json[AVAILABILITY].toString(),
      isPurchased: json[ISPURCHASED].toString(),
      isReturnable: json[ISRETURNABLE],
      availability:json[STATUS],
      // otherImage: json['images'].cast<String>(),
      otherImage: otherImage,
      // prVarientList: variant,
      // attributeList: attList,
      // filterList: filterList,
      isFavLoading: false,
      selVarient: 0,
      attrIds: json[ATTR_VALUE],
      madein: json[MADEIN],
      shortDescription: json[SHORT],
      indicator: json[INDICATOR].toString(),
      stockType: json[STOCKTYPE].toString(),
      tax: json[TAX_PER],
      total: json[TOTAL],
      categoryId: json[CATID],
      selectedId: selected,
      totalAllow: json[TOTALALOOW],
      cancleTill: json[CANCLE_TILL],
      video: json[VIDEO],
      videType: json[VIDEO_TYPE],
      // tagList: tags,
      itemsCounter: items,
      warranty: json[WARRANTY],
      minOrderQuntity: int.parse(json[MINORDERQTY]??"0"),
      qtyStepSize: json[QTYSTEP],
      gurantee: json[GAURANTEE],
      reviewList: reviewList,
      history: false,
      minPrice: json[MINPRICE],
      maxPrice: json[MAXPRICE],
      seller_name: json[SELLER_NAME],
      supplier:json['supplier'] != null? new Category.fromJson(json['supplier']): null,
      category: json['category'] != null? new Category.fromJson(json['category']): null,
      seller_profile: json[SELLER_PROFILE],
      // seller_rating: json[SELLER_RATING],
      store_description: json[STORE_DESC],
      store_name: json[STORE_NAME],
      seller_id: json[SELLER_ID],
      is_attch_req: json[IS_ATTACH_REQ],
      codAllowed: json[COD_ALLOWED],

      // totalImg: tImg,
      // totalReviewImg: json[REV_IMG][TOTALIMGREVIEW],
      // productRating: reviewList
    );
  }

  factory Product.all(String name, String img, cat) {
    return Product(name: name, catName: cat, image: img, history: false);
  }

  factory Product.history(String history) {
    return Product(name: history, history: true);
  }

  factory Product.fromSeller(Map<String, dynamic> json) {
    return Product(
        seller_name: json[SELLER_NAME],
        seller_profile: json[SELLER_PROFILE],
        seller_rating: json[SELLER_RATING],
        noOfRatingsOnSeller: json[NO_OF_RATE],
        store_description: json[STORE_DESC],
        store_name: json[STORE_NAME],
        totalProductsOfSeller: json[TOTAL_PRODUCTS],
        seller_id: json[SELLER_ID]);
  }

  factory Product.fromCat(Map<String, dynamic> parsedJson) {
    return Product(
      id: parsedJson[ID],
      name: parsedJson[NAME],
      image: parsedJson[ICON],
      banner: parsedJson[IMAGE],
      isFromProd: false,
      offset: 0,
      totalItem: 0,
      // tax: parsedJson[TAX],
      // subList: createSubList(parsedJson['children']),
    );
  }

  factory Product.popular(String name, String image) {
    return Product(name: name, image: image);
  }

  static List<Product>? createSubList(List? parsedJson) {
    if (parsedJson == null || parsedJson.isEmpty) return null;

    return parsedJson.map((data) => Product.fromCat(data)).toList();
  }
}

class Product_Varient {
  String? id,
      productId,
      attribute_value_ids,
      price,
      disPrice,
      type,
      attr_name,
      varient_value,
      availability,
      cartCount;
  List<String>? images;

  Product_Varient(
      {
        this.id,
        this.productId,
        this.attr_name,
        this.varient_value,
        this.price,
        this.disPrice,
        this.attribute_value_ids,
        this.availability,
        this.cartCount,
        this.images}
      );

  factory Product_Varient.fromJson(Map<String, dynamic> json) {
    List<String> images = List<String>.from(json[IMAGES]);

    return Product_Varient(
        id: json[ID],
        attribute_value_ids: json[ATTRIBUTE_VALUE_ID],
        productId: json[PRODUCT_ID],
        attr_name: json[ATTR_NAME],
        varient_value: json[VARIENT_VALUE],
        disPrice: json[DIS_PRICE],
        price: json[PRICE],
        availability: json[AVAILABILITY].toString(),
        cartCount: json[CART_COUNT],
        images: images);
  }
}

class Attribute {
  String? id, value, name, sType, sValue;

  Attribute({this.id, this.value, this.name, this.sType, this.sValue});

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
        id: json[IDS],
        name: json[NAME],
        value: json[VALUE],
        sType: json[STYPE],
        sValue: json[SVALUE]);
  }
}

class Filter {
  String? attributeValues, attributeValId, name, swatchType, swatchValue;

  Filter(
      {this.attributeValues,
        this.attributeValId,
        this.name,
        this.swatchType,
        this.swatchValue});

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
        attributeValId: json[ATT_VAL_ID],
        name: json[NAME],
        attributeValues: json[ATT_VAL],
        swatchType: json[STYPE],
        swatchValue: json[SVALUE]);
  }
}

class ReviewImg {
  String? totalImg;
  List<User>? productRating;

  ReviewImg({this.totalImg, this.productRating});

  factory ReviewImg.fromJson(Map<String, dynamic> json) {
    var reviewImg = (json[PRODUCTRATING] as List?);
    List<User> reviewList = [];
    if (reviewImg == null || reviewImg.isEmpty) {
      reviewList = [];
    } else {
      reviewList = reviewImg.map((data) => User.forReview(data)).toList();
    }

    return ReviewImg(totalImg: json[TOTALIMG], productRating: reviewList);
  }
}

class Promo {
  String? id,
      promoCode,
      message,
      image,
      remainingDays,
      status,
      noOfRepeatUsage,
      maxDiscountAmt,
      discountType,
      noOfUsers,
      minOrderAmt,
      repeatUsage,
      discount,
      endDate,
      isInstantCashback,
      startDate;
  bool isExpanded;

  Promo({
    this.id,
    this.promoCode,
    this.message,
    this.startDate,
    this.endDate,
    this.discount,
    this.repeatUsage,
    this.minOrderAmt,
    this.noOfUsers,
    this.discountType,
    this.maxDiscountAmt,
    this.image,
    this.noOfRepeatUsage,
    this.status,
    this.remainingDays,
    this.isInstantCashback,
    this.isExpanded = false,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: json[ID],
      promoCode: json[PROMO_CODE],
      message: json[MESSAGE],
      image: json[IMAGE],
      remainingDays: json[REMAIN_DAY],
      discount: json[DISCOUNT],
      discountType: json[DISCOUNT_TYPE],
      endDate: json[END_DATE],
      maxDiscountAmt: json[MAX_DISCOUNT_AMOUNT],
      minOrderAmt: json[MIN_ORDER_AMOUNT],
      noOfRepeatUsage: json[NO_OF_REPEAT_USAGE],
      noOfUsers: json[NO_OF_USERS],
      repeatUsage: json[REPEAT_USAGE],
      startDate: json[START_DATE],
      isInstantCashback: json[INSTANT_CASHBACK],
      status: json[STATUS],
    );
  }
}

class Images {
  String? id;
  String? url;
  String? name;
  String? description;

  Images({this.id, this.url, this.name, this.description});

  factory Images.fromJson(Map<String, dynamic> json) {
   return Images(
    id:json[ID],
    url:json[URL],
    name:json[NAME],
    description:json[DESC]
    );
  }
}

class Suppliers {
  String? id;
  String? name;
  String? contact;
  String? email;
  String? seller_rating,noOfRatingsOnSeller,totalProductsOfSeller,seller_profile;

  Suppliers(
      {this.id,
        this.name,
        this.contact,
        this.email,
        this.seller_rating,
        this.totalProductsOfSeller,
        this.seller_profile,
        this.noOfRatingsOnSeller

      });

  factory Suppliers.fromJson(Map<String, dynamic> json) {
    return Suppliers(
    id:json[ID],
    name:json[NAME],
    contact: json[CONTACT],
    email: json[EMAIL],
    seller_rating: json[SELLER_RATING],
    totalProductsOfSeller: json[TOTAL_PRODUCTS],
      seller_profile: json[SELLER_PROFILE],
      noOfRatingsOnSeller: json[NO_OF_RATE],
    );
  }


}
class Rating {
  String? ratingOne;
  String? ratingTwo;
  String? ratingThree;
  String? ratingFour;
  String? ratingFive;
  String? ratingValue;
  String? total;

  Rating({this.ratingOne,
    this.ratingTwo,
    this.ratingThree,
    this.ratingFour,
    this.ratingFive,
    this.ratingValue,
    this.total});

 factory Rating.fromJson(Map<String, dynamic> json) {
   return Rating(
    ratingOne :json['rating_one'],
    ratingTwo :json['rating_two'],
    ratingThree :json['rating_three'],
    ratingFour:json['rating_four'],
    ratingFive: json['rating_five'],
    ratingValue: json['rating_value'],
    total:json['total']);
  }
}
class Variant {
  int? id;
  String? type;
  List<Values>? values;

  Variant({this.id, this.type, this.values});

  Variant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    if (json['values'] != null) {
      values = <Values>[];
      json['values'].forEach((v) {
        values!.add(new Values.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    if (this.values != null) {
      data['values'] = this.values!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Values {
  int? id;
  String? name;
  String? price;
  String? discount;
  String? variantqty;

  Values({this.id, this.name, this.price, this.discount, this.variantqty});

  Values.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    discount = json['discount'];
    variantqty = json['variantqty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    data['discount'] = this.discount;
    data['variantqty'] = this.variantqty;
    return data;
  }
}

class Category {
  String? id;
  String? name;

  Category({this.id,  this.name});

 factory Category.fromJson(Map<String, dynamic> json) {
   return Category(
    id:json[ID],
    name :json[NAME],
    );
  }

}
