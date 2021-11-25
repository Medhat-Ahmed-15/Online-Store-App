import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product_bluePrint_provider.dart';
import 'package:http/http.dart'
    as http; //since this exposes a lot of methods and variables and stuff, I want to avoid name clashes and therefore I bundle this all on this HTTP prefix which ensures that we never run into any name clashes because we always access the features from this package with (http. any method I want)

//thus far we have the class but now we need to turn this class here into a data container,
// into provider, and there the products are important for a couple of places of this app, they
//are important in the product detail and the product overview screen, that means that I want to provide
//this in the main dart file because that's important and thats something I have to know if the provider package,
//I need to provide a class which I then want to use from diffrent widgets in my app at the highest possible point of all
//these widgets which will be intrested , which means that if the product overview and the product details screen are intrested in the data,
//I have to provide the class in a widget that is above them, which in my case is this my app widget

class ProductsProvider with ChangeNotifier {
  /*since I turned items this into a private property which means it can't be accessed from outside, I'll add a getter here which will return a list of products, and I will return a copy items which I did here by wrapping items here with square brackets and then by using the spreadd operator(. . .) and I did this because if I would return my items List here the origin one, then i would return a pointer at this object in memory and that means that anywhere in the code where i  get access to my products class here and where i then get access to the items,I get that address and therefore I get direct access to this list of items in memory and hence i could start editing this list of items from anywhere else in the app where i tap into this product class I don't want to do that because when my products change, I actually have to call certain method  to tell all the  listners of this provider, that new data is available, so let's say we had an add product method here which returns nothing and which for the moment 
doesn't take an argument and then here we would simply add something to our items(_items.add(value))then,of course we typically would have the problem that if we change dtaa in this class, how would we let all our widgets or the widgets that are intrested know about this and that why we had this change notifier because that gives us access to a notifyListnersMethod() so that in these widgets which are listening to this calls and to changes in this class are then rebuilt  and do actualy get the lastest data we have in there and that's why I return a copy so that we can't directly edit our items here from anywhere else in the app because if we want to do that we could not call notify listners because we can only do this from inside this class and hence our widgets that depend on the data in here would not rebuild correctly because they wouldn't know about the chang*/
  List<ProductBlueprintProvider> _items = [
    // ProductBlueprintProvider(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String _authToken;
  final String _authUSerId;
  ProductsProvider(this._authToken, this._items, this._authUSerId);

  List<ProductBlueprintProvider> get items {
    return [..._items];
  }

  List<ProductBlueprintProvider> get favoritesItems {
    return _items.where((element) => element.isFavorite == true).toList();
  }

  ProductBlueprintProvider findSingleProductById(String productId) {
    return _items.firstWhere((element) => element.id == productId);
  }

  Future<void> addProducts(ProductBlueprintProvider newProduct) async {
    //when I use async and awiat which is an alternative way of using '.then' , I just have to put await befor the block taht takes a bit time longer to execute after this block comes the 'then' method but i don't write it and aslo I don't hhave to write return when using async as it automatically return the future execution and regarding the catch I also don't have to write '.catch' simply use the try and catch
    //Now I made this function as a future so when the body of the post finishes and the response arrives and what inside 'then' also finishes and thats important, that is why I put 'return' of the this future function at the top 3and el http to be sure that aslo the 'functionn inside  then finished' so when I call this method in 'EditAddUserProductScreen' i find that I can call '.then' and I needed '.then' to pop The screen which I mean to go back to the products list after I am sure that the data are sent to firebase and the response arrived and also data saved in my local memory so then I can add aloading spinner
    final String url =
        'https://shop-app-455c8-default-rtdb.firebaseio.com/products.json?auth=$_authToken';

    var response = await http.post(url,
        body: json.encode({
          'creatorId': _authUSerId,
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
          'isFavorite': false,
          'isAddedToCart': false,
        }));

    print(json.decode(response
        .body)); //this is to see what is inside response and I decoded it using json to convet from json data to data we can read which will convert to a map where the id is with title 'name' and same as pots it has body
    newProduct = ProductBlueprintProvider(
        id: json.decode(response.body)['name'],
        description: newProduct.description,
        imageUrl: newProduct.imageUrl,
        price: newProduct.price,
        title: newProduct.title);
    _items.add(newProduct);
    notifyListeners();
  }

  List<ProductBlueprintProvider> get itemsInTheCart {
    return _items.where((element) => element.isAddedToCart == true).toList();
  }

  void removeItemsFromCart(List<ProductBlueprintProvider> itemsInTheCart) {
    itemsInTheCart.forEach((element) {
      element.isAddedToCart = false;
    });
    notifyListeners();
  }

  Future<void> editProductItem(
      String editedProductId, ProductBlueprintProvider editedProduct) async {
    final String url =
        'https://shop-app-455c8-default-rtdb.firebaseio.com/products/$editedProductId.json?auth=$_authToken'; //since this url like this without '$id' target the products folder which target all the products and I want to target a specific product by its Id to edit it so that's why i added '$id' which is string interpolation so that this url gets updated by the specific Id it gets and go to it
//i didn't update the isFavorite because I didn't come near her when I selected a product to update it in the edit screen so I just want to update these and the rest which is isfavorite leave it as it is
    await http.patch(
        url, //firebase supports patch requests and sending a patch request will tell firebase to merge the data which is incoming with the existing data at that address I am sending to
        body: json.encode({
          'price': editedProduct.price,
          'title': editedProduct.title,
          'imageUrl': editedProduct.imageUrl,
          'description': editedProduct.description,
          'isFavorite': editedProduct.isFavorite,
          'isAddedToCart': editedProduct.isAddedToCart,
          'creatorId': _authUSerId
        }));

    var index = _items.indexWhere((element) => element.id == editedProductId);
    _items[index] = editedProduct;
    notifyListeners();
  }

  Future<void> removeProductItemById(String id) async {
    final String url =
        'https://shop-app-455c8-default-rtdb.firebaseio.com/products/$id.json?auth=$_authToken';
    int index = _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[
        index]; //what I did here is to ensure that if there is any error in deleting this product, then I have a backup of it which I did by storing the item that I am going to delete in a variable to putit back in case an erro ocurred
    _items.removeAt(index);
    notifyListeners();

    var response = await http.delete(url);

    if (response.statusCode >=
        400) //el fekra hna fal delete 2n lw fee error el mafrood ya5osh fal catch 3ashan yarag3 tany el product el ana sheilto taht fee(_items.removeAt(index);) bs  el bauahsl 2n delete msh batarmee error hata lw fee error 3ashan ked ana ba check ba nfsee w bashoof el response el status code fee kam w 3ala 2asaso a take decision search for thhis note((HTTP.delete() error handling thing ==>IMPORTANT)) to understand what happened here, but briefly I did this because delete its default behavior doesn't throw an error when for example I remove .json from the url
    {
      _items.add(existingProduct);
      notifyListeners();
      throw HttpException(
          'Could not delete product'); //ana 3mlt keda 3ashan bama 2n el delete msh bat throw error automatically fana ba throw leeha error ana 3amlo bal class dah manually 3ashan el code el fal catch yab2 executed
    }
    existingProduct = null;
  }

//since now we need to filter the products according to its users when we fetch them and since its a server side task I do this filtering on the server side because I don't want to fetch all products and then filter by id on the client I could do that but that would be alot of work on the client that should rather happen on the server, otherwise i am hiting my server, fetching hundreds of entries from the database just to filter out one entry on the client, I would transfer loads of data would slow down my server, would slow down my client just to get one product and that's not what I want , thankfully firebase has a built-in filtering mechanism
  Future<void> fetchAndSetProducts([bool isUserProducts = false]) async {
    //what I wrote between square brackets in this method is something Knew I didn't know about but it can be done which is giving a default value for this variable in case I didn't pass to it any value

    String url;

    if (isUserProducts == false) {
      url =
          'https://shop-app-455c8-default-rtdb.firebaseio.com/products.json?auth=$_authToken'; // this the way which I understoof from him is how to attach the token to the request method  to send it to the server so that the server knows that this request is dine by an authenticated user and its done by attaching the token to the url
    } else {
      url =
          'https://shop-app-455c8-default-rtdb.firebaseio.com/products.json?auth=$_authToken(&orderBy="creatorId"&equalTo="$_authUSerId"'; //this is how we tell fireBase to filter by adding another query parameter before or after that token thing in the url by adding (((&orderBy="the key which i wnat to filter by which in my case the user id"&equalTo="$userId"))) and don't forget that some rules needed to be added in the firebase site so check the video for this part to see what happened
    }

    try {
      var response = await http.get(url);
      print(json.decode(response.body));
      var responseMap = json.decode(response.body) as Map<String,
          dynamic>; // so the response here after I saw it is a map with nested map in it so I made this variable to hold this map and of type<string,object or dynamic> I should of wrote of type<String,map> which is what this response actually is but dart won't understand this nested map so instead I will write object or dynamic as  they are generic

      if (responseMap == null) {
        return;
      }

      url =
          'https://shop-app-455c8-default-rtdb.firebaseio.com/userFavorites/$_authUSerId.json?auth=$_authToken';
      response = await http.get(url);
      print(json.decode(response.body));
      var responseMapForUserFavoriteStatus =
          json.decode(response.body) as Map<String, dynamic>;
      //I wrote these 5 lines of code above me after the if check because I don't want to do that if we have no product , so I'll wait for this check

      List<ProductBlueprintProvider> loadedItemsFromFirebase = [];
      responseMap.forEach((productId, productData) {
        //the key here which the unique key that firebase generate which I will make it the product ID see what the print above output do understand how the response look like when i fetch the data from firebase
        loadedItemsFromFirebase.add(
          ProductBlueprintProvider(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            isFavorite: responseMapForUserFavoriteStatus == null
                ? false
                : responseMapForUserFavoriteStatus[productId] ??
                    false, // the double check operator ==> '??' checks weather the expression behind it which is "responseMapForUserFavoriteStatus[productId]" if it is equal null then do something
            isAddedToCart: productData['isAddedToCart'],
            imageUrl: productData['imageUrl'],
          ),
        );
      });
      _items = loadedItemsFromFirebase;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
