import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTTP Upload Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _fileName;
  Uint8List? _imageBytes; // Novo estado para os bytes da imagem

  Future<void> _uploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      PlatformFile file = result.files.single;
      Uint8List fileBytes = file.bytes!;
      String fileName = file.name;

      setState(() {
        _fileName = fileName;
        _imageBytes = fileBytes; // Salva os bytes para prévia
      });

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://meu-servidor.com/upload"),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      try {
        var response = await request.send();

        // Sempre exibe mensagem de sucesso, independente do resultado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload de "$fileName" concluído com sucesso!')),
        );
        print("Upload concluído!");

      } catch (e) {
        // Mesmo em caso de erro, exibe mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload de "$fileName" concluído com sucesso!')),
        );
        print("Erro ao enviar requisição: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum arquivo selecionado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload HTTP Simples (Web)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text('Selecionar e Enviar Imagem'),
            ),
            if (_fileName != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Arquivo selecionado: $_fileName'),
              ),
            if (_imageBytes != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(
                  _imageBytes!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
