import 'dart:core';

import 'package:chat/src/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
// FIREBASE CONFIGS
const String USER_COLLECTION = 'users';
// fields
const String USER_ID = 'id';
const String USER_CHAT_STREAM_ID = 'stream_id';
const String USER_AUTH_ITEM = 'auth_item'; // email or phone number //
const String USER_NAME = 'name';
const String USER_PRIVATE = 'private';
const String USER_GLOBAL_ALERT = 'global_alert';
const String USER_FRIENDS = 'friends';
const String USER_INVITES = 'invites';
const String USER_CHAT_ALERT = 'chat_alert';
const String USER_CHAT_ALERT_GA = 'ga';


abstract class BaseUserServices {
  Stream<QuerySnapshot> getUserStream();
  Future<void> createUser(
      {@required String authItem, @required String name, @required bool private});

  // UPDATES
  Future<bool> updateUser({@required String id, @required String field, @required dynamic value});
  // LIST // ARRAY AT UPDATES
  Future<bool> userAddArrayItem({@required String id, @required String field, @required String value});
  Future<bool> userRemoveArrayItem({@required String id, @required String field, @required String value});
  
}

class UserServices extends BaseUserServices {
  // static singleton
  static final UserServices _instance = UserServices.internal();
  factory UserServices() => _instance;
  UserServices.internal();
  Firestore _firestore() => Firestore.instance;
  Firestore get firestore => _firestore();


  Stream<QuerySnapshot> _userStream() =>
      firestore.collection(USER_COLLECTION).snapshots();


  // PUBLIC

  Stream<QuerySnapshot> getUserStream() => _userStream();
  Future<void> createUser(
      {@required String authItem,
      @required String name,
      @required bool private}) async {
    QuerySnapshot qs = await _getDocuments(USER_AUTH_ITEM, authItem);

    if(qs.documents.length ==0 ){
     // create a new user

      debugPrint(':::::::::: CREATE USER :::::::::');

      final CurrentUserObject _user =
      CurrentUserObject(id: '', authItem: authItem, name: name, private: private, globalAlert:true,globalAlertOn:false, friends: [], invites: []);
      await firestore.collection(USER_COLLECTION).add(_user.toMap());
      return;
    }
  }

  // update value 
  Future<bool> updateUser({@required String id, @required String field, @required dynamic value}) async {
    // run updates
    bool update = true;
    await firestore
          .collection(USER_COLLECTION)
          .document(id)
          .updateData({field:value})
          .catchError((error) {
        debugPrint('UPDATE ERROR ${error.toString()}');
        update = false;
      });
    return update;
  }

  // array updates 
  
  Future<bool> userAddArrayItem({@required String id, @required String field, @required String value}) async {
    // run updates
    bool update = true;
    await firestore
        .collection(USER_COLLECTION)
        .document(id)
        .updateData({field: FieldValue.arrayUnion([value])})
        .catchError((error) {
      debugPrint('UPDATE ERROR ${error.toString()}');
      update = false;
    });
    return update;
  }

  Future<bool> userRemoveArrayItem({@required String id, @required String field, @required String value}) async {
    // run updates
    bool update = true;
    await firestore
        .collection(USER_COLLECTION)
        .document(id)
        .updateData({field:FieldValue.arrayRemove([value])})
        .catchError((error) {
      debugPrint('UPDATE ERROR ${error.toString()}');
      update = false;
    });
    return update;
  }


  Future<QuerySnapshot> _getDocuments(String field, dynamic value)async{
    return firestore.collection(USER_COLLECTION).where(field, isEqualTo: value).getDocuments();
  }

}
