import 'package:animate_do/animate_do.dart';
import 'package:diary/models/user_model.dart';
import 'package:diary/screens/home_screen.dart';
import 'package:diary/screens/login_screen.dart';
import 'package:diary/services/authService.dart';
import 'package:diary/services/userService.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  RegistrationScreen({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isLoading = false;

  void signup() async {
    setState(() {
      _isLoading = true;
    });

    final authService = AuthService();
    final userService = UserService();

    if (!_isValidEmail(widget._emailController.text)) {
      _showErrorDialog('Invalid email');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!_isValidUsername(widget._usernameController.text)) {
      _showErrorDialog('Please enter your First Name');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!_isValidLastName(widget._lastnameController.text)) {
      _showErrorDialog('Please enter your Last Name');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!_isValidPassword(widget._passwordController.text)) {
      _showErrorDialog('Password must be at least 6 characters long');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (widget._confirmPasswordController.text !=
        widget._passwordController.text) {
      _showErrorDialog('Passwords do not match');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await authService.signup(
          widget._emailController.text, widget._passwordController.text);

      User user = User(
        email: widget._emailController.text,
        firstName: widget._usernameController.text,
        lastName: widget._lastnameController.text,
        password: widget._passwordController.text,
      );

      await userService.saveUserToFirestore(
        widget._emailController.text,
        widget._usernameController.text,
        widget._lastnameController.text,
        widget._passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
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
                                fontWeight: FontWeight.bold),
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
                                color: Color.fromRGBO(143, 148, 251, 1)),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(143, 148, 251, .2),
                                  blurRadius: 20.0,
                                  offset: Offset(0, 10)),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color:
                                            Color.fromRGBO(143, 148, 251, 1)),
                                  ),
                                ),
                                child: TextField(
                                  controller: widget._emailController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Email",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color:
                                            Color.fromRGBO(143, 148, 251, 1)),
                                  ),
                                ),
                                child: TextField(
                                  controller: widget._usernameController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "First Name",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color:
                                            Color.fromRGBO(143, 148, 251, 1)),
                                  ),
                                ),
                                child: TextField(
                                  controller: widget._lastnameController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Last Name",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color:
                                            Color.fromRGBO(143, 148, 251, 1)),
                                  ),
                                ),
                                child: TextField(
                                  controller: widget._passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Password",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color:
                                            Color.fromRGBO(143, 148, 251, 1)),
                                  ),
                                ),
                                child: TextField(
                                  controller: widget._confirmPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Confirm Password",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      FadeInUp(
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
                                    fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        child: Text(
                          "Have an account? Login",
                          style: TextStyle(
                              color: Color.fromARGB(255, 245, 237, 5)),
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
