import 'package:flutter/material.dart';
import 'package:hadieaty/Localdb/localDb.dart';
import 'sharedPrefs.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController numberController = TextEditingController(); // Added number controller
  LocalDatabase localDatabase = LocalDatabase();

  Future<void> registerUser(String name, String email, String password, String number) async {
    try {
      // Check if email already exists
      var userResult = await localDatabase.readData(
          '''SELECT * FROM Users WHERE email = "$email"'''
      );

      if (userResult.isNotEmpty) {
        // Email already exists
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Email already exists. Please log in.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Insert new user into database
      await localDatabase.insertData(
          '''INSERT INTO Users (name, email, password, number) VALUES ("$name", "$email", "$password", "$number")'''
      );

      // Success dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Registration successful! Please log in.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to login page
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle errors
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('Registration failed: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var preferences = Provider.of<PreferencesService>(context);
    return Scaffold(
      backgroundColor:
      preferences.isDarkMode ? Color(0xff1e1e1e) : const Color(0xffefefef),
      appBar: AppBar(
        title: Center(
          child: Text(
            'HADIEATY',
            style: TextStyle(
              fontSize: 55,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
        toolbarHeight: 100,
        backgroundColor: preferences.isDarkMode
            ? Color(0xff1e1e1e)
            : const Color(0xffefefef),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Enter Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Enter Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Enter Password'),
              obscureText: true,
            ),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'Enter Phone Number'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                registerUser(
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                  numberController.text,
                );
              },
              child: const Text('Register'),
            ),
            const Spacer(),
            Container(
              child: Image.asset(
                'lib/assets/giftBox.png',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
