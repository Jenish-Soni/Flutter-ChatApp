import 'package:chat_app_flutter/firebase_options.dart';
import 'package:chat_app_flutter/services/alert_service.dart';
import 'package:chat_app_flutter/services/auth_service.dart';
import 'package:chat_app_flutter/services/database_service.dart';
import 'package:chat_app_flutter/services/media_service.dart';
import 'package:chat_app_flutter/services/navigation_service.dart';
import 'package:chat_app_flutter/services/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

Future<void> setupFirebase() async{
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> registerservices() async{
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(AuthService());

  getIt.registerSingleton<NavigationService>(NavigationService());

  getIt.registerSingleton<AlertService>(AlertService());
  getIt.registerSingleton<MediaService>(MediaService());
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<DatabaseService>(DatabaseService());
}

String generateChatID({required String uid1,required String uid2}){
  List uids = [uid1, uid2];
  uids.sort();
  String chatId = uids.fold("",(id,uid)=> "$id$uid");
  return chatId;
}