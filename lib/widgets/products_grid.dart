import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';

import 'product_item.dart';

class Products_Grid extends StatelessWidget {
  bool favoriteListSelected;
  Products_Grid(this.favoriteListSelected);
  @override
  Widget build(BuildContext context) {
    var objProductsProvider = Provider.of<ProductsProvider>(
        //this sets up direct communication channel behind the scenes
        context); //saw the of(context) couple of times before in thsi course in theme in navigator so to actually understand it go to the videos were started these topics
    var productsList = favoriteListSelected
        ? objProductsProvider.favoritesItems
        : objProductsProvider.items;
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //gridDelegate allows us to define how the grid generally should be structured, so how many columns most importantly,(((FixedCrossAxisCount)))which means I can definne that i want to have a certain amount of columns and it will simply squeeze the items onto the screen so that this crteria is met,the alternative of (((SliverGridDelegateWithFixedCrossAxisCount))) would be the (((SliverGridDelegateWithFixedExtent))) which we used  earlier in the coarse where we can define how wide every grid item should be and it will then create as many columns as it can for the given devise size
        childAspectRatio: 3 / 2,
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: productsList.length,
      itemBuilder: (ctx, index) {
        return ChangeNotifierProvider.value(
          value: productsList[
              index], //products[index] haya haya fa had zatha product el howa provider bata3ee hna
          child: ProductItem(
              //id: productsList[index].id,
              //title: productsList[index].title,
              //imageUrl: productsList[index].imageUrl,
              ),
        );
      },
    );
  }
}
