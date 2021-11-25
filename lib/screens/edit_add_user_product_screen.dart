import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_bluePrint_provider.dart';
import 'package:shop_app/providers/products_provider.dart';

class EditAddUserProductScreen extends StatefulWidget {
  static final routeName = '/editAddUserProductScreen';
  @override
  _EditAddUserProductScreenState createState() =>
      _EditAddUserProductScreenState();
}

class _EditAddUserProductScreenState extends State<EditAddUserProductScreen> {
  bool _loadingSpinner = false;
  String productId;
  bool _initState = true;
  final _prciceFocusNode =
      FocusNode(); //Now it would be nice to ahve that transition from title to price when we click the next button here that we made in textInputAction: and that something we ahve to do manuallly and we do that withh help of so-called focus node, FocusNode() is a class built into flutter we instantiate it here and we store that focus node in the price focus node key here, in that property so we create this focus node because taht focus node now can be assigned to a text input widget like price  or title
  final _descriptionFocusNode = FocusNode();
  final _imageurlInput = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  var _editedProducts = ProductBlueprintProvider(
    id: null,
    description: '',
    imageUrl: '',
    price: 0,
    title: '',
  );

  @override
  void dispose() {
    //this method is used to be sure that I clear up that memory
    _imageUrlFocusNode.removeListener(
        reBuild); //I cleared that listner when we doispose of that state, otherwise the listener keeps on living in memeory even though even the page is not presented anymore
    _prciceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    //here I set uo my own listener to the imageUrlFocusNode in initState because it is a good place to set up that initial listner

    _imageUrlFocusNode.addListener(reBuild);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    //Called when a dependency of this State object changes. For example, if the previous call to build referenced an InheritedWidget that later changed, the framework would call this method to notify this object about the change.
    if (_initState == true) {
      //condition dah ana 3amlto 3ashan el function dee tat3ml mara wahda bs 3ashan 3ayz 2a3ml initialization mara wahda bs msh kol ma change yahsl msh mantky

      productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProducts = Provider.of<ProductsProvider>(context, listen: false)
            .findSingleProductById(productId);
        _imageurlInput.text = _editedProducts.imageUrl;
      }
    }
    _initState = false;

    super.didChangeDependencies();
  }

  void reBuild() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(
          () {}); //it's a bit of a hack because I need the page to be rebuild to show the url image when I move to another text field not just only by clicking the done button in the keyboard
    }
  }

  Future<void> _saveForm() async {
    var objProductProvider =
        Provider.of<ProductsProvider>(context, listen: false);

    var validationResult = _formKey.currentState
        .validate(); //THIS TRIGGERS ALL THE VALIDATORS AND THIS WILL RETURN TRUE IF THEY ALL HAVE NO ERROR AND WILL RETURN FALSE IF ONLY ONE VALIDATOR REUTURNS A STRING WHICH IS ERROR INPUT USER

    if (validationResult == true) {
      _formKey.currentState
          .save(); //.save() is simply a method provided by the state object of the form widget provided by flutter which will save that form using the key that i made and now the function _saveForm() will execute the  onSave: argumment on every text form field which allows me to take the value entred into the text form field and do with it whatever I want for example store it into a global map that collects all text inputs

      try {
        if (productId != null) {
          setState(() {
            _loadingSpinner = true;
          });
          await objProductProvider.editProductItem(productId, _editedProducts);
          setState(() {
            _loadingSpinner = false;
          });
          Navigator.of(context).pop();
        } else {
          setState(() {
            _loadingSpinner = true;
          });

          await objProductProvider.addProducts(_editedProducts);
          Navigator.of(context).pop();

          setState(() {
            _loadingSpinner = false;
          });
        }
      } catch (error) {
        //now when any error occurres during storing data in the firebase will be caught here and handled by showing an alter dialog and after executing the catch error the then method will be executed, the instructor put a catch error in the actual add method back in products_provider.dart file and inside the catch block throw an error I don't know why he did this approach but it worked fine with me without it
        await showDialog(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product!'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
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
            : Padding(
                padding: const EdgeInsets.all(15),
                child: Form(
                  key: _formKey,
                  //Now in general the form manages our values, when we submit everything, i don't need to add my own text editing controllers to get access to the values of my inputs
                  child: SingleChildScrollView(
                      child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          //THE VALUE THAT THE VALIDATOR TAKES AS AN ARGGUMENT IS THE USER INPUT FOR THAT TEXT FIELD AND I CAN STULE THE ERROR MESSAGE IN INPUT DECORATION
                          if (value.isEmpty) {
                            return 'Please provide a value';
                          }
                          return null; //returning null means input is correct
                        },
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          errorStyle:
                              TextStyle(color: Theme.of(context).errorColor),
                        ),
                        initialValue: _editedProducts.title,
                        textInputAction: TextInputAction
                            .next, //this controls what the bottom right button in the soft keyboard will show, whether it's a checkmark or a done text to confirm that you're done or a next text

                        style: TextStyle(color: Colors.white),
                        onFieldSubmitted: (_) {
                          //with that we tell flutter that when this first input is submitted, so when this next button is pressed in the soft keyboard,we actually want to focus the element with the price focus node and we assign that price focus node to the second text form field here
                          FocusScope.of(context).requestFocus(_prciceFocusNode);
                        },
                        onSaved: (value) {
                          _editedProducts = ProductBlueprintProvider(
                              //  I set it equal to a new product because I might remeber that in the product blueprint class all the properties are final, so we can't reassign the value after a product has created so instead we have to create a new product and override the existing edited product with it, that here we can create a product which takes all the old values of the existing added product and overrides the one vlaue for which this text form field was responsible

                              description: _editedProducts.description,
                              imageUrl: _editedProducts.imageUrl,
                              price: _editedProducts.price,
                              isFavorite: _editedProducts.isFavorite,
                              id: _editedProducts.id,
                              title: value);
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: (value) {
                          //THE VALUE THAT THE VALIDATOR TAKES AS AN ARGGUMENT IS THE USER INPUT FOR THAT TEXT FIELD AND I CAN STULE THE ERROR MESSAGE IN INPUT DECORATION
                          if (value.isEmpty) {
                            return 'Please provide a value';
                          }
                          return null; //returning null means input is correct
                        },
                        decoration: InputDecoration(
                          labelText: 'Price',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        initialValue: _editedProducts.price.toString(),
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        focusNode: _prciceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (value) {
                          _editedProducts = ProductBlueprintProvider(
                            //  I set it equal to a new product because I might remeber that in the product blueprint class all the properties are final, so we can't reassign the value after a product has created so instead we have to create a new product and override the existing edited product with it, that here we can create a product which takes all the old values of the existing added product and overrides the one vlaue for which this text form field was responsible

                            description: _editedProducts.description,
                            imageUrl: _editedProducts.imageUrl,
                            price: double.parse(value),
                            title: _editedProducts.title,
                            isFavorite: _editedProducts.isFavorite,
                            id: _editedProducts.id,
                          );
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: (value) {
                          //THE VALUE THAT THE VALIDATOR TAKES AS AN ARGGUMENT IS THE USER INPUT FOR THAT TEXT FIELD AND I CAN STULE THE ERROR MESSAGE IN INPUT DECORATION
                          if (value.isEmpty) {
                            return 'Please provide a value';
                          }
                          return null; //returning null means input is correct
                        },
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        initialValue: _editedProducts.description,
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        onSaved: (value) {
                          _editedProducts = ProductBlueprintProvider(
                            //  I set it equal to a new product because I might remeber that in the product blueprint class all the properties are final, so we can't reassign the value after a product has created so instead we have to create a new product and override the existing edited product with it, that here we can create a product which takes all the old values of the existing added product and overrides the one vlaue for which this text form field was responsible

                            description: value,
                            imageUrl: _editedProducts.imageUrl,
                            price: _editedProducts.price,
                            title: _editedProducts.title,
                            isFavorite: _editedProducts.isFavorite,
                            id: _editedProducts.id,
                          );
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white)),
                            child: _imageurlInput.text == ''
                                ? Text(
                                    'Enter URL',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  )
                                : FittedBox(
                                    child: Image.network(
                                    _imageurlInput.text,
                                    fit: BoxFit.cover,
                                  )),
                          ),
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                //THE VALUE THAT THE VALIDATOR TAKES AS AN ARGGUMENT IS THE USER INPUT FOR THAT TEXT FIELD AND I CAN STULE THE ERROR MESSAGE IN INPUT DECORATION
                                if (value.isEmpty) {
                                  return 'Please provide a value';
                                }

                                // if ((!value.startsWith('http') ||
                                //         !value.startsWith('https')) &&
                                //     (!value.endsWith('.jpg') ||
                                //         !value.endsWith('.png'))) {
                                //   return 'Please enter the correct pattern of a URL';
                                // }
                                return null; //returning null means input is correct
                              },
                              decoration: InputDecoration(
                                labelText: 'Image URL',
                                labelStyle: TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              textInputAction: TextInputAction.done,
                              style: TextStyle(color: Colors.white),
                              keyboardType: TextInputType.url,
                              controller: _imageurlInput,
                              focusNode:
                                  _imageUrlFocusNode, //I will make a listener for this focus node becaise when this loses focus so when the user unselsct it, then we can react to this to make sure that we updated the UI and use the imageUrlController to show a preview
                              onSaved: (value) {
                                _editedProducts = ProductBlueprintProvider(
                                  //  I set it equal to a new product because I might remeber that in the product blueprint class all the properties are final, so we can't reassign the value after a product has created so instead we have to create a new product and override the existing edited product with it, that here we can create a product which takes all the old values of the existing added product and overrides the one vlaue for which this text form field was responsible

                                  description: _editedProducts.description,
                                  imageUrl: value,
                                  price: _editedProducts.price,
                                  title: _editedProducts.title,
                                  isFavorite: _editedProducts.isFavorite,
                                  id: _editedProducts.id,
                                );
                              },
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
                ),
              ),
      ),
    );
  }
}
