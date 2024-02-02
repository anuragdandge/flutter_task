import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'authentications/login.dart';
import 'createPost/createPostImage.dart';
import 'createPost/createPostVideo.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    getDetails();
  }

  File? _selectedImage;
  late String? name = "";
  late String? uuid = "";
  late String? phone = "";
  late String? profileUrl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: ((context) => AlertDialog(
                      title: const Text("Reel / Image"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Get.to(() => const CreatePostImage());
                                },
                                icon: const Icon(Icons.photo),
                                label: const Text(
                                  "Image",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // _pickVideoFromGallery();
                                  Get.to(() => const CreatePostVideo());
                                },
                                icon: const Icon(Icons.video_camera_back),
                                label: const Text(
                                  "Video",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Close",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )),
              );
            },
            icon: const Icon(Icons.add_box_outlined),
          ),
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLoggedIn', false);
              Navigator.pop(context);
              Navigator.pop(context);
              Get.to(() => const Login());
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      height: 60,
                      width: 60,
                      child: _selectedImage == null
                          ? IconButton(
                              onPressed: _pickImageFromGallery,
                              icon: Icon(Icons.add_photo_alternate))
                          : Image.network(profileUrl!),
                    ),
                    Text("$name"),
                  ],
                ),
                const Column(
                  children: [
                    Text(
                      "10",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Posts"),
                  ],
                ),
                const Column(
                  children: [
                    Text(
                      "20",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Followers"),
                  ],
                ),
                const Column(
                  children: [
                    Text(
                      "30",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Following"),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                var uuid = prefs.getString('uuid');
                QuerySnapshot snapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .where('uuid', isEqualTo: uuid)
                    .get();

                print(snapshot.docs[0].id);
              },
              child: const Text(" Edit Profile "),
            )
          ],
        ),
      ),
    );
  }

  Future<void> getDetails() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var n = sharedPreferences.getString('name');
    var p = sharedPreferences.getString('phone');
    var u = sharedPreferences.getString('uuid');
    print("$n+$p+$u");
    setState(() {
      name = n;
      phone = p;
      uuid = u;
    });
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    print(returnedImage);
    if (returnedImage == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uuid = prefs.getString('uuid');
    debugPrint(uuid);

    // Get Document ID from firebase
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uuid', isEqualTo: uuid)
        .get();
    var userId = snapshot.docs[0].id;
    debugPrint(userId);
    var firebaseStorage = FirebaseStorage.instance.ref('userProfiles/$uuid');
    UploadTask uploadTask = firebaseStorage.putFile(
        _selectedImage!, SettableMetadata(contentType: 'image/jpg'));
    await uploadTask.whenComplete(() {});
    String downloadURL = await firebaseStorage.getDownloadURL();
    debugPrint(downloadURL);
    String durl = "$downloadURL";
    debugPrint(durl);

    addToUserProfile(userId, durl);
    setState(() {
      _selectedImage = File(returnedImage.path);
      print(_selectedImage);
    });
  }

  Future<void> addToUserProfile(String userId, String durl) async {
    debugPrint("addToUserProfile");
    try {
      CollectionReference collRef =
          FirebaseFirestore.instance.collection('users/$userId');
      collRef.add(
        {
          'profileUrl': durl,
        },
      );
      setState(() {
        profileUrl = durl;
      });
      debugPrint("Data Added ");
    } catch (e) {
      debugPrint("Error $e");
    }
  }
}
