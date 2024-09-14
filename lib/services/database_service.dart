import 'package:chat_app_flutter/model/user_profile.dart';
import 'package:chat_app_flutter/services/auth_service.dart';
import 'package:chat_app_flutter/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../model/chat.dart';
import '../model/message.dart';

class DatabaseService {
  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference? _userCollection;
  CollectionReference? _chatCollection;
  late AuthService _authService;

  DatabaseService() {
    _authService = _getIt.get<AuthService>();
    _setupCollectionReference();
  }

  void _setupCollectionReference() {
    _userCollection = _firebaseFirestore
        .collection('users')
        .withConverter<UserProfile>(
            fromFirestore: (snapshots, _) =>
                UserProfile.fromJson(snapshots.data()!),
            toFirestore: (userprofile, _) => userprofile.toJson());
    
    _chatCollection = _firebaseFirestore.collection('chats').withConverter<Chat>(fromFirestore: (snapshots,_)=> Chat.fromJson(snapshots.data()!), toFirestore: (chat,_)=> chat.toJson());
  }

  Future<void> createUserProfile({
    required UserProfile userprofile
}) async{
    await _userCollection?.doc(userprofile.uid).set(userprofile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles(){
    return _userCollection?.where("uid",isNotEqualTo:_authService.user!.uid).snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkchatExist(String uid1,String uid2) async{
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatCollection?.doc(chatID).get();

    if(result != null){
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1,String uid2) async{
    String chatId =  generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatId);
    final chat = Chat(id: chatId, participants: [uid1,uid2], messages: []);
    await docRef.set(chat);
  }

  Future<void> sendChatMessage(String uid1, String uid2, Message message) async{
    String chatId = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatId);
    await docRef.update({
      "messages":FieldValue.arrayUnion([message.toJson()])
    });
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2){
    String chatId = generateChatID(uid1: uid1, uid2: uid2);
    return _chatCollection!.doc(chatId).snapshots() as Stream<DocumentSnapshot<Chat>>;
  }
}

