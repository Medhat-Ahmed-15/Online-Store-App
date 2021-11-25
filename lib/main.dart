import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/providers/cart_item_provider.dart';
import 'package:shop_app/providers/order_item_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_add_user_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview.dart';
import 'package:shop_app/screens/user_products_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          //if i am not using the context in the builder here is alternative way is by calling this((ChangeNotifierProvider.value)) and instead of givimg create  as aargument the argumnt will be value:ProductsProvider() but for here its better to keep as it is because  I am instantiate a new class not reused one like  I did in the grid list on products_grid, so here also would be ok if i used .value but would be less  efficient
          ChangeNotifierProvider(
              create: (ctx) =>
                  AuthProvider()), //now since that all the providers that In them I make requests and since that these providers needs the token that is generated from the auth provider so here comes the point which a provider depends on another provider or a provider needs something from another provider because instead of doing this communication with complex ways like where I actually manage the token outside of the auth class here in the widget and then you pass it to all your objects here and also pass it to the auth constructor to use it in there and that would be horrible. Thankfully, the provider package has an easy solution for this. Instead of using ChangeNotifierProvider here like this, you can use a different version of that, you can use the ChangeNotifierProxyProvider. and it doesn't have value constructor so instead you have to use that normal constructor with a builder which I showed you earlier and it forces you into that builder for a good reason because that builder actually gives you a context and then it gives you a dynamic value and that dynamic value is the interesting part here.
          ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
            //This allows you to set up a provider which itself depends on another provider which was defined before this one. So you have to make sure that your auth provider is the first one in the list and then the other providers can depend on it.
            create: (ctx) => ProductsProvider('', [],
                ''), //el line dah litteraly howa keda lazm 2ahoto 3ashan maydrbsh error w howa el instructor mahatoosh 3ashan el version bata3to makantsh talbah
            update: (ctx, auth, currentProductsObject) => ProductsProvider(
                auth.token,
                currentProductsObject.items,
                auth.userID), //we have to make sure that when this gets rebuilt and we create a new instance of products, we of course don't lose all the data we had in there before because in products, you must not forget that you had a list of your products. That was the key thing we were managing in there, the list of our items. Now of course, it would be pretty bad if we would lose that list. So actually, what we want to do here is you want to make sure that we initialize these items as well as a second value and thats what we did when we received the third argument of update which is 'currentProductsIbject' which holds the prev Object so we used it to get the old list and pass it to the productsProvider constructor
          ),
          //ChangeNotifierProvider(create: (ctx) => CartItemProvider()),

          ChangeNotifierProxyProvider<AuthProvider, CartItemProvider>(
            create: (ctx) => CartItemProvider('', {}, ''),
            update: (ctx, auth, currentCartItemObject) => CartItemProvider(
              auth.token,
              currentCartItemObject.returnCartItems,
              auth.userID,
            ),
          ),

          ChangeNotifierProxyProvider<AuthProvider, OrderItemProvider>(
            create: (ctx) => OrderItemProvider('', [], ''),
            update: (ctx, auth, currentOrderItemObject) => OrderItemProvider(
                auth.token,
                currentOrderItemObject.returnOrdersList,
                auth.userID),
          ),
        ], //lazm dee ((=>)) msh dee (({}))],

        child: Consumer<AuthProvider>(
          builder: (ctx, authProviderObj, _) => MaterialApp(
            //so just because something changes in here will not build material app, it will only rebuild widgets which are listening

            title: 'MyShop',
            theme: ThemeData(
                primarySwatch: Colors.deepOrange,
                accentColor: Colors.deepOrange,
                canvasColor: Color.fromRGBO(20, 90, 50, 1),
                fontFamily: 'Lato'),
            home: authProviderObj.isAuthenticated()
                ? ProductOverview()
                : FutureBuilder(
                    future: authProviderObj.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : AuthScreen(),
                  ),
            routes: {
              //'/': (ctx) => ,
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditAddUserProductScreen.routeName: (ctx) =>
                  EditAddUserProductScreen(),
            },
          ),
        ));
  }
}
