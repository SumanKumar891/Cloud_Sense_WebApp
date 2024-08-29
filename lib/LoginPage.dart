import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:ui'; // Import for BackdropFilter
import 'package:cloud_sense_webapp/DeviceListPage.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class SignInSignUpScreen extends StatefulWidget {
  @override
  _SignInSignUpScreenState createState() => _SignInSignUpScreenState();
}

class _SignInSignUpScreenState extends State<SignInSignUpScreen> {
  bool _isSignIn = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _errorMessage = '';
  bool _emailValid = true;
  bool _isLoading = false;
  String? _verificationCode;
  String? _emailToVerify;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _emailValid = EmailValidator.validate(_emailController.text);
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SignInResult res = await Amplify.Auth.signIn(
        username: _emailController.text,
        password: _passwordController.text,
      );
      if (res.isSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DeviceListPage(emailId: _emailController.text),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Sign-in failed';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SignUpResult res = await Amplify.Auth.signUp(
        username: _emailController.text,
        password: _passwordController.text,
        options: SignUpOptions(
          userAttributes: {
            CognitoUserAttributeKey.email: _emailController.text,
            CognitoUserAttributeKey.name: _nameController.text,
          },
        ),
      );

      if (res.isSignUpComplete) {
        _emailToVerify = _emailController.text;
        Future.microtask(() => _showVerificationDialog());
        // _showVerificationDialog();
      } else {
        setState(() {
          _errorMessage = 'Sign-up failed';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmSignUp() async {
    if (_verificationCode == null || _emailToVerify == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      SignUpResult res = await Amplify.Auth.confirmSignUp(
        username: _emailToVerify!,
        confirmationCode: _verificationCode!,
      );
      if (res.isSignUpComplete) {
        setState(() {
          _isSignIn = true;
        });
      } else {
        setState(() {
          _errorMessage = 'Verification failed';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // void _showVerificationDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Verify Your Email'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //                 'A verification code has been sent to your email. Please enter the code below:'),
  //             TextField(
  //               onChanged: (value) {
  //                 _verificationCode = value;
  //               },
  //               decoration: InputDecoration(labelText: 'Verification Code'),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               _confirmSignUp();
  //             },
  //             child: Text('Submit'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify Your Email'),
          content: Padding(
            padding:
                const EdgeInsets.all(16.0), // Add padding around the content
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'A verification code has been sent to your email. Please enter the code below:',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                    height: 16), // Add space between the text and text field
                TextField(
                  onChanged: (value) {
                    _verificationCode = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType
                      .number, // Set keyboard type to number for code input
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _confirmSignUp(); // Confirm sign-up
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/sunn.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          Center(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 800),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.1, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              child: _isSignIn ? _buildSignIn() : _buildSignUp(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignIn() {
    return SingleChildScrollView(
      key: ValueKey('SignIn'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 400,
            height: 500,
            color: const Color.fromARGB(155, 0, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 55),
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(223, 216, 226, 231)),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 40, right: 40, bottom: 20, top: 20),
                  child: Text(
                    'To keep connected with us please login with your personal info.',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(223, 205, 108, 230)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    width: 290,
                    height: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      image: DecorationImage(
                        image: AssetImage('assets/loginImage.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 400,
            height: 500,
            padding: EdgeInsets.all(32.0),
            color: const Color.fromARGB(155, 255, 255, 255),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24),
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(243, 173, 21, 211),
                  ),
                ),
                SizedBox(height: 42),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    errorText: _emailValid ? null : 'Invalid email format',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: ElevatedButton(
                      onPressed: _signIn,
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 245, 241, 240)),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        backgroundColor: Color.fromARGB(223, 205, 108, 230),
                      ),
                    ),
                  ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an Account?',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(181, 113, 5, 214)),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignIn = false;
                        });
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUp() {
    return SingleChildScrollView(
      key: ValueKey('SignUp'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 400,
            height: 500,
            padding: EdgeInsets.all(32.0),
            color: const Color.fromARGB(155, 255, 255, 255),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                Text('Create Account',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(243, 173, 21, 211),
                    )),
                SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    errorText: _emailValid ? null : 'Invalid email format',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: _signUp,
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 245, 241, 240)),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        backgroundColor: Color.fromARGB(223, 205, 108, 230),
                      ),
                    ),
                  ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an Account?',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(181, 113, 5, 214)),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignIn = true;
                        });
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 400,
            height: 500,
            color: const Color.fromARGB(155, 0, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 55),
                Text(
                  'Welcome!',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(223, 216, 226, 231)),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 40, right: 40, bottom: 20, top: 20),
                  child: Text(
                    'Enter your personal details and start journey with us.',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(223, 205, 108, 230)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    width: 290,
                    height: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      image: DecorationImage(
                        image: AssetImage('assets/loginImage.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
