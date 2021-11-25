import 'package:flutter/foundation.dart';

class CartItemBlueprint {
  String id; //dah id el cart zat nfsha msh el product
  double price;
  int quantity;
  String title;

  CartItemBlueprint({
    @required this.id,
    @required this.price,
    @required this.quantity,
    @required this.title,
  });
}
