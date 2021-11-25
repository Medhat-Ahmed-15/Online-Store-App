import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

//so that we can call notify listeners to make sure that all places in the UI that depend on our auth logic here are updated
//non of these are final because allmof that will be able to change acroos the lifetime of our application for example a certain user may logout so all of these will change
class AuthProvider with ChangeNotifier {
  String
      _token; //this token expires at some point of time, that's a security mechanism. This token doesn't live on forever, typically it expires after one hour,  for example the token Firebase generates expires after one hour, so one hour after you got it, it will be treated as invalid.
  DateTime _expiryDate; //the expirey date of the token
  String _userId;
  Timer logOutTimer;

//the rule for checking that a user is authenticated is if he has a token or the token isn't expired then he is authenticated
  bool isAuthenticated() {
    if (token != null) {
      return true;
    }
    return false;
  }

  String get token {
    if (_token != null &&
        _expiryDate.isAfter(DateTime
            .now()) && //after today which means its expiry date still in the future
        _expiryDate != null) {
      return _token;
    }
    return null;
  }

  String get userID {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB1Mu4KVacIKRHpvpxpDszIEDo7ZNEo5Ew';

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        //since the error that comes from firebase is not an error response it doesn't have an error status code and therefore I learned for post and get, the HTTP package would normally throw an error if my response has an error status code therefore this does not happen here because our response has a 200 status code  but simmply contains a body that indicates that we have error then I needed to manually check the response to see if their is an error and since the response is a map which contains a keey of error which contains in it a key of message which contain error message so its a nested map so then I can check if there is an error
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];

      _userId = responseData['localId'];

      _expiryDate = DateTime.now().add(Duration(
          seconds: int.parse(responseData[
              'expiresIn']))); //must be calculated because the only thing we get back  is expiresIn which only contains a string but in that string we have the number the seconds So we'll have to parse that string and turn it into a number but then after turning it into a number, we have to derive a date from that. So expiry date should be a datetime object so we take the dateTime of now and add to it the amount of seconds that will expire in to generate a future date the token will expire in it

      _autoLogOut();

      notifyListeners();
      final prefs = await SharedPreferences
          .getInstance(); //Now this here actually returns a future which eventually will return a shared preferences instance and that is then basically your tunnel to that on device storage. So we should await that so that we don't store the future in here but the real access to shared preferences and now we can use prefs to write and read data to and from the shared preferences device storage

      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });

      //Now we can store user data here and give that a key by which we can retrieve it and that key is totally up to you, should be a string and I'll just name it user data
      prefs.setString('userData', userData); //this to write data
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password,
        'signUp'); //ana 3mlt return hna w dah msh kal 3ada 3ashan el mafrood using async bat3ml return automatically b3d ma ta5als waiting el haya (await) bs haya el fekra hna 2n el function dee mogard zy bawaba lal function el f3ln bat post haga fal firebase ana hna bs bab3t el hagat el el function authenticate mahtagaha 3ashan ta2dr tab3t haga lal firebase wana 3mlt keda 3ashan bama 2n code el sign in w el sign up nfs el ahaga 2a5tlaf bs segment fal url fana 3mlt function sabta lal 2tnein w ba call it mara fal sign in w mara fal sign up w baktb "return" ra8m 2n dah 3aks el 3ada lama ba use async bs 3ashan ana hna msh mahatag a wait la haga ana mahtag 2ab3t function delw2ty w tab2 haya ta wait hnak
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password,
        'signInWithPassword'); //ana 3mlt return hna w dah msh kal 3ada 3ashan el mafrood using async bat3ml return automatically b3d ma ta5als waiting el haya (await) bs haya el fekra hna 2n el function dee mogard zy bawaba lal function el f3ln bat post haga fal firebase ana hna bs bab3t el hagat el el function authenticate mahtagaha 3ashan ta2dr tab3t haga lal firebase wana 3mlt keda 3ashan bama 2n code el sign in w el sign up nfs el ahaga 2a5tlaf bs segment fal url fana 3mlt function sabta lal 2tnein w ba call it mara fal sign in w mara fal sign up w baktb "return" ra8m 2n dah 3aks el 3ada lama ba use async bs 3ashan ana hna msh mahatag a wait la haga ana mahtag 2ab3t function delw2ty w tab2 haya ta wait hnak
  }

//this method is for retreiving data from device It will return a future and actually that is not a future which will in the end return nothing but here I want to have a future which returns a boolean because this method will be the tryAutoLogin method. it will return a boolean because it should signal whether we were successful when we try to automatically log the user in, so we are successful if we find a token and that token is still valid or if we were not successful
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogOut();
    return true;
  }

  Future<void> logOut() async {
    _token = null;
    _expiryDate = null;
    _userId = null;

    if (logOutTimer != null) {
      logOutTimer.cancel();
      logOutTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogOut() {
    if (logOutTimer != null) {
      logOutTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    logOutTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }
}
