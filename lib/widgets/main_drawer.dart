import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

class MainDrawer extends StatelessWidget {
  Widget buildListTile(
      IconData icon, String text, BuildContext context, Function tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        text,
        style: TextStyle(
            fontSize: 24,
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            color: Colors.white),
      ),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
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
            Container(
              width: double.infinity,
              color: Theme.of(context).accentColor,
              padding: EdgeInsets.all(20),
              height: 200,
              alignment: Alignment
                  .center, //THIS CONTROLS HOW THE CHILD OF THE CONTAINER IS ALIGNNED
              child: Text(
                'Hello Friend😀',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 30),
              ),
            ),
            SizedBox(height: 20),
            buildListTile(Icons.shop, 'Shop', context, () {
              Navigator.of(context).pushReplacementNamed('/');
            }),
            Divider(
              color: Theme.of(context).accentColor,
            ),
            buildListTile(Icons.payment, 'Orders', context, () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            }),
            Divider(
              color: Theme.of(context).accentColor,
            ),
            buildListTile(Icons.edit, 'Manage Products', context, () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            }),
            Divider(
              color: Theme.of(context).accentColor,
            ),
            buildListTile(Icons.exit_to_app, 'Logout', context, () {
              Navigator.of(context)
                  .pop(); //dee 3ashan ta2fl el bar...ana 3arf 2nee 2wl ma hadoos hna 3al logout harooh la page tanya w msh hayafr2 ma3aya 2aflt el drawer wla la2 bs fhowa lazm 2a2fl el drawer hata lw msh hahaeis beeh 3ashan mayadaneesh error

              Navigator.of(context).pushReplacementNamed(
                  '/'); //the instructor recommend always go to slash, slash nothing and that is the home route. Since you always go there, you ensure that this logic here in the main.dart file will always run whenever the logout button is pressed and since this always runs and since this home route is always loaded, we will always end up on the AuthScreen when we clear our data in the logout method of the auth provider. So simply add this additional line here and go to your home route to ensure that you never have unexpected behaviors when logging out.

              Provider.of<AuthProvider>(context, listen: false).logOut();
            }),
            Divider(
              color: Theme.of(context).accentColor,
            ),
          ],
        ),
      ),
    );
  }
}
