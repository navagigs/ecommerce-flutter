import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pos/users/fragments/favorite.dart';
import 'package:pos/users/fragments/home.dart';
import 'package:pos/users/fragments/order.dart';
import 'package:pos/users/fragments/profile.dart';
import 'package:pos/users/userPreferences/current_user.dart';

class Dashboard extends StatelessWidget {
  static const nameRoute = '/Dashboard';

  CurrentUser _rememberCurrentUser = Get.put(CurrentUser());

  final List<Widget> _fragmentScreens = [
    Home(),
    FavoriteListScreen(),
    OrderScreen(),
    Profile(),
  ];

  final List _navigationButtonsProperties = [
    {
      'active_icon': Icons.home,
      'non_active_icon': Icons.home_outlined,
      'label': 'Home',
    },
    {
      'active_icon': Icons.favorite,
      'non_active_icon': Icons.favorite_border,
      'label': 'Favorite',
    },
    {
      'active_icon': FontAwesomeIcons.boxOpen,
      'non_active_icon': FontAwesomeIcons.box,
      'label': 'Order',
    },
    {
      'active_icon': Icons.person,
      'non_active_icon': Icons.person_outline,
      'label': 'Profile',
    },
  ];

  final _indexNumber = 0.obs;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: CurrentUser(),
        initState: (currentState) {
          _rememberCurrentUser.getUserInfo();
        },
        builder: (controller) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Obx(
                () => _fragmentScreens[_indexNumber.value],
              ),
            ),
            bottomNavigationBar: Obx(
              () => BottomNavigationBar(
                currentIndex: _indexNumber.value,
                onTap: (value) {
                  _indexNumber.value = value;
                },

                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedItemColor: Color.fromARGB(255, 255, 255, 255),
                unselectedItemColor: Colors.white70,
                selectedLabelStyle:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                unselectedLabelStyle: TextStyle(fontSize: 11),
                type: BottomNavigationBarType.fixed,
                elevation:
                    0, // Elevation disesuaikan karena kita pakai gradien.
                backgroundColor: Color.fromARGB(
                    255, 255, 64, 0), // Transparan untuk gradien.
                items:
                    List.generate(_navigationButtonsProperties.length, (index) {
                  var navBtnProperty = _navigationButtonsProperties[index];
                  return BottomNavigationBarItem(
                    icon: Icon(
                      navBtnProperty["non_active_icon"],
                      size: 28,
                    ),
                    activeIcon: Icon(
                      navBtnProperty["active_icon"],
                      size: 32,
                    ),
                    label: navBtnProperty["label"],
                  );
                }),
              ),
            ),
          );
        });
  }
}
