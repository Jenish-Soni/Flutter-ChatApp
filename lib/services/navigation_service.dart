import 'package:chat_app_flutter/pages/home_page.dart';
import 'package:chat_app_flutter/pages/login_page.dart';
import 'package:chat_app_flutter/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class NavigationService{

  late GlobalKey<NavigatorState> _navigationkey;

  final Map<String, Widget Function(BuildContext)> _routes ={
    "/login":(context) => LoginPage(),
    "/register":(context) => RegisterPage(),
    "/home":(context) => HomePage(),
  };

  GlobalKey<NavigatorState>? get navigatorkey{
    return _navigationkey;
  }

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
}

  NavigationService(){
    _navigationkey = GlobalKey<NavigatorState>();
  }
  void push(MaterialPageRoute route){
    _navigationkey.currentState?.push(route);
  }
  void pushNamed(String routeName){
    _navigationkey.currentState?.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName){
    _navigationkey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack(){
    _navigationkey.currentState?.pop();
  }

}