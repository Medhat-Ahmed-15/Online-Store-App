import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/widgets/main_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

import 'edit_add_user_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static final routeName = '/userProductsScreen';

  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<ProductsProvider>(ctx, listen: false)
        .fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    ////????? IMPORTANT IMPORTANT IMPORTANT IMPORTANT ?????\\\\==> ANA HNA FAL TWO COMMENTS BATOO3 EL OBJECT BATA3 EL PROVIDER LEIH 5ALATHOM COMMENT W INSTEAD OF THAT HATAT CONSUMER FAL MAKAN EL MAHATAG A LISTEN FEEH EL HOWA TAHT 3AND EL "RefreshIndicator" ANA 3MLT KEDA 3ASHAN ANA HNA 2STA5DMT ===>FUTURE BUILDER<=== YA3NII 3ASHAN A FETCH EL DATA MSH HAHTAG A CONVERT TO STATEFUL WIDGET 3ASHAN 2ASTA5DAM SET STATE 3ASHAN 2A3ML LOADING SPINNER ZY MNA MAT3AWD LA2 EL FUTURE BUILDER BATSAHL 3ALAYA EL MAWDOO3 DAH BA 2NEE BAT CHECK 3AL CONNECTION STATE EL BA2DR A ACCESSO MN EL snapshot EL BATB2 MAWGOODA Fal builder el batadeene kol el info el mahtagha lal data batat3te el gaya mn el firebase w since ba2 2n fal future paramater ana ba call fetch ya3nii feeha notify listner ya3nii ana lw 3mlt uncomment lal listners el taht dol ha5osh fa infinite loop 3ashan hafdl a build mn el 2wl la infinity

    // var objProductsProvider = Provider.of<ProductsProvider>(context);
    // var userProductsList = objProductsProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditAddUserProductScreen.routeName);
            },
            icon: Icon(Icons.add),
          ),
        ],
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
        child: FutureBuilder(
            future: Provider.of<ProductsProvider>(context, listen: false)
                .fetchAndSetProducts(true),
            builder: (context, snapshot) =>
                snapshot.connectionState == ConnectionState.waiting
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        //used to pull and refresh the widgetI  I wrapped over it
                        onRefresh: () => _refreshProducts(context),
                        child: Consumer<ProductsProvider>(
                          builder: (BuildContext context, objProductsProvider,
                              Widget child) {
                            var userProductsList = objProductsProvider.items;
                            return ListView.builder(
                              itemBuilder: (ctx, index) {
                                return Column(
                                  children: [
                                    UserProductItem(
                                      userProductsList[index].title,
                                      userProductsList[index].imageUrl,
                                      userProductsList[index].id,
                                    ),
                                    Divider(
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ],
                                );
                              },
                              itemCount: userProductsList.length,
                            );
                          },
                        ),
                      )),
      ),
    );
  }
}
