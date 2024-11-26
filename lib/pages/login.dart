import 'package:flutter/material.dart';
import 'package:hadieaty/Localdb/localDb.dart';
import 'sharedPrefs.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  LocalDatabase localDatabase = LocalDatabase();

  Future<void> loginUser(String email, String password) async {
    var userResult = await localDatabase
        .readData('''SELECT * FROM Users WHERE email = "$email"''');

    if (userResult.isNotEmpty) {
      String storedPassword = userResult[0]['password'];

      if (storedPassword == password) {
        // Save the user's email in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', email);

        // Make this user the admin
        await localDatabase.updateData(
            '''UPDATE Users SET role = 1 WHERE email = "$email"''');
        print('Admin logged in');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Invalid password
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid password. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // User not found
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Email not found. Please register.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/register'); // Navigate to register page
              },
              child: const Text('Register'),
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
            style: GoogleFonts.anticDidone(
              fontSize: 45,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
        toolbarHeight: 100,
        backgroundColor: const Color(0xffefefef),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Enter Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Enter Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                loginUser(emailController.text, passwordController.text);
              },
              child: const Text('Login'),
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
