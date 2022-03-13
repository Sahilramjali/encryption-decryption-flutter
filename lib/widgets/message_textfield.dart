import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:encryptor/encryptor.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:permission_handler/permission_handler.dart';
//import 'package:uuid/uuid.dart';

class MessageTextField extends StatefulWidget {
  String? currentId;
  String? friendId;

  MessageTextField(this.currentId, this.friendId);

  @override
  _MessageTextFieldState createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  final TextEditingController _controller = TextEditingController();
  File? imagefile;
  File? file;
  String? fname;
  String password = "WKFGH^&@fka2345&13232&";
  /* Future getFile() async {
    ImagePicker _picker = ImagePicker();
    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imagefile = File(xFile.path);
        print(imagefile);
        uploadImage();
      }
    });
  }*/
  /* String? _path;
  File? encFilepath;
  encrypt() {
    AesCrypt crypt = AesCrypt();
    crypt.aesSetMode(AesMode.cbc);
    crypt.setPassword("abcdefk47589%7(0)");

    // Sets overwrite mode.
    // It's optional. By default the mode is 'AesCryptOwMode.warn'.
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    encFilepath = File(crypt.encryptFileSync(_path!));
  }*/

  Future selectfile() async {
    PlatformFile? pfile;
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    final path = result.files.single.path!;
    setState(() {
      file = File(path);
      // _path = file!.path;
      // encrypt();
      pfile = result.files.first;
      fname = pfile?.name;
      //fname = '$fname' + '.aes';
    });
    uploadFile();
    print(fname);
  }

  Future uploadFile() async {
    int status = 1;
    if (file == null) return;
    var fileName = fname;
    final destination = 'files/$fname';
    //  final destination = 'files/$fileName';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentId)
        .collection('messages')
        .doc(widget.friendId)
        .collection('chats')
        .doc(fileName)
        .set({
      "senderId": widget.currentId,
      "receiverId": widget.friendId,
      "message": "",
      "type": "file",
      "date": DateTime.now(),
      'fileurl': "",
      "status": ""
    });

    final ref = FirebaseStorage.instance.ref(destination);
//var uploadTask = await ref.putFile(file!).catchError((error) async {
    var uploadTask = await ref.putFile(file!).catchError((error) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentId)
          .collection('messages')
          .doc(widget.friendId)
          .collection('chats')
          .doc(fileName)
          .delete();
      status = 0;
    });
    if (status == 1) {
      String fileUrl = await uploadTask.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentId)
          .collection('messages')
          .doc(widget.friendId)
          .collection('chats')
          .doc(fileName)
          .update({
        "senderId": widget.currentId,
        "receiverId": widget.friendId,
        "message": (fname!),
        "type": "file",
        "date": DateTime.now(),
        "fileurl": fileUrl,
        "status": ""
      }).then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentId)
            .collection('messages')
            .doc(widget.friendId)
            .set({
          'last_msg': fname,
        });
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.friendId)
          .collection('messages')
          .doc(widget.currentId)
          .collection('chats')
          .add({
        "senderId": widget.currentId,
        "receiverId": widget.friendId,
        "message": (fname!),
        "type": "file",
        "date": DateTime.now(),
        "fileurl": fileUrl,
        "status": ""
      }).then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.friendId)
            .collection('messages')
            .doc(widget.currentId)
            .set({
          'last_msg': (fname!),
        });
      });

      print(fileUrl);
    }
  }

  /* Future uploadImage() async {
    int status = 1;
    String fileName = Uuid().v1();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentId)
        .collection('messages')
        .doc(widget.friendId)
        .collection('chats')
        .doc(fileName)
        .set({
      "senderId": widget.currentId,
      "receiverId": widget.friendId,
      "message": "",
      "type": "img",
      "date": DateTime.now(),
    });
    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imagefile!).catchError((error) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentId)
          .collection('messages')
          .doc(widget.friendId)
          .collection('chats')
          .doc(fileName)
          .delete();
      status = 0;
    });
    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentId)
          .collection('messages')
          .doc(widget.friendId)
          .collection('chats')
          .doc(fileName)
          .update({
        "senderId": widget.currentId,
        "receiverId": widget.friendId,
        "message": imageUrl,
        "type": "img",
        "date": DateTime.now(),
      }).then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentId)
            .collection('messages')
            .doc(widget.friendId)
            .set({
          'last_msg': imageUrl,
        });
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.friendId)
          .collection('messages')
          .doc(widget.currentId)
          .collection('chats')
          .add({
        "senderId": widget.currentId,
        "receiverId": widget.friendId,
        "message": imageUrl,
        "type": "img",
        "date": DateTime.now(),
      }).then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.friendId)
            .collection('messages')
            .doc(widget.currentId)
            .set({
          'last_msg': imageUrl,
        });
      });

      print(imageUrl);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white,
      padding: const EdgeInsets.fromLTRB(5, 0, 3, 55),
      child: Row(children: [
        Expanded(
            child: TextField(
          controller: _controller,
          decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  selectfile();
                },
                icon: const Icon(Icons.attach_file),
                color: Colors.white,
              ),
              labelText: "Enter Message",
              floatingLabelAlignment: FloatingLabelAlignment.center,
              floatingLabelStyle: const TextStyle(
                fontSize: 20,
              ),
              // fillColor: Colors.grey,
              // filled: true,
              border: OutlineInputBorder(
                borderSide: const BorderSide(width: 0),
                gapPadding: 5,
                borderRadius: BorderRadius.circular(25),
              )),
        )),
        const SizedBox(
          width: 20,
        ),
        GestureDetector(
          onTap: () async {
            FocusScope.of(context).unfocus();
            String message = _controller.text;

            if (_controller.text.isNotEmpty) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.currentId)
                  .collection('messages')
                  .doc(widget.friendId)
                  .collection('chats')
                  .add({
                "senderId": widget.currentId,
                "receiverId": widget.friendId,
                "message": Encryptor.encrypt(password, message),
                "type": "text",
                "date": DateTime.now(),
                "status": ""
              }).then((value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.currentId)
                    .collection('messages')
                    .doc(widget.friendId)
                    .set({
                  'last_msg': Encryptor.encrypt(password, message),
                });
              });

              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.friendId)
                  .collection('messages')
                  .doc(widget.currentId)
                  .collection('chats')
                  .add({
                "senderId": widget.currentId,
                "receiverId": widget.friendId,
                "message": Encryptor.encrypt(password, message),
                "type": "text",
                "date": DateTime.now(),
                "status": ""
              }).then((value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.friendId)
                    .collection('messages')
                    .doc(widget.currentId)
                    .set({
                  'last_msg': Encryptor.encrypt(password, message),
                });
              });
              _controller.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter message')));
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 1, 0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffee122a),
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        )
      ]),
    );
  }
}
