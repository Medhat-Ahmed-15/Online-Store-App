import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_item_provider.dart';
import 'package:shop_app/providers/order_item_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static final routeName = '/cartScreen';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _loadingSpinner = false;
  bool _loadingSpinner2 = false;
  bool _isInit = true;
  var objCarItemProvider;
  var objProductsProvider;

  void thenMethod() {
    setState(() {
      _loadingSpinner = false;
    });

    objCarItemProvider.clear();

    objProductsProvider.removeItemsFromCart(objProductsProvider.itemsInTheCart);
  }

  @override
  void didChangeDependencies() {
    //  and now here we shouldn't use async await here for didChangeDependencies or for initState because these are not methods which return futures  normally and since you override the built-in methods, you shouldn't change what they return. So using async here would change what they return because an async method always returns a future and  therefore, don't use async await here but here, I will use the old approach with then
    if (_isInit) {
      setState(() {
        _loadingSpinner2 = true;
      });
      Provider.of<CartItemProvider>(context).fetchAndSetProducts().then((_) {
        //I don't care about the  value inside the then function
        setState(() {
          _loadingSpinner2 = false;
        });
      }).catchError((error) {
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occurred❗'),
                  content: Text('Something went wrong🥵🥵'),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Okay'))
                  ],
                ));
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    objCarItemProvider = Provider.of<CartItemProvider>(context);
    var carItemMap = objCarItemProvider.returnCartItems;

    var objOrdertemProvider =
        Provider.of<OrderItemProvider>(context, listen: false);

    objProductsProvider = Provider.of<ProductsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(8, 56, 8, 1).withOpacity(0.5),
              Color.fromRGBO(174, 182, 191, 1).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 1],
          ),
        ),
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(15),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount:',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        SizedBox(width: 10),
                        Chip(
                          backgroundColor: Theme.of(context).accentColor,
                          label: Text(
                            '\$${objCarItemProvider.calculateTotalAmount().toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                        color: Theme.of(context).accentColor,
                        width: 1,
                      )),
                      /*======>>> */ child: FlatButton(
                        onPressed: objCarItemProvider.calculateTotalAmount() <=
                                0
                            ? null
                            : () async {
                                setState(() {
                                  _loadingSpinner = true;
                                });

                                try {
                                  await objOrdertemProvider.addOrder(
                                      carItemMap.values.toList(),
                                      objCarItemProvider
                                          .calculateTotalAmount());

                                  thenMethod();
                                } catch (error) {
                                  return showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                            title: Text('An error occurred❗'),
                                            content: Text(
                                                'Failed to place your order🥵🥵'),
                                            actions: [
                                              FlatButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _loadingSpinner = false;
                                                    });

                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Okay'))
                                            ],
                                          ));
                                }
                              },
                        child: _loadingSpinner == true
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                'Order Now',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 20),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            /*=======> */ _loadingSpinner2 == true
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView.builder(
                    itemBuilder: (ctx, index) {
                      //THAT'S HOW I LOOP ON A MAP ON ONLY VALUES
                      return CartItem(
                        cartItemId: carItemMap.values.toList()[index].id,
                        productId: carItemMap.keys.toList()[index],
                        title: carItemMap.values.toList()[index].title,
                        price: carItemMap.values.toList()[index].price,
                        quantity: carItemMap.values.toList()[index].quantity,
                      );
                    },
                    itemCount: carItemMap.length,
                  ))
          ],
        ),
      ),
    );
  }
}
