import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class Lynn {
  final String name = "Lynn";
  final int age = 10;
  final String gender = "Mädchen";
  final String personalityDescription = "Ein aufgewecktes, fröhliches und liebevolles Kind, das es liebt zuzuhören und Ratschläge zu geben.";

  Future<Map<String, dynamic>> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'userName': prefs.getString('userName') ?? 'Freund',
      'userAge': prefs.getInt('userAge') ?? 0,
      'userGender': prefs.getString('userGender') ?? 'unbekannt'
    };
  }

  List<String> greetings(String userName) => [
    "Hallo $userName! Wie geht's dir heute?",
    "Hey $userName! Lange nicht gesehen. Wie war dein Tag?",
    "Hi $userName! Ich habe dich vermisst. Alles gut bei dir?",
    "Hallo! Wie war dein Tag, $userName?",
    "Hey! Wie fühlst du dich heute, $userName?"
  ];

  List<String> schoolRelated = [
    "Wie war die Schule heute?",
    "Hast du heute etwas Neues in der Schule gelernt?",
    "Erzähl mir von deinem Schultag!"
  ];

  List<String> generalQuestions = [
    "Was hast du heute vor?",
    "Gibt es etwas, worüber du sprechen möchtest?",
    "Wie fühlst du dich gerade?"
  ];

  List<String> recentInteractions = [];

  String greetUser(String userName) {
    return greetings(userName)[Random().nextInt(greetings(userName).length)];
  }

  String askAboutSchool() {
    return schoolRelated[Random().nextInt(schoolRelated.length)];
  }

  String askGeneralQuestion() {
    return generalQuestions[Random().nextInt(generalQuestions.length)];
  }

  void addUserInteraction(String interaction) {
    if (recentInteractions.length >= 5) {
      recentInteractions.removeAt(0);
    }
    recentInteractions.add(interaction);
  }

  String respondToUser(String userInput, String userName, int userAge, String userGender) {
    addUserInteraction(userInput);

    if (userInput.contains("Schule")) {
      return askAboutSchool();
    } else if (recentInteractions.contains("traurig") || userInput.contains("traurig")) {
      return "Oh nein, warum fühlst du dich traurig? Ich bin hier, um zuzuhören.";
    } else if (recentInteractions.contains("glücklich") || userInput.contains("glücklich")) {
      return "Das ist toll zu hören! Was hat dich heute so glücklich gemacht?";
    } else if (userInput.contains("Geburtstag")) {
      int nextAge = userAge + 1;
      return "Oh, wirst du bald $nextAge? Das ist aufregend!";
    } else if (userGender == "Mädchen" && userInput.contains("Tanz")) {
      return "Tanzen ist so viel Spaß! Welche Art von Tanz magst du am liebsten?";
    } else if (userGender == "Junge" && userInput.contains("Fußball")) {
      return "Fußball ist ein tolles Spiel! Spielst du in einem Team?";
    } else {
      return greetUser(userName);
    }
  }
}
