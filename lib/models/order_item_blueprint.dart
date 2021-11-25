import 'cart_item_bluePrint.dart';

class OrderItemBlueprint {
  final String orderId;
  final DateTime dateTime;
  final List<CartItemBlueprint> productsList;
  final double totalPrice;

  OrderItemBlueprint(
      {this.orderId, this.dateTime, this.productsList, this.totalPrice});
}
