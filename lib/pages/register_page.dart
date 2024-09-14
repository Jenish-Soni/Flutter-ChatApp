import 'dart:io';

import 'package:chat_app_flutter/const.dart';
import 'package:chat_app_flutter/model/user_profile.dart';
import 'package:chat_app_flutter/services/alert_service.dart';
import 'package:chat_app_flutter/services/auth_service.dart';
import 'package:chat_app_flutter/services/database_service.dart';
import 'package:chat_app_flutter/services/media_service.dart';
import 'package:chat_app_flutter/services/navigation_service.dart';
import 'package:chat_app_flutter/services/storage_service.dart';
import 'package:chat_app_flutter/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? email, password, name;
  File? selectedImage;
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late MediaService _mediaService;
  final GlobalKey<FormState> _registerformkey = GlobalKey<FormState>();
  late AuthService _authService;
  bool isloading = false;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AlertService _alertService;
  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
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
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        children: [
          _headerText(),
          if (!isloading) _registerform(),
          if (!isloading) _loginAnAccountLink(),
          if (isloading)
            const Expanded(
                child: Center(
              child: CircularProgressIndicator(),
            ))
        ],
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
            "Let's get going!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            "Register the account using form below",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _registerform() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.60,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * 0.05),
      child: Form(
          key: _registerformkey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _pfpSelectionForm(),
              CustomFormField(
                  hintText: "Name",
                  height: MediaQuery.sizeOf(context).height * 0.1,
                  validationRegExp: NAME_VALIDATION_REGEX,
                  onSaved: (value) {
                    setState(() {
                      name = value;
                    });
                  }),
              CustomFormField(
                  hintText: "Email",
                  height: MediaQuery.sizeOf(context).height * 0.1,
                  validationRegExp: EMAIL_VALIDATION_REGEX,
                  onSaved: (value) {
                    setState(() {
                      email = value;
                    });
                  }),
              CustomFormField(
                  hintText: "Password",
                  height: MediaQuery.sizeOf(context).height * 0.1,
                  validationRegExp: PASSWORD_VALIDATION_REGEX,
                  onSaved: (value) {
                    setState(() {
                      password = value;
                    });
                  }),
              _registerbutton()
            ],
          )),
    );
  }

  Widget _pfpSelectionForm() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
          radius: MediaQuery.of(context).size.width * 0.15,
          backgroundImage: selectedImage != null
              ? FileImage(selectedImage!)
              : NetworkImage(PLACEHOLDER_PFP) as ImageProvider),
    );
  }

  Widget _registerbutton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        color: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          setState(() {
            isloading = true;
          });
          try {
            if ((_registerformkey.currentState?.validate() ?? false) &&
                selectedImage != null) {
              _registerformkey.currentState?.save();
              bool result = await _authService.signup(email!, password!);
              if (result) {
                String? pfpURL = await _storageService.uploadUserPfp(
                    file: selectedImage!, uid: _authService.user!.uid);
                if(pfpURL !=null){
                  await _databaseService.createUserProfile(userprofile: UserProfile(uid: _authService.user!.uid, name: name, pfpURL: pfpURL));
                  _alertService.showToast(text: "User registered successfully!",icon: Icons.check);
                  _navigationService.pushReplacementNamed("/home");
                  _navigationService.goBack();
                }
                else{
                  throw Exception("Unable to upload user profile picture");
                }
               }
              else{
                throw Exception("Unable to register user");
              }
            }
          } catch (e) {
            _alertService.showToast(text: "User registered successfully!",icon: Icons.error);
          }
          setState(() {
            isloading = false;
          });
        },
        child: Text(
          "Register",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAnAccountLink() {
    return Expanded(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: Text(
              "Login",
              style: TextStyle(fontWeight: FontWeight.w800),
            )),
      ],
    ));
  }
}
