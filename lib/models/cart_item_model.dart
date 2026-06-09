import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int qty;

  CartItemModel({
    required this.product,
    required this.qty,
  });

  int get harga {
    return product.hargaSetelahDiskon;
  }

  int get total {
    return harga * qty;
  }

  CartItemModel copyWith({
    ProductModel? product,
    int? qty,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      qty: qty ?? this.qty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'qty': qty,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product']),
      qty: json['qty'] ?? 1,
    );
  }
}