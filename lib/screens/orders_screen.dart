import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/order_item_provider.dart';
import 'package:shop_app/widgets/main_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static final routeName = '/ordersScreen';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isInit = true;
  bool _loadingSpinner = false;

  @override
  void didChangeDependencies() {
    print('erooorrrrr');
    //  and now here we shouldn't use async await here for didChangeDependencies or for initState because these are not methods which return futures  normally and since you override the built-in methods, you shouldn't change what they return. So using async here would change what they return because an async method always returns a future and  therefore, don't use async await here but here, I will use the old approach with then
    if (_isInit) {
      setState(() {
        _loadingSpinner = true;
      });
      Provider.of<OrderItemProvider>(context).fetchAndSetOrders().then((_) {
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
    var objOrderItemProvider = Provider.of<OrderItemProvider>(context);
    var ordersList = objOrderItemProvider.returnOrdersList;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
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
            : ListView.builder(
                itemBuilder: (ctx, index) {
                  return OrderItem(
                    ordersList[index].orderId,
                    ordersList[index].dateTime,
                    ordersList[index].productsList,
                    ordersList[index].totalPrice,
                  );
                },
                itemCount: ordersList.length,
              ),
      ),
    );
  }
}
