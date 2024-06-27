import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary/screens/login_screen.dart';
import 'package:diary/services/authService.dart';
import 'package:diary/services/userService.dart';
import 'package:animate_do/animate_do.dart';

class RegistrationScreen extends StatefulWidget {
  RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  bool _isLoading = false;

  void signup() async {
    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);

    if (!_isValidEmail(_emailController.text)) {
      _showErrorDialog('Invalid email');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!_isValidUsername(_usernameController.text)) {
      _showErrorDialog('Please enter your First Name');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!_isValidLastName(_lastnameController.text)) {
      _showErrorDialog('Please enter your Last Name');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!_isValidPassword(_passwordController.text)) {
      _showErrorDialog('Password must be at least 6 characters long');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_confirmPasswordController.text != _passwordController.text) {
      _showErrorDialog('Passwords do not match');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await authService.signup(_emailController.text, _passwordController.text);

      await userService.saveUserToFirestore(
        _emailController.text,
        _usernameController.text,
        _lastnameController.text,
        _passwordController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    return email.isNotEmpty && email.contains('@');
  }

  bool _isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  bool _isValidUsername(String username) {
    return username.isNotEmpty;
  }

  bool _isValidLastName(String lastname) {
    return lastname.isNotEmpty;
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/loginbg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FadeInUp(
                        duration: Duration(milliseconds: 1600),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20),
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      FadeInUp(
                        duration: Duration(milliseconds: 1800),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color.fromRGBO(143, 148, 251, 1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(143, 148, 251, .2),
                                blurRadius: 20.0,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromRGBO(143, 148, 251, 1),
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Email",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromRGBO(143, 148, 251, 1),
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "First Name",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromRGBO(143, 148, 251, 1),
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  controller: _lastnameController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Last Name",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromRGBO(143, 148, 251, 1),
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Password",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromRGBO(143, 148, 251, 1),
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Confirm Password",
                                    hintStyle: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      _isLoading
                          ? CircularProgressIndicator()
                          : FadeInUp(
                              duration: Duration(milliseconds: 1900),
                              child: GestureDetector(
                                onTap: signup,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromRGBO(143, 148, 251, 1),
                                        Color.fromRGBO(143, 148, 251, .6),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(height: 30),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors
                              .blue, // Choose your desired background color
                          borderRadius: BorderRadius.circular(
                              10), // Optional: Add border radius
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Have an account? Login",
                            style: TextStyle(
                              color: Color.fromARGB(255, 245, 237, 5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
