import 'package:flutter/material.dart';
import 'package:pos/users/authenticaton/login_screen.dart';
import 'package:pos/users/userPreferences/current_user.dart';
import 'package:get/get.dart';
import 'package:pos/users/userPreferences/user_preferences.dart';

class Profile extends StatelessWidget {
  final CurrentUser _currentUser = Get.put(CurrentUser());

  Future<void> showAlertDialog(BuildContext context) async {
    // set up the buttons

    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget launchButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        RememeberUserPrefs.removeUserInfo().then((value) {
          // LoginPage();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Keluar"),
      content: Text("Apakah anda yakin akan keluar dari aplikasi?"),
      actions: [
        cancelButton,
        launchButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget userInfoItemProfile(IconData iconData, String userData) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color.fromARGB(255, 255, 255, 255),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 30,
            color: Colors.black,
          ),
          const SizedBox(
            width: 16,
          ),
          Text(
            userData,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(32),
      children: [
        Center(
          child: Image.asset(
            "assets/images/man.png",
            width: 240,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        userInfoItemProfile(Icons.person, _currentUser.user.user_name),
        const SizedBox(
          height: 20,
        ),
        userInfoItemProfile(Icons.email, _currentUser.user.user_email),
        const SizedBox(
          height: 20,
        ),
        Center(
          child: Material(
            color: Color.fromARGB(255, 255, 64, 0),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                showAlertDialog(context);
              },
              borderRadius: BorderRadius.circular(32),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                child: Text(
                  "Keluar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
