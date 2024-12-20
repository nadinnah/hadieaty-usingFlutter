import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../controllers/event_controller.dart';
import '../models/event.dart';

class AddEventPage extends StatelessWidget {
  final Event? event; // Nullable event for editing

  AddEventPage({this.event});

  @override
  Widget build(BuildContext context) {
    final EventController _controller = EventController();
    final _formKey = GlobalKey<FormState>();

    // TextEditingControllers for form fields
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    // Initial status value
    String _status = 'Upcoming';

    // Pre-fill form fields if editing
    if (event != null) {
      nameController.text = event!.name;
      descriptionController.text = event!.description;
      locationController.text = event!.location;
      categoryController.text = event!.category ?? '';
      dateController.text = event!.date;
      _status = event!.status ?? 'Upcoming';
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: const Color(0xffefefef),
        title: Text(
          event == null ? 'Add New Event' : 'Edit Event',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Event Name
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.event),
                          hintText: 'Event Name',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fillColor: Colors.grey[50],
                          filled: true,
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Event name is required' : null,
                      ),
                      const SizedBox(height: 10),

                      // Event Description
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.description),
                          hintText: 'Description',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fillColor: Colors.grey[50],
                          filled: true,
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 10),

                      // Event Date (with DatePicker)
                      TextFormField(
                        controller: dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.calendar_today),
                          hintText: 'Select a date',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fillColor: Colors.grey[50],
                          filled: true,
                        ),
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            dateController.text = pickedDate.toLocal() as String;
                          }
                        },
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please select a date' : null,
                      ),
                      const SizedBox(height: 10),

                      // Event Location
                      TextFormField(
                        controller: locationController,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.location_on),
                          hintText: 'Location',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fillColor: Colors.grey[50],
                          filled: true,
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Location is required' : null,
                      ),
                      const SizedBox(height: 10),

                      // Event Category
                      TextFormField(
                        controller: categoryController,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.category),
                          hintText: 'Category',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fillColor: Colors.grey[50],
                          filled: true,
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Category is required' : null,
                      ),
                      const SizedBox(height: 10),

                      // Event Status Dropdown
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.timeline),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fillColor: Colors.grey[50],
                          filled: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
                          DropdownMenuItem(value: 'Current', child: Text('Current')),
                          DropdownMenuItem(value: 'Past', child: Text('Past')),
                        ],
                        onChanged: (value) {
                          _status = value!;
                        },
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please select a status' : null,
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final newEvent = Event(
                              id: event?.id,
                              name: nameController.text.trim(),
                              description: descriptionController.text.trim(),
                              location: locationController.text.trim(),
                              category: categoryController.text.trim(),
                              date: dateController.text.trim(),
                              status: _status,
                              createdBy:
                              FirebaseAuth.instance.currentUser?.uid ?? '',
                              syncStatus: false, // Reset to UnSynced on edit
                              firebaseId: event?.firebaseId, // Retain firebaseId
                              createdAt: event?.createdAt ??
                                  DateFormat('dd-MM-yyyy hh:mm') as String,
                            );

                            bool success;
                            if (event == null) {
                              success = await _controller.addEventLocally(newEvent);
                            } else {
                              success =
                              await _controller.updateEventLocally(newEvent);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? "Event ${event == null ? 'added' : 'updated'} successfully."
                                      : "Failed to save event.",
                                ),
                                backgroundColor:
                                success ? Colors.green : Colors.red,
                              ),
                            );

                            if (success) Navigator.pop(context, true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xff273331),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(event == null ? 'Add Event' : 'Update Event'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Positioned Image
          Container(
            child: Image.asset(
              'lib/assets/images/giftBoxes.png',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );

  }
}
