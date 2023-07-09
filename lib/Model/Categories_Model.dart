import 'package:agritungotest/Helper/String.dart';

class CategoriesData {
  String? id;
  String? name;
  String? icon;
  Null? description;
  String? timestamp;
  String? image;
  List<Products>? products;

  CategoriesData(
      {
        this.id,
        this.name,
        this.icon,
        this.description,
        this.timestamp,
        this.image,
        this.products});

  CategoriesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
    description = json['description'];
    timestamp = json['timestamp'];
    image = json['image'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['icon'] = this.icon;
    data['description'] = this.description;
    data['timestamp'] = this.timestamp;
    data['image'] = this.image;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  String? id;
  String? name;
  String? price;
  String? image;
  String? unit;
  String? description;
  String? status;
  String? createdAt;
  String? totalqty;
  String? totalAllowedQuantity;
  String? minimumOrderQuantity;
  String? discount;
  List<String>? images;
  Rating? rating;
  bool? isFavLoading = false;
  String? isFav;
  Products(
      {this.id,
        this.name,
        this.price,
        this.image,
        this.unit,
        this.description,
        this.status,
        this.createdAt,
        this.totalqty,
        this.totalAllowedQuantity,
        this.minimumOrderQuantity,
        this.discount,
        this.images,
        this.rating,
      this.isFavLoading,
      this.isFav
      });

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    image = json['image'];
    unit = json['unit'];
    description = json['description'];
    status = json['status'];
    createdAt = json['created_at'];
    totalqty = json['totalqty'];
    totalAllowedQuantity = json['total_allowed_quantity'];
    minimumOrderQuantity = json['minimum_order_quantity'];
    discount = json['discount'];
    isFavLoading = false;
    images = json['images'].cast<String>();
    rating = json['rating'] != null ? new Rating.fromJson(json['rating']) : null;
    isFav= json[FAV].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['is_favorite'] = this.isFav;
    data['price'] = this.price;
    data['image'] = this.image;
    data['unit'] = this.unit;
    data['description'] = this.description;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['totalqty'] = this.totalqty;
    data['total_allowed_quantity'] = this.totalAllowedQuantity;
    data['minimum_order_quantity'] = this.minimumOrderQuantity;
    data['discount'] = this.discount;
    data['images'] = this.images;
    if (this.rating != null) {
      data['rating'] = this.rating!.toJson();
    }
    return data;
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

  Rating(
      {this.ratingOne,
        this.ratingTwo,
        this.ratingThree,
        this.ratingFour,
        this.ratingFive,
        this.ratingValue,
        this.total});

  Rating.fromJson(Map<String, dynamic> json) {
    ratingOne = json['rating_one'];
    ratingTwo = json['rating_two'];
    ratingThree = json['rating_three'];
    ratingFour = json['rating_four'];
    ratingFive = json['rating_five'];
    ratingValue = json['rating_value'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rating_one'] = this.ratingOne;
    data['rating_two'] = this.ratingTwo;
    data['rating_three'] = this.ratingThree;
    data['rating_four'] = this.ratingFour;
    data['rating_five'] = this.ratingFive;
    data['rating_value'] = this.ratingValue;
    data['total'] = this.total;
    return data;
  }
}