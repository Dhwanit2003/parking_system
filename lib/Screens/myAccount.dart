import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String? profileImageUrl;
  String collectionName = "";
  final String defaultImageUrl = "https://www.w3schools.com/howto/img_avatar.png";


  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot adminDoc =
    await _firestore.collection('Admin').doc(user!.displayName).get();

    if (adminDoc.exists) {
      collectionName = "Admin"; // Set the collection type
      loadUserData(adminDoc);
    } else {
      // If not found in Admin, check in "Employee"
      DocumentSnapshot employeeDoc =
      await _firestore.collection('Employee').doc(user!.displayName).get();

      if (employeeDoc.exists) {
        collectionName = "Employee"; // Set the collection type
        loadUserData(employeeDoc);
      }
    }
  }
  void loadUserData(DocumentSnapshot userDoc) {
    setState(() {
      emailController.text = userDoc['email'] ?? '';
      phoneController.text = userDoc['phoneNumber'] ?? '';
      nameController.text = userDoc['name'] ?? '';
    });
  }

  Future<void> updateUserData() async {
    if (user != null) {
      await _firestore.collection(collectionName).doc(user!.displayName).set({
        'email': emailController.text,
        'phoneNumber': phoneController.text,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account updated successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => context.pop(),
      ),
          title: Text("My Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(profileImageUrl ?? defaultImageUrl),

            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                prefixIcon: const Icon(Icons.account_circle_rounded, color: Colors.grey),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                prefixIcon: const Icon(Icons.mail , color: Colors.grey),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                prefixIcon: const Icon(Icons.phone, color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateUserData,
              child: Text("UPDATE ACCOUNT"),
            ),
          ],
        ),
      ),
    );
  }
}
