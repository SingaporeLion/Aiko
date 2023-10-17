import 'package:flutter/material.dart';
import 'package:AIKO/routes/routes.dart';
import 'package:AIKO/helper/local_storage.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  String _greetingMessageTop = '';
  String _greetingMessageBottom = '';
  String? _selectedGender;
  final localStorage = LocalStorage();  // Erstellen Sie eine Instanz von LocalStorage

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _checkStoredData();
  }

  void _checkStoredData() {
    String? userName = LocalStorage.getString('userName');
    String? userAge = LocalStorage.getString('userAge');
    String? userGender = LocalStorage.getString('userGender');

    print("Abgerufener Benutzername: $userName");
    print("Abgerufenes Alter: $userAge");
    print("Abgerufenes Geschlecht: $userGender");

    if (userName != null && userGender != null) {
      setState(() {
        _greetingMessageTop = 'Schön Dich wiederzusehen,';
        _greetingMessageBottom = userGender == 'Mädchen'
            ? 'liebe $userName!'
            : 'lieber $userName!';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    print("LoginScreen wird gebaut");
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[800]!, Colors.purple[700]!, Colors.blue[600]!, Colors.blue[300]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo/bot.png', height: 350, width: 250,),
                Text(
                  'Hallo großer Entdecker 🌟',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                if (_greetingMessageTop != null && _greetingMessageBottom != null) ...[
                  Text(
                    _greetingMessageTop,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pacifico',
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _greetingMessageBottom,
                    textAlign: TextAlign.center,
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
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                ] else ...[
                  // Container für "Dein Name"
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(fontFamily: 'Pacifico', fontSize: 19, color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        hintText: 'Dein Name',
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
                    ),
                  ),
                  SizedBox(height: 10),
                  // Container für "Dein Alter"
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _ageController,
                      style: TextStyle(fontFamily: 'Pacifico', fontSize: 19, color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
                    width: MediaQuery.of(context).size.width * 0.6,
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
                      print("Button wurde gedrückt!");

                      // Daten speichern mit LocalStorage
                      await LocalStorage.setString('userName', _nameController.text);
                      await LocalStorage.setString('userAge', _ageController.text);
                      await LocalStorage.setString('userGender', _selectedGender ?? '');

                      print("Gespeicherter Benutzername: ${_nameController.text}");
                      print("Gespeichertes Alter: ${_ageController.text}");
                      print("Gespeichertes Geschlecht: ${_selectedGender ?? ''}");

                      Navigator.pushReplacementNamed(context, Routes.homeScreen);
                    },
                    child: Text('Los geht\'s! 🚀', style: TextStyle(fontFamily: 'Pacifico')),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      minimumSize: Size(200, 60), // Hier können Sie die Größe anpassen
                    ),
                  )

                ],
              ],
            ),
          ),
        ),
      ),
    );
  }}
