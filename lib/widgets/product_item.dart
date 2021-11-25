import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/providers/cart_item_provider.dart';
import 'package:shop_app/providers/product_bluePrint_provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem({this.id, this.title, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    bool productFavoriteStatus;
    bool productCartStatus;
    var objProductBlueprintProvider =
        //I turn off the listner when I just need the data from provider and dont want to listen to any changes but down in the favorite icon widget I'm gonna wrap it with consumer widget which is an alternative way of listeneing to provider but its advnatage is that i can put it to the specifiic parts that only wnts to listen to changes
        Provider.of<ProductBlueprintProvider>(
      context,
    ); //now here it will look for the nearest product which is provided, which simply happens in the provided grid where i am providing a provider in the itemBuilder:

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
              arguments: objProductBlueprintProvider.id);
        },
        child: GridTile(
          //just alternative of using container or card
          child: Hero(
            tag: objProductBlueprintProvider
                .id, //this tag is then used on the new page which is loaded because the hero animation is always used between two different pages, two different screens, it's used on the new screen which is loaded to know which image on the old screen to float over so to say, which image should be animated over into the new screen. It can be any tag you want, here I'll use the product ID which I have available but in general, that can be any tag you want, it should of course be unique per image otherwise Flutter doesn't know which image to shift over.Now of course, setting it up here is only one part, you also need to go to the place where you're animating to, so hero is a widget that only makes sense if you're switching between different screens. The new screen we're animating to is the product detail screen and there, I'm also outputting an image here and therefore this now should also be wrapped into a widget.
            child: FadeInImage(
              image: NetworkImage(objProductBlueprintProvider.imageUrl),
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              fit: BoxFit.cover,
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            title: FittedBox(
              child: Text(
                objProductBlueprintProvider.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
            ),
            //this 👇👇👇 was the way I used to save an item as favorite in the firebase not all of it of course the other way the instructor used is by doing the whole thing in (((product_blueprint_proovider.dart)))
            // leading: IconButton(
            //   icon: Icon(objProductBlueprintProvider.isFavorite
            //       ? Icons.favorite
            //       : Icons.favorite_border),
            //   color: Theme.of(context).accentColor,
            //   onPressed: () async {
            //     productFavoriteStatus = objProductBlueprintProvider.isFavorite;
            //     objProductBlueprintProvider.toggleFavoriteButton();
            //     ProductBlueprintProvider editedProduct =
            //         objProductBlueprintProvider;
            //     try {
            //       await Provider.of<ProductsProvider>(context, listen: false)
            //           .editProductItem(
            //               objProductBlueprintProvider.id, editedProduct);
            //     } catch (error) {
            //       objProductBlueprintProvider.isFavorite =
            //           productFavoriteStatus;

            //       return showDialog(
            //           context: context,
            //           builder: (ctx) => AlertDialog(
            //                 title: Text('An error occurred❗'),
            //                 content: Text('Something went wrong🥵🥵'),
            //                 actions: [
            //                   FlatButton(
            //                       onPressed: () {
            //                         Navigator.of(context).pop();
            //                       },
            //                       child: Text('Okay'))
            //                 ],
            //               ));
            //     }
            //   },
            // ),

            leading: IconButton(
              icon: Icon(objProductBlueprintProvider.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border),
              color: Theme.of(context).accentColor,
              onPressed: () async {
                try {
                  var objAuthProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  objProductBlueprintProvider.toggleFavoriteButton(
                      objAuthProvider.token, objAuthProvider.userID);
                } catch (error) {
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
                }
              },
            ),

            trailing: Consumer<CartItemProvider>(
              builder: (_, objCartItemProvider, child) => IconButton(
                icon: Icon(objProductBlueprintProvider.isAddedToCart
                    ? Icons.shopping_cart
                    : Icons.shopping_cart_outlined),
                color: Theme.of(context).accentColor,
                onPressed: () async {
                  //productCartStatus = objProductBlueprintProvider.isAddedToCart;
                  objProductBlueprintProvider.toggleCartButton();
                  ProductBlueprintProvider editedProduct =
                      objProductBlueprintProvider;

                  try {
                    await Provider.of<ProductsProvider>(context, listen: false)
                        .editProductItem(
                            objProductBlueprintProvider.id, editedProduct);
                  } catch (error) {
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
                  }

                  try {
                    if (objProductBlueprintProvider.isAddedToCart == false) {
                      //delw2ty ana hna kont 3ayz lama 2adoos 3ala icon el cart w haya asln fal cart a remove it mn el cart list w 3ashan a remove it mn el cart list lazm yab2 3andee el id bata3 el product dah fal cart list w howa dah el ana 3amalto hna, geibt el title bata3 el product dah w 3amlt search 3aleih fal cart list w lama wasaltalo 5adt el key bata3o el howa el id 3ashan el cart list 3obara 3an map w ba3d ked howa dah el ana ba3to fal function 3ashan a remove

                      var cartItemsMap = objCartItemProvider.returnCartItems;

                      String productIncartId = cartItemsMap.keys.firstWhere(
                          (element) =>
                              cartItemsMap[element].title ==
                              objProductBlueprintProvider.title);

                      await objCartItemProvider.removeItem(productIncartId);
                    } else {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added item to cart!'),
                          duration: Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'Undo',
                            /************** */ onPressed: () async {
                              var cartItemsMap =
                                  objCartItemProvider.returnCartItems;

                              String productIncartId = cartItemsMap.keys
                                  .firstWhere((element) =>
                                      cartItemsMap[element].title ==
                                      objProductBlueprintProvider.title);
                              await objCartItemProvider
                                  .removeItem(productIncartId);
                              objProductBlueprintProvider.toggleCartButton();
                              ProductBlueprintProvider editedProduct =
                                  objProductBlueprintProvider;

                              try {
                                await Provider.of<ProductsProvider>(context,
                                        listen: false)
                                    .editProductItem(
                                        objProductBlueprintProvider.id,
                                        editedProduct);
                              } catch (error) {
                                return showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                          title: Text('An error occurred❗'),
                                          content:
                                              Text('Something went wrong🥵🥵'),
                                          actions: [
                                            FlatButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Okay'))
                                          ],
                                        ));
                              }
                            },
                          ),
                        ),
                      );
                      await objCartItemProvider.addCartItems(
                          objProductBlueprintProvider.id,
                          objProductBlueprintProvider.price,
                          objProductBlueprintProvider.title);
                    }
                  } catch (error) {
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
                  }
                },
              ),
            ),
          ),
        ),
      ),
    ); //a new widget instead of using conntainer or card,and as a child i will use an image as the MAIN content
  }
}
