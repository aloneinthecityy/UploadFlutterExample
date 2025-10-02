import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upload Flutter Web',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UploadPage(),
    );
  }
}

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  double _progress = 0.0;

  /// Seleciona arquivo da máquina
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // pode trocar para FileType.any
      withData: true, // necessário para pegar bytes no Web
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFileBytes = result.files.first.bytes;
        _selectedFileName = result.files.first.name;
      });
    }
  }

  /// Faz upload para servidor fake
  Future<void> _uploadFile() async {
    if (_selectedFileBytes == null || _selectedFileName == null) return;

    Dio dio = Dio();

    try {
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(
          _selectedFileBytes!,
          filename: _selectedFileName,
        ),
      });

      final response = await dio.post(
        "https://httpbin.org/post", // servidor fake p/ teste
        data: formData,
        onSendProgress: (sent, total) {
          setState(() {
            _progress = sent / total;
          });
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload concluído! 🎉")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro no upload: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload no Flutter Web")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedFileBytes != null
                ? Image.memory(_selectedFileBytes!, height: 200)
                : const Icon(Icons.image, size: 150, color: Colors.grey),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.photo),
              label: const Text("Escolher Imagem"),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _uploadFile,
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Fazer Upload"),
            ),

            const SizedBox(height: 20),

            _progress > 0
                ? LinearProgressIndicator(value: _progress)
                : Container(),
          ],
        ),
      ),
    );
  }
}
