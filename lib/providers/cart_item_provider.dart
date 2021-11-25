import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_app/models/cart_item_bluePrint.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class CartItemProvider with ChangeNotifier {
  Map<String, CartItemBlueprint> _cartItems = {};

  Map<String, CartItemBlueprint> get returnCartItems {
    return {
      ..._cartItems
    }; //that's how I make a copy for a map same like I did for a list and if I think about it make sense i am making a new map by this{} and putting in it the map that I created by extarcting its thingd by using . . .
  }

  final String _authToken;
  final String _authUSerId;
  CartItemProvider(this._authToken, this._cartItems, this._authUSerId);

  Future<void> addCartItems(
      String productId, double price, String title) async {
    final String url =
        'https://shop-app-455c8-default-rtdb.firebaseio.com/cart/$_authUSerId.json?auth=$_authToken';

    var response = await http.post(url,
        body: json.encode({
          'title': title,
          'price': price,
          'Quantity': 1,
        }));

    _cartItems.putIfAbsent(
        //dee el method el ba use it 3ashan add feeha item gdeeda w bata5od key el item dah w function bat generate el value

        json.decode(response.body)['name'],
        () => CartItemBlueprint(
              id: DateTime.now()
                  .toString(), //dah id el cart zat nfshe msh el product fana 5aleito yab2 el date
              price: price,
              quantity: 1,
              title: title,
            ));

    notifyListeners();
  }

  Future<void> fetchAndSetProducts() async {
    final String url =
        'https://shop-app-455c8-default-rtdb.firebaseio.com/cart/$_authUSerId.json?auth=$_authToken';
    try {
      var response = await http.get(url);
      var responseMap = json.decode(response.body) as Map<String, dynamic>;
      if (responseMap == null) {
        return;
      }
      Map<String, CartItemBlueprint> loadedCartItemsFromFirebase = {};
      responseMap.forEach((productId, productData) {
        loadedCartItemsFromFirebase.putIfAbsent(
            productId,
            () => CartItemBlueprint(
                  id: DateTime.now().toString(),
                  price: productData['price'],
                  quantity: 1,
                  title: productData['title'],
                ));
      });

      _cartItems = loadedCartItemsFromFirebase;
      if (_cartItems.isEmpty) {
        throw HttpException('No items added to the cart yet');
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> removeItem(String productId) async {
    final String url =
        'https://shop-app-455c8-default-rtdb.firebaseio.com/cart/$_authUSerId/$productId.json?auth=$_authToken';

    _cartItems.remove(productId);
    notifyListeners();

    var response = await http.delete(url);
  }

  int get cartLegnth {
    return _cartItems.length;
  }

  double calculateTotalAmount() {
    double total = 0.0;
    _cartItems.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  int countNumberOfcartItems() {
    return _cartItems.length;
  }

  Future<void> clear() async {
    final String url =
        'https://shop-app-455c8-default-rtdb.firebaseio.com/cart/$_authUSerId.json?auth=$_authToken';
    http.delete(url);
    _cartItems = {};
    notifyListeners();
  }
}
