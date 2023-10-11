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
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _checkStoredData();
  }

  void _checkStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    String? userGender = prefs.getString('userGender');

    if (userName != null && userGender != null) {
      String greeting = userGender == 'Mädchen'
          ? 'Schön Dich wiederzusehen, liebe $userName!'
          : 'Schön Dich wiederzusehen, lieber $userName!';
      // Hier können Sie die Begrüßung anzeigen oder den Benutzer zum Hauptbildschirm weiterleiten
    }
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo/bot.png', height: 350, width: 250,),
                Text(
                  'Hallo großer Entdecker! 🌟',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 20),
                // Container für "Dein Name"
                // Container für "Dein Name"
                Container(
                  width: MediaQuery.of(context).size.width * 0.6, // 60% der Bildschirmbreite
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(fontFamily: 'Pacifico', fontSize: 19, color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      hintText: 'Dein Name',  // Änderung hier
                      filled: true,
                      fillColor: Colors.blue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // Container für "Dein Alter"
                Container(
                  width: MediaQuery.of(context).size.width * 0.6, // 60% der Bildschirmbreite
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _ageController,
                    style: TextStyle(fontFamily: 'Pacifico', fontSize: 19, color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Höhenanpassung
                      hintText: 'Dein Alter',
                      labelStyle: TextStyle(fontFamily: 'Pacifico', fontSize: 19, color: Colors.white),
                      filled: true,
                      fillColor: Colors.blueAccent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                SizedBox(height: 10),

                // Container für "Dein Geschlecht"
                Container(
                  width: MediaQuery.of(context).size.width * 0.6, // 60% der Bildschirmbreite
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      hint: Text(
                        'Dein Geschlecht',
                        style: TextStyle(fontFamily: 'Pacifico', fontSize: 19, color: Colors.white),
                      ),
                      dropdownColor: Colors.blueAccent,
                      style: TextStyle(fontFamily: 'Pacifico', fontSize: 19, color: Colors.white),
                      items: <String>['Mädchen', 'Junge', 'Andere']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontFamily: 'Pacifico', fontSize: 20)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('userName', _nameController.text);
                    await prefs.setString('userAge', _ageController.text);
                    await prefs.setString('userGender', _selectedGender ?? ''); // Speichern des Geschlechts
                    Navigator.pushReplacementNamed(context, Routes.homeScreen);
                  },
                  child: Text('Los geht\'s! 🚀', style: TextStyle(fontFamily: 'Pacifico')),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0), // Abrundungswert
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}