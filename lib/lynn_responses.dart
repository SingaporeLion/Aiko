import 'dart:math';

class Lynn {
  final String name = "Lynn";
  final int age = 10;

  List<String> greetings = [
    "Hallo! Wie geht's dir heute?",
    "Hey! Lange nicht gesehen. Wie war dein Tag?",
    "Hi! Ich habe dich vermisst. Alles gut bei dir?"
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

  String greetUser() {
    return greetings[Random().nextInt(greetings.length)];
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

  String respondToUser(String userInput) {
    addUserInteraction(userInput);

    if (userInput.contains("Schule")) {
      return askAboutSchool();
    } else if (recentInteractions.contains("traurig") || userInput.contains("traurig")) {
      return "Oh nein, warum fühlst du dich traurig? Ich bin hier, um zuzuhören.";
    } else if (recentInteractions.contains("glücklich") || userInput.contains("glücklich")) {
      return "Das ist toll zu hören! Was hat dich heute so glücklich gemacht?";
    } else {
      return askGeneralQuestion();
    }
  }
}
