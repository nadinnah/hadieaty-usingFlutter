import 'package:flutter/material.dart';
import '../models/gift.dart';

class GiftDetailsPage extends StatefulWidget {
  final Gift gift;
  final bool isOwnEvent;

  GiftDetailsPage({required this.gift, required this.isOwnEvent});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _description;
  late String _category;
  late double _price;
  late bool _isPledged; // Represent status as a boolean

  @override
  void initState() {
    super.initState();
    _name = widget.gift.name;
    _description = widget.gift.description;
    _category = widget.gift.category;
    _price = widget.gift.price;
    _isPledged = widget.gift.status == 'pledged';
  }

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
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Gift Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
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
                      enabled: widget.isOwnEvent && !_isPledged,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Gift Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
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
                      enabled: widget.isOwnEvent && !_isPledged,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Gift Category
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
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
                      enabled: widget.isOwnEvent && !_isPledged,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Gift Price
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
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
                      enabled: widget.isOwnEvent && !_isPledged,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Gift Status (Toggle Button)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Status:"),
                        Switch(
                          value: _isPledged,
                          onChanged: widget.isOwnEvent
                              ? (value) {
                            setState(() {
                              _isPledged = value;
                            });
                          }
                              : null, // Disable for non-owners
                        ),
                        Text(
                          _isPledged ? "Pledged" : "Available",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Save Button
                  if (widget.isOwnEvent && !_isPledged)
                    ElevatedButton(
                      onPressed: _saveGift,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xff273331),
                        padding: EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
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
