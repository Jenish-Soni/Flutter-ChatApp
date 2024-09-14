import 'dart:io';

import 'package:chat_app_flutter/model/message.dart';
import 'package:chat_app_flutter/model/user_profile.dart';
import 'package:chat_app_flutter/services/auth_service.dart';
import 'package:chat_app_flutter/services/database_service.dart';
import 'package:chat_app_flutter/services/media_service.dart';
import 'package:chat_app_flutter/services/storage_service.dart';
import 'package:chat_app_flutter/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../model/chat.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatuser;
  const ChatPage({super.key, required this.chatuser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;
  ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    currentUser = ChatUser(
        id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser = ChatUser(
        id: widget.chatuser.uid!,
        firstName: widget.chatuser.name,
        profileImage: widget.chatuser.pfpURL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatuser.name!),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
        stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
        builder: (context, snapshot) {
          Chat? chat = snapshot.data?.data();
          List<ChatMessage> messages = [];
          if (chat != null && chat.messages != null) {
            messages = _generateChatMessageList(chat.messages!);
          }
          return DashChat(
            messageOptions: const MessageOptions(
                showOtherUsersAvatar: true, showTime: true),
            currentUser: currentUser!,
            onSend: _sendMessage,
            messages: messages,
            inputOptions: InputOptions(
                alwaysShowSend: true, trailing: [_mediaMessageButton()]),
          );
        });
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
            senderID: chatMessage.user!.id,
            content: chatMessage.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await _databaseService.sendChatMessage(currentUser!.id, otherUser!.id, message);
      }
    } else {
      Message messages = Message(
          senderID: currentUser!.id,
          content: chatMessage.text,
          messageType: MessageType.Text,
          sentAt: Timestamp.fromDate(chatMessage.createdAt));
      await _databaseService.sendChatMessage(
          currentUser!.id, otherUser!.id, messages);
    }
  }

  List<ChatMessage> _generateChatMessageList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if(m.messageType == MessageType.Image){
        return ChatMessage(user: m.senderID == currentUser!.id ? currentUser! : otherUser!, createdAt: m.sentAt!.toDate(),medias: [
          ChatMedia(url: m.content!, fileName: "", type: MediaType.image),
        ]);
      }else{
      return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          text: m.content!,
          createdAt: m.sentAt!.toDate());}
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
        onPressed: () async {
          File? file = await _mediaService.getImageFromGallery();
          if (file != null) {
            String chatId =
                generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);
            String? downloadURL = await _storageService.uploadImageToChat(
                file: file, chatID: chatId);

            if (downloadURL != null) {
              ChatMessage chatMessage = ChatMessage(
                  user: currentUser!,
                  createdAt: DateTime.now(),
                  medias: [
                    ChatMedia(
                        url: downloadURL, fileName: "", type: MediaType.image)
                  ]);
              _sendMessage(chatMessage);
            }
          }
        },
        icon: Icon(
          Icons.image,
          color: Theme.of(context).colorScheme.primary,
        ));
  }
}
