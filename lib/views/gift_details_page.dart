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

  late String _name;
  late String _description;
  late String _category;
  late double _price;
  late bool _isPledged;
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name = widget.gift.name;
    _description = widget.gift.description ?? '';
    _category = widget.gift.category ?? '';
    _price = widget.gift.price ?? 0.0;
    _isPledged = widget.gift.status == 'pledged';
  }

  Future<void> _pickImage() async {
    await _requestPermissions();

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
                await _pickImageFromCamera();
              },
              child: Text(
                "Take a Picture",
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _pickImageFromGallery();
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

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.photos].request();
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveGift() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      widget.gift.name = _name;
      widget.gift.description = _description;
      widget.gift.category = _category;
      widget.gift.price = _price;
      widget.gift.status = _isPledged ? 'pledged' : 'available';

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
                    onTap: _pickImage,
                    child: Column(
                      children: [
                        _imageFile == null
                            ? Image.asset(
                          'lib/assets/images/defaultGift.jpeg',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Image.file(
                          _imageFile!,
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
                    initialValue: _name,
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
                      _name = value!;
                    },
                    enabled: !_isPledged,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: _description,
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
                      _description = value!;
                    },
                    enabled: !_isPledged,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: _category,
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
                      _category = value!;
                    },
                    enabled: !_isPledged,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: _price.toString(),
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
                      _price = double.parse(value!);
                    },
                    enabled: !_isPledged,
                  ),
                  const SizedBox(height: 20),
                  if (!_isPledged)
                    ElevatedButton(
                      onPressed: _saveGift,
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
