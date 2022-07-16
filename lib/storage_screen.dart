import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  @override
  void initState() {
    super.initState();
    baglantiAl();
  }
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  File? yuklenecekDosya;
  String? indirmeBaglantisi;
  Future<void> kameradanYukle()async{
    var alinanDosya = await ImagePicker().pickImage(source:  ImageSource.camera);
    setState(() {
      yuklenecekDosya = File(alinanDosya!.path);
    });
    Reference storageRef = FirebaseStorage.instance.ref().child("profilResimleri").child(firebaseAuth.currentUser!.uid).child("profilResmi.png");
    UploadTask task =  storageRef.putFile(yuklenecekDosya!);
  }
  Future<void> baglantiAl()async{
    String url =  await FirebaseStorage.instance.ref().child("profilResimleri").child(firebaseAuth.currentUser!.uid).child("profilResmi.png").getDownloadURL();
    setState(() {
    indirmeBaglantisi = url;
    });    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(children: [
        if(indirmeBaglantisi != null)
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImage(indirmeBaglantisi!))
          ),
        ),
        ElevatedButton(onPressed: kameradanYukle, child: const Text("Kameradan yukle"))
      ],)),
    );
  }
}