import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/local_storage.dart';
import '../model/support_model/support_ticket.dart';
import '../model/user_model/user_model.dart';
import '../routes/routes.dart';
import '../utils/config.dart';
import '../widgets/api/toast_message.dart';

class MainController extends GetxController {
  // Entfernen Sie alle Firebase-bezogenen Variablen und Methoden

  // Ihre weiteren nicht Firebase-bezogenen Funktionen und Variablen
  // ...

  // Anpassen oder Entfernen von Firebase-abhängigen Methoden
  // ...

  // Beispiel für eine Methode, die Sie behalten könnten
  void showToastMessage(String message) {
    ToastMessage.success(message);
  }

// Weitere Methoden und Logik
// ...
}

// Entfernen Sie alle Klassen, die Firebase-bezogene Daten oder Funktionalitäten verwenden
