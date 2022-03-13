import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/usermodel.dart';

class ProfileScreen extends StatefulWidget {
  UserModel user;

  ProfileScreen(this.user);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("User Profile"),
          centerTitle: true,
          backgroundColor: const Color(0xffee122a),
        ),
        body: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.user.uid)
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.data != null) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(50, 40, 15, 25),
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(80),
                                    child: Image.network(
                                      snapshot.data['image'],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(80, 1, 50, 10),
                                child: Text(snapshot.data['status'],
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.green)),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(80, 50, 50, 10),
                                child: Text(snapshot.data['name'],
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white)),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(55, 20, 50, 10),
                                child: Text(snapshot.data['email'],
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    })),
          ],
        ));
  }
}
