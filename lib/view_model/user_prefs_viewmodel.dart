import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_kuldeep_practical/model/user_model.dart';
import 'package:uuid/uuid.dart';

import '../constants/constants.dart';
import '../helper/hive_db_helper.dart';
import '../view/tasks_view.dart';

final userProvider = StateNotifierProvider<UserPrefsViewMode, UserModel>((ref) {
  ref.onDispose(() {
    HiveDbHelper.closeBox();
  });
  return UserPrefsViewMode();
});

class UserPrefsViewMode extends StateNotifier<UserModel> {
  UserPrefsViewMode() : super(HiveDbHelper.getUser(StringRes.userPrefs) ?? UserModel());

  createUser({
    required String userName,
    required String userEmail,
    required BuildContext context,
  }) {
    Uuid uuid = const Uuid();
    final userData = UserModel(
      id: uuid.v4(),
      isLightTheme: true,
      username: userName,
      userEmail: userEmail,
    );
    HiveDbHelper.registerUser(userData);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const TasksView()),
    );
  }

  getUserData() {
    state = HiveDbHelper.getUser(StringRes.userPrefs);
  }

  changeTheme() {
    bool isLightTheme = state.isLightTheme ?? false;
    if (isLightTheme) {
      isLightTheme = false;
    } else {
      isLightTheme = true;
    }
    state = HiveDbHelper.updateUser(
      StringRes.userPrefs,
      UserModel(
        id: state.id,
        isLightTheme: isLightTheme,
        username: state.username,
        userEmail: state.userEmail,
      ),
    );
  }

  setDefaultSortOrder(String sortBy) {
    state = HiveDbHelper.updateUser(
      StringRes.userPrefs,
      UserModel(
        id: state.id,
        isLightTheme: state.isLightTheme,
        username: state.username,
        userEmail: state.userEmail,
        sortBy: sortBy,
      ),
    );
  }
}
