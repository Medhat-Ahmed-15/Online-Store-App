import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class ProductBlueprintProvider with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;
  bool isAddedToCart;

  ProductBlueprintProvider(
      {@required this.id,
      @required this.description,
      @required this.imageUrl,
      this.isFavorite = false,
      this.isAddedToCart = false,
      @required this.price,
      @required this.title});

//since 2n this class is for every instance of the products ya3nii 2aya kan el parameters el hna id, title, keda fa dol tab3 kol instance seperatly lal products
  Future<void> toggleFavoriteButton(String authToken, String userId) async {
    final String url =
        'https://shop-app-455c8-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken'; //ana hna fal url dah aa 3amlo keda 3ashan kol user yab2 leeh el favorites batoo3o w kol product id yab2 ganbo el favorite status bata3o

    bool oldFavoriteStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    var response = await http.put(url,
        body: json.encode(
            //  'isFavorite': //since 2n dee put msh patch homa el 2tnein similar awii bs patch bat8ayr el fields el gowa el data 3ashan keda kont bahtag 'isFavorite' bs put bat8ayr el data block kolha el haya hna 3obara 3an bs true or false
            isFavorite //as I can see here when I update something specific in the firebase  table I can just target specific item not the whole table,,,ya3ni table products dah el ana 3amlo feeh isfavorite w title w description w price w quantity w image url w keda bs hna ana 3ayz a update isfavorite bs fa haya bs el katabtha
            ));

    if (response.statusCode > 400) {
      isFavorite = oldFavoriteStatus;
      notifyListeners();
      throw HttpException('error');
    }
  }

  void toggleCartButton() {
    isAddedToCart = !isAddedToCart;
    notifyListeners();
  }
}
