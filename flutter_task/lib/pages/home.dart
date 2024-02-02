import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/pages/createPost/createPostImage.dart';
import 'package:flutter_task/pages/createPost/createPostVideo.dart';
import 'package:flutter_task/pages/profile.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late VideoPlayerController? _videoPlayerController;

  final collection = FirebaseFirestore.instance.collection('posts');
  late List<Map<String, dynamic>> posts = [];
  bool isLoaded = false;

  Future<void> _getPosts() async {
    final collection = FirebaseFirestore.instance.collection('posts');

    var data = await collection.get();

    List<Map<String, dynamic>> tempList = [];

    for (var element in data.docs) {
      tempList.add(element.data());
    }

    setState(() {
      posts = tempList;
      isLoaded = true;
      print(tempList);
    });
  }

  Future<void> refreshList() async {
    _getPosts();
  }

  @override
  void initState() {
    super.initState();
    _getPosts();
    _videoPlayerController = VideoPlayerController.file(File(''));
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              debugPrint("Result ");
              _getPosts();
            },
            icon: const Icon(Icons.favorite_border_outlined),
          ),
        ],
      ),
      body: isLoaded != true
          ? const CircularProgressIndicator()
          : RefreshIndicator(
              onRefresh: refreshList,
              child: Container(
                width: double.infinity,
                child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          posts[index]['type'] == "image"
                              ? Image.network(
                                  posts[index]['postUrl'],
                                )
                              : Container(
                                  child: Text("Video"),
                                ),
                          Text(posts[index]['caption']),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.favorite_border),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(FontAwesomeIcons.comment),
                              ),
                            ],
                          )
                        ],
                      );
                    }),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {},
              icon: Icon(Icons.home),
            ),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.video),
            label: "Reels",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                Get.to(() => const Profile());
              },
              icon: const Icon(Icons.person_outline_outlined),
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
