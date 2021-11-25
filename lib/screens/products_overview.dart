import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_item_provider.dart';
import 'package:shop_app/providers/product_bluePrint_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/main_drawer.dart';

import 'package:shop_app/widgets/products_grid.dart';

enum FilterOptions { Favorites, All }

class ProductOverview extends StatefulWidget {
  @override
  _ProductOverviewState createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  bool favoriteLIstSelected = false;
  bool _isInit = true;
  bool _loadingSpinner = false;

//since it didn't work to call the operation that fetches data from firebase using the listner this one ==>"Provider.of<Products>(context).fetchAndSetProducts();" as it contain context and as we know init state don't like context in it, so we have two alternatives , one we used before which is didChangeDependencies() and put in it bool condition which is switched in it to prevent entering this method again as it's default behavior is to be called often but  what we did is bit of a hack,,second option which is knew is to call  Future.delayed(Duration.zero) .then((_) {} which after the duration is finished which i will put it to zero then I can use context in the 'then'method
  @override
  void initState() {
    // Provider.of<Products>(context).fetchAndSetProducts(); // WON'T WORK!
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAndSetProducts();
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //  and now here we shouldn't use async await here for didChangeDependencies or for initState because these are not methods which return futures  normally and since you override the built-in methods, you shouldn't change what they return. So using async here would change what they return because an async method always returns a future and  therefore, don't use async await here but here, I will use the old approach with then
    if (_isInit) {
      setState(() {
        _loadingSpinner = true;
      });
      Provider.of<ProductsProvider>(context).fetchAndSetProducts().then((_) {
        //I don't care about the  value inside the then function
        setState(() {
          _loadingSpinner = false;
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: (ctx) => [
              PopupMenuItem(
                child: Text('Only favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('All products'),
                value: FilterOptions.All,
              ),
            ],
            icon: Icon(Icons.more_vert),
            onSelected: (FilterOptions selectedOption) {
              setState(() {
                if (selectedOption == FilterOptions.All) {
                  favoriteLIstSelected = false;
                } else {
                  favoriteLIstSelected = true;
                }
              });
            },
          ),
          Consumer<CartItemProvider>(
            builder: (_, objCartItemProvider, child) => Badge(
              //here I want to have an icon button which shows the cart icon, takes us to the cart screen and aslo shows a small label that tells us how many items are in the cart,so here I want to add an icon button with that cart icon and an extra badge, Now this badge on the icon button is not a widget that would be built into flutter so I made badge.dart file
              value: objCartItemProvider.countNumberOfcartItems().toString(),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
              ),
            ),
          )
        ],
        title: Text('MyShop'),
      ),
      drawer: MainDrawer(),
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
        child: _loadingSpinner == true
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Products_Grid(favoriteLIstSelected),
      ),
    );
  }
}
