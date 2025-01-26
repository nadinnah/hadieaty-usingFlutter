import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../services/shared_preference.dart';
import '../models/gift.dart';

class GiftDetailsPage extends StatefulWidget {
  final Gift gift;

  GiftDetailsPage({required this.gift});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  late String name;
  late String description;
  late String category;
  late double price;
  late bool isPledged;
  File? imageFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    name = widget.gift.name;
    description = widget.gift.description ?? '';
    category = widget.gift.category ?? '';
    price = widget.gift.price ?? 0.0;
    isPledged = widget.gift.status == 'pledged';
  }


  pickImage() async {
    await requestPermissions();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final preferences = Provider.of<PreferencesService>(context, listen: false);
        final isDarkMode = preferences.isDarkMode;

        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xff1e1e1e) : const Color(0xffefefef),
          title: Text(
            "Select Image Source",
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await pickImageFromCamera();
              },
              child: Text(
                "Take a Picture",
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await pickImageFromGallery();
              },
              child: Text(
                "Choose from Gallery",
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> requestPermissions() async {
    await [Permission.camera, Permission.photos].request();
  }

  Future<void> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  void saveGift() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      widget.gift.name = name;
      widget.gift.description = description;
      widget.gift.category = category;
      widget.gift.price = price;
      widget.gift.status = isPledged ? 'pledged' : 'available';

      Navigator.pop(context, widget.gift);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = Provider.of<PreferencesService>(context);
    final isDarkMode = preferences.isDarkMode;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDarkMode ? const Color(0xff1e1e1e) : const Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xff1e1e1e) : const Color(0xffefefef),
        title: Text(
          "Gift Details",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Column(
                      children: [
                        imageFile == null
                            ? Image.asset(
                          'lib/assets/images/defaultGift.jpeg',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Image.file(
                          imageFile!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to select an image',
                          style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(
                      icon: Icon(Icons.card_giftcard, color: isDarkMode ? Colors.white : Colors.black),
                      hintText: "Gift Name",
                      hintStyle: const TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter the gift name";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value!;
                    },
                    enabled: !isPledged,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: description,
                    decoration: InputDecoration(
                      icon: Icon(Icons.description, color: isDarkMode ? Colors.white : Colors.black),
                      hintText: "Description",
                      hintStyle: const TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a description";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      description = value!;
                    },
                    enabled: !isPledged,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: category,
                    decoration: InputDecoration(
                      icon: Icon(Icons.category, color: isDarkMode ? Colors.white : Colors.black),
                      hintText: "Category",
                      hintStyle: const TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
                    style: const TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a category";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      category = value!;
                    },
                    enabled: !isPledged,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: price.toString(),
                    decoration: InputDecoration(
                      icon: Icon(Icons.attach_money, color: isDarkMode ? Colors.white : Colors.black),
                      hintText: "Price",
                      hintStyle: const TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
                    style: const TextStyle(color: Colors.black),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a price";
                      }
                      if (double.tryParse(value) == null) {
                        return "Please enter a valid number";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      price = double.parse(value!);
                    },
                    enabled: !isPledged,
                  ),
                  const SizedBox(height: 20),
                  if (!isPledged)
                    ElevatedButton(
                      onPressed: saveGift,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: isDarkMode ? Colors.grey : const Color(0xff273331),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Save Gift",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              child: Image.asset(
                'lib/assets/images/giftBoxes.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
