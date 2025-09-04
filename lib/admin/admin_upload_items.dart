import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/admin/admin_dashboard.dart';
import 'package:pos/admin/admin_get_all_orders.dart';
import 'package:pos/api/api.dart';
import 'package:pos/themes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AdminUpload extends StatefulWidget {
  const AdminUpload({super.key});

  @override
  State<AdminUpload> createState() => _AdminUploadState();
}

class _AdminUploadState extends State<AdminUpload> {
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImageXFile;

  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var ratingController = TextEditingController();
  var tagsController = TextEditingController();
  var priceController = TextEditingController();
  var sizesController = TextEditingController();
  var colorsController = TextEditingController();
  var descriptionController = TextEditingController();
  var imageLink = "";

  //default screen
  ambilGambar() async {
    pickedImageXFile = await _picker.pickImage(source: ImageSource.camera);

    // Navigator.pop(context);
    // Get.back();

    setState(() => pickedImageXFile);
  }

  pickImageGaleri() async {
    pickedImageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {}); // <-- Tambahkan ini
  }

  showDialogBoxFromImage() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: const Color.fromARGB(255, 36, 36, 36),
            title: const Text(
              'Upload Image',
              style: TextStyle(color: Colors.white),
            ),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  ambilGambar();
                },
                child: const Text(
                  "Ambil gambar dari kamera",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  pickImageGaleri();
                },
                child: const Text(
                  "Pilih dari galeri HP",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              )
            ],
          );
        });
  }
  //end default screen

  Widget defaultScreen() {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.white), // <--- ini bikin ikon back jadi putih
        title: Text(
          'Upload Produk',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 6,
                blurRadius: 6,
                offset: Offset(0, -4),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.topRight,
              stops: [0.1, 0.8, 1],
              colors: [redColor, redColor, yellowColor],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.centerLeft,
            //   end: Alignment.topRight,
            //   stops: [0.1, 0.8, 1],
            //   colors: [redColor, redColor, yellowColor],
            // ),
            ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_photo_alternate,
                color: Colors.grey,
                size: 200,
              ),
              Material(
                color: redColor,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: () {
                    showDialogBoxFromImage();
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 28,
                    ),
                    child: Text(
                      'Upload Gambar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  uploadItemImage() async {
    if (pickedImageXFile == null) {
      Fluttertoast.showToast(msg: 'Silakan pilih gambar terlebih dahulu.');
      return;
    }

    try {
      var requestImgurApi = http.MultipartRequest(
        "POST",
        Uri.parse("https://api.imgur.com/3/image"),
      );

      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      requestImgurApi.fields["title"] = imageName;
      requestImgurApi.headers["Authorization"] = "Client-ID 8e4ea620dcd89ed";

      var imageFile = await http.MultipartFile.fromPath(
        'image',
        pickedImageXFile!.path,
        filename: imageName,
      );

      requestImgurApi.files.add(imageFile);
      var responseFromImgurApi = await requestImgurApi.send();
      var responseDataFromImgurApi =
          await responseFromImgurApi.stream.toBytes();
      var resultFromImgurApi = String.fromCharCodes(responseDataFromImgurApi);
      Map<String, dynamic> jsonRes = jsonDecode(resultFromImgurApi);

      if (jsonRes['success'] == true) {
        imageLink = jsonRes["data"]["link"];
        saveItem();
      } else {
        Fluttertoast.showToast(msg: "Gagal upload gambar.");
      }
    } catch (e) {
      print("Upload Error: $e");
      Fluttertoast.showToast(msg: "Terjadi kesalahan saat upload gambar.");
    }
  }

  saveItem() async {
    List<String> tagsList = tagsController.text.split(','); //dipisah otomatis
    List<String> sizesList = sizesController.text.split(','); //dipisah otomatis
    List<String> colorsList =
        colorsController.text.split(','); //red, white, black

    try {
      var response = await http.post(
        Uri.parse(API.uploadNewItem),
        body: {
          "item_id": '1',
          "name": nameController.text.trim().toString(),
          "rating": ratingController.text.trim().toString(),
          "tags": tagsList.toString(),
          "price": priceController.text.trim().toString(),
          "sizes": sizesList.toString(),
          "colors": colorsList.toString(),
          "description": descriptionController.text.trim().toString(),
          "image": imageLink.toString(),
        },
      );
      if (response.statusCode == 200) {
        var resBodyUloadItem = jsonDecode(response.body);
        if (resBodyUloadItem['success'] == true) {
          Fluttertoast.showToast(msg: 'Data item berhasil ditambahkan!');
          setState(() {
            pickedImageXFile = null;
          });

          Get.offAll(() =>
              AdminDashboard()); // <-- arahkan ke halaman list order, bukan upload ulang
        } else {
          Fluttertoast.showToast(msg: 'Data item gagal ditambahkan!');
        }
      } else {
        Fluttertoast.showToast(msg: 'Status is not 200');
      }
    } catch (errorMsg) {
      print("Error::" + errorMsg.toString());
    }
  }

  Widget uploadItemFromScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, //menghilangkan icon back
        title: const Text(
          'Upload Form',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              setState(() {
                pickedImageXFile = null;
                nameController.clear();
                ratingController.clear();
                tagsController.clear();
                priceController.clear();
                sizesController.clear();
                colorsController.clear();
                descriptionController.clear();
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminUpload()),
              );
            },
            icon: const Icon(
              Icons.clear,
              color: Colors.white,
            )),
        actions: [
          TextButton(
              onPressed: () {
                Fluttertoast.showToast(msg: "Sedang Upload...");
                uploadItemImage();
              },
              child: const Text(
                "Selesai",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ))
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 6,
                blurRadius: 6,
                offset: Offset(0, -4),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.topRight,
              stops: [0.1, 0.8, 1],
              colors: [redColor, redColor, yellowColor],
            ),
          ),
        ),
      ),
      backgroundColor: whiteColor,
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              image: pickedImageXFile != null
                  ? DecorationImage(
                      image: FileImage(File(pickedImageXFile!.path)),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(15),
            ),
            child: pickedImageXFile == null
                ? const Icon(Icons.image, size: 100, color: Colors.grey)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                child: Column(
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          //nama
                          TextFormField(
                            controller: nameController,
                            validator: (val) =>
                                val == "" ? "Masukan nama" : null,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  color: Color.fromARGB(255, 62, 0, 0),
                                  fontStyle: FontStyle.italic),
                              prefixIcon: const Icon(
                                Icons.title,
                                color: Colors.black,
                              ),
                              hintText: "Masukan nama",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          //rating
                          TextFormField(
                            controller: ratingController,
                            validator: (val) =>
                                val == "" ? "Masukan rating" : null,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  color: Color.fromARGB(255, 62, 0, 0),
                                  fontStyle: FontStyle.italic),
                              prefixIcon: const Icon(
                                Icons.rate_review,
                                color: Colors.black,
                              ),
                              hintText: "Masukan rating",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),

                          //tags
                          TextFormField(
                            controller: tagsController,
                            validator: (val) =>
                                val == "" ? "Masukan tag" : null,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  color: Color.fromARGB(255, 62, 0, 0),
                                  fontStyle: FontStyle.italic),
                              prefixIcon: const Icon(
                                Icons.tag,
                                color: Colors.black,
                              ),
                              hintText: "Masukan tag",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),

                          //price
                          TextFormField(
                            controller: priceController,
                            validator: (val) =>
                                val == "" ? "Masukan harga" : null,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  color: Color.fromARGB(255, 62, 0, 0),
                                  fontStyle: FontStyle.italic),
                              prefixIcon: const Icon(
                                Icons.price_change_outlined,
                                color: Colors.black,
                              ),
                              hintText: "Masukan harga",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),

                          //size
                          TextFormField(
                            controller: sizesController,
                            validator: (val) =>
                                val == "" ? "Masukan ukuran" : null,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  color: Color.fromARGB(255, 62, 0, 0),
                                  fontStyle: FontStyle.italic),
                              prefixIcon: const Icon(
                                Icons.picture_in_picture,
                                color: Colors.black,
                              ),
                              hintText: "Masukan ukuran",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),

                          //color
                          TextFormField(
                            controller: colorsController,
                            validator: (val) =>
                                val == "" ? "Masukan warna" : null,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  color: Color.fromARGB(255, 62, 0, 0),
                                  fontStyle: FontStyle.italic),
                              prefixIcon: const Icon(
                                Icons.color_lens,
                                color: Colors.black,
                              ),
                              hintText: "Masukan warna",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),

                          //description
                          TextFormField(
                            controller: descriptionController,
                            validator: (val) =>
                                val == "" ? "Masukan deskripsi" : null,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  color: Color.fromARGB(255, 62, 0, 0),
                                  fontStyle: FontStyle.italic),
                              prefixIcon: const Icon(
                                Icons.description,
                                color: Colors.black,
                              ),
                              hintText: "Masukan deskripsi",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          //button upload
                          Material(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              onTap: () {
                                if (formKey.currentState!.validate()) {
                                  Fluttertoast.showToast(
                                    msg: "Uploading...",
                                  );
                                  uploadItemImage();
                                }
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 28,
                                ),
                                child: Text(
                                  'Upload',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pickedImageXFile == null ? defaultScreen() : uploadItemFromScreen();
  }
}
