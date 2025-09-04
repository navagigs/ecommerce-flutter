import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/themes.dart';
import 'package:pos/users/fragments/cart/cart_list_screen.dart';
import 'package:pos/users/model/clothes.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pos/users/controllers/item_detail_controller.dart';

import 'package:pos/api/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pos/users/userPreferences/current_user.dart';

class ItemDetailScreen extends StatefulWidget {
  final Clothes? itemInfo;
  ItemDetailScreen({
    this.itemInfo,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final ItemDetailController itemDetailController =
      Get.put(ItemDetailController());
  final currentOnlineUser = Get.put(CurrentUser());

  addItemToCart() async {
    try {
      var res = await http.post(
        Uri.parse(API.addToCart),
        body: {
          'user_id': currentOnlineUser.user.user_id.toString(),
          'item_id': widget.itemInfo!.item_id.toString(),
          'quantity': itemDetailController.quantity.toString(),
          'color': widget.itemInfo!.colors![itemDetailController.color],
          'size': widget.itemInfo!.sizes![itemDetailController.size],
        },
      );
      if (res.statusCode == 200) {
        var resBodyAddToCart = jsonDecode(res.body);
        if (resBodyAddToCart['success'] == true) {
          Fluttertoast.showToast(msg: "Ditambahkan ke keranjang!");
        } else {
          Fluttertoast.showToast(msg: "Gagal Ditambahkan ke keranjang!");
        }
      } else {
        Fluttertoast.showToast(msg: "Status is not 200");
      }
    } catch (errorMsg) {
      print("Error::" + errorMsg.toString());
    }
  }

  validateFavorite() async {
    try {
      var resFavorite = await http.post(
        Uri.parse(API.validateFavorite),
        body: {
          'user_id': currentOnlineUser.user.user_id.toString(),
          'item_id': widget.itemInfo!.item_id.toString(),
        },
      );
      if (resFavorite.statusCode == 200) {
        var resBody = jsonDecode(resFavorite.body);
        bool found = resBody['favoriteFound'] == true;
        itemDetailController.setIsFavorite(found); // ✔ gunakan nilai sebenarnya
      } else {
        Fluttertoast.showToast(msg: "Gagal cek status favorite.");
      }
    } catch (e) {
      print("validateFavorite() error: $e");
    }
  }

  addItemFavorite() async {
    try {
      var res = await http.post(
        Uri.parse(API.addFavorite),
        body: {
          'user_id': currentOnlineUser.user.user_id.toString(),
          'item_id': widget.itemInfo!.item_id.toString(),
        },
      );

      if (res.statusCode == 200) {
        var body = jsonDecode(res.body);
        if (body['success'] == true) {
          Fluttertoast.showToast(msg: "Ditambahkan ke favorite!");
          itemDetailController.setIsFavorite(true); // Langsung ubah status
        } else {
          Fluttertoast.showToast(msg: "Gagal menambahkan ke favorite!");
        }
      } else {
        Fluttertoast.showToast(msg: "Status is not 200");
      }
    } catch (e) {
      print("addItemFavorite() error: $e");
    }
  }

  deleteItemFavorite() async {
    try {
      var res = await http.post(
        Uri.parse(API.deleteFavorite),
        body: {
          'user_id': currentOnlineUser.user.user_id.toString(),
          'item_id': widget.itemInfo!.item_id.toString(),
        },
      );

      if (res.statusCode == 200) {
        var body = jsonDecode(res.body);
        if (body['success'] == true) {
          Fluttertoast.showToast(msg: "Menghapus favorite!");
          itemDetailController.setIsFavorite(false);
        } else {
          Fluttertoast.showToast(msg: "Gagal menghapus favorite!");
        }
      } else {
        Fluttertoast.showToast(msg: "Status is not 200");
      }
    } catch (e) {
      print("deleteItemFavorite() error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    validateFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gambar utama
          FadeInImage(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            placeholder: const AssetImage('assets/images/noimg.jpg'),
            image: NetworkImage(
              widget.itemInfo!.image!,
            ),
            imageErrorBuilder: (context, error, stackTraceError) {
              return const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                ),
              );
            },
          ),
          // Tombol back
          Positioned(
            top: 40,
            left: 10,
            right: 10, // Tambahkan batas kanan untuk Row
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.deepOrange,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Spacer(),
                Obx(
                  () => IconButton(
                    onPressed: () {
                      if (itemDetailController.isFavorite == true) {
                        deleteItemFavorite();
                      } else {
                        addItemFavorite();
                      }
                    },
                    icon: Icon(
                      itemDetailController.isFavorite
                          ? Icons.bookmark
                          : Icons.bookmark_border_outlined,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.to(CartListScreen());
                  },
                  icon: Icon(
                    itemDetailController.isFavorite
                        ? Icons.shopping_cart
                        : Icons.shopping_cart_outlined,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ),

          // Konten informasi item
          Align(
            alignment: Alignment.bottomCenter,
            child: itemInfoWidget(),
          ),
        ],
      ),
    );
  }

  itemInfoWidget() {
    return Container(
      height: MediaQuery.of(Get.context!).size.height * 0.6,
      width: MediaQuery.of(Get.context!).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -1),
            blurRadius: 6,
            color: Colors.grey,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        // Membungkus dengan SingleChildScrollView untuk scroll jika konten meluap
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 8,
                width: 140,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 64, 0),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.itemInfo!.name!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 2,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RatingBar.builder(
                            initialRating: widget.itemInfo!.rating!,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (updateRating) {},
                            ignoreGestures: true,
                            unratedColor: Colors.grey,
                            itemSize: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "(${widget.itemInfo!.rating})",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.itemInfo!.tags
                            .toString()
                            .replaceAll("[", "")
                            .replaceAll("]", ""),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 255, 64, 0),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 0,
                          right: 0,
                        ),
                        child: Text(
                          "\Rp." + widget.itemInfo!.price.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (itemDetailController.quantity > 1) {
                                itemDetailController.setQuantityItem(
                                    itemDetailController.quantity - 1);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Quantity Tidak Boleh Kurang Dari 1");
                              }
                            },
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(
                              width: 10), // Jarak antara tombol dan angka
                          Text(
                            itemDetailController.quantity.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              width: 10), // Jarak antara angka dan tombol

                          IconButton(
                            onPressed: () {
                              itemDetailController.setQuantityItem(
                                  itemDetailController.quantity + 1);
                            },
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              "Size : ",
              style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 255, 64, 0),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 4,
            ),
            Wrap(
              runSpacing: 8,
              spacing: 8,
              children: List.generate(
                widget.itemInfo!.sizes!.length,
                (index) {
                  return Obx(
                    () => GestureDetector(
                      onTap: () {
                        itemDetailController.setSizeItem(index);
                      },
                      child: Container(
                        height: 35,
                        width: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: itemDetailController.size == index
                                ? Color.fromARGB(255, 255, 64, 0)
                                : Color.fromARGB(255, 255, 64, 0),
                          ),
                          color: itemDetailController.size == index
                              ? Color.fromARGB(255, 255, 64, 0).withOpacity(0.4)
                              : Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.itemInfo!.sizes![index]
                              .replaceAll("[", "")
                              .replaceAll("]", ""),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              "Color : ",
              style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 255, 64, 0),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 4,
            ),
            Wrap(
              runSpacing: 8,
              spacing: 8,
              children: List.generate(
                widget.itemInfo!.colors!.length,
                (index) {
                  return Obx(
                    () => GestureDetector(
                      onTap: () {
                        itemDetailController.setColorItem(index);
                      },
                      child: Container(
                        height: 35,
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: itemDetailController.color == index
                                ? Color.fromARGB(255, 255, 64, 0)
                                : Color.fromARGB(255, 255, 64, 0),
                          ),
                          color: itemDetailController.color == index
                              ? Color.fromARGB(255, 255, 64, 0).withOpacity(0.4)
                              : Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.itemInfo!.colors![index]
                              .replaceAll("[", "")
                              .replaceAll("]", ""),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Description : ",
              style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 255, 64, 0),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              widget.itemInfo!.description!,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Material(
              elevation: 4,
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  addItemToCart();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  child: Text(
                    "Keranjang",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
