import 'dart:convert';

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:pos/api/api.dart';
import 'package:pos/themes.dart';
import 'package:pos/admin/admin_order_detail.dart';
import 'package:pos/users/model/order.dart';
import 'package:pos/users/userPreferences/current_user.dart';
import 'package:http/http.dart' as http;

class AdminGetAllOrders extends StatelessWidget {
  final currentOnlineUser = Get.put(CurrentUser());

  Future<List<Order>> getAllOrdersList() async {
    List<Order> orderList = [];

    try {
      var res = await http.post(
        Uri.parse(API.AdminGetOrders),
        body: {},
      );
      // print("Response: ${res.body}");
      if (res.statusCode == 200) {
        var responseBody = jsonDecode(res.body);
        if (responseBody['success'] == true) {
          (responseBody['allOrderData'] as List).forEach((eachOrderData) {
            orderList.add(Order.fromJson(eachOrderData));
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Status Code is not 200");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Terjadi Kesalahan: $error");
    }
    return orderList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.white), // <--- ini bikin ikon back jadi putih
        title: Text(
          'Order',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 6,
                blurRadius: 6,
                offset: Offset(0, -4),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.topRight,
              stops: [0.1, 0.8, 1],
              colors: [redColor, redColor, yellowColor],
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset(
                      "assets/images/orders_icon.png",
                      width: 140,
                    ),
                    Text(
                      "All Order List",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 28,
                      ),
                      child: Text(
                        "Pesanan berhasil diterima.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: displayOrder(context),
          )
        ],
      ),
    );
  }

  Widget displayOrder(context) {
    return FutureBuilder(
      future: getAllOrdersList(),
      builder: (context, AsyncSnapshot<List<Order>> dataSnapShot) {
        if (dataSnapShot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Center(
                child: Text(
                  "Loading...",
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }
        if (dataSnapShot.connectionState == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Center(
                child: Text(
                  "Tidak ada data order...",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }
        if (dataSnapShot.data!.length > 0) {
          List<Order> orderList = dataSnapShot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderList.length,
            itemBuilder: (context, index) {
              Order eachOrderData = orderList[index];
              return Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: ListTile(
                    onTap: () {
                      Get.to(AdminOrderDetail(
                        clickOrderInfo: eachOrderData,
                      ));
                    },
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order ID # ${eachOrderData.order_id.toString()}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Rp.${eachOrderData.totalAmount!.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //tanggal dan ajm
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat("dd MMMM yyyy")
                                  .format(eachOrderData.dateTime!),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              DateFormat("hh:mm a")
                                  .format(eachOrderData.dateTime!),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        const Icon(
                          Icons.navigate_next,
                          color: Colors.deepOrange,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Center(
                child: Text(
                  "Belum ada data order...",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }
      },
    );
  }
}
