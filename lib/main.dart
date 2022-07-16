import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crud_lesson/auth_screen.dart';
import 'package:firebase_crud_lesson/storage_screen.dart';
import 'package:firebase_crud_lesson/video_screen.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MyHomePage();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController t1 = TextEditingController();

  final TextEditingController t2 = TextEditingController();

  final String firestoreCollectionName = "Yazilar";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> yaziEkle() async {
    if (t1.text.isNotEmpty && t2.text.isNotEmpty) {
      try {
        await _firestore.collection(firestoreCollectionName).doc(t1.text).set({
          "id": t1.text,
          "description": t2.text,
        });
        setState(() {
          t1.clear();
          t2.clear();
        });
      } catch (e) {
        print("bir problem oluştu");
      }
    }
  }

  Future<void> yaziGuncelle() async {
    if (t1.text.isNotEmpty && t2.text.isNotEmpty) {
      try {
        await _firestore
            .collection(firestoreCollectionName)
            .doc(t1.text)
            .update({
          "id": t1.text,
          "description": t2.text,
        });
        setState(() {
          t1.clear();
          t2.clear();
        });
      } catch (e) {
        print("bir problem oluştu");
      }
    }
  }

  Future<void> yaziSil() async {
    if (t1.text.isNotEmpty) {
      try {
        await _firestore
            .collection(firestoreCollectionName)
            .doc(t1.text)
            .delete();
        setState(() {
          t1.clear();
          t2.clear();
        });
      } catch (e) {
        print("bir problem oluştu");
      }
    }
  }

  Future<void> yaziOku() async {
    if (t1.text.isNotEmpty) {
      DocumentSnapshot? documentSnapshot = await _firestore
          .collection(firestoreCollectionName)
          .doc(t1.text)
          .get();
      if (documentSnapshot.data() != null) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("id : ${data["id"]}"),
                  content: Text("açıklama : ${data["description"]}"),
                ));
        t1.clear();
      } else {
        showDialog(
            context: context,
            builder: (context) => const AlertDialog(
                  title: Text("Yanlış id girişi"),
                ));
        setState(() {
          t1.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
          IconButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const StorageScreen()));
          }, icon: const Icon(Icons.person),),
          IconButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const VideoScreen()));
          }, icon: const Icon(Icons.video_call_outlined),),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: StreamBuilder(
                  stream: _firestore
                      .collection(firestoreCollectionName)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Bir hata oluştu',
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    } else if (snapshot.data == null) {
                      return const Center(
                        child: Text(
                          'Henüz bi görev eklemediniz',
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    } else {
                      List<DocumentSnapshot> listDocumentSnapshot =
                          snapshot.data.docs;
                      return ListView.builder(
                          itemCount: listDocumentSnapshot.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data =
                                listDocumentSnapshot[index].data()
                                    as Map<String, dynamic>;
                            return ListTile(
                              title: Text(data["id"]),
                              subtitle: Text(data['description']),
                            );
                          });
                    }
                  },
                ),
              ),
              TextField(
                controller: t1,
                decoration: const InputDecoration(hintText: "id"),
              ),
              TextField(
                controller: t2,
                decoration: const InputDecoration(hintText: "açıklama"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: yaziEkle,
                    style: ElevatedButton.styleFrom(primary: Colors.amber),
                    child: const Text("Ekle"),
                  )),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: yaziOku,
                          style: ElevatedButton.styleFrom(primary: Colors.blue),
                          child: const Text("Oku"))),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: yaziSil,
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    child: const Text("Sil"),
                  )),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: yaziGuncelle,
                    style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
                    child: const Text("Güncelle"),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
