import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/pages/home.dart';
import 'package:flutter_task/pages/authentications/verify_phone.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Column(children: [
                  Container(
                      child: Image.asset("assets/images/Instagram_logo.png")),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Username  ';
                      }
                      return null;
                    },
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: ' Phone Number  ',
                      labelText: 'Phone Number  ',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: passwordController,
                    obscureText: passwordController.text.isEmpty
                        ? false
                        : isPasswordVisible,
                    obscuringCharacter: '*',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Password ';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                      hintText: ' Password ',
                      labelText: ' Password ',
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
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
                      onPressed: () async {
                        final snapshot = await checkCredentials();
                        if (snapshot.docs.isNotEmpty) {
                          for (QueryDocumentSnapshot document
                              in snapshot.docs) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            String password = data['password'];
                            String uuid = data['uuid'];
                            String name = data['name'];
                            String phone = data['phone'];

                            if (passwordController.text != password) {
                              // ignore: use_build_context_synchronously
                              showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                  title: Text("Password Not Matched "),
                                ),
                              );
                            } else {
                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('isLoggedIn', true);
                              await prefs.setString('uuid', uuid);
                              await prefs.setString('phone', phone);
                              await prefs.setString('name', name);
                              debugPrint(" User Logged In !!!");
                              debugPrint("$uuid");
                              debugPrint("$name");
                              debugPrint("$phone");
                              Navigator.pop(context);

                              Get.to(() => const Home());
                            }
                          }
                        } else {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Phone Number does not exist '),
                              duration: Duration(
                                  seconds: 2), // Adjust the duration as needed
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VerifyPhone(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<QuerySnapshot> checkCredentials() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phoneController.text)
        .get();
    return snapshot;
  }
}
