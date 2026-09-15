class ProductFavoriteModel {
  int? id;
  int? vendorId;
  String? vendorName;
  int? resturantId;
  String? resturantName;
  String? productName;
  String? productDescription;
  num? productPrice;
  int? categoryId;
  String? categoryName;
  int? productId;
  String? productTitle;
  String? status;
  String? productImage;
  String? createdAt;

  ProductFavoriteModel({
    this.id,
    this.vendorId,
    this.vendorName,
    this.resturantId,
    this.resturantName,
    this.productName,
    this.productDescription,
    this.productPrice,
    this.categoryId,
    this.categoryName,
    this.productId,
    this.productTitle,
    this.status,
    this.productImage,
    this.createdAt,
  });

  ProductFavoriteModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vendorId = json['vendor_id'];
    vendorName = json['vendor_name'];
    resturantId = json['resturant_id'];
    resturantName = json['resturant_name'];
    productName = json['product_name'];
    productDescription = json['product_description'];
    productPrice = json['product_price'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    productId = json['product_id'];
    productTitle = json['product_title'];
    status = json['status'];
    productImage = json['product_image'];
    createdAt = json['created_at'];
  }
}
