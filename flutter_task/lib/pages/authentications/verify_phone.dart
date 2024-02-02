import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login.dart';
import 'signup.dart';

class VerifyPhone extends StatefulWidget {
  const VerifyPhone({super.key});

  @override
  State<VerifyPhone> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  TextEditingController phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String smsCode = "";
  bool rememberUser = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RegExp phoneValid = RegExp(r"^\+?[0-9]{10,12}$");
  bool validatePhoneNumber(String phone) {
    String phoneNumber = phone.trim();

    if (phoneValid.hasMatch(phoneNumber)) {
      return true;
    } else {
      return false;
    }
  }

  _verifyPhoneNumber(String phone) async {
    debugPrint(" Phone Number Entered  ");
    setState(() {
      _isLoading = true;
    });
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: phone.trim(),
          verificationCompleted: (PhoneAuthCredential authCredential) async {
            await _auth.signInWithCredential(authCredential).then((value) {
              debugPrint("verificationCompleted...");
              setState(() {
                _isLoading = false;
              });
            });
          },
          verificationFailed: (((error) {
            print("Verification Failed  $error");
            debugPrint("verificationFailed !!! ");
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Verification Failed !!!")));
          })),
          codeSent: (String verificationId, [int? forceResendingToken]) {
            debugPrint("CodeSent...");
            setState(() {
              _isLoading = false;
            });
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                      title: const Text("Enter OTP"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                              controller: _codeController,
                              keyboardType: TextInputType.number)
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              debugPrint("OTP Entered !!!");
                              FirebaseAuth auth = FirebaseAuth.instance;
                              smsCode = _codeController.text;
                              PhoneAuthCredential credential =
                                  PhoneAuthProvider.credential(
                                      verificationId: verificationId,
                                      smsCode: smsCode);
                              auth
                                  .signInWithCredential(credential)
                                  .then((value) {
                                // ignore: unnecessary_null_comparison
                                if (value != null) {
                                  debugPrint("Verification Completed !!!");
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Get.to(() => SignUp(
                                        phoneNumber: phoneController.text,
                                      ));
                                } else {
                                  debugPrint("Verification Failed !!!");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Verification Failed !!!"),
                                    ),
                                  );
                                }
                              }).catchError((e) {
                                print(e);
                              });
                            },
                            child: const Text("Submit "))
                      ],
                    ));
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            verificationId = verificationId;
            debugPrint("CodeAutoRetrieval...");
          },
          timeout: const Duration(seconds: 45));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    child: Image.asset('assets/images/otp.jpg'),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "91*******",
                      labelText: "Phone Number",
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Colors.deepPurple,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Phone Number';
                      } else {
                        bool result = validatePhoneNumber(value);
                        if (result) {
                          return null;
                        } else {
                          return "Enter Number like +91*****";
                        }
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _verifyPhoneNumber("+91${phoneController.text}");
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Get OTP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
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
            ),
          ),
        ),
      ),
    );
  }
}
