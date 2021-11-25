import 'dart:math';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:shop_app/models/cart_item_bluePrint.dart';

import 'order_item_detail.dart';

class OrderItem extends StatefulWidget {
  String orderId;
  DateTime dateTime;
  List<CartItemBlueprint> productsList;
  double totalPrice;

  OrderItem(this.orderId, this.dateTime, this.productsList, this.totalPrice);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        margin: EdgeInsets.all(15),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              ListTile(
                title: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).accentColor,
                      width: 5,
                    ),
                  ),
                  child: FittedBox(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Order ID:   ${widget.orderId}',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
                subtitle: Column(
                  children: [
                    Row(
                      children: [
                        Text('Date:'),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(widget.dateTime),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text('Time:'),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          DateFormat('hh:mm').format(widget.dateTime),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text('Total Amount:'),
                        SizedBox(
                          width: 10,
                        ),
                        Text(' \$${widget.totalPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Spacer(
                    flex: 10,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        expanded = !expanded;
                      });
                    },
                    icon: (Icon(
                        expanded ? Icons.expand_less : Icons.expand_more)),
                  )
                ],
              ),
              AnimatedContainer(
                height: expanded == true
                    ? min(widget.productsList.length * 20.0 + 10, 180)
                    : 0, //i used (((min)))because the he amount of height  here I want it depends on the amounnt of items we have in the list and this function which I can use here to use the minimum height out of two values, either widget.order.products.legnth and multiply it by 20 and add base height of 100, so tahts the first possible value that ensures that we never  add too big container, a too high container if we only have one product for example but if we have 10 different products in there, I also don't want to expand this infinetly and have a super big container and therefore the other value is lets say 180, so now min will pick either of these two values here it will calculate this and if this is smaller, then we'll take that or if that gets very large and 180 is smaller then it will take 180 as a height for our container and min requires double and of course items will be scrollable
                duration: Duration(milliseconds: 300),
                child: ListView.builder(
                  itemBuilder: (ctx, index) {
                    return OrderItemdetail(widget.productsList[index]);
                  },
                  itemCount: widget.productsList.length,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
