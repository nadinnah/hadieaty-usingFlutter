import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';  // Import Event Controller
import '../models/event.dart';  // Import Event Model

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
  String _status = 'Upcoming';  // Default status
  String _createdAt = '';  // Current date (you can implement getting current date logic)

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
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _date = "${picked.toLocal()}".split(' ')[0]; // Format the date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Event"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Event Name
              TextFormField(
                decoration: InputDecoration(labelText: "Event Name"),
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

              // Event Description
              TextFormField(
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
              ),

              // Event Date
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Date",
                  suffixIcon: Icon(Icons.calendar_today),
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

              // Event Location
              TextFormField(
                decoration: InputDecoration(labelText: "Location"),
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

              // Event Category
              TextFormField(
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
              ),

              // Event Status (Dropdown)
              DropdownButtonFormField<String>(
                value: _status,
                items: [
                  DropdownMenuItem(value: 'Upcoming', child: Text("Upcoming")),
                  DropdownMenuItem(value: 'Current', child: Text("Current")),
                  DropdownMenuItem(value: 'Past', child: Text("Past")),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: InputDecoration(labelText: "Status"),
              ),

              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _addEvent,
                child: Text("Add Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
