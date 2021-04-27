import 'package:flutter_secure_storage/flutter_secure_storage.dart';


const String STORAGE_AUTH_KEY = 'auth_key';
abstract class BaseSecureStorageServices {
    // Auth
    Future<void> setAuth(String auth);
    Future<String> getAuth();
    Future<void> clearAuth();
    Future<void> clearAll();
}

class SecureStorageServices extends BaseSecureStorageServices {
    // static singleton
    static final SecureStorageServices _instance = SecureStorageServices.internal ();
    factory SecureStorageServices() => _instance;
    SecureStorageServices.internal();

    FlutterSecureStorage _flutterSecureStorage =  FlutterSecureStorage();
    FlutterSecureStorage get flutterSecureStorage => _flutterSecureStorage;

    // AUTH 
    Future<void> setAuth(String auth)async{
        await flutterSecureStorage.write(key: STORAGE_AUTH_KEY, value: auth);
    }
    Future<String> getAuth()async{
        return await flutterSecureStorage.read(key: STORAGE_AUTH_KEY);
    }
    Future<void> clearAuth()async{
        await flutterSecureStorage.delete(key: STORAGE_AUTH_KEY);
    }


    // clear all 
    Future<void> clearAll()async{
        await flutterSecureStorage.deleteAll();
    }


}