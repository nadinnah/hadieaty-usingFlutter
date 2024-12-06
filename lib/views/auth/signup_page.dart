import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
// User controller for local database
import 'login_page.dart'; // To navigate to the login page

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController(); // Added name field
  final phoneController = TextEditingController(); // Added phone field
  final _formKey = GlobalKey<FormState>();

  final Authenticate authController = Authenticate();
  final UserController userController = UserController();

  String errorMessage = '';
  bool isLoading = false;

  // Signup method
  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Sign up using Firebase Authentication
      bool status = await authController.Sign_up(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (status) {
        // Save user data to local SQLite database
        await userController.insertUser({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'preferences': '{}', // Default empty preferences
          'password': passwordController.text.trim(), // Save hashed password ideally
          'role': 0, // Regular user
          'profilePic': '', // Default profile picture URL
          'number': int.parse(phoneController.text.trim()),
        });

        // Navigate to home page after successful signup
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', (Route<dynamic> route) => false);
      } else {
        setState(() {
          errorMessage = 'Signup failed: Email already in use.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Signup failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Validation for email and password
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Name is required' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value == null || value.isEmpty ? 'Phone number is required' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: validateEmail,
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: validatePassword,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: signup,
                child: Text('Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text("Already have an account? Login"),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
