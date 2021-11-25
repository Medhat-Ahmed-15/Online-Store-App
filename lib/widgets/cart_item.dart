import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_item_provider.dart';
import 'package:shop_app/providers/product_bluePrint_provider.dart';
import 'package:shop_app/providers/products_provider.dart';

class CartItem extends StatelessWidget {
  final String title;
  final String productId;
  final double price;
  final int quantity;
  final String cartItemId;

  CartItem(
      {this.cartItemId,
      this.quantity,
      this.price,
      this.title,
      this.productId,
      id});

  @override
  Widget build(BuildContext context) {
    var objProductsProvider =
        Provider.of<ProductsProvider>(context, listen: false);

    return Dismissible(
      key: ValueKey(
          productId), //this needs a key to work correctly to avoid issues
      background: Container(
        margin: EdgeInsets.all(15),
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete,
          size: 40,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) async {
        //in this function we received the direction in which it was dismissed in case I am allowing different directions and I want to do something based on the different and in this case i will check on direction
        // objProductsProvider
        //     .removeItemsFromCart(objProductsProvider.itemsInTheCart);

        var productsList = objProductsProvider.items;
        var currrentProduct =
            productsList.firstWhere((element) => element.title == title);
        currrentProduct.toggleCartButton();
        ProductBlueprintProvider editedProduct = currrentProduct;

        try {
          await Provider.of<ProductsProvider>(context, listen: false)
              .editProductItem(currrentProduct.id, editedProduct);
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

        Provider.of<CartItemProvider>(context, listen: false)
            .removeItem(productId);
      },
      confirmDismiss: (direction) {
        //remember that in here, in confirmDissmiss, this function actually has to return a future<bool> and not just call show dialog,Now show dialog actually does return a future though and this future will be called whenever the dialog is closed, so actually we can return the result of show dialog here because again,show dialog return a future, so we return a future now but it should be a future that in the end yields true or false and that's the missing piece but here in onPressed, we can control what the future resolves by calling navigator pop, so the future resolves to a value that was passed to navigator pop
        //in this function we received the direction in which it was dismissed in case I am allowing different directions and I want to do something based on the different and in this case i will check on direction

        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to remove the item from the cart?'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Yes'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('No'),
              ),
            ],
          ),
        );
      },
      direction: DismissDirection.endToStart,
      child: Card(
        margin: EdgeInsets.all(15),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).accentColor,
            child: FittedBox(
              child: Text(
                '\$$price',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          title: Text(title),
          subtitle: Text('\$${price * quantity}'),
          trailing: Text('${quantity}X'),
        ),
      ),
    );
  }
}
