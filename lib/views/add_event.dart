import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/event_controller.dart';
import '../models/event.dart';

class AddEventPage extends StatefulWidget {
  final Event? event; // Nullable event for editing

  AddEventPage({this.event}); // Accept event for editing

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final EventController _controller = EventController();
  final _formKey = GlobalKey<FormState>();

  // Event fields
  String _name = '';
  String _description = '';
  String _location = '';
  String _category = '';
  String _status = 'Upcoming';
  String _createdAt = DateTime.now().toIso8601String();
  late String _createdBy; // Field for the user who created the event
  bool _syncStatus = false;

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Populate `createdBy` with current user's email
    _createdBy = FirebaseAuth.instance.currentUser?.email ?? 'Unknown';

    // Populate fields for editing if event is provided
    if (widget.event != null) {
      final event = widget.event!;
      _name = event.name;
      _description = event.description;
      _dateController.text = event.date;
      _location = event.location;
      _category = event.category!;
      _status = event.status!;
      _createdAt = event.createdAt;
      _syncStatus = event.syncStatus;
      _createdBy = event.createdBy; // Use existing createdBy value if editing
    }
  }

  Future<void> _addOrUpdateEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      Event newEvent = Event(
        name: _name,
        description: _description,
        date: _dateController.text,
        location: _location,
        category: _category,
        status: _status,
        createdAt: _createdAt,
        createdBy: FirebaseAuth.instance.currentUser?.uid ?? '', // Set createdBy
        syncStatus: _syncStatus,
      );

      bool success;

      if (widget.event == null) {
        // Add new event
        success = await _controller.addEventLocally(newEvent);
      } else {
        // Update existing event
        success = await _controller.updateEvent(newEvent);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Event ${widget.event == null ? 'added' : 'updated'} successfully"),
          ),
        );
        Navigator.pop(context, true); // Return a success flag

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save event."),
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toLocal().toIso8601String().split('T')[0];
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
          widget.event == null ? "Add New Event" : "Edit Event",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Event Name
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  icon: Icon(Icons.event),
                  hintText: "Event Name",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Colors.grey[50],
                  filled: true,
                ),
                onSaved: (value) => _name = value ?? '',
                validator: (value) => value!.isEmpty ? "Please enter the event name" : null,
              ),
              SizedBox(height: 10),

              // Event Description
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  icon: Icon(Icons.description),
                  hintText: "Description",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Colors.grey[50],
                  filled: true,
                ),
                onSaved: (value) => _description = value ?? '',
                validator: (value) => value!.isEmpty ? "Please enter a description" : null,
              ),
              SizedBox(height: 10),

              // Event Date
              TextFormField(
                readOnly: true,
                controller: _dateController,
                decoration: InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.date_range),
                  hintText: "Select a date",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Colors.grey[50],
                  filled: true,
                ),
                onTap: () => _selectDate(context),
                validator: (value) => value!.isEmpty ? "Please select a date" : null,
              ),
              SizedBox(height: 10),

              // Event Location
              TextFormField(
                initialValue: _location,
                decoration: InputDecoration(
                  icon: Icon(Icons.location_on),
                  hintText: "Location",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Colors.grey[50],
                  filled: true,
                ),
                onSaved: (value) => _location = value ?? '',
                validator: (value) => value!.isEmpty ? "Please enter a location" : null,
              ),
              SizedBox(height: 10),

              // Event Category
              TextFormField(
                initialValue: _category,
                decoration: InputDecoration(
                  icon: Icon(Icons.category),
                  hintText: "Category",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Colors.grey[50],
                  filled: true,
                ),
                onSaved: (value) => _category = value ?? '',
                validator: (value) => value!.isEmpty ? "Please enter a category" : null,
              ),
              SizedBox(height: 10),

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
                decoration: InputDecoration(
                  icon: Icon(Icons.timeline),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Colors.grey[50],
                  filled: true,
                ),
              ),
              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _addOrUpdateEvent,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xff273331),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(widget.event == null ? 'Add Event' : 'Update Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
