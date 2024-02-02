import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/pages/authentications/login.dart';
import 'package:flutter_task/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String uuid = const Uuid().v4();
  TextEditingController usernameController = TextEditingController();
  RegExp passValid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  bool validatePassword(String pass) {
    String password = pass.trim();

    if (passValid.hasMatch(password)) {
      return true;
    } else {
      return false;
    }
  }

  RegExp fullNameValid =
      RegExp(r"^[a-zA-Z]+(([',\.\-\s][a-zA-Z ])?[a-zA-Z]*)*$");
  bool validateFullName(String name) {
    String fullName = name.trim();

    if (fullNameValid.hasMatch(fullName)) {
      return true;
    } else {
      return false;
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full Name ';
                          } else {
                            bool result = validateFullName(value);
                            if (result) {
                              return null;
                            } else {
                              return " Name Should Contain Alphabets Only ";
                            }
                          }
                        },
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: ' Name',
                          labelText: 'Full name',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Username  ';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: ' Username ',
                          labelText: 'Username ',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: passwordController,
                        // obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Password ';
                          } else {
                            bool result = validatePassword(value);
                            if (result) {
                              return null;
                            } else {
                              return " Password should contain Capital, small letter & Number & Special";
                            }
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: ' Password ',
                          labelText: ' Password ',
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _generateNewUuid();
                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('isLoggedIn', true);
                              await prefs.setString("uuid", uuid);
                              await prefs.setString(
                                  "phone", widget.phoneNumber);
                              await prefs.setString(
                                  "name", nameController.text);
                              FirebaseFirestore firebaseFirestore =
                                  FirebaseFirestore.instance;
                              firebaseFirestore.collection("users").add({
                                "uuid": uuid,
                                "name": nameController.text,
                                "username": usernameController.text,
                                "password": passwordController.text,
                                "phone": widget.phoneNumber,
                              });
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Home(),
                                ),
                              );
                              debugPrint(
                                  "Successful${nameController.text}${usernameController.text}${passwordController.text} ${widget.phoneNumber}");
                            } else {
                              debugPrint("Unsuccessful");
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            padding: const MaterialStatePropertyAll(
                              EdgeInsets.all(16),
                            ),
                            backgroundColor:
                                const MaterialStatePropertyAll(Colors.blue),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 350,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Login(),
                                ),
                              );
                            },
                            child: const Text(
                              "Login ",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _generateNewUuid() {
    setState(() {
      uuid = const Uuid().v4(); // Generate a new random UUID
    });
  }
}
