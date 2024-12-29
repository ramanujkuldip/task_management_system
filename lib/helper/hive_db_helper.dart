import 'package:hive_flutter/hive_flutter.dart';

import '../constants/constants.dart';
import '../model/user_model.dart';

class HiveDbHelper {
  static final userBox = Hive.box(StringRes.userPrefs);
  static UserModel? userData;

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserModelAdapter());
    await Hive.openBox(StringRes.userPrefs);
    userData = getUser(StringRes.userPrefs);
  }

  static registerUser(UserModel userData) {
    userBox.put(StringRes.userPrefs, userData);
  }

  static updateUser(String key, UserModel userData) {
    userBox.put(key, userData);
    return userData;
  }

  static getUser(String key) {
    return userBox.get(key);
  }

  static deleteUser(String key) {
    return userBox.delete(key);
  }

  static closeBox() {
    return userBox.close();
  }
}
