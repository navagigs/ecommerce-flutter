import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pos/api/api.dart';
import 'package:pos/users/fragments/cart/cart_list_screen.dart';
import 'package:pos/users/fragments/items/item_detail.dart';
import 'package:pos/users/model/clothes.dart';

class SearchItems extends StatefulWidget {
  final String? typeKeyWords;

  SearchItems({
    this.typeKeyWords,
  });
  @override
  State<SearchItems> createState() => _SearchItemsState();
}

class _SearchItemsState extends State<SearchItems> {
  TextEditingController searchController = TextEditingController();

  Future<List<Clothes>> readSearchResult() async {
    List<Clothes> clothesSearchList = [];

    if (searchController.text.isNotEmpty) {
      try {
        var res = await http.post(
          Uri.parse(API.searchItem),
          body: {
            "typedKeyWords": searchController.text,
          },
        );

        if (res.statusCode == 200) {
          var responseBodyOfSearchListItems = jsonDecode(res.body);

          if (responseBodyOfSearchListItems['success'] == true) {
            (responseBodyOfSearchListItems['clothItemData'] as List)
                .forEach((eachSearchItem) {
              clothesSearchList.add(Clothes.fromJson(eachSearchItem));
            });
          }
        } else {
          Fluttertoast.showToast(msg: "Status Code is not 200");
        }
      } catch (error) {
        Fluttertoast.showToast(msg: "Terjadi Kesalahan: $error");
      }
    }
    return clothesSearchList;
  }

  void initState() {
    super.initState();
    searchController.text = widget.typeKeyWords!;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => {Navigator.pop(context)}),
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 2),
            Expanded(child: showSearchBarWidget()), // Memperlebar
            const SizedBox(width: 10),
          ],
        ),
      ),
      body: searchItemWidget(context),
    );
  }

  Widget showSearchBarWidget() {
    return TextField(
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
            searchController.clear();
            setState(() {});
          },
          icon: const Icon(
            Icons.close,
            color: Color.fromARGB(255, 255, 64, 0),
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Color.fromARGB(255, 255, 64, 0),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Color.fromARGB(255, 255, 64, 0),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  searchItemWidget(context) {
    return FutureBuilder(
        future: readSearchResult(),
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
                                      "\Rp." +
                                          eachClothItemData.price.toString(),
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
