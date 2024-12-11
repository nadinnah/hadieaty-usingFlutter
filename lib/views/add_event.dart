import 'package:flutter/material.dart';
import '../controllers/event_controller.dart'; // Import Event Controller
import '../models/event.dart'; // Import Event Model

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final EventController _controller = EventController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  // Event fields
  String _name = '';
  String _description = '';
  String _date = '';
  String _location = '';
  String _category = '';
  String _status = 'Upcoming'; // Default status
  String _createdAt = ''; // Current date (you can implement getting current date logic)

  // Add Event method
  void _addEvent() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save(); // Save the form fields

      Event newEvent = Event(
        name: _name,
        description: _description,
        date: _date,
        location: _location,
        category: _category,
        status: _status,
        createdAt: _createdAt,
      );

      // Call the controller to add the event
      _controller.addEvent(newEvent);

      // After adding the event, navigate back
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020), // Set the minimum date
      lastDate: DateTime(2101), // Set the maximum date
    );
    if (picked != null) {
      setState(() {
        _date = "${picked.toLocal()}".split(' ')[0]; // Format the date
      });
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
          "Add New Event",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Event Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.event),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: "Event Name",
                        fillColor: Colors.grey[50],
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the event name";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _name = value ?? '';
                      },
                    ),
                  ),
                  SizedBox(height: 10),

                  // Event Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
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
                    ),
                  ),
                  SizedBox(height: 10),

                  // Event Date
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.date_range),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: "Date",
                        fillColor: Colors.grey[50],
                        filled: true,
                      ),
                      readOnly: true, // Make the TextField read-only
                      controller: TextEditingController(text: _date),
                      onTap: () {
                        _selectDate(context); // Open the date picker
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a date";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),

                  // Event Location
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.location_on),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: "Location",
                        fillColor: Colors.grey[50],
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a location";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _location = value ?? '';
                      },
                    ),
                  ),
                  SizedBox(height: 10),

                  // Event Category
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
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
                    ),
                  ),
                  SizedBox(height: 10),

                  // Event Status (Dropdown)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      items: [
                        DropdownMenuItem(
                            value: 'Upcoming', child: Text("Upcoming")),
                        DropdownMenuItem(
                            value: 'Current', child: Text("Current")),
                        DropdownMenuItem(value: 'Past', child: Text("Past")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _status = value!;
                        });
                      },
                      decoration: InputDecoration(
                        icon: Icon(Icons.timeline),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillColor: Colors.grey[50],
                        filled: true,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _addEvent,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xff273331),
                      padding:
                      EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Add Event",
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
