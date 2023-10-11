import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AIKO/routes/routes.dart'; // Importieren Sie die Routes, falls noch nicht geschehen

class SecondWelcomeScreen extends StatefulWidget {
  @override
  _SecondWelcomeScreenState createState() => _SecondWelcomeScreenState();
}

class _SecondWelcomeScreenState extends State<SecondWelcomeScreen> {
  String? userName;
  String? userGender;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
      userGender = prefs.getString('userGender');
    });
  }

  @override
  Widget build(BuildContext context) {
    String greeting = userGender == 'Mädchen'
        ? 'Schön Dich wiederzusehen, liebe $userName!'
        : 'Schön Dich wiederzusehen, lieber $userName!';

    return Scaffold(
      body: Container(
        // ... (ähnliches Design wie im ersten WelcomeScreen)
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ... (Logo, etc.)
              Text(
                greeting,
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, Routes.homeScreen);
                },
                child: Text('Los geht\'s! 🚀', style: TextStyle(fontFamily: 'Pacifico')),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Abrundung des Buttons
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
