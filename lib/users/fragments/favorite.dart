import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:pos/users/model/clothes.dart';
import 'package:pos/users/model/favorite.dart';
import 'package:pos/users/userPreferences/current_user.dart';
import 'package:pos/users/fragments/items/item_detail.dart';
import 'package:pos/api/api.dart';
import 'package:http/http.dart' as http;

class FavoriteListScreen extends StatefulWidget {
  @override
  State<FavoriteListScreen> createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends State<FavoriteListScreen> {
  final currentOnlineUser = Get.put(CurrentUser());

  late Future<List<Favorite>> _favoriteListFuture;

  @override
  void initState() {
    super.initState();
    _favoriteListFuture = getCurrentUserFavoriteList();
  }

  Future<void> _reloadFavorites() async {
    setState(() {
      _favoriteListFuture = getCurrentUserFavoriteList();
    });
  }

  Future<List<Favorite>> getCurrentUserFavoriteList() async {
    List<Favorite> favoriteListOfCurrentUser = [];
    late Future<List<Favorite>> _favoriteListFuture;

    @override
    void initState() {
      super.initState();
      _favoriteListFuture = getCurrentUserFavoriteList();
    }

    Future<void> _reloadFavorites() async {
      setState(() {
        _favoriteListFuture = getCurrentUserFavoriteList();
      });
    }

    try {
      var res = await http.post(
        Uri.parse(API.readFavoriteList),
        body: {
          "user_id": currentOnlineUser.user.user_id.toString(),
        },
      );

      if (res.statusCode == 200) {
        var responseBodyOfCurrentUserFavoriteListItems = jsonDecode(res.body);

        if (responseBodyOfCurrentUserFavoriteListItems['success'] == true) {
          (responseBodyOfCurrentUserFavoriteListItems['currentUserFavoriteData']
                  as List)
              .forEach((eachFavoriteItemRecord) {
            favoriteListOfCurrentUser
                .add(Favorite.fromJson(eachFavoriteItemRecord));
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Status Code is not 200");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Terjadi Kesalahan: $error");
    }
    return favoriteListOfCurrentUser;
  }

  void _showToast(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 244, 244, 244), // ini untuk background halaman
      body: RefreshIndicator(
        backgroundColor: Colors.deepOrange, // ini untuk loading circle refresh
        onRefresh: _reloadFavorites,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 8, 8),
                  child: Text(
                    "Favorite",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                _UserFavoriteList(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _UserFavoriteList(BuildContext context) {
    return FutureBuilder(
        future: _favoriteListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Masih Kosong"));
          }

          List<Favorite> favorites = snapshot.data!;

          return ListView.builder(
              itemCount: favorites.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                Favorite eachFavoriteItemRecord = favorites[index];

                Clothes clickedItemInfo = Clothes(
                  item_id: eachFavoriteItemRecord.item_id,
                  name: eachFavoriteItemRecord.name,
                  price: eachFavoriteItemRecord.price,
                  image: eachFavoriteItemRecord.image,
                  description: eachFavoriteItemRecord.description,
                  sizes: eachFavoriteItemRecord.sizes,
                  colors: eachFavoriteItemRecord.colors,
                  tags: eachFavoriteItemRecord.tags,
                  rating: eachFavoriteItemRecord.rating,
                );
                return GestureDetector(
                  onTap: () {
                    Get.to(ItemDetailScreen(itemInfo: clickedItemInfo));
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                      16,
                      index == 0 ? 16 : 8,
                      16,
                      index == favorites.length - 1 ? 16 : 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 255, 255, 255),
                      boxShadow: [
                        BoxShadow(
                          offset:
                              const Offset(0, 0), // Menggeser bayangan ke bawah
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
                                        eachFavoriteItemRecord.name!,
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
                                        eachFavoriteItemRecord.price.toString(),
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
                                      eachFavoriteItemRecord.tags
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
                              eachFavoriteItemRecord.image!,
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
        });
  }
}
