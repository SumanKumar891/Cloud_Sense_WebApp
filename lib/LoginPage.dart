// import 'package:flutter/material.dart';
// import 'package:email_validator/email_validator.dart';
// import 'dart:ui'; // Import for BackdropFilter
// import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
// import 'package:cloud_sense_webapp/DeviceListPage.dart';

// class SignInSignUpScreen extends StatefulWidget {
//   @override
//   _SignInSignUpScreenState createState() => _SignInSignUpScreenState();
// }

// class _SignInSignUpScreenState extends State<SignInSignUpScreen> {
//   bool _isSignIn = true;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   String _errorMessage = '';
//   bool _emailValid = true;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _emailController.addListener(() {
//       setState(() {
//         _emailValid = EmailValidator.validate(_emailController.text);
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   Future<void> _signIn() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final result = await Amplify.Auth.signIn(
//         username: _emailController.text,
//         password: _passwordController.text,
//       );

//       if (result.isSignedIn) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) =>
//                   DeviceListPage(emailId: 'user@example.com')),
//         );
//       }
//     } on AuthException catch (e) {
//       setState(() {
//         _errorMessage = e.message;
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _signUp() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final result = await Amplify.Auth.signUp(
//         username: _emailController.text,
//         password: _passwordController.text,
//         options: SignUpOptions(userAttributes: {
//           AuthUserAttributeKey.email: _emailController.text,
//           AuthUserAttributeKey.name: _nameController.text,
//         }),
//       );

//       if (result.isSignUpComplete) {
//         setState(() {
//           _isSignIn = true;
//         });
//       }
//     } on AuthException catch (e) {
//       setState(() {
//         _errorMessage = e.message;
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/sunn.jpg'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//               child: Container(
//                 color: Colors.black.withOpacity(0.2),
//               ),
//             ),
//           ),
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: AppBar(
//               leading: IconButton(
//                 icon: Icon(Icons.arrow_back),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//             ),
//           ),
//           Center(
//             child: AnimatedSwitcher(
//               duration: Duration(milliseconds: 800),
//               transitionBuilder: (Widget child, Animation<double> animation) {
//                 return SlideTransition(
//                   position: Tween<Offset>(
//                     begin: Offset(0.1, 0.0),
//                     end: Offset.zero,
//                   ).animate(animation),
//                   child: child,
//                 );
//               },
//               child: _isSignIn ? _buildSignIn() : _buildSignUp(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSignIn() {
//     return SingleChildScrollView(
//       key: ValueKey('SignIn'),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             width: 400,
//             height: 500,
//             color: const Color.fromARGB(155, 0, 0, 0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 55),
//                 Text(
//                   'Welcome Back!',
//                   style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Color.fromARGB(223, 216, 226, 231)),
//                 ),
//                 SizedBox(height: 15),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       left: 40, right: 40, bottom: 20, top: 20),
//                   child: Text(
//                     'To keep connected with us please login with your personal info.',
//                     style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(223, 205, 108, 230)),
//                   ),
//                 ),
//                 // Container(
//                 Padding(
//                   padding: const EdgeInsets.only(top: 20.0),
//                   child: Container(
//                     width: 290,
//                     height: 190,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(50),
//                       image: DecorationImage(
//                         image: AssetImage('assets/loginImage.png'),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: 400,
//             height: 500,
//             padding: EdgeInsets.all(32.0),
//             color: const Color.fromARGB(155, 255, 255, 255),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 24),
//                 Text(
//                   'Login',
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Color.fromARGB(243, 173, 21, 211),
//                   ),
//                 ),
//                 SizedBox(height: 42),
//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(),
//                     errorText: _emailValid ? null : 'Invalid email format',
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 TextField(
//                   controller: _passwordController,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(),
//                   ),
//                   obscureText: true,
//                 ),
//                 if (_errorMessage.isNotEmpty) ...[
//                   Text(
//                     _errorMessage,
//                     style: TextStyle(color: Colors.red),
//                   ),
//                   SizedBox(height: 16),
//                 ],
//                 if (_isLoading)
//                   CircularProgressIndicator()
//                 else
//                   Padding(
//                     padding: const EdgeInsets.only(top: 30.0),
//                     child: ElevatedButton(
//                       onPressed: _signIn,
//                       child: Text(
//                         'Sign In',
//                         style: TextStyle(
//                             color: const Color.fromARGB(255, 245, 241, 240)),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                         backgroundColor: Color.fromARGB(223, 205, 108, 230),
//                       ),
//                     ),
//                   ),
//                 SizedBox(height: 32),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Don\'t have an Account?',
//                       style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold,
//                           color: const Color.fromARGB(181, 113, 5, 214)),
//                     ),
//                     SizedBox(height: 16),
//                     TextButton(
//                       onPressed: () {
//                         setState(() {
//                           _isSignIn = false;
//                         });
//                       },
//                       child: Text(
//                         'Sign Up',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSignUp() {
//     return SingleChildScrollView(
//       key: ValueKey('SignUp'),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             width: 400,
//             height: 500,
//             padding: EdgeInsets.all(32.0),
//             color: const Color.fromARGB(155, 255, 255, 255),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 16),
//                 Text('Create Account',
//                     style: TextStyle(
//                       fontSize: 30,
//                       fontWeight: FontWeight.bold,
//                       color: Color.fromARGB(243, 173, 21, 211),
//                     )),
//                 SizedBox(height: 24),
//                 TextField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     labelText: 'Name',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(),
//                     errorText: _emailValid ? null : 'Invalid email format',
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 TextField(
//                   controller: _passwordController,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(),
//                   ),
//                   obscureText: true,
//                 ),
//                 if (_errorMessage.isNotEmpty) ...[
//                   Text(
//                     _errorMessage,
//                     style: TextStyle(color: Colors.red),
//                   ),
//                   SizedBox(height: 16),
//                 ],
//                 if (_isLoading)
//                   CircularProgressIndicator()
//                 else
//                   Padding(
//                     padding: const EdgeInsets.only(top: 20.0),
//                     child: ElevatedButton(
//                       onPressed: _signUp,
//                       child: Text(
//                         'Sign Up',
//                         style: TextStyle(
//                             color: const Color.fromARGB(255, 245, 241, 240)),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                         backgroundColor: Color.fromARGB(223, 205, 108, 230),
//                       ),
//                     ),
//                   ),
//                 SizedBox(height: 32),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Already have an Account?',
//                       style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold,
//                           color: const Color.fromARGB(181, 113, 5, 214)),
//                     ),
//                     SizedBox(height: 16),
//                     TextButton(
//                       onPressed: () {
//                         setState(() {
//                           _isSignIn = true;
//                         });
//                       },
//                       child: Text(
//                         'Sign In',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: 400,
//             height: 500,
//             color: const Color.fromARGB(155, 0, 0, 0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 55),
//                 Text(
//                   'Welcome to Cloud Sense!',
//                   style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Color.fromARGB(223, 216, 226, 231)),
//                 ),
//                 SizedBox(height: 15),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       left: 40, right: 40, bottom: 20, top: 20),
//                   child: Text(
//                     'Sign up to get started with Cloud Sense and keep track of your environmental data.',
//                     style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(223, 205, 108, 230)),
//                   ),
//                 ),
//                 Container(
//                   width: 250,
//                   height: 200,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(50),
//                     image: DecorationImage(
//                       image: AssetImage('assets/signup3.png'),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
