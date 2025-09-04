import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:pos/api/api.dart';
import 'package:pos/users/fragments/dashboard.dart';
import 'package:pos/users/fragments/home.dart';
import 'package:pos/users/model/order.dart';
import 'package:pos/users/userPreferences/current_user.dart';
import 'package:http/http.dart' as http;

class OrderConfirmation extends StatelessWidget {
  final List<int>? selectCartIDs;
  final List<Map<String, dynamic>>? selectedCartListItemsInfo;
  final double? totalAmount;
  final String? deliverySys;
  final String? deliveryAddress;
  final String? paymentSys;
  final String? no_telepon;
  final String? alamat;
  final String? catatan;

  OrderConfirmation({
    this.selectCartIDs,
    this.selectedCartListItemsInfo,
    required this.totalAmount,
    this.deliverySys,
    this.deliveryAddress,
    this.paymentSys,
    this.no_telepon,
    this.alamat,
    this.catatan,
  });

  RxList<int> _imageSelectedByte = <int>[].obs;
  Uint8List get imageSelectedByte => Uint8List.fromList(_imageSelectedByte);

  RxString _imageSelectedName = ''.obs;
  String get imageSelectedName => _imageSelectedName.value;

  final ImagePicker _picker = ImagePicker();

  CurrentUser currentUser = Get.put(CurrentUser());

  setSelectedImage(Uint8List selectedImage) {
    _imageSelectedByte.value = selectedImage;
  }

  setSelectedImageName(String selectedImageName) {
    _imageSelectedName.value = selectedImageName;
  }

  uploadImageFromGallery() async {
    // Implementasi fungsi uploadImageFromGallery
    final pickImageXFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickImageXFile != null) {
      final bytesOfImage = await pickImageXFile.readAsBytes();
      setSelectedImage(bytesOfImage);

      setSelectedImageName(path.basename(pickImageXFile.path));
    }
  }

  pickImageFromGallery() async {
    final pickImageXFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickImageXFile != null) {
      final bytesOfImage = await pickImageXFile.readAsBytes();
      setSelectedImage(bytesOfImage);
      setSelectedImageName(path.basename(pickImageXFile.path));
    }
  }

  saveOrder() async {
    // Implementasi fungsi saveOrder
    String selectedItems = selectedCartListItemsInfo!
        .map((eachSelectedItem) => jsonEncode(eachSelectedItem))
        .toList()
        .join("||");

    Order order = Order(
      order_id: 1,
      user_id: currentUser.user.user_id,
      selectedItems: selectedItems,
      deliverySystem: deliverySys,
      paymentSystem: paymentSys,
      catatan: catatan,
      totalAmount: totalAmount,
      status: 'BARU',
      dateTime: DateTime.now(),
      no_telepon: no_telepon,
      alamat: alamat,
      image: path.basenameWithoutExtension(imageSelectedName) +
          "-" +
          DateTime.now().millisecondsSinceEpoch.toString() +
          path.extension(imageSelectedName),
    );

    try {
      var resOrder = await http.post(
        Uri.parse(API.addOrder),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(order.toJson(base64Encode(imageSelectedByte))),
      );

      if (resOrder.statusCode == 200) {
        // print("Response: ${resOrder.body}");

        var responseBodyOrder = jsonDecode(resOrder.body);
        if (responseBodyOrder['success'] == true) {
          selectCartIDs!.forEach((eachSelectedItemCartID) {
            deleteSelectedItemFromCartList(eachSelectedItemCartID);
          });
        }
      }
      // Get.back();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  deleteSelectedItemFromCartList(int cartID) async {
    try {
      var res = await http.post(
        Uri.parse(API.deleteSelectedItemFromCartList),
        body: {
          "cart_id": cartID.toString(),
        },
      );
      if (res.statusCode == 200) {
        var responseBody = jsonDecode(res.body);
        if (responseBody['success'] == true) {
          Fluttertoast.showToast(msg: "Order Berhasil Disimpan");
          await Future.delayed(Duration(seconds: 1));
          Get.offAll(() =>
              Dashboard()); // pastikan Home pakai onInit() di controllernya
        }
      } else {
        Fluttertoast.showToast(msg: "Terjadi Kesalahan ${res.statusCode}");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Errpr:" + error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white, // Warna icon back
          ),
          onPressed: () {
            Navigator.pop(context); // Aksi kembali
          },
        ),
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(
            color: Colors.white, // Warna teks
          ),
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/transaksi.png",
              width: 60,
            ),
            const SizedBox(
              height: 4,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Harap lampirkan  \nbukti transaksi / struk / screenshot',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Material(
              elevation: 8,
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () {
                  //upload image
                  uploadImageFromGallery();
                },
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  child: Text(
                    "Upload Bukti Transaksi",
                    style: TextStyle(
                      color: Colors.white, // Warna teks
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Obx(
              () => ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                    maxHeight: MediaQuery.of(context).size.width * 0.6,
                  ),
                  child: imageSelectedByte.isNotEmpty
                      ? Image.memory(
                          imageSelectedByte,
                          fit: BoxFit.contain,
                        )
                      : Placeholder(
                          color: Colors.grey,
                        )),
            ),
            const SizedBox(
              height: 16,
            ),
            Obx(
              () => Material(
                elevation: 8,
                color:
                    imageSelectedByte.isEmpty ? Colors.grey : Colors.deepOrange,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                    onTap: () {
                      if (imageSelectedByte.isNotEmpty) {
                        saveOrder();
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Lampirkan bukti transaksi');
                      }
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: const Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      child: Text(
                        "Konfirmasi & Proses",
                        style: TextStyle(
                          color: Colors.white, // Warna teks
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
