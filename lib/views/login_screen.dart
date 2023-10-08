import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AIKO/routes/routes.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[100]!, Colors.blue[100]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView( // Hinzugefügt
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo/bot.png', height: 350, width: 250,),
                Text(
                  'Hallo kleiner Entdecker! 🌟',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),

                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Dein Name',
                    filled: true,
                    fillColor: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Dein Alter',
                    filled: true,
                    fillColor: Colors.blueAccent,
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('userName', _nameController.text);
                    await prefs.setString('userAge', _ageController.text);
                    Navigator.pushReplacementNamed(context, Routes.homeScreen);
                  },
                  child: Text('Los geht\'s! 🚀', style: TextStyle(fontFamily: 'Pacifico')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}