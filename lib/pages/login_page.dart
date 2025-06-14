import 'package:chat_app_flutter/const.dart';
import 'package:chat_app_flutter/services/alert_service.dart';
import 'package:chat_app_flutter/services/auth_service.dart';
import 'package:chat_app_flutter/services/navigation_service.dart';
import 'package:chat_app_flutter/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late NavigationService _navigationService;
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  late AuthService _authService;
  String? email,password;
  late AlertService _alertService;
  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        children: [_headerText(), _loginForm(),_createAnAccountLink()],
      ),
    ));
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi, Welcome Back!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            "Hello again, you've been missed",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.40,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * 0.05),
      child: Form(
        key: _loginFormKey,
          child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomFormField(
            height: MediaQuery.sizeOf(context).height * 0.1,
            hintText: "Email",
            validationRegExp: EMAIL_VALIDATION_REGEX,
            onSaved: (value){
              setState(() {
                email = value;
              });
            },
          ),
          CustomFormField(
            height: MediaQuery.sizeOf(context).height * 0.1,
            hintText: "Password",
            validationRegExp: PASSWORD_VALIDATION_REGEX,
            obscuretext: true,
            onSaved: (value){
              setState(() {
              password = value;
              });
            },
          ),
          _loginButton(),

        ],
      )),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async{
          if(_loginFormKey.currentState!.validate()??false){
            _loginFormKey.currentState?.save() ;
            bool _result = await _authService.login(email!, password!);
            print(_result);
            if(_result){
              _navigationService.pushReplacementNamed('/home');
            }else{
              _alertService.showToast(text: "Failed to login",icon: Icons.error);

            }
          }
        },
        child: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _createAnAccountLink() {
    return Expanded(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Don't have an account? "),
            GestureDetector(onTap: (){
              _navigationService.pushNamed("/register");
            }, child: Text("Sign Up",style: TextStyle(fontWeight: FontWeight.w800),)),
      ],
    ));
  }
}
