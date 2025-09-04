import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:pos/users/controllers/cart_list_controller.dart';
import 'package:pos/users/fragments/order/order_now_screen.dart';
import 'package:pos/users/model/cart.dart';
import 'package:pos/users/model/clothes.dart';
import 'package:pos/users/userPreferences/current_user.dart';
import 'package:pos/users/fragments/items/item_detail.dart';
import 'package:pos/api/api.dart';
import 'package:http/http.dart' as http;

class CartListScreen extends StatefulWidget {
  const CartListScreen({super.key});

  @override
  State<CartListScreen> createState() => _CartListScreenState();
}

class _CartListScreenState extends State<CartListScreen> {
  final currentOnlineUser = Get.put(CurrentUser());
  final cartListController = Get.put(CartListController());

  getCurrentUserCartList() async {
    List<Cart> cartListOfCurrentUser = [];
    try {
      var res = await http.post(
        Uri.parse(API.getCartList),
        body: {
          "currentOnlineUserId": currentOnlineUser.user.user_id.toString(),
        },
      );

      if (res.statusCode == 200) {
        final responseBody = jsonDecode(res.body);

        if (responseBody['success'] == true) {
          (responseBody['cartData'] as List).forEach((eachCurrentUserCartItem) {
            cartListOfCurrentUser.add(Cart.fromJson(eachCurrentUserCartItem));
          });
        } else {
          Fluttertoast.showToast(
              msg: responseBody['message'] ?? "Keranjang kosong!");
        }

        cartListController.setList(cartListOfCurrentUser);
      } else {
        throw Exception("Server error: ${res.statusCode}");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Terjadi Kesalahan: $error");
    }
  }

  calculateTotalAmount() {
    cartListController.setTotal(0);
    if (cartListController.selectedItemList.length > 0) {
      cartListController.cartList.forEach((itemInCart) {
        if (cartListController.selectedItemList.contains(itemInCart.cart_id)) {
          double eachItemTotalAmount = (itemInCart.price!) *
              (double.parse(itemInCart.quantity.toString()));

          cartListController
              .setTotal(cartListController.total.value + eachItemTotalAmount);
        }
      });
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
          getCurrentUserCartList();
        }
      } else {
        Fluttertoast.showToast(msg: "Terjadi Kesalahan ${res.statusCode}");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Errpr:" + error.toString());
    }
  }

  Future<void> updateQuantityInUserCart(int cartId, int newQty) async {
    try {
      var res = await http.post(
        Uri.parse(API.updateQuantity),
        body: {
          'cart_id': cartId.toString(),
          'quantity': newQty.toString(),
        },
      );

      if (res.statusCode == 200) {
        var responseBodyQuantity = jsonDecode(res.body);
        if (responseBodyQuantity['success'] == true) {
          // Refresh cart list
          getCurrentUserCartList();
        } else {
          Fluttertoast.showToast(msg: responseBodyQuantity['message']);
        }
      } else {
        Fluttertoast.showToast(msg: "Server error: ${res.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  List<Map<String, dynamic>> getSelectedCartListItemInformation() {
    List<Map<String, dynamic>> selectedCartListItemInformation = [];

    if (cartListController.selectedItemList.length > 0) {
      cartListController.cartList.forEach((selectedCartListItem) {
        if (cartListController.selectedItemList
            .contains(selectedCartListItem.cart_id)) {
          Map<String, dynamic> itemInformation = {
            'item_id': selectedCartListItem.item_id,
            'name': selectedCartListItem.name,
            'image': selectedCartListItem.image,
            'price': selectedCartListItem.price,
            'size': selectedCartListItem.size,
            'color': selectedCartListItem.color,
            'quantity': selectedCartListItem.quantity,
            'totalAmount':
                selectedCartListItem.price! * selectedCartListItem.quantity!,
          };
          selectedCartListItemInformation.add(itemInformation);
        }
      });
    }
    return selectedCartListItemInformation;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserCartList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
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
          "Keranjang",
          style: TextStyle(
            color: Colors.white, // Warna teks
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        actions: [
          Obx(
            () => IconButton(
              onPressed: () {
                if (cartListController.isSelectedAll.value) {
                  cartListController.clearAllSelectedItems();
                } else {
                  for (var item in cartListController.cartList) {
                    cartListController.addSelectedItem(item.cart_id!);
                  }
                }
                calculateTotalAmount();
              },
              icon: Icon(
                cartListController.isSelectedAll.value
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: Colors.white,
              ),
            ),
          ),
          Obx(() {
            final isEnabled = cartListController.selectedItemList.isNotEmpty;
            return IconButton(
              onPressed: isEnabled
                  ? () async {
                      var result = await Get.dialog(AlertDialog(
                        title: const Text("Delete"),
                        content: const Text("Hapus semua item yang dipilih?"),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text("Batal"),
                          ),
                          TextButton(
                            onPressed: () => Get.back(result: "yesDelete"),
                            child: const Text("Hapus"),
                          ),
                        ],
                      ));

                      if (result == "yesDelete") {
                        for (var id
                            in cartListController.selectedItemList.toList()) {
                          await deleteSelectedItemFromCartList(id);
                        }
                        cartListController.clearAllSelectedItems();
                        calculateTotalAmount();
                      }
                    }
                  : null, // tombol disabled jika tidak ada item
              icon: Icon(
                Icons.delete_sweep,
                size: 26,
                color: isEnabled ? Colors.white : Colors.deepOrange,
              ),
            );
          })
        ],
      ),
      body: Obx(
        () => cartListController.cartList.length > 0
            ? ListView.builder(
                itemCount: cartListController.cartList.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  Cart cartModel = cartListController.cartList[index];
                  Clothes clothesModel = Clothes(
                    item_id: cartModel.item_id,
                    name: cartModel.name,
                    price: cartModel.price,
                    image: cartModel.image,
                    description: cartModel.description,
                    sizes: cartModel.sizes,
                    rating: cartModel.rating,
                    colors: cartModel.colors,
                    tags: cartModel.tags,
                  );
                  return Container(
                    margin: EdgeInsets.fromLTRB(
                      12,
                      index == 0 ? 12 : 6,
                      12,
                      index == cartListController.cartList.length - 1 ? 12 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.3), blurRadius: 4)
                      ],
                    ),
                    child: Row(children: [
                      //checkbox
                      Obx(
                        () => IconButton(
                          onPressed: () {
                            if (cartListController.selectedItemList
                                .contains(cartModel.cart_id)) {
                              cartListController
                                  .deleteSelectedItem(cartModel.cart_id!);
                            } else {
                              cartListController
                                  .addSelectedItem(cartModel.cart_id!);
                            }
                            calculateTotalAmount();
                          },
                          icon: Icon(
                            cartListController.selectedItemList
                                    .contains(cartModel.cart_id)
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),

                      Expanded(
                        child: ListTile(
                          onTap: () {
                            Get.to(ItemDetailScreen(itemInfo: clothesModel));
                          },
                          contentPadding: const EdgeInsets.all(6),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FadeInImage(
                              height: 100,
                              width: 70,
                              fit: BoxFit.cover,
                              placeholder:
                                  const AssetImage('assets/images/noimg.jpg'),
                              image: NetworkImage(cartModel.image ?? ""),
                              imageErrorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                          title: Text(
                            clothesModel.name ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Color: ${cartModel.color?.replaceAll('[', '').replaceAll(']', '')}\n"
                                      "Size: ${cartModel.size?.replaceAll('[', '').replaceAll(']', '')}",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10,
                                        top: 10), // Atur jarak dari kanan
                                    child: Text(
                                      "\Rp.${cartModel.price?.toStringAsFixed(0)}",
                                      // "Rp.${cartModel.price}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if ((cartModel.quantity!) > 1) {
                                        updateQuantityInUserCart(
                                          cartModel.cart_id!,
                                          cartModel.quantity! - 1,
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 24),
                                  ),
                                  Text("${cartModel.quantity}"),
                                  IconButton(
                                    onPressed: () {
                                      updateQuantityInUserCart(
                                        cartModel.cart_id!,
                                        cartModel.quantity! + 1,
                                      );
                                    },
                                    icon: const Icon(Icons.add_circle_outline,
                                        size: 24),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ]),
                  );
                })
            : const Center(
                child: Text("Keranjang Kosong"),
              ),
      ),
      bottomNavigationBar: GetBuilder<CartListController>(
        init: CartListController(),
        builder: (c) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Label dan Nilai Total Bayar
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Bayar:",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    // const SizedBox(height: 1),
                    Obx(() => Text(
                          "Rp.${cartListController.total.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )),
                  ],
                ),

                // Tombol Checkout
                ElevatedButton(
                  onPressed: () {
                    cartListController.selectedItemList.length > 0
                        ? Get.to(OrderNowScreen(
                            selectedCartListItemsInfo:
                                getSelectedCartListItemInformation(),
                            totalAmount: cartListController.total.value,
                            selectCartIDs: cartListController.selectedItemList))
                        : null;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Checkout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
