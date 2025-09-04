import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:pos/themes.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pos/users/fragments/cart/cart_list_screen.dart';
import 'package:pos/users/fragments/componets/card_info_home1.dart';
import 'package:pos/users/fragments/componets/card_info_home2.dart';
import 'package:pos/users/fragments/items/item_detail.dart';
import 'package:pos/users/fragments/items/seach_items.dart';
import 'package:pos/users/model/clothes.dart';
import 'package:http/http.dart' as http;
import 'package:pos/api/api.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Home extends StatelessWidget {
  TextEditingController searchController = TextEditingController();

  Future<List<Clothes>> getTrandingItems() async {
    List<Clothes> trendingClothItemList = [];

    try {
      var res = await http.post(Uri.parse(API.getTrendingPopuler));

      if (res.statusCode == 200) {
        var responseTreding = jsonDecode(res.body);
        if (responseTreding['success'] == true) {
          (responseTreding['clothItemData'] as List).forEach((eachRecord) {
            trendingClothItemList.add(Clothes.fromJson(eachRecord));
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Terjadi Kesalahan 200");
      }
    } catch (errorMsg) {
      print("Error:: " + errorMsg.toString());
    }

    return trendingClothItemList;
  }

  Future<List<Clothes>> getAllClothItems() async {
    List<Clothes> allClothItemList = [];

    try {
      var res = await http.post(Uri.parse(API.getAllClothItems));

      if (res.statusCode == 200) {
        var responseTreding = jsonDecode(res.body);
        if (responseTreding['success'] == true) {
          (responseTreding['clothItemData'] as List).forEach((eachRecord) {
            allClothItemList.add(Clothes.fromJson(eachRecord));
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Terjadi Kesalahan 200");
      }
    } catch (errorMsg) {
      print("Error:: " + errorMsg.toString());
    }

    return allClothItemList;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: const Color.fromARGB(
            255, 244, 244, 244), // ⬅️ Warna background halaman
        padding:
            const EdgeInsets.only(bottom: 24), // agar tidak terlalu mepet bawah
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            showSearchBarWidget(),

            const SizedBox(height: 16),

            // Paling Populer
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                'Paling Populer',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 64, 0),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),

            trendingPopulerClothItem(),

            const SizedBox(height: 24),

            // Koleksi Baru
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                'Koleksi Baru',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 64, 0),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),

            allItemWidget(context),

            // Tambahan info lain kalau ada
            // cardInfo(),
          ],
        ),
      ),
    );
  }

  Widget showSearchBarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TextField(
        style: const TextStyle(color: Colors.grey),
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Cari produk disini...',
          prefixIcon: IconButton(
            onPressed: () {
              Get.to(SearchItems(typeKeyWords: searchController.text));
            },
            icon: const Icon(
              Icons.search,
              color: Color.fromARGB(255, 255, 64, 0),
            ),
          ),
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 18,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              Get.to(() => CartListScreen());
            },
            icon: Icon(
              Icons.shopping_cart,
              color: Color.fromARGB(255, 255, 64, 0),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Color.fromARGB(255, 255, 64, 0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Color.fromARGB(255, 255, 64, 0),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget trendingPopulerClothItem() {
    return FutureBuilder(
      future: getTrandingItems(),
      builder: (context, AsyncSnapshot<List<Clothes>> dataSnapShot) {
        if (dataSnapShot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (dataSnapShot.data == null) {
          return const Center(
            child: Text("No Trending"),
          );
        }
        if (dataSnapShot.data!.length > 0) {
          return SizedBox(
            height: 260,
            child: ListView.builder(
              itemCount: dataSnapShot.data!.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                Clothes eachClothItemData = dataSnapShot.data![index];
                return GestureDetector(
                  onTap: () {
                    Get.to(() => ItemDetailScreen(itemInfo: eachClothItemData));
                    // Get.to(ItemDetail(itemInfo: eachClothItemData));
                  },
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.fromLTRB(
                      index == 0 ? 16 : 8,
                      10,
                      index == dataSnapShot.data!.length - 1 ? 16 : 8,
                      10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 255, 255, 255),
                      boxShadow: [
                        BoxShadow(
                          offset:
                              const Offset(0, 4), // Menggeser bayangan ke bawah
                          blurRadius: 8.0, // Membuat bayangan lebih lembut
                          spreadRadius:
                              1.0, // Menambah area penyebaran bayangan
                          color: Colors.grey.withOpacity(
                              0.2), // Warna abu-abu dengan transparansi
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: FadeInImage(
                            height: 150,
                            width: 200,
                            fit: BoxFit.cover,
                            placeholder:
                                const AssetImage('assets/images/noimg.jpg'),
                            image: NetworkImage(
                              eachClothItemData.image!,
                            ),
                            imageErrorBuilder:
                                (context, error, stackTraceError) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      eachClothItemData.name!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 5, 5, 5),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "\Rp.${eachClothItemData.price?.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  RatingBar.builder(
                                    initialRating:
                                        eachClothItemData.rating?.toDouble() ??
                                            0.0,
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
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "(" +
                                        eachClothItemData.rating.toString() +
                                        ")",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Center(
            child: Text("No Trending"),
          );
        }
      },
    );
  }

  allItemWidget(context) {
    return FutureBuilder(
        future: getAllClothItems(),
        builder: (context, AsyncSnapshot<List<Clothes>> dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (dataSnapShot.data == null) {
            return const Center(
              child: Text("No Trending"),
            );
          }

          if (dataSnapShot.data!.length > 0) {
            return ListView.builder(
                itemCount: dataSnapShot.data!.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  Clothes eachClothItemData = dataSnapShot.data![index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(
                          () => ItemDetailScreen(itemInfo: eachClothItemData));
                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(
                        16,
                        index == 0 ? 16 : 8,
                        16,
                        index == dataSnapShot.data!.length - 1 ? 16 : 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 255, 255, 255),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(
                                0, 0), // Menggeser bayangan ke bawah
                            blurRadius: 8.0, // Membuat bayangan lebih lembut
                            spreadRadius:
                                1.0, // Menambah area penyebaran bayangan
                            color: Colors.grey.withOpacity(
                                0.2), // Warna abu-abu dengan transparansi
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      //nama
                                      Expanded(
                                        child: Text(
                                          eachClothItemData.name!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      //price
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 0,
                                      right: 0,
                                    ),
                                    child: Text(
                                      "\Rp.${eachClothItemData.price?.toStringAsFixed(0)}",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  //tags
                                  Text(
                                    "Tags: \n" +
                                        eachClothItemData.tags
                                            .toString()
                                            .replaceAll("[", "")
                                            .replaceAll("]", ""),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 255, 64, 0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            child: FadeInImage(
                              height: 130,
                              width: 130,
                              fit: BoxFit.cover,
                              placeholder:
                                  const AssetImage('assets/images/noimg.jpg'),
                              image: NetworkImage(
                                eachClothItemData.image!,
                              ),
                              imageErrorBuilder:
                                  (context, error, stackTraceError) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                  ),
                                );
                              },
                            ),
                          ),

                          //price
                        ],
                      ),
                    ),
                  );
                });
          } else {
            return Center(
              child: Text("No data "),
            );
          }
        });
  }
}
