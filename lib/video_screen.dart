import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VideoScreen extends StatefulWidget {
const VideoScreen({Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  File? yuklenecekDosya;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? indirmeBaglantisi;

  Future<void> kameradanVideoYukle()async{
    var alinanDosya = await ImagePicker().pickVideo(source: ImageSource.camera);
    setState(() {
      yuklenecekDosya = File(alinanDosya!.path);
    });
    Reference videoRef = FirebaseStorage.instance.ref().child("videolar").child("video.mp4");
    UploadTask task = videoRef.putFile(yuklenecekDosya!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,  
        children: [
        ElevatedButton(onPressed: kameradanVideoYukle, child: const Text("Upload Video"))
      ],),),
    );
  }
}