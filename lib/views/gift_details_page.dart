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
      appBar: AppBar(
        title: Text("Gift Details"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Gift Name
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: "Gift Name"),
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

              // Gift Description
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: "Description"),
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

              // Gift Category
              TextFormField(
                initialValue: _category,
                decoration: InputDecoration(labelText: "Category"),
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

              // Gift Price
              TextFormField(
                initialValue: _price.toString(),
                decoration: InputDecoration(labelText: "Price"),
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

              // Gift Status (Toggle Button)
              Row(
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
                  Text(_isPledged ? "Pledged" : "Available"),
                ],
              ),

              SizedBox(height: 20),

              // Save Button
              if (widget.isOwnEvent && !_isPledged)
                ElevatedButton(
                  onPressed: _saveGift,
                  child: Text("Save Gift"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
