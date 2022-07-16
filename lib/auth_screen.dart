import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController t1 = TextEditingController();
  final TextEditingController t2 = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: t1,
              decoration: InputDecoration(
                  hintText: "Username",
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: t2,
              decoration: InputDecoration(
                  hintText: "Password",
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: loginUser, child: const Text("Login"),),),
                const SizedBox(width: 10,),
                Expanded(child: ElevatedButton(onPressed: createUser, child: const Text("Register"),),),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> createUser() async{
    if (t1.text.isNotEmpty && t2.text.isNotEmpty) {
      try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: t1.text, password: t2.text);
      await  _firestore.collection("Kullanicilar").doc(userCredential.user?.email).set({
        "email" :userCredential.user?.email, 
      });
    } on FirebaseAuthException catch(e) {
      if (e.code == 'email-already-in-use') {
        showDialog(context: context, builder: (context) => const AlertDialog(content: Text("bu email zaten mevcut"),));
      } else if(e.code == 'weak-password'){
        showDialog(context: context, builder: (context) => const AlertDialog(content: Text("şifreyi güçlendirin"),));
        
      }
    }catch(e){
      print(e);
    }
    }else{
        showDialog(context: context, builder: (context) => const AlertDialog(content: Text("Alanlar boş bırakılamaz"),));
    }
  }
  Future<void> loginUser() async{
    if (t1.text.isNotEmpty && t2.text.isNotEmpty) {
      try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: t1.text, password: t2.text);
      print(userCredential.user?.email);
    } on FirebaseAuthException catch(e) {
      if (e.code == "user-not-found") {
        showDialog(context: context, builder: (context) => const AlertDialog(content: Text("Kullanıcı bulunamadı"),));
      } else if(e.code == "wrong-password"){
        showDialog(context: context, builder: (context) => const AlertDialog(content: Text("şifre hatalı"),));
      }
    }catch(e){
      print(e);
    }
    }else{
        showDialog(context: context, builder: (context) => const AlertDialog(content: Text("Alanlar boş bırakılamaz"),));
    }
  }
}
