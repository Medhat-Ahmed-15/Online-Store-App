import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static final routeName = '/productDetailScreen';

  @override
  Widget build(BuildContext context) {
    final String productId =
        ModalRoute.of(context).settings.arguments as String;

//I could of done bringing the single product by its id like this👇👇👇butt it is probbably much better to move as much logic as posiible out of our widgets into our provider class
    /*
    var objProductsProvider =
        Provider.of<ProductsProvider>(context); //object of the provider
    var productsList = objProductsProvider.items;

    var theSingleProductByID =
        productsList.firstWhere((element) => element.id == productId);*/

    var objProductsProvider = Provider.of<ProductsProvider>(context,
        listen:
            false); //just gonna need the object of the provider to call the method that I did there in the provider class that makes the logic that just commented it up
    //by writing this (((listen: false))) i turned off the listner for this class that means when any changes happen in the data in the provider class all classes which have listners turned on will rebuild except for this will not rebuild as its listner is turned off and i did that because for this class the class that just shows the detail of every product will not bee affected by any changes happen to the data I mean no changes will affect the UI unlike the Products Overview Screen if a new product is added then the build method of the Products Overview Screen must be called to show this new product but this class only shows data and it bring it the provider class but will not be effected by any changes

    var theSingleProductByID =
        objProductsProvider.findSingleProductById(productId);

    return Scaffold(
      //since I used slivers which make dynamically appbar I dont need appbar here👇👇👇
      // appBar: AppBar(
      //   // title: Text(theSingleProductByID.title),
      // ),
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
        //because i need more control over how scrolling is handled because different things will now be scrolling or we need to do different things when we scroll we need  to change that image innto the app bar, so kind of transform the image to the app bar and of course that should be smoothly animated We don't set up an appBar anymore because instead, we'll now manually animate a widget from our body into the appBar over time and the custom scroll view here actually doesn't take a child but our list of slivers.
        child: CustomScrollView(
          // slivers are just scrollable areas on the screen, so parts on the screen that can scroll.
          slivers: [
            SliverAppBar(
              expandedHeight:
                  300, //expanded height which is the height that should have if it's not the app bar but the image and we previouslu used 300 as height for the image so we're just put 300 here
              pinned:
                  true, //this means the app bar will always be visible when we scroll
              flexibleSpace: FlexibleSpaceBar(
                //that is what should be inside of that app bar and here where I am gonna put my image because that is what should be visible if this app bar is exxpanded
                title: Text(theSingleProductByID
                    .title), //el text dee haya kman el batathat 3al soora
                background: Hero(
                  tag: productId,
                  child: Image.network(
                    theSingleProductByID.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            //sliver list is basically your list view as a part of multiple slivers, so in case your list view is a part of multiple scrollable things on a screen which should scroll independently and where you want to have some special tricks when they scroll, then you will use sliver list here.
            SliverList(
                delegate: SliverChildListDelegate([
              //delegate tell it how to render the content of the list and it will replace what was in the column with all but without the image

              SizedBox(height: 10),
              Text(
                '\$${theSingleProductByID.price}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  theSingleProductByID.description,
                  style: TextStyle(color: Colors.deepOrange),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              SizedBox(height: 800),
            ])),
          ],
        ),
      ),
    );
  }
}
