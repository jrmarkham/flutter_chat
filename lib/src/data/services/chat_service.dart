import 'dart:core';

import 'package:chat/src/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';


// FIREBASE CONFIGS

const String CHATS_COLLECTION = 'chats';
// USER ARRAY FOR CHATS
const String CHATS_FIELD_USERS = 'users';
const String CHATS_CHAT_COLLECTION = 'chat';

// GLOBAL
const String GLOBAL_CHAT_COLLECTION = 'global_chat';
// fields for char message
const String MESSAGE_ID = 'id';
const String MESSAGE_USER_ID = 'user_id';
const String MESSAGE_TYPE = 'type';
const String MESSAGE_CONTENT = 'content';
const String MESSAGE_DATE = 'date';

abstract class BaseChatServices {
  Stream<QuerySnapshot> getGlobalChatStream();
  Stream<QuerySnapshot> getChatStream(String documentId);

  // GLOBAL CHAT
  Future<bool> createGlobalChatMessage(
      MessagePropsObject props, String uid); // Message Object //
  Future<bool> deleteGlobalChatMessage(String msgId); // delete your message
// PRIVATE  CHAT
  Future<String> findChatStreamByUsers(
      String uid0, String uid1);

  Future<String> createChatStream(String uid0, String uid1);

  Future<bool> createChatMessage(MessagePropsObject props, String uid,
      String docId); // Message Object +  userId  //
  Future<bool> deleteChatMessage(
      String msgId, String docId); // Message Object +  userId  //
}

class ChatServices extends BaseChatServices {
  // static singleton
  static final ChatServices _instance = ChatServices.internal();
  factory ChatServices() => _instance;
  ChatServices.internal();
  Firestore _firestore() => Firestore.instance;
  Firestore get firestore => _firestore();
  Stream<QuerySnapshot> _globalChatStream() =>
      firestore.collection(GLOBAL_CHAT_COLLECTION).snapshots();

  // PUBLIC
  Stream<QuerySnapshot> getGlobalChatStream() => _globalChatStream();

  Stream<QuerySnapshot> getChatStream(String documentId) {
    return firestore
        .collection(CHATS_COLLECTION)
        .document(documentId)
        .collection(CHATS_CHAT_COLLECTION)
        .snapshots();
  }

  Future<bool> createGlobalChatMessage(MessagePropsObject props, String uid) async {
    // create message and add to chat document
    bool post = true;

    MessagePostObject msg = MessagePostObject(
        content: props.content,
        userId: uid,
        messageType: props.messageType,
        date: FieldValue.serverTimestamp());

    await firestore
        .collection(GLOBAL_CHAT_COLLECTION)
        .add(msg.toMap())
        .catchError((error) {
      post = false;
      debugPrint(':::::ERROR POSTING ${error.toString()}');
    });
    return post;
  }

  Future<bool> deleteGlobalChatMessage(String msgId) async {
    // delete message
    bool delete = true;

    return delete;
  }

  Future<String> findChatStreamByUsers(
      String uid0, String uid1) async {
    // create chat document dialog w/ a user(s)
    final String query0 = '$CHATS_FIELD_USERS.$uid0';
    final String query1 = '$CHATS_FIELD_USERS.$uid1';
    final QuerySnapshot qs = await firestore
        .collection(CHATS_COLLECTION)
        .limit(1)
        .where(query0, isEqualTo: true)
        .where(query1, isEqualTo: true)
        .getDocuments();


    debugPrint(':::: findChatStreamByUsers qs ==  ${qs.toString()} ::::');

    return qs != null && qs.documents.length > 0
        ? qs.documents[0].documentID
        : createChatStream(uid0, uid1);
  }

  Future<String> createChatStream(String uid0, String uid1) async {
    // create chat document dialog w/ a user(s)

    final Map<String, dynamic> map = Map();
    map[CHATS_FIELD_USERS] = {uid0: true,  uid1: true};

    final docRef = await firestore.collection(CHATS_COLLECTION).add(map);
    return docRef.documentID;
  }

  Future<bool> createChatMessage(
      MessagePropsObject props, String uid, String docId) async {
    // create message and add to chat document
    bool post = true;
    MessagePostObject msg = MessagePostObject(
        content: props.content,
        userId: uid,
        messageType: props.messageType,
        date: FieldValue.serverTimestamp());

    await firestore
        .collection(CHATS_COLLECTION)
        .document(docId)
        .collection(CHATS_CHAT_COLLECTION)
        .add(msg.toMap())
        .catchError((error) {
      post = false;
      debugPrint(':::::ERROR POSTING ${error.toString()}');
    });

    return post;
  }

  Future<bool> deleteChatMessage(String msgId, String docId) async {
    // delete message
    bool delete = true;
    return delete;
  }

}
