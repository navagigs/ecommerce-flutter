import 'package:get/get.dart';

class ItemDetailController extends GetxController {
  final RxInt _quantityItem = 1.obs;
  final RxInt _sizeItem = 0.obs;
  final RxInt _colorItem = 0.obs;
  final RxBool _isFavorite = false.obs;

  // Getters
  int get quantity => _quantityItem.value;
  int get size => _sizeItem.value;
  int get color => _colorItem.value;
  bool get isFavorite => _isFavorite.value;

  // Setters
  void setQuantityItem(int value) => _quantityItem.value = value;
  void setSizeItem(int value) => _sizeItem.value = value;
  void setColorItem(int value) => _colorItem.value = value;
  void setIsFavorite(bool value) => _isFavorite.value = value;

  // Opsional: reset semua jika dibutuhkan
  void reset() {
    _quantityItem.value = 1;
    _sizeItem.value = 0;
    _colorItem.value = 0;
    _isFavorite.value = false;
  }
}
