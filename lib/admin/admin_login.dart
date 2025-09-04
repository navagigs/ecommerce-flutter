import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:pos/admin/admin_dashboard.dart';
import 'package:pos/themes.dart';
import 'package:pos/users/authenticaton/login_screen.dart';
import 'package:pos/users/authenticaton/signup_screen.dart';
import 'package:get/get.dart';
import 'package:pos/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pos/users/fragments/dashboard.dart';
import 'package:pos/users/model/user.dart';
import 'package:pos/users/userPreferences/user_preferences.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  var formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var isObsecure = true.obs;

  loginAdmin() async {
    try {
      var res = await http.post(
        Uri.parse(API.AdminLogin),
        body: {
          'admin_email': emailController.text.trim(),
          'admin_password': passwordController.text.trim(),
        },
      );

      if (res.statusCode == 200) {
        var resBodyLogin = jsonDecode(res.body);
        if (resBodyLogin['success'] == true) {
          Fluttertoast.showToast(
              msg: "Login berhasil, Selamat datang di Halaman Admin!");

          Future.delayed(Duration(milliseconds: 2000), () {
            // Get.to(Dashboard());
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          });
        } else {
          Fluttertoast.showToast(msg: "Login gagal!");
        }
      } else {
        Fluttertoast.showToast(msg: 'Status is not 200');
      }
    } catch (errorMsg) {
      print("Error::" + errorMsg.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: redColor,
      body: LayoutBuilder(
        builder: (context, cons) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: cons.maxHeight,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 135),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 110, vertical: 10),
                    child: Image.asset('assets/images/crop.png', height: 80),
                  ),
                  Container(
                    child: Container(
                      child: Text(
                        "Halaman Admin",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                        child: Column(
                          children: [
                            Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  //email
                                  TextFormField(
                                    controller: emailController,
                                    validator: (val) =>
                                        val == "" ? "Masukan email" : null,
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(
                                          color: Color.fromARGB(255, 62, 0, 0),
                                          fontStyle: FontStyle.italic),
                                      prefixIcon: const Icon(
                                        Icons.email,
                                        color: Colors.black,
                                      ),
                                      hintText: "Masukan email",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),

                                  //password
                                  Obx(
                                    () => TextFormField(
                                      controller: passwordController,
                                      obscureText: isObsecure.value,
                                      validator: (val) =>
                                          val == "" ? "Masukan password" : null,
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                            color:
                                                Color.fromARGB(255, 62, 0, 0),
                                            fontStyle: FontStyle.italic),
                                        prefixIcon: const Icon(
                                          Icons.vpn_key_sharp,
                                          color: Colors.black,
                                        ),
                                        suffixIcon: Obx(
                                          () => GestureDetector(
                                            onTap: () {
                                              isObsecure.value =
                                                  !isObsecure.value;
                                            },
                                            child: Icon(
                                              isObsecure.value
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        hintText: "Masukan password",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),

                                  //button login
                                  Material(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(30),
                                    child: InkWell(
                                      onTap: () {
                                        if (formKey.currentState!.validate()) {
                                          //login
                                          loginAdmin();
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(30),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 28,
                                        ),
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "apakah anda user?",
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen()),
                                    );
                                  },
                                  child: const Text(
                                    'Login!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
