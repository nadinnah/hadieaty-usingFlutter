import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler
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
  File? _imageFile;  // To hold the selected image file

  final ImagePicker _picker = ImagePicker();  // Image picker instance

  @override
  void initState() {
    super.initState();
    _name = widget.gift.name;
    _description = widget.gift.description!;
    _category = widget.gift.category!;
    _price = widget.gift.price!;
    _isPledged = widget.gift.status == 'pledged';
  }

  // Function to request permission and pick an image
  Future<void> _pickImage() async {
    // Request permission for camera and gallery
    await _requestPermissions();

    // Show dialog to choose between camera or gallery
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Image Source"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _pickImageFromCamera();
              },
              child: Text("Take a Picture"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _pickImageFromGallery();
              },
              child: Text("Choose from Gallery"),
            ),
          ],
        );
      },
    );
  }

  // Request permissions for camera and gallery
  Future<void> _requestPermissions() async {
    // Request permissions for camera and gallery
    await [
      Permission.camera,
      Permission.photos,
    ].request();
  }

  // Function to pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);  // Update the image file
      });
    }
  }

  // Function to take a picture using the camera
  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);  // Update the image file
      });
    }
  }

  // Function to save the gift details
  void _saveGift() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Update the gift details
      widget.gift.name = _name;
      widget.gift.description = _description;
      widget.gift.category = _category;
      widget.gift.price = _price;
      widget.gift.status = _isPledged ? 'pledged' : 'available';

      Navigator.pop(context, widget.gift); // Return updated gift
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: Color(0xffefefef),
        title: Text(
          "Gift Details",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0), // Padding around the whole form
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Image Picker (to pick a gift image)
                  GestureDetector(
                    onTap: _pickImage, // Tap to select or capture image
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
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to select an image',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  )

                  ,


                  SizedBox(height: 20),

                  // Gift Name
                  TextFormField(
                    initialValue: _name,
                    decoration: InputDecoration(
                      icon: Icon(Icons.card_giftcard),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "Gift Name",
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter the gift name";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value ?? '';
                    },
                    enabled: !_isPledged,
                  ),
                  SizedBox(height: 10),

                  // Gift Description
                  TextFormField(
                    initialValue: _description,
                    decoration: InputDecoration(
                      icon: Icon(Icons.description),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "Description",
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a description";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _description = value ?? '';
                    },
                    enabled: !_isPledged,
                  ),
                  SizedBox(height: 10),

                  // Gift Category
                  TextFormField(
                    initialValue: _category,
                    decoration: InputDecoration(
                      icon: Icon(Icons.category),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "Category",
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a category";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _category = value ?? '';
                    },
                    enabled: !_isPledged,
                  ),
                  SizedBox(height: 10),

                  // Gift Price
                  TextFormField(
                    initialValue: _price.toString(),
                    decoration: InputDecoration(
                      icon: Icon(Icons.attach_money),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "Price",
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
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
                      _price = double.parse(value ?? '0');
                    },
                    enabled: !_isPledged,
                  ),
                  SizedBox(height: 10),


                  // Save Button
                  if (!_isPledged)
                    ElevatedButton(
                      onPressed: _saveGift,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xff273331),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
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
