import 'package:pos/users/model/cart.dart';
import 'package:get/get.dart';

class CartListController extends GetxController {
  RxList<Cart> cartList = <Cart>[].obs;
  RxList<int> selectedItemList = <int>[].obs;
  RxDouble total = 0.0.obs;
  RxBool isSelectedAll = false.obs;

  void setList(List<Cart> list) {
    cartList.assignAll(list);
    setIsSelectedAllItems(); // selalu perbarui status "Pilih Semua"
  }

  void addSelectedItem(int id) {
    if (!selectedItemList.contains(id)) {
      selectedItemList.add(id);
    }
    setIsSelectedAllItems();
  }

  void deleteSelectedItem(int id) {
    selectedItemList.remove(id);
    setIsSelectedAllItems();
  }

  void clearAllSelectedItems() {
    selectedItemList.clear();
    setIsSelectedAllItems();
  }

  void setTotal(double value) {
    total.value = value;
  }

  void setIsSelectedAllItems() {
    isSelectedAll.value =
        selectedItemList.length == cartList.length && cartList.isNotEmpty;
  }
}
