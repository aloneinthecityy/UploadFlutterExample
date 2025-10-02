import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  runApp(MaterialApp(home: Scaffold(body: UploadFirebase())));
}

class UploadFirebase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text("Upload Firebase"),
        onPressed: () async {
          final res = await FilePicker.platform.pickFiles(withData: true);
          if (res != null) {
            Uint8List bytes = res.files.first.bytes!;
            String name = res.files.first.name;
            await FirebaseStorage.instance.ref("uploads/$name").putData(bytes);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Feito!")));
          }
        },
      ),
    );
  }
}
