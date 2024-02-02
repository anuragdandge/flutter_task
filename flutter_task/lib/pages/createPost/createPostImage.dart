import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/pages/home.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class CreatePostImage extends StatefulWidget {
  const CreatePostImage({super.key});

  @override
  State<CreatePostImage> createState() => _CreatePostImageState();
}

class _CreatePostImageState extends State<CreatePostImage> {
  File? image;
  final picker = ImagePicker();
  File? _selectedImage;
  File? _selectedVideo;
  late bool isUploading = false;
  late bool isUploded = false;
  TextEditingController caption = TextEditingController();
  String uuid = const Uuid().v4();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Image '),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: _selectPassportPhoto(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton.icon(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.blueAccent)),
                        label: const Text(
                          "Camera ",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: _pickImageFromCamera,
                        icon: const Icon(
                          Icons.camera,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton.icon(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.blueAccent)),
                        label: const Text(
                          "Gallery ",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(
                          Icons.photo,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: caption,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Add Caption';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Add Caption ",
                  ),
                ),
              ),
              isUploading ? CircularProgressIndicator() : SizedBox(),
              const SizedBox(
                height: 100,
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        if (_selectedImage == null) {
                          showDialog(
                            context: context,
                            builder: ((context) => AlertDialog(
                                  title: const Text("Select Photo "),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close"),
                                    )
                                  ],
                                )),
                          );
                        } else {
                          setState(() {
                            isUploading = true;
                          });
                          uploadImage();
                          Navigator.pop(context);
                        }
                      });
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
                    " Share ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectPassportPhoto() {
    if (_selectedImage != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: Colors.grey, width: 2),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.contain,
                width: double.infinity,
                height: 400,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1),
                    color: Colors.blue,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    )),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        height: 400,
        width: double.infinity,
        child: const Center(
            child: Text(
          " Select Image ",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        )),
      );
    }
  }

  Widget _buildAlertDialog() {
    return AlertDialog(
      title: const Text("Select Image "),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                style: ButtonStyle(
                    iconColor:
                        MaterialStatePropertyAll(Colors.deepPurple[400])),
                onPressed: () {
                  _pickImageFromCamera();
                  // _buildAlertDialog();
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt),
                    const SizedBox(width: 20),
                    Text("Camera ", style: TextStyle(color: Colors.blue[400])),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                style: ButtonStyle(
                    iconColor:
                        MaterialStatePropertyAll(Colors.deepPurple[400])),
                onPressed: () async {
                  _pickImageFromGallery();
                  //  get UUID from shared prefs
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var uuid = prefs.getString('uuid');
                  debugPrint(uuid);

                  // Get Document ID from firebase
                  QuerySnapshot snapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('uuid', isEqualTo: uuid)
                      .get();
                  var userId = snapshot.docs[0].id;
                  debugPrint(userId);

                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.upload_file),
                    const SizedBox(width: 20),
                    Text("Gallery ",
                        style: TextStyle(color: Colors.deepPurple[400]))
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Close",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        )
      ],
    );
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
      print(_selectedImage);
    });
  }

  Future _pickVideoFromGallery() async {
    final returnedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (returnedVideo == null) return;
    setState(() {
      _selectedVideo = File(returnedVideo.path);
      print(_selectedVideo);
    });
  }

  Future _pickImageFromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
      print(_selectedImage);
    });
  }

  Future uploadImage() async {
    if (_selectedImage == null) {
      showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text("Select Photo "),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                )
              ],
            )),
      );
    } else {
      //  get UUID from shared prefs
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

      //  Extract Extension
      final fileExtension = p.extension(_selectedImage!.path);

      var img = const Uuid().v4();
      // create Instance
      var firebaseStorage =
          FirebaseStorage.instance.ref('posts/$img$fileExtension');

      UploadTask uploadTask = firebaseStorage.putFile(
          _selectedImage!, SettableMetadata(contentType: 'image/jpg'));
      await uploadTask.whenComplete(() {});
      String downloadURL = await firebaseStorage.getDownloadURL();
      debugPrint(downloadURL);
      String durl = "$downloadURL$fileExtension";
      debugPrint(durl);

      addToUserProfile(userId, durl);
    }
  }

  void _generateNewUuid() {
    setState(() {
      uuid = const Uuid().v4(); // Generate a new random UUID
    });
  }

  Future<void> addToUserProfile(String userId, String durl) async {
    debugPrint("addToUserProfile");
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('users/$userId/posts');
    CollectionReference collRefP =
        FirebaseFirestore.instance.collection('posts');
    try {
      collRef.add(
        {
          'uuid': uuid,
          'postUrl': durl,
          'type': 'image',
          'caption': caption.text,
          'registeredAt': DateTime.now(),
        },
      );
      collRefP.add(
        {
          'userId': userId,
          'postUrl': durl,
          'type': 'image',
          'caption': caption.text,
          'registeredAt': DateTime.now(),
        },
      );
      // setState(() {
      //   isUploded = true;
      //   isUploading = false;
      //   Get.to(() => const Home());
      // });
      debugPrint("Data Added ");
    } catch (e) {
      debugPrint("Error $e");
    }
  }
}
