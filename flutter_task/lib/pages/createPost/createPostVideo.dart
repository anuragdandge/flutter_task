import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/pages/home.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class CreatePostVideo extends StatefulWidget {
  const CreatePostVideo({Key? key}) : super(key: key);

  @override
  State<CreatePostVideo> createState() => _CreatePostVideoState();
}

class _CreatePostVideoState extends State<CreatePostVideo> {
  late File? _selectedVideo = File('');
  final TextEditingController caption = TextEditingController();
  String uuid = const Uuid().v4();
  late VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(''));
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer(File file) async {
    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.file(file)
      ..addListener(() => setState(() {}))
      ..setLooping(true)
      ..initialize().then((_) => _videoPlayerController!.play());
    setState(() {});
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Video")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  _selectedVideo != null
                      ? AspectRatio(
                          aspectRatio:
                              _videoPlayerController!.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController!),
                        )
                      : const SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: _pickVideoFromGallery,
                        child: const Row(
                          children: [
                            Icon(Icons.video_camera_back),
                            SizedBox(width: 20),
                            Text("Video From Gallery"),
                          ],
                        ),
                      ),
                    ],
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
                    border: OutlineInputBorder(),
                    hintText: "Add Caption",
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedVideo == null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Select Video"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        );
                      } else {
                        uploadVideo();
                        Navigator.pop(context);
                        Get.to(() => const Home());
                      }
                    }
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.all(16),
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                  child: const Text(
                    "Share",
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

  Future<void> _pickVideoFromGallery() async {
    final returnedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (returnedVideo == null) return;
    if (!mounted) return;
    setState(() {
      _selectedVideo = File(returnedVideo.path);
      print(_selectedVideo);
      initializePlayer(_selectedVideo!);
    });
  }

  Future uploadVideo() async {
    if (_selectedVideo == null) {
      showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text("Select Video "),
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
      final fileExtension = p.extension(_selectedVideo!.path);

      var vid = const Uuid().v4();
      // create Instance
      var firebaseStorage =
          FirebaseStorage.instance.ref('posts/$vid$fileExtension');

      UploadTask uploadTask = firebaseStorage.putFile(
          _selectedVideo!, SettableMetadata(contentType: 'video/mp4'));
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
    try {
      CollectionReference collRef =
          FirebaseFirestore.instance.collection('users/$userId/posts');
      CollectionReference collRefP =
          FirebaseFirestore.instance.collection('posts');
      collRef.add(
        {
          'uuid': uuid,
          'postUrl': durl,
          'type': 'video',
          'caption': caption.text,
          'registeredAt': DateTime.now(),
        },
      );
      collRefP.add(
        {
          'uuid': uuid,
          'postUrl': durl,
          'type': 'video',
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
