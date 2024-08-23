import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'DeviceListPage.dart';

class SignInSignUpScreen extends StatefulWidget {
  @override
  _SignInSignUpScreenState createState() => _SignInSignUpScreenState();
}

class _SignInSignUpScreenState extends State<SignInSignUpScreen> {
  bool _isSignIn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fullscreen GIF background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/cloud.gif'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // AppBar with back arrow
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop(); // Go back to the previous screen
                },
              ),
              backgroundColor:
                  Colors.transparent, // Transparent AppBar background
              elevation: 0, // Remove shadow from AppBar
            ),
          ),
          // Main content
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
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String errorMessage = '';
    bool emailValid = true;
    bool isLoading = false;

    void validateEmail() {
      setState(() {
        emailValid = EmailValidator.validate(emailController.text);
      });
    }

    @override
    void initState() {
      super.initState();
      emailController.addListener(validateEmail);
    }

    @override
    void dispose() {
      emailController.dispose();
      passwordController.dispose();
      super.dispose();
    }

    return SingleChildScrollView(
      child: Row(
        key: ValueKey('SignIn'),
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
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(223, 205, 108, 230)),
                    ),
                  ),
                  Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      image: DecorationImage(
                        image: AssetImage('assets/loginImage.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                ]),
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
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    errorText: emailValid ? null : 'Invalid email format',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 22),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the DeviceListPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DeviceListPage()),
                    );
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 245, 241, 240)),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Color.fromARGB(223, 205, 108, 230),
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
      child: Row(
        key: ValueKey('SignUp'),
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
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(243, 173, 21, 211),
                    )),
                SizedBox(height: 36),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 36),
                ElevatedButton(
                  onPressed: () {
                    // Handle Sign Up action here
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 245, 241, 240)),
                  ),
                  style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Color.fromARGB(223, 205, 108, 230)),
                ),
                SizedBox(height: 36),
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
                  SizedBox(height: 16),
                  Text(
                    'Join Us Now!',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(223, 216, 226, 231)),
                  ),
                  SizedBox(height: 13),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, bottom: 0, top: 20),
                    child: Text(
                      'Create your account to experience seamless connection.',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(223, 205, 108, 230)),
                    ),
                  ),
                  Container(
                    width: 320,
                    height: 230,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      image: DecorationImage(
                        image: AssetImage('assets/signup3.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                ]),
          ),
        ],
      ),
    );
  }
}
