import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pos/api/api.dart';
import 'package:pos/users/model/order.dart';

class OrderDetail extends StatefulWidget {
  final Order? clickOrderInfo;

  OrderDetail({this.clickOrderInfo});

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  RxString _status = "BARU".obs;
  String get status => _status.value;

  updateStatus(String parcelStatus) {
    _status.value = parcelStatus;
  }

  showDialogForStatus() async {
    if (widget.clickOrderInfo!.status == "BARU") {
      var response = await Get.dialog(
        AlertDialog(
          title: const Text("Konfirmasi Pesanan"),
          content: const Text(
            "Apakah anda yakin ingin menerima pesanan ini?",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                "No",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back(result: "TERIMA");
              },
              child: Text(
                "Yes",
                style: TextStyle(
                  color: Colors.deepOrange,
                ),
              ),
            )
          ],
        ),
      );

      if (response == "TERIMA") {
        updateStatusValueInDatabase();
      }
    }
  }

  updateStatusValueInDatabase() async {
    try {
      var res = await http.post(
        Uri.parse(API.updateStatusOrders),
        body: {
          "order_id": widget.clickOrderInfo!.order_id.toString(),
        },
      );

      if (res.statusCode == 200) {
        var responseBody = jsonDecode(res.body);
        if (responseBody['success'] == true) {
          updateStatus("DIKIRIM");
        } else {
          Fluttertoast.showToast(msg: responseBody['message']);
        }
      } else {
        Fluttertoast.showToast(msg: "Server error: ${res.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  void iniState() {
    super.initState();
    updateStatus(widget.clickOrderInfo!.status.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 244, 244), //
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
        title: Text(
          "Order ID # ${widget.clickOrderInfo!.order_id.toString()}",
          style: TextStyle(
            color: Colors.white, // Warna teks
          ),
        ),
        backgroundColor: Colors.deepOrange,
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => {
                  if (status == 'BARU')
                    {
                      showDialogForStatus(),
                    }
                },
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Dikirim",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(() {
                        return status == "BARU"
                            ? const Icon(Icons.help_outline, color: Colors.red)
                            : const Icon(Icons.help_center_outlined,
                                color: Colors.green);
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: displayClickedOrderItems(),
              ),

              SizedBox(height: 15),
              // ✅ Container putih berbayangan untuk detail order
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Pemesan',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.deepOrange),
                    ),
                    const SizedBox(height: 15),
                    showTitleAndContent(
                      "Tanggal Pemesan",
                      DateFormat('dd MMMM yyyy').format(DateTime.parse(
                          widget.clickOrderInfo!.dateTime.toString())),
                    ),
                    const SizedBox(height: 15),
                    showTitleAndContent(
                        "No Telepon", widget.clickOrderInfo!.no_telepon ?? "-"),
                    const SizedBox(height: 15),
                    showTitleAndContent(
                        "Alamat", widget.clickOrderInfo!.alamat ?? "-"),
                    const SizedBox(height: 15),
                    showTitleAndContent("Pengiriman",
                        widget.clickOrderInfo!.deliverySystem ?? "-"),
                    const SizedBox(height: 15),
                    showTitleAndContent("Pembayaran",
                        widget.clickOrderInfo!.paymentSystem ?? "-"),
                    const SizedBox(height: 15),
                    showTitleAndContent(
                        "Catatan", widget.clickOrderInfo!.catatan ?? "-"),
                    const SizedBox(height: 15),
                    showTitleAndContent(
                      "Total",
                      "Rp. ${widget.clickOrderInfo!.totalAmount?.toStringAsFixed(0) ?? "0"}",
                    ),
                    const SizedBox(height: 24),
                    showTitle("Bukti Pembayaran :"),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FadeInImage(
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder:
                            const AssetImage('assets/images/noimg.jpg'),
                        image: NetworkImage(
                          API.hostImages + (widget.clickOrderInfo?.image ?? ""),
                        ),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showTitleAndContent(String titleText, String contentText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        showTitle(titleText),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: showContentTitle(contentText),
          ),
        ),
      ],
    );
  }

  Widget showContentTitle(String contentText) {
    return Text(
      contentText,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color.fromARGB(255, 0, 0, 0),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget showTitle(String titleText) {
    return Text(titleText,
        style: const TextStyle(
          fontSize: 16,
          color: Color.fromARGB(137, 104, 104, 104),
        ));
  }

  displayClickedOrderItems() {
    List<String> clickOrderItemsInfo =
        widget.clickOrderInfo!.selectedItems!.split("||");
    return Column(
      children: List.generate(clickOrderItemsInfo.length, (index) {
        Map<String, dynamic> itemInfo = jsonDecode(clickOrderItemsInfo[index]);
        return Container(
          margin: EdgeInsets.only(
            top: index == 0 ? 8 : 4,
            bottom: index == clickOrderItemsInfo.length - 1 ? 8 : 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 0),
              ),
            ],
          ),
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
                  image: NetworkImage(itemInfo["image"]),
                  imageErrorBuilder: (context, error, stackTraceError) {
                    return const Center(
                      child: Icon(Icons.broken_image_outlined),
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemInfo["name"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${itemInfo["size"].replaceAll("[", "").replaceAll("]", "")} - ${itemInfo["color"].replaceAll("[", "").replaceAll("]", "")}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${itemInfo['quantity']} x Rp.${itemInfo["price"].toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Rp.${itemInfo["totalAmount"].toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
