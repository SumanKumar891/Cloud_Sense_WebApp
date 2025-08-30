import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cloud_sense_webapp/GPS.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_sense_webapp/DeviceListPage.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'main.dart';

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
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _isPasswordValid(String password) {
    final passwordRegex =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
    _emailController.addListener(() {
      setState(() {
        _emailValid = EmailValidator.validate(_emailController.text);
      });
    });
  }

  Future<void> _checkCurrentUser() async {
    try {
      var currentUser = await Amplify.Auth.getCurrentUser();
      var userAttributes = await Amplify.Auth.fetchUserAttributes();
      String? email;
      for (var attr in userAttributes) {
        if (attr.userAttributeKey == AuthUserAttributeKey.email) {
          email = attr.value;
          break;
        }
      }
      if (email != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(email);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          if (email.trim().toLowerCase() == "05agriculture.05@gmail.com") {
            print("Subscribing $email to GPS SNS topic in _checkCurrentUser.");
            await subscribeToGpsSnsTopic(token);
            await prefs.setBool('isGpsTokenSubscribed', true);
            bool? wasAmmoniaSubscribed =
                prefs.getBool('isAmmoniaTokenSubscribed');
            if (wasAmmoniaSubscribed == true) {
              await unsubscribeFromSnsTopic(token);
              await prefs.remove('isAmmoniaTokenSubscribed');
            }
            Navigator.pushReplacementNamed(context, '/deviceinfo');
          } else {
            bool hasAmmoniaSensor = await userHasAmmoniaSensor(email);
            if (hasAmmoniaSensor) {
              print(
                  "Subscribing $email to ammonia SNS topic in _checkCurrentUser.");
              await subscribeToSnsTopic(token);
              await prefs.setBool('isAmmoniaTokenSubscribed', true);
            }
            bool? wasGpsSubscribed = prefs.getBool('isGpsTokenSubscribed');
            if (wasGpsSubscribed == true) {
              await unsubscribeFromGpsSnsTopic(token);
              await prefs.remove('isGpsTokenSubscribed');
            }
            Navigator.pushReplacementNamed(context, '/devicelist');
          }
        }
      }
    } catch (_) {
      // Not signed in — stay on SignInSignUpScreen
    }
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
      _isLoading = true; // Show loading indicator
    });

    try {
      // Ensure any previous session is cleared before signing in
      try {
        await Amplify.Auth.signOut();
      } catch (e) {
        print("Ignoring sign-out error before sign-in: $e");
      }

      // Attempt to sign in with provided credentials
      SignInResult res = await Amplify.Auth.signIn(
        username: _emailController.text,
        password: _passwordController.text,
      );

      if (res.isSignedIn) {
        // Store email in shared preferences for session management
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String email = _emailController.text.trim().toLowerCase();
        await prefs.setString('email', email);

        // Update UserProvider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(email);

        print("✅ User logged in: $email");

        // 🔹 Get FCM Token and subscribe to appropriate SNS topic
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          if (email == "05agriculture.05@gmail.com") {
            print("Subscribing $email to GPS SNS topic.");
            await subscribeToGpsSnsTopic(token);
            await prefs.setBool('isGpsTokenSubscribed', true);
            // Ensure ammonia is unsubscribed for this user
            bool? wasAmmoniaSubscribed =
                prefs.getBool('isAmmoniaTokenSubscribed');
            if (wasAmmoniaSubscribed == true) {
              await unsubscribeFromSnsTopic(token);
              await prefs.remove('isAmmoniaTokenSubscribed');
            }
          } else {
            bool hasAmmoniaSensor = await userHasAmmoniaSensor(email);
            if (hasAmmoniaSensor) {
              print("Subscribing $email to ammonia SNS topic.");
              await subscribeToSnsTopic(token);
              await prefs.setBool('isAmmoniaTokenSubscribed', true);
            } else {
              print(
                  "No ammonia sensor found for $email. Skipping subscription.");
            }
            // Ensure GPS is unsubscribed for non-authorized users
            bool? wasGpsSubscribed = prefs.getBool('isGpsTokenSubscribed');
            if (wasGpsSubscribed == true) {
              await unsubscribeFromGpsSnsTopic(token);
              await prefs.remove('isGpsTokenSubscribed');
            }
          }
          print("✅ Subscription handling completed after login.");
        } else {
          print("⚠ FCM Token not available at login.");
        }

        // ✅ Navigate based on specific user
        if (email == "05agriculture.05@gmail.com") {
          print("Navigating to /deviceinfo for $email");
          Navigator.pushReplacementNamed(context, '/deviceinfo');
        } else {
          print("Navigating to /devicelist for $email");
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        _showSnackbar('Sign-in failed');
      }
    } on AuthException catch (e) {
      print("AuthException during sign-in: ${e.message}");
      _showSnackbar(e.message); // Show error message if sign-in fails
    } catch (e) {
      print("Unexpected error during sign-in: $e");
      _showSnackbar('An unexpected error occurred');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _forgotPassword() async {
    String? email = await _showEmailInputDialog();
    if (email != null && EmailValidator.validate(email)) {
      try {
        await Amplify.Auth.resetPassword(username: email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A password reset code has been sent to your email.'),
          ),
        );
        _showPasswordResetCodeDialog(email);
      } on AuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } else {
      _showSnackbar('Please enter a valid email address.');
    }
  }

  Future<void> _showPasswordResetCodeDialog(String email) async {
    String? resetCode;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController resetCodeController = TextEditingController();

        return AlertDialog(
          title: Text('Enter Reset Code'),
          content: TextField(
            controller: resetCodeController,
            decoration: InputDecoration(labelText: 'Reset Code'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                resetCode = resetCodeController.text;
                Navigator.of(context).pop();
                if (resetCode != null && resetCode!.isNotEmpty) {
                  _showNewPasswordDialog(email, resetCode!);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNewPasswordDialog(String email, String resetCode) async {
    String? newPassword;
    String? confirmPassword;
    bool passwordsMatch = true;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController newPasswordController = TextEditingController();
        TextEditingController confirmPasswordController =
            TextEditingController();

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Enter New Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: newPasswordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  if (!passwordsMatch)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Passwords do not match',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Submit'),
                  onPressed: () async {
                    newPassword = newPasswordController.text;
                    confirmPassword = confirmPasswordController.text;

                    if (newPassword == confirmPassword) {
                      Navigator.of(context).pop();
                      await _confirmResetPassword(
                          email, resetCode, newPassword!);
                    } else {
                      setState(() {
                        passwordsMatch = false;
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmResetPassword(
      String email, String resetCode, String newPassword) async {
    try {
      await Amplify.Auth.confirmResetPassword(
        username: email,
        newPassword: newPassword,
        confirmationCode: resetCode,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Password has been reset. Please log in with your new password.')),
      );
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  Future<String?> _showEmailInputDialog() async {
    String? email;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController emailController = TextEditingController();
        return AlertDialog(
          title: Text('Reset Password'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                email = emailController.text;
                Navigator.of(context).pop(email);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true; // Show loading indicator during sign-up
    });

    // Manual password check BEFORE sign-up attempt
    final password = _passwordController.text;
    if (!_isPasswordValid(password)) {
      setState(() {
        _isLoading = false;
      });

      // Show snackbar directly without setting _errorMessage
      _showSnackbar(
        'Password must be at least 8 characters long and include:a number,a special character, a letter',
      );
      return;
    }

    try {
      // Sign up with email, password, and name attributes
      final res = await Amplify.Auth.signUp(
        username: _emailController.text,
        password: _passwordController.text,
        options: SignUpOptions(
          userAttributes: {
            CognitoUserAttributeKey.email: _emailController.text,
            CognitoUserAttributeKey.name: _nameController.text,
          },
        ),
      );

      // ✅ Here we check if sign-up is complete
      if (res.isSignUpComplete) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-up successful! Please sign in.')),
        );
        setState(() {
          _isSignIn = true; // Switch to sign-in mode
        });
      } else {
        // ⚠ Verification required
        _emailToVerify = _emailController.text;
        _showVerificationDialog(); // Prompt user to enter verification code
      }
    } on UsernameExistsException {
      // Resend code if user already exists but hasn't verified
      try {
        await Amplify.Auth.resendSignUpCode(username: _emailController.text);
        _emailToVerify = _emailController.text;
        _showVerificationDialog();
      } on AuthException catch (e) {
        _showSnackbar(e.message); // 🔴 Snackbar only for error
      }
    } on AuthException catch (e) {
      _showSnackbar(e.message); // 🔴 Snackbar only for error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendVerificationCode() async {
    if (_emailToVerify == null) {
      _showSnackbar(
          'Please provide your email to resend the verification code.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Amplify.Auth.resendSignUpCode(username: _emailToVerify!);
      _showSnackbar('Verification code has been resent to your email.');
    } on AuthException catch (e) {
      _showSnackbar(e.message);
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
      await Amplify.Auth.confirmSignUp(
        username: _emailToVerify!,
        confirmationCode: _verificationCode!,
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(_emailToVerify!);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _emailToVerify!);
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        bool hasAmmoniaSensor = await userHasAmmoniaSensor(_emailToVerify!);
        if (hasAmmoniaSensor) {
          print(
              "Subscribing $_emailToVerify to ammonia SNS topic after sign-up.");
          await subscribeToSnsTopic(token);
          await prefs.setBool('isAmmoniaTokenSubscribed', true);
        }
        bool? wasGpsSubscribed = prefs.getBool('isGpsTokenSubscribed');
        if (wasGpsSubscribed == true) {
          await unsubscribeFromGpsSnsTopic(token);
          await prefs.remove('isGpsTokenSubscribed');
        }
      }

      setState(() {
        _isSignIn = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up successful! Please sign in.')),
      );
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

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify Your Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'A verification code has been sent to your email. Please enter the code below:'),
              TextField(
                onChanged: (value) {
                  _verificationCode = value;
                },
                decoration: InputDecoration(labelText: 'Verification Code'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _resendVerificationCode();
              },
              child: Text('Resend Code'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmSignUp();
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black,
              size: MediaQuery.of(context).size.width < 800 ? 16 : 32),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            color: isDarkMode ? const Color(0xFF121212) : Colors.transparent,
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
              child: _isSignIn ? _buildSignIn(isDarkMode) : _buildSignUp(),
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 15.0,
              child: Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.redAccent,
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSignIn(bool isDarkMode) {
    return SingleChildScrollView(
      key: ValueKey('SignIn'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 800;
          return isSmallScreen
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildContent(isSmallScreen, isDarkMode),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildContent(isSmallScreen, isDarkMode),
                );
        },
      ),
    );
  }

  List<Widget> _buildContent(bool isSmallScreen, bool isDarkMode) {
    return [
      Container(
        width: isSmallScreen ? double.infinity : 400,
        height: 500,
        color: isDarkMode
            ? const Color.fromARGB(255, 231, 231, 231)
            : const Color.fromARGB(255, 38, 37, 37),
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
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Text(
                'To keep connected with us please login with your personal info.',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? const Color.fromARGB(255, 13, 123, 233)
                      : const Color.fromARGB(255, 49, 145, 241),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Container(
                width: 250,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  image: DecorationImage(
                    image: AssetImage('assets/signin.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        width: isSmallScreen ? double.infinity : 400,
        height: 500,
        padding: EdgeInsets.all(32.0),
        color: isDarkMode
            ? const Color.fromARGB(255, 38, 37, 37)
            : const Color.fromARGB(255, 231, 231, 231),
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
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 42),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(),
                errorText: _emailValid ? null : 'Invalid email format',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.redAccent : Colors.red),
                ),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.blue
                          : const Color.fromARGB(255, 76, 39, 176)),
                ),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            if (_isLoading)
              CircularProgressIndicator()
            else
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: _signIn,
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.black
                          : const Color.fromARGB(255, 245, 241, 240),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    backgroundColor: isDarkMode
                        ? const Color.fromARGB(255, 13, 123, 233)
                        : const Color.fromARGB(255, 49, 145, 241),
                  ),
                ),
              ),
            SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _forgotPassword,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: -1,
                        child: Container(
                          height: 1.5,
                          width: 40,
                          color: isDarkMode
                              ? Colors.blue
                              : Color.fromARGB(243, 32, 39, 230),
                        ),
                      ),
                      Text(
                        'Reset',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.blue : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an Account?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSignIn = false;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: -1,
                        child: Container(
                          height: 1.5,
                          width: 45,
                          color: isDarkMode
                              ? Colors.blue
                              : Color.fromARGB(243, 32, 39, 230),
                        ),
                      ),
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.blue : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ];
  }

  Widget _buildSignUp() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      key: ValueKey('SignUp'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 800;
          return isSmallScreen
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildSignUpContent(isSmallScreen, isDarkMode),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildSignUpContent(isSmallScreen, isDarkMode),
                );
        },
      ),
    );
  }

  List<Widget> _buildSignUpContent(bool isSmallScreen, bool isDarkMode) {
    return [
      Container(
        width: isSmallScreen ? double.infinity : 400,
        height: 500,
        color: isDarkMode
            ? const Color.fromARGB(255, 231, 231, 231)
            : const Color.fromARGB(255, 38, 37, 37),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text(
              'Welcome!',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.black : Colors.white),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Text(
                'Enter your personal details and start your journey with us.',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? const Color.fromARGB(255, 13, 123, 233)
                      : const Color.fromARGB(255, 49, 145, 241),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Container(
                width: 250,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  image: DecorationImage(
                    image: AssetImage('assets/signin.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        width: isSmallScreen ? double.infinity : 400,
        height: 500,
        padding: EdgeInsets.all(32.0),
        color: isDarkMode
            ? const Color.fromARGB(255, 38, 37, 37)
            : const Color.fromARGB(255, 231, 231, 231),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.blue
                          : const Color.fromARGB(255, 76, 39, 176)),
                ),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(),
                errorText: _emailValid ? null : 'Invalid email format',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.redAccent : Colors.red),
                ),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.blue
                          : const Color.fromARGB(255, 76, 39, 176)),
                ),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
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
                        color: isDarkMode
                            ? Colors.black
                            : const Color.fromARGB(255, 245, 241, 240)),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    backgroundColor: isDarkMode
                        ? const Color.fromARGB(255, 13, 123, 233)
                        : const Color.fromARGB(255, 49, 145, 241),
                  ),
                ),
              ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an Account?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSignIn = true;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: -1,
                        child: Container(
                          height: 1.5,
                          width: 45,
                          color: isDarkMode
                              ? Colors.blue
                              : Color.fromARGB(243, 32, 39, 230),
                        ),
                      ),
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.blue : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ];
  }
}
