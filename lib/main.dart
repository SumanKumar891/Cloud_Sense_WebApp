// import 'package:cloud_sense_webapp/HomePage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: HomePage(
//             //email: 'milanpreetkaur502@gmail.com',
//             ));
//   }
// }
// import 'package:amplify_authenticator/amplify_authenticator.dart';
// import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
// import 'package:flutter/material.dart';
// import 'amplifyconfiguration.dart';
// import 'package:cloud_sense_webapp/HomePage.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     _configureAmplify();
//   }

//   Future<void> _configureAmplify() async {
//     try {
//       final auth = AmplifyAuthCognito();
//       await Amplify.addPlugin(auth);
//       await Amplify.configure(amplifyconfig);
//     } on Exception catch (e) {
//       safePrint('An error occurred configuring Amplify: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Cloud Sense',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomePage(), // Reference to the HomePage
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_sense_webapp/homepage.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:cloud_sense_webapp/amplifyconfiguration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Configure Amplify
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print('Could not configure Amplify: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Sense',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

// import 'package:amplify_authenticator/amplify_authenticator.dart';
// import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
// import 'package:flutter/material.dart';

// import 'amplifyconfiguration.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     _configureAmplify();
//   }

//   Future<void> _configureAmplify() async {
//     try {
//       final auth = AmplifyAuthCognito();
//       await Amplify.addPlugin(auth);

//       // call Amplify.configure to use the initialized categories in your app
//       await Amplify.configure(amplifyconfig);
//     } on Exception catch (e) {
//       safePrint('An error occurred configuring Amplify: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Authenticator(
//       signUpForm: SignUpForm.custom(fields: [
//         SignUpFormField.name(),
//         SignUpFormField.email(),
//         SignUpFormField.password(),
//         SignUpFormField.passwordConfirmation(),
//       ]),
//       child: MaterialApp(
//         builder: Authenticator.builder(),
//         home: 
//         ),
//       ),
//     );
//   }
// }
