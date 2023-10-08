import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../helper/local_storage.dart';
import '../model/support_model/support_ticket.dart';
import '../model/user_model/user_model.dart';
import '../routes/routes.dart';
import '../utils/config.dart';
import '../widgets/api/toast_message.dart';

class MainController {
  static final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance; // firebase instance/object
  static User get user => _auth.currentUser!;

  /// auth service
  Future<UserCredential> signInWithApple({List<Scope> scopes = const [Scope.email, Scope.fullName]}) async {
    // 1. perform the sign-in request
    final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
          String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        final userCredential =
        await _auth.signInWithCredential(credential);
        final firebaseUser = userCredential.user!;
        final fullName = appleIdCredential.fullName;

        if (scopes.contains(Scope.fullName)) {

          debugPrint("=============${fullName?.familyName.toString()}");
          debugPrint("=============${fullName?.givenName.toString()}");
          debugPrint("=============${fullName?.nickname.toString()}");
          debugPrint("=============${appleIdCredential.email.toString()}=============");

          if (fullName != null &&
              fullName.givenName != null &&
              fullName.familyName != null) {

            final displayName = '${fullName.givenName} ${fullName.familyName}';
            debugPrint("============$displayName");
            await firebaseUser.updateDisplayName(displayName);
          }
        }
        return userCredential;
      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }
  Future<UserCredential> signInWithGoogle() async {

    try{
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      debugPrint("-------authService => signInWithGoogle  =>  after get google auth --------");

      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      debugPrint("-------authService => signInWithGoogle  =>  before get google auth --------");


      debugPrint("-------authService => signInWithGoogle  =>  after get credential --------");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, // accessToken from google auth
        idToken: googleAuth?.idToken, // idToken from google auth
      );

      debugPrint("-------authService => signInWithGoogle  =>  before get credential --------");


      debugPrint("-------authService => signInWithGoogle  =>  after get userCredential --------");
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      debugPrint("-------authService => signInWithGoogle  =>  before get userCredential --------");


      return userCredential;
    } on PlatformException catch (e){
      debugPrint("PlatformException on Auth Service ${e.message}");
      throw UnimplementedError();
    } on FirebaseAuthException catch (e){
      debugPrint("FirebaseAuthException on Auth Service ${e.message}");
      throw UnimplementedError();
    } catch (e){
      debugPrint("Error on Auth Service $e");
      throw UnimplementedError();
    }
  }

  /// for login services
  static checkPremiumOrNot(UserModel userData) async{
    /// check free or premium

    final DocumentSnapshot userDoc = await _fireStore
        .collection('botUsers')
        .doc(user.uid)
        .get();

    if(userDoc.exists){
      checkData(userDoc);
    }else{
      setData(userData);
    }
  }

  static setData(UserModel userData) async{
    await _fireStore
        .collection('botUsers')
        .doc(user.uid)
        .set(userData.toJson());

    LocalStorage.showIsFreeUser( isShowAdYes: true);
    if(LocalStorage.getSubscriptionStatus()){
      Get.offAllNamed(Routes.purchasePlanScreen);
    }else{
      Get.offAllNamed(Routes.homeScreen);
    }
  }

  static checkData(DocumentSnapshot<Object?> userDoc) {
    if (userDoc.get('isPremium')) {
      LocalStorage.saveTextCount(count: userDoc.get('textCount'));
      LocalStorage.saveImageCount(count: userDoc.get('imageCount'));
      LocalStorage.saveContentCount(count: userDoc.get('contentCount'));
      LocalStorage.saveHashTagCount(count: userDoc.get('hashTagCount'));
      LocalStorage.saveDate(value: userDoc.get('date'));
      LocalStorage.showIsFreeUser(isShowAdYes: !userDoc.get('isPremium'));
      Get.offAllNamed(Routes.homeScreen);
    } else {
      LocalStorage.saveTextCount(count: userDoc.get('textCount'));
      LocalStorage.saveImageCount(count: userDoc.get('imageCount'));
      LocalStorage.saveContentCount(count: userDoc.get('contentCount'));
      LocalStorage.saveHashTagCount(count: userDoc.get('hashTagCount'));
      LocalStorage.showIsFreeUser( isShowAdYes: true);
      Get.offAllNamed(Routes.homeScreen);
    }
  }

  /// common service
  static sendSupportTicket({
    required String email,
    required String name,
    required String note,
  }) async{

    SupportModel supportData = SupportModel(
      email: email,
      name: name,
      note: note,
    );

    try{
      await _fireStore
          .collection('supportData')
          .doc(email)
          .collection('issues')
          .doc()
          .set(supportData.toJson());

      ToastMessage.success('Send Your Issue Successfully');

    } on FirebaseAuthException catch (e) {
      debugPrint(
          "🐞🐞🐞 Printing Error FirebaseAuthException => ${e.message!}  🐞🐞🐞");
      ToastMessage.error(e.message!);
    } on PlatformException catch (e) {
      debugPrint("🐞🐞🐞 Printing Error PlatformException => ${e.message!}  🐞🐞🐞");
    } catch(e) {
      debugPrint("🐞🐞🐞 Printing Error PlatformException => ${e.toString()}  🐞🐞🐞");
    }
  }

  /// after login services
  static Future<void> addQuestionsToFirestore() async {
    try {
      final reff = _fireStore.collection('suggested_category');

      for (var element in catList) {
        await reff
            .doc(element.catName)
            .set({
              "catName": element.catName,
              "questions": element.questions
            });
      }

      debugPrint('Questions added to Firestore successfully!');
    } catch (e) {
      debugPrint('Error adding questions to Firestore: $e');
    }
  }

  static getCredentials() async {

    // getSuggestedCategory();

    final DocumentSnapshot userDoc = await _fireStore
        .collection('credentials')
        .doc('manage-api-key')
        .get();

    LocalStorage.saveChatGptApiKey(key: userDoc.get('chat-gpt-api-key'));
    LocalStorage.savePaypalClientId(key: userDoc.get('paypal-client-id'));
    LocalStorage.savePaypalSecret(key: userDoc.get('paypal-secret'));

    debugPrint("""
        Get ChatGpt Api Key ↙️
        ${LocalStorage.getChatGptApiKey()},
        Get Paypal ClientId ↙️
        ${LocalStorage.getPaypalClientId()},
        Get Paypal Secret ↙️
        ${LocalStorage.getPaypalSecret()},
        """);
  }

  // static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getSuggestedCategory() async {
  //
  //
  //   final QuerySnapshot<Map<String, dynamic>> userDoc = await _fireStore
  //       .collection('suggested_category')
  //       .get();
  //
  //   debugPrint(userDoc.docs.length.toString());
  //   debugPrint(userDoc.docs.toString());
  //
  //   // for (var element in userDoc.docs) {
  //   //   debugPrint(element["catName"]);
  //   //   // debugPrint(element["questions"]);
  //   // }
  //   return userDoc.docs;
  //
  //
  // }

  static getUserInfo() async {
    debugPrint(LocalStorage.getId()!);
    final DocumentSnapshot userDoc = await _fireStore
        .collection("botUsers")
        .doc(LocalStorage.getId()!)
        .get();

    LocalStorage.saveImageCount(count: userDoc.get('textCount'));
    LocalStorage.saveImageCount(count: userDoc.get('imageCount'));
    LocalStorage.saveContentCount(count: userDoc.get('contentCount'));
    LocalStorage.saveHashTagCount(count: userDoc.get('hashTagCount'));

    debugPrint("""
       1=> ${userDoc.get('textCount')} : ${LocalStorage.getTextCount()}
       2=> ${userDoc.get('imageCount')} : ${LocalStorage.getImageCount()}
       3=> ${userDoc.get('contentCount')} : ${LocalStorage.getContentCount()}
       3=> ${userDoc.get('contentCount')} : ${LocalStorage.getHashTagCount()}
        """);

    debugPrint("Get User Info");
    debugPrint("User Status ${userDoc.get("isPremium")}");
    debugPrint("Date ${userDoc.get("date")}");
    debugPrint("Saved Date ${LocalStorage.getDate()}");
    debugPrint("Saved Date ${LocalStorage.getDateString()}");
    debugPrint("Saved Date ${LocalStorage.getSubscriptionDate()}");

    if (userDoc.get("isPremium")) {
      debugPrint("Get User Premium Check");

      LocalStorage.saveDate(value: userDoc.get('date'));

      debugPrint("New Saved Date ${LocalStorage.getDate()}");
      debugPrint("New Saved Date ${LocalStorage.getDateString()}");
      debugPrint("New Saved Date ${LocalStorage.getSubscriptionDate()}");

      DateTime purchaseDate = DateTime.fromMillisecondsSinceEpoch(
          LocalStorage.getDate(),
          isUtc: true);
      int day = DateTime.now().day - purchaseDate.day;

      debugPrint(
          "MainController: getUserInfo: duration due is => ${day.toString()}");

      if (day < 30) {
        debugPrint("MainController: getUserInfo: have day enough");
        if (LocalStorage.getTextCount() < ApiConfig.premiumMessageLimit) {
          debugPrint("MainController: getUserInfo: have text enough");
        } else if (LocalStorage.getImageCount() <
            ApiConfig.premiumImageGenLimit) {
          debugPrint("MainController: getUserInfo: have image gen enough");
        } else if (LocalStorage.getContentCount() <
            ApiConfig.premiumContentLimit) {
          debugPrint("MainController: getUserInfo: have image gen enough");
        } else if (LocalStorage.getHashTagCount() <
            ApiConfig.premiumHashTagLimit) {
          debugPrint("MainController: getUserInfo: have image gen enough");
        } else {
          debugPrint(
              "You Are Free user now  coz: you have not any text and image gen limit");

          updateToFreeUser();
        }
      } else {
        debugPrint("You Are Free user now  coz: you have not any day limit");
        updateToFreeUser();
      }
    } else {
      LocalStorage.showIsFreeUser(isShowAdYes: true);
    }
  }

  static updateTextCount(int value) async {
    LocalStorage.saveTextCount(count: value);

    await _fireStore
        .collection('botUsers')
        .doc(LocalStorage.getId()!)
        .update({"textCount": value});

    getUserInfo();
  }

  static updateImageGenCount(int value) async {
    LocalStorage.saveImageCount(count: value);

    await _fireStore
        .collection('botUsers')
        .doc(LocalStorage.getId()!)
        .update({"imageCount": value});

    getUserInfo();
  }

  static updateContentCount(int value) async {
    LocalStorage.saveContentCount(count: value);

    await _fireStore
        .collection('botUsers')
        .doc(LocalStorage.getId()!)
        .update({"contentCount": value});

    getUserInfo();
  }

  static updateHashTagCount(int value) async {
    LocalStorage.saveHashTagCount(count: value);

    await _fireStore
        .collection('botUsers')
        .doc(LocalStorage.getId()!)
        .update({"hashTagCount": value});

    getUserInfo();
  }

  static updateToFreeUser() async {
    debugPrint("You Are Free user now");
    LocalStorage.showIsFreeUser(isShowAdYes: true);
    LocalStorage.saveImageCount(count: 0);
    LocalStorage.saveTextCount(count: 0);
    LocalStorage.saveContentCount(count: 0);
    LocalStorage.saveHashTagCount(count: 0);
    LocalStorage.saveDate(value: 0);

    await _fireStore
        .collection('botUsers')
        .doc(LocalStorage.getId()!)
        .update({
      "isPremium": false,
      "textCount": 0,
      "imageCount": 0,
      "contentCount": 0,
      "hashTagCount": 0,
      "date": 0
    });

    getUserInfo();
    // Get.offAllNamed(Routes.purchasePlanScreen);
  }

  static updateToPremiumUser() async {
    LocalStorage.showIsFreeUser(isShowAdYes: false);
    LocalStorage.saveImageCount(count: 0);
    LocalStorage.saveTextCount(count: 0);
    LocalStorage.saveContentCount(count: 0);
    LocalStorage.saveHashTagCount(count: 0);
    LocalStorage.saveDate(value: DateTime.now().millisecondsSinceEpoch);

    debugPrint("------------------------------------------------");
    debugPrint(DateTime.now().millisecondsSinceEpoch.toString());
    debugPrint("------------------------------------------------");
    debugPrint(LocalStorage.getDateString());
    debugPrint(LocalStorage.getDate().toString());

    debugPrint("Update User Plan to premium");
    debugPrint("Saved Date ${LocalStorage.getDate()}");
    debugPrint("Saved Date ${LocalStorage.getDateString()}");
    debugPrint("Saved Date ${LocalStorage.getSubscriptionDate()}");

    await _fireStore
        .collection('botUsers')
        .doc(LocalStorage.getId()!)
        .update({
      "isPremium": true,
      "textCount": 0,
      "imageCount": 0,
      "contentCount": 0,
      "hashTagCount": 0,
      "date": DateTime.now().millisecondsSinceEpoch
    });

    getUserInfo();
  }
}

















/// update suggestions cate and questions model
class CateogrySuggetion{
  final String catName;
  final List<String> questions;

  CateogrySuggetion({
    required this.catName,
    required this.questions
  });
}

List<String> interviewQuestions = [
  "What is knowledge based interview questions?",
  "What are the top 5 questions to ask an interviewer?",
  "What are the three good questions to ask an interviewer?",
  "What are the 10 most common interview questions with answers?",
  "What are some good questions to ask during an interview as the interviewer?",
  "How do you close an interview?",
  "How do you start an introduction for an interview?",
  "How do I sell myself in an interview?",
  "How do you know if your interview went well?",
  "How do I Prepare for an interview?",
  "How do I conduct a successful Interview?",
  "How do I handle difficult interview",
  "Using table,  generate interview report sheet for interview",
  "How do I assess a candidate’s potential for growth and development?"
];
List<String> businessAssistantQuestions = [
  "What are the responsibilities of a business Assistance?",
  "How do I become successful business assistance?",
  "What skills are required for business assistance?",
  "What are the best tools and software for business assistance?",
  "What is the role of virtual business assistance?",
  "How do I improve my organizational skills as business assistance?",
  "What are the best practices for effective communication as business assistance?",
  "How do I manage multiple tasks and priorities as a business assistant?",
  "How can a business assistant contribute to the growth of an organization?",
  "Suggest professional courses to my aid my efficiency as a business assistant ",
  "Is a business assistant a career?"
];
List<String> developerQuestions = [
  "What are the responsibilities of a business Assistance?",
  "How do I become successful business assistance?",
  "What skills are required for business assistance?",
  "What are the best tools and software for business assistance?",
  "What is the role of virtual business assistance?",
  "How do I improve my organizational skills as business assistance?",
  "What are the best practices for effective communication as business assistance?",
  "How do I manage multiple tasks and priorities as a business assistant?",
  "How can a business assistant contribute to the growth of an organization?",
  "Suggest professional courses to my aid my efficiency as a business assistant ",
  "Is a business assistant a career?"
];
List<String> advertiserQuestions = [
   "What are the 5 key points in advertising?",
   "What are the 4 main parts of an advertisement?",
   "What are the key questions to be kept in mind while planning an advertisement?",
   "Why are questions used in advertisements?",
   "The 10 Most Important Advertising Questions to Ask When Creating a Campaign",
   "What are the 4 C's of advertising?",
   "What are the 7 Cs of advertising?",
   "What are the two main types of advertising?",
   "What are the 10 functions of advertising?",
   "What are the two kinds of advertising?",
   "What makes a successful advertisement?",
   "What are the 3 main intentions of advertising?",
   "What are the elements of a successful advertisement?"
];
List<String> languageExpertQuestions = [
  "What makes language a language?",
   "What are the 7 elements of language?",
   "What does a language expert do?",
   "What are the 10 questions in English?",
   "What are the basic questions of linguistics?",
   "How do I prepare for a language interview?",
   "What are the five elements of language?",
   "What are the different types of questions in language teaching?",
   "What are common questions about language culture?",
   "What are the 4 fundamentals of language?",
   "What are natural language questions?",
   "What are the 4 linguistic features of a language?"
];
List<String> emailWritingQuestions = [
  "How do I write a professional email?",
   "What are some common email etiquette rules to follow?",
   "Write a letter of appreciation to a boss for….",
   "Write a Letters of recommendation",
   "Write an Interview follow-up letters.",
   "Write an Offer letters for the position of …",
   "Write a letter of termination of appointment for…",
   "Write a Letters of commendation. ...",
   "Write a Letters of resignation. ...",
   "What are some common mistakes to avoid when writing an email?",
   "What are 5 things that every email should include?",
   "What are 4 features of an email?",
   "What are the 3 styles of email?",
   "What are the six rules of email?",
];
List<String> chefQuestions = [
 "What are the five attributes of a great chef?",
 "What must a chef know?",
 "What challenges do chefs face?",
 "What are 4 duties of a chef?",
 "What are the 8 qualities of a professional chef?",
 "How many types of chefs are there?",
 "What is the greatest weakness of a chef?",
 "What is the difference between a chef and a cook?",
 "What are the 5 basics of cooking?",
 "What are the 4 rules of cooking?",
 "What are the six objectives of cooking?",
 "What are the questions for cook interview?",
 "What are the three cooking skills?"
];
List<String> mentalHealthQuestions = [
 "What are the 5 contributing factors to mental health?",
 "What causes mental health problems?",
 "What are the 3 levels of mental health?",
 "What are 3 parts of mental health?",
 "What are the top 3 mental health?",
 "What are all 7 components of health?",
 "What are the 12 aspects of health?",
 "How can exercise affect my mental health",
 "Suggest the best exercises that can help my mental health",
 "When do I need to see a doctor concerning my mental health",
 "What are the relationships between my mental health and my body"
];
List<String> selfImprovementQuestions = [
  "What are 3 areas of self-improvement?",
  "How do I self improve?",
  "What is an example of self-improvement?",
  "Why is self-improvement important?",
  "What are your 5 best self-improvement principles?",
  "What are the main areas of self-improvement?",
  "What are the 4 pillars of self-improvement?",
  "What are the 12 areas for self-improvement?",
  "What is the meaning of self-improvement?",
  "What are the 8 facets of self-improvement?",
  "What are the 5 areas of personal development?",
  "What is the principle of self-improvement?",
];

List<CateogrySuggetion> catList = [
  CateogrySuggetion(
      catName: "Interview",
      questions: interviewQuestions
  ),
  CateogrySuggetion(
      catName: "Business Assistant",
      questions: businessAssistantQuestions
  ),
  CateogrySuggetion(
      catName: "Developer",
      questions: developerQuestions
  ),
  CateogrySuggetion(
      catName: "Advertiser",
      questions: advertiserQuestions
  ),
  CateogrySuggetion(
      catName: "Language Expert",
      questions: languageExpertQuestions
  ),
  CateogrySuggetion(
      catName: "E-mail Writing",
      questions: emailWritingQuestions
  ),
  CateogrySuggetion(
      catName: "Chef",
      questions: chefQuestions
  ),
  CateogrySuggetion(
      catName: "Mental Health",
      questions: mentalHealthQuestions
  ),
  CateogrySuggetion(
      catName: "Self Improvement",
      questions: selfImprovementQuestions
  ),
];