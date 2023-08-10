import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../essentials/auth_storage.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AuthStorage _authStorage;

  @override
  void initState() {
    super.initState();
    _initializeAuthStorage();
  }

  void _initializeAuthStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _authStorage = AuthStorage(prefs);
  }

  void _handleRegistration() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      await _authStorage.saveCredentials(username, password);

      // After successful registration, navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(178, 223, 219, 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) {
                  _handleRegistration();
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) {
                  _handleRegistration();
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _handleRegistration,
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
