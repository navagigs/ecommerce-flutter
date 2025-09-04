import 'package:get/get.dart';

import 'package:pos/users/model/user.dart';
import 'package:pos/users/userPreferences/user_preferences.dart';

class CurrentUser extends GetxController {
  Rx<User> _currentUser = User(0, '', '', '').obs;

  User get user => _currentUser.value;

  getUserInfo() async {
    User? getUserInfoFromLocalStorage = await RememeberUserPrefs.readUserInfo();
    _currentUser.value = getUserInfoFromLocalStorage!;
  }
}
