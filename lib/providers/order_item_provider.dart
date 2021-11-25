import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_app/models/cart_item_bluePrint.dart';
import 'package:shop_app/models/order_item_blueprint.dart';
import 'package:http/http.dart' as http;

//import 'package:flutter/material.dart';

class OrderItemProvider with ChangeNotifier {
  List<OrderItemBlueprint> _ordersList = [];

  List<OrderItemBlueprint> get returnOrdersList {
    return [..._ordersList];
  }

  final String _authToken;
  final String _authUSerId;
  OrderItemProvider(this._authToken, this._ordersList, this._authUSerId);

  Future<void> addOrder(
      List<CartItemBlueprint> productsList, double totalPrice) async {
    final String url =
        'https://shop-app-455c8-default-rtdb.firebaseio.com/orders/$_authUSerId.json?auth=$_authToken';

    var response = await http.post(url,
        body: json.encode({
          'dateTime': DateTime.now().toString(),
          'totalPrice': totalPrice,
          'productsList': productsList
              .map((cartItem) => {
                    //lazm lw hada5l list of 2y haga fal index el wahda fal firebase lazm 2ahwlha la map el 2wl
                    'id': cartItem.id,
                    'price': cartItem.price,
                    'quantity': cartItem.quantity,
                    'title': cartItem.title
                  })
              .toList(), //this is to say its a list of maps
        }));

    //insert dee el difference el waheed bnha w bein add 2nha bat inset mn index mo3ayn el howa hna zero 3ashan 3ayz el haga el ha3mlha add tab2 fal 2wl msh fal 2a5r zy ma add bat3ml 3ashan mantkee yab2 2a5r order 3amlo add yab2 fal 2wl
    _ordersList.insert(
      0,
      OrderItemBlueprint(
          orderId: json.decode(response.body)['name'],
          dateTime: DateTime.now(),
          totalPrice: totalPrice,
          productsList: productsList),
    );
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final String url =
        'https://shop-app-455c8-default-rtdb.firebaseio.com/orders/$_authUSerId.json?auth=$_authToken';

    var response = await http.get(url);
    var responseMap = json.decode(response.body) as Map<String, dynamic>;

    if (responseMap == null) {
      _ordersList = [];
      return;
    }

    List<OrderItemBlueprint> loadedOrdersFromFirebase = [];

    responseMap.forEach((orderId, orderData) {
      loadedOrdersFromFirebase.add(
        OrderItemBlueprint(
          orderId: orderId,
          dateTime: DateTime.parse(orderData['dateTime']),
          totalPrice: orderData['totalPrice'],
          productsList: (orderData['productsList'] as List<dynamic>)
              .map(
                (item) => CartItemBlueprint(
                  //ana hna 2sta5dmt .map  3ashan 2ahwlha la list of CartItemBlueprint zy ma kont bast5dm .map dee brdo 3ahsan 2ahwlha la list of widgets msln
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ),
              )
              .toList(),
        ),
      );
    });

    _ordersList = loadedOrdersFromFirebase;
    notifyListeners();
  }
}
