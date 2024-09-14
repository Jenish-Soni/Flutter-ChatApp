import 'package:chat_app_flutter/model/user_profile.dart';
import 'package:chat_app_flutter/pages/chat_page.dart';
import 'package:chat_app_flutter/services/alert_service.dart';
import 'package:chat_app_flutter/services/auth_service.dart';
import 'package:chat_app_flutter/services/database_service.dart';
import 'package:chat_app_flutter/services/navigation_service.dart';
import 'package:chat_app_flutter/widgets/chat_file.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(onPressed: () async{
            bool result = await _authService.logout();
            print(result);
            if(result){
              _alertService.showToast(text: "Successfully Logged out!",icon: Icons.check);
              _navigationService.pushReplacementNamed("/login");
            }
          }, icon: const Icon(Icons.logout))
        ],
      ),
      body: _buildUI()
    );
  }


  Widget _buildUI(){
    return SafeArea(child: Padding(padding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),child: _chatList(),));
  }

  Widget _chatList(){
    return StreamBuilder(stream: _databaseService.getUserProfiles(), builder: (context,snapshot){
      if(snapshot.hasError){
        return Center(
          child: Text("Unable to load data"),
        );
      }
      print(snapshot.data);
      if(snapshot.hasData && snapshot.data != null){
        final users = snapshot.data!.docs;
        return ListView.builder(itemCount: users.length,itemBuilder: (context,index){
          UserProfile user = users[index].data();
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChatTile(userProfile: user, onTap: ()async{
              final chatExist = await _databaseService.checkchatExist(_authService.user!.uid,user.uid!);
              if(!chatExist){
                await _databaseService.createNewChat(_authService.user!.uid,user.uid!);
              }
              _navigationService.push(MaterialPageRoute(builder: (context){
                 return ChatPage(chatuser: user,);
              }));
            }),
          );
        });
      }
      return Center(
        child: CircularProgressIndicator(),
      );
    });
  }
}
