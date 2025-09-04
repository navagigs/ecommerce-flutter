class Order {
  int? order_id;
  int? user_id;
  String? selectedItems;
  String? deliverySystem;
  String? paymentSystem;
  String? catatan;
  double? totalAmount;
  String? status;
  DateTime? dateTime;
  String? image;
  String? no_telepon;
  String? alamat;

  Order({
    this.order_id,
    this.user_id,
    this.selectedItems,
    this.deliverySystem,
    this.paymentSystem,
    this.catatan,
    this.totalAmount,
    this.status,
    this.dateTime,
    this.no_telepon,
    this.image,
    this.alamat,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        order_id: int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
        user_id: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
        selectedItems: json['selectedItems']?.toString() ?? '',
        deliverySystem: json['deliverySystem']?.toString() ?? '',
        paymentSystem: json['paymentSystem']?.toString() ?? '',
        catatan: json['catatan']?.toString() ?? '',
        totalAmount:
            double.tryParse(json['totalAmount']?.toString() ?? '') ?? 0.0,
        status: json['status']?.toString() ?? '',
        dateTime: DateTime.tryParse(json['dateTime']?.toString() ?? '') ??
            DateTime.now(),
        no_telepon: json['no_telepon']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        alamat: json['alamat']?.toString() ?? '',
      );

  Map<String, dynamic> toJson(String imageBase64) => {
        'user_id': user_id.toString(),
        'selectedItems': selectedItems,
        'deliverySystem': deliverySystem,
        'paymentSystem': paymentSystem,
        'catatan': catatan,
        'totalAmount': totalAmount!.toStringAsFixed(2),
        'status': status,
        'dateTime':
            dateTime!.toIso8601String(), // opsional jika digunakan di DB
        'no_telepon': no_telepon,
        'alamat': alamat,
        'image': image,
        'imageFile': imageBase64,
      };
}
