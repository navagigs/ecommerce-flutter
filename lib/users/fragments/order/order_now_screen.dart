import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pos/users/controllers/order_now_controller.dart';
import 'package:pos/users/fragments/order/order_confirmation.dart';

class OrderNowScreen extends StatelessWidget {
  final List<Map<String, dynamic>>? selectedCartListItemsInfo;
  final double? totalAmount;
  final List<int>? selectCartIDs;

  OrderNowController orderNowController = Get.put(OrderNowController());
  List<String> deliverySystemNameList = ['PosID', 'GOJEK', 'GRAB'];
  List<String> paymentSystemNameList = ['BCA', 'BRI', 'MANDIRI'];

  TextEditingController no_teleponController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController catatanController = TextEditingController();

  OrderNowScreen({
    this.selectedCartListItemsInfo,
    this.totalAmount,
    this.selectCartIDs,
  });

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
          'Pesanan Sekarang',
          style: TextStyle(
            color: Colors.white, // Warna teks
          ),
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView(
        children: [
          //item order

          displaySelectedItemsFromCart(),

          const SizedBox(height: 10),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Delivery System",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: deliverySystemNameList.map((deliverySystemName) {
                return Obx(() => RadioListTile<String>(
                      tileColor: const Color.fromARGB(255, 246, 246, 246),
                      dense: true,
                      activeColor: Colors.black,
                      title: Text(deliverySystemName,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black)),
                      value: deliverySystemName,
                      groupValue: orderNowController.deliverySys,
                      onChanged: (newDeliverySystemValue) {
                        orderNowController
                            .setDeliverySystem(newDeliverySystemValue!);
                      },
                    ));
              }).toList(),
            ),
          ),

          const SizedBox(height: 5),

          ///payment system
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Payment System",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "Company Account Number / ID : \n 3201010101010101",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: paymentSystemNameList.map((paymentSystemName) {
                return Obx(() => RadioListTile<String>(
                      tileColor: const Color.fromARGB(255, 246, 246, 246),
                      dense: true,
                      activeColor: Colors.black,
                      title: Text(paymentSystemName,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black)),
                      value: paymentSystemName,
                      groupValue: orderNowController.paymentSys,
                      onChanged: (newPaymentSystemValue) {
                        orderNowController
                            .setPaymentSystem(newPaymentSystemValue!);
                      },
                    ));
              }).toList(),
            ),
          ),

          const SizedBox(height: 5),
          //no telepon
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Nomor Telepon",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: no_teleponController,
              decoration: InputDecoration(
                hintText: 'Masukan nomor telepon Anda',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.deepOrange,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 5),
          //alamat
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Alamat",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: alamatController,
              keyboardType: TextInputType.multiline,
              maxLines: null, // biar bisa otomatis tambah baris
              minLines: 2, // tampil tinggi awal 5 baris
              decoration: InputDecoration(
                hintText: 'Masukan nomor alamat Anda',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.deepOrange,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 5),
          //catatan ke seller
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Catatan ke Seller",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: catatanController,
              keyboardType: TextInputType.multiline,
              maxLines: null, // biar bisa otomatis tambah baris
              minLines: 1, // tampil tinggi awal 5 baris
              decoration: InputDecoration(
                hintText: 'Masukan catatan ke seller',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.deepOrange,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  // color: const Color.fromARGB(255, 237, 235, 235),
                  // borderRadius: BorderRadius.circular(16),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black12,
                  //     blurRadius: 6,
                  //     offset: Offset(0, 3),
                  //   ),
                  // ],
                  ),
              child: Row(
                children: [
                  Text(
                    "Total Bayar",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Rp. ${totalAmount!.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 5),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Material(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  if (no_teleponController.text.isNotEmpty &&
                      alamatController.text.isNotEmpty) {
                    Get.to(OrderConfirmation(
                      selectCartIDs: selectCartIDs,
                      selectedCartListItemsInfo: selectedCartListItemsInfo,
                      totalAmount: totalAmount,
                      deliverySys: orderNowController.deliverySys,
                      paymentSys: orderNowController.paymentSys,
                      no_telepon: no_teleponController.text,
                      alamat: alamatController.text,
                      catatan: catatanController.text,
                    ));
                  } else {
                    Fluttertoast.showToast(
                        msg: "Lengkapi data terlebih dahulu");
                  }

                  // aksi bayar
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    // ✅ Ini bikin teks berada di tengah
                    child: Text(
                      "Bayar Sekarang",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  displaySelectedItemsFromCart() {
    return Column(
      children: List.generate(selectedCartListItemsInfo!.length, (index) {
        Map<String, dynamic> eachSelectedItem =
            selectedCartListItemsInfo![index];
        return Container(
          margin: EdgeInsets.fromLTRB(16, index == 0 ? 16 : 8, 16,
              index == selectedCartListItemsInfo!.length - 1 ? 16 : 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 0),
                ),
              ]),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: FadeInImage(
                  height: 130,
                  width: 130,
                  fit: BoxFit.cover,
                  placeholder: const AssetImage('assets/images/noimg.jpg'),
                  image: NetworkImage(
                    eachSelectedItem["image"],
                  ),
                  imageErrorBuilder: (context, error, stackTraceError) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //name
                        Text(
                          eachSelectedItem["name"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        //Size + color
                        Text(
                          eachSelectedItem["size"]
                                  .replaceAll("[", "")
                                  .replaceAll("]", "") +
                              " - " +
                              eachSelectedItem["color"]
                                  .replaceAll("[", "")
                                  .replaceAll("]", ""),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 8),
                        //Qty
                        Text(
                          eachSelectedItem['quantity'].toString() +
                              " x" +
                              " Rp." +
                              eachSelectedItem["price"].toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ]),
                ),
              ),

              //quantity

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Rp.${eachSelectedItem["totalAmount"].toStringAsFixed(0)}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
