import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/screens/edit_add_user_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String productId;

  UserProductItem(this.title, this.imageUrl, this.productId);

  @override
  Widget build(BuildContext context) {
    var scaffold = ScaffoldMessenger.of(context);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        trailing: Container(
          width: 100,
          child: Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                        EditAddUserProductScreen.routeName,
                        arguments: productId);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).accentColor,
                  )),
              IconButton(
                  onPressed: () async {
                    try {
                      await Provider.of<ProductsProvider>(context,
                              listen: false)
                          .removeProductItemById(productId);

                      scaffold.showSnackBar(SnackBar(
                          content: Text(
                        'Deleted successfully🎈🎈',
                        textAlign: TextAlign.center,
                      )));
                    } catch (error) {
                      scaffold.showSnackBar(
                          //since 2n scaffold.of(context) can't be used inside a future class due to how Flutter works internally.It's already updating the widget tree at this point of time and therefore it's not sure whether a context still refers to the same context it did before
                          //since 'Scaffold.of(context)' can't be used inside future class due to how Flutter works internally.It's already updating the widget tree at this point of time and therefore it's not sure whether a context still refers to the same context it did before and so for this I assigned it to a variable outside the future class and used this variable here
                          SnackBar(
                              content: Text(
                        'Deleting failed😥😥',
                        textAlign: TextAlign.center,
                      )));
                    }
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).errorColor,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
