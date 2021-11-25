import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/auth_provider.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
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
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          //color: Theme.of(context).accentTextTheme.title.color,
                          fontSize: 50,
                          color: Colors.white,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
//we need some timer,because basically an interval which fires every 60 milliseconds and then we add something to that height so that we reach 320 which is our end height by the end of 60 times 60 milliseconds, but thankfully flutter provides a better way which is animation controller instead of setting this whole thhing manually using timer

  AnimationController
      _controller; //animation controller of course is a class provided by Flutter that helps us with controlling animations as the name suggests.

  Animation<Size>
      _heightAnimation; // we also need to set up an animation object and since I plan on animating the hight or in other words, the size of a container, animation is a generic type where we have to tell Dart or Flutter what we want to animate, so here I want to animate the size and size is another class just like animation provided by Flutter,

  Animation<double> fadeTextAnimation;

//Now these ☝☝☝ should be confugured in initstate👇👇👇 when this state object is created

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds:
                300)); // now vsync in a nutshell basically is an argument where we give the animation controller a pointer at the object, the widget in the end which it should watch and only when that widget is really visible on the screen, the animation should play, so this optimizes performance because it ensures that we really only animate what's visible to the user and it  doesn't work without adding a mixin ==>(((with SingleTickerProviderStateMixin)))<== and what this does in the end is it simply adds a couple of methods and properties here and what this does if we have a look at it, it simply adds a method here, a couple of methods actually to this class here, to this state class which is then implicitly used by vsync or by the animation controller to find out whether it's currently visible and so on.

    _heightAnimation = Tween<Size>(
            //The tween class when you instantiate it gives you an object which in the end knows how to animate between two values and it takes two parameters begin: and end: which both of them takes width and height the begining of width and height and the ending of width and height and since the width doesn't change so its gonna be ==>double.infinity<== and tween itself doesn't give us an animation though, it just has information on how to animate between two values, to create an animated object based on this, you have to call animate and now pass in an animation object which will basically wrap itself around this information on what to animate and the animation object describes how to animate it.
            begin: Size(double.infinity, 260),
            end: Size(double.infinity, 320))
        .animate(CurvedAnimation(
            parent: _controller,
            curve: Curves
                .fastOutSlowIn)); //the missing thing is to curve here for curved animation, that simply defines how the duration time here is basically split. The default here of course would be Curves.linear, curves simply is a helper class with a couple of static properties and linear means that it simply moves between the begin and end value here in the same speed but you can also for example set this to easeIn or fastOutSlowIn which means it starts slow and ends fast and typically, you want to experiment with these different values to find an animation between these start and end values

    fadeTextAnimation = Tween<double>(
            begin: 0,
            end:
                1) //since I want to animate through opacity for text transition so its just double
        .animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));

/*Now with that listner down👇👇👇, we could control the height here and we would animate it

but of course is pretty cumbersome to manually set up a listener, assign a height down there and

so on and thankfully, Flutter has built-in widgets that make it easier for us.

It is important however to understand what happens behind the scenes and that you have a controller

and an animation play together, controller simply controls, starts, configures and so on the animation, animation

then decides how to animate between which values and then you use the animation simply wherever you

want to use that dynamically changed value which changes very often per second

somewhere in your widget tree.

Now of course keep in mind the build reruns for every frame therefore, so every 16 milliseconds, build

reruns and things did change on the UI.

So you want to make sure that you really only rebuild the things that do need updating and you want

to make sure that you update as efficiently as possible.*/
    // _heightAnimation.addListener(() {
    //there, we also now need to add a listener to call set state whenever this updates and it should update whenever it redraws the screen. So here in the end, we just have an anonymous function in which we call set state and to set state, we can pass an empty update function because there isn't really something I want to update, I just want to rerun the build method to redraw the screen because as I understood how animmation works it updates the screen every specfifc time as I decided it so after this time I need to rebuild so I need setstate
    //  setState(() {});
    // });
  }

  @override
  //we should also dispose of it when the widget is removed, when the state is removed. So we should add dispose here and inside of dispose, we should also call controller dispose to make sure that we clean the listener and so on.
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void showErrorDialog(String errorMessage) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An Error Occurred!'),
              content: Text(errorMessage),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Okay'))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      //now after I logged in or signed up I am gona need to switch to the products overview scrreen and this would work if I used pushreplacementNamed and navigate to the products overview screen this would work but it has one major downside which is it would mean that we always start on the auth page when we open the app and we have to login so that we are then forwarded to the shop page and that's not really what I want to do. instead I am going to the main file and in the home: argument where I used to start by  default to the auth screen I am gonna make a condition if the user is already logged in then switch to auth screen alse switch to products overview screen, so in the main file we  are gonna play around the idea of building the material app that in the main file when ever any changes occur because on it we ar gonna reneder diffrent screens either the auth screen or products overview screen
      //we till we're not telling the server we're not attaching the token to the requests we're sending to the server  can't load the products and that's normal because till now we know now that we're logged in we know that in our app here but not the server
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<AuthProvider>(context, listen: false)
            .signIn(_authData['email'], _authData['password']);
      } else {
        // Sign user up
        await Provider.of<AuthProvider>(context, listen: false)
            .signUp(_authData['email'], _authData['password']);
      }
    } on HttpException catch (error) {
      //on Httpexception that I wrote here to filter that for this catch only catch exception from type that I made
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      showErrorDialog(errorMessage);
    } catch (error) {
      //and this is for general error for example network failure
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward(); //forword starts the animation
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });

// Now and once you're done, you want out play that back, so here you simply call controller reverse, so when you're going back to login mode, you want to reverse the animation to shrink the container again.
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedBuilder(
        animation: _heightAnimation,
        builder: (context, ch) => Container(
            //height:_authMode == AuthMode.Signup ? 320 : 260,
            //the difference to the old code is that we don't suddenly change from 260 to 320, instead we smoothly animate there but of course we now need to kick off this animation and we do that in switchAuthMode. Instead of just switching the auth mode here,
            height: _heightAnimation.value
                .height, //here, we assign this to heightAnimation.value and there, .height of course and this will change over time as soon as we start the animation.
            constraints: BoxConstraints(
              minHeight: _heightAnimation.value.height,
            ),
            width: deviceSize.width * 0.75,
            padding: EdgeInsets.all(16.0),
            child: ch),
        child: Form(
          //child of Animated builder, and this child is not going to rebuild when anything changes because in the builder: parameter of AnimatedBuilder I decided that the only part that is going to rebuild is the container but builder talso takes a parameter which is child which I wrote here is 'ch' and I told that that the container's child is ch while the child of the animatedBilder is connected to this ch 'howa howa' fana lama 2ahb 2a2ool 2n haga nested mayat3amalahash rebuild 2a3ml bos howa ana 3arf 2nee momken 2ansa el heita dee bs ana delw2ty fahamha kowais awii momken lama 2ansa w 2ashoof ell video 2aftkr w 2afhm
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText:
                      true, //makes sure input isn't seen to the user because its a password
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                AnimatedContainer(
                  //el animated container dah ana 3amlto 3ashan lw sheilto hayab2 fee gap fadee shaklo weihsh lama mayab2ash feeh confirm password
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 120 : 0),
                  duration: Duration(milliseconds: 300),
                  child: FadeTransition(
                    opacity: fadeTextAnimation,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      decoration:
                          InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              }
                              return null;
                            }
                          : null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
