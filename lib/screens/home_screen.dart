import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../essentials/calendar.dart';
import 'daily_goals_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                _logOut(context);
              } else if (value == 'delete_account') {
                _deleteAccount(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Log Out'),
              ),
              const PopupMenuItem<String>(
                value: 'delete_account',
                child: Text('Delete Account'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(178, 223, 219, 1.0), // Set background color
        ),
        child: Center(
          child: Column(
            children: [
              const Text(
                'Welcome to the Planner!',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DailyGoalsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: const Text('Open Daily Goals'),
              ),
              const SizedBox(height: 16),
              Calendar(), // Display the WeekCalendar
            ],
          ),
        ),
      ),
    );
  }

  void _logOut(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _deleteAccount(BuildContext context) async {
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Clear account-related data from shared preferences
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      // After successful account deletion, navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
}
