import 'package:flutter/material.dart';
import 'package:shop_app/models/cart_item_bluePrint.dart';

class OrderItemdetail extends StatelessWidget {
  CartItemBlueprint cartItemBlueprint;
  OrderItemdetail(this.cartItemBlueprint);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          cartItemBlueprint.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Spacer(
          flex: 10,
        ),
        Text('x${cartItemBlueprint.quantity}'),
        SizedBox(
          width: 10,
        ),
        Text('\$${cartItemBlueprint.price}'),
      ],
    );
  }
}
