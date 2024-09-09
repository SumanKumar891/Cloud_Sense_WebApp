import 'package:flutter/material.dart';
import 'dart:ui'; // Required for BackdropFilter

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact Us',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow
        iconTheme: IconThemeData(
          color: Colors.black, // Set back arrow color to white
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/tower.jpg', // Update with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Apply blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color:
                    Colors.black.withOpacity(0.3), // Optional: Adjust opacity
              ),
            ),
          ),
          // AppBar on top of everything
          // Align(
          //   alignment: Alignment.topCenter,
          //   child: AppBar(
          //     title: Text(
          //       'Contact Us',
          //       style: TextStyle(color: Colors.black),
          //     ),
          //     backgroundColor: Colors.transparent, // Make AppBar transparent
          //     elevation: 0, // Remove shadow
          //     iconTheme: IconThemeData(
          //       color: Colors.black, // Set back arrow color to white
          //     ),
          //   ),
          // ),
          // Content on top of the blurred background
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(66.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    // Small screen: Column layout
                    return Column(
                      children: [
                        _info(),
                        _form(),
                      ],
                    );
                  } else {
                    // Large screen: Row layout
                    return Row(
                      children: [
                        Expanded(flex: 1, child: _info()),
                        Expanded(flex: 1, child: _form()),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info() {
    return Padding(
      padding: const EdgeInsets.only(
          right: 36.0, top: 36.0), // Add padding on the right side
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get in Touch',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                // Optional: Add shadows to the text for better visibility
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.black.withOpacity(0.6),
                  offset: Offset(3.0, 3.0),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'We would love to hear from you!\nWhether you have a question about our services, need assistance,\nor just want to provide feedback, feel free to reach out.',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          SizedBox(height: 32),
          Row(
            children: [
              Icon(Icons.email, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            ' contact.awadh@iitrpr.ac.in',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.phone, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Phone',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '01881 - 232601',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'IIT Ropar TIF (AWaDH), 214 / M. Visvesvaraya Block, Indian Institute of Technology Ropar, Rupnagar - 140001, Punjab ',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Add email functionality here
            },
            icon: Icon(Icons.mail),
            label: Text('Send an Email'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 201, 139, 219),
            ),
          ),
        ],
      ),
    );
  }

  Widget _form() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 36.0, top: 36), // Add padding on the left side
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white.withOpacity(
              0.8), // Optional: Add background color to make the form more readable
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 44),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 44),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: 'How can we help you?',
                    border: InputBorder.none,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your message';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 44.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Handle form submission
                  }
                },
                child: Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
