import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
      title: 'Dio Upload Example',
      theme: ThemeData(
        primarySwatch: Colors.green,
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
  final Dio _dio = Dio(); // Instância do Dio
  double _uploadProgress = 0.0; // Para mostrar o progresso do upload
  String? _fileName;
  Uint8List? _imageBytes; // Para armazenar os bytes da imagem

  Future<void> _uploadImage() async {
    // 1. Abre o seletor de arquivos
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // Importante para web
    );

    if (result != null && result.files.single.bytes != null) {
      // Obtém o nome e os bytes do arquivo selecionado
      PlatformFile file = result.files.single;
      Uint8List fileBytes = file.bytes!;
      String fileName = file.name;

      setState(() {
        _fileName = fileName;
        _uploadProgress = 0.0; // Reseta o progresso para um novo upload
        _imageBytes = null; // Limpa a prévia anterior
      });

      try {
        // 2. Prepara os dados para o formulário multipart
        FormData formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            fileBytes,
            filename: fileName, // Nome do arquivo para o backend
          ),
        });

        // 3. Envia a requisição POST com Dio
        Response response = await _dio.post(
          "https://meu-servidor.com/upload", // Substitua pelo seu endpoint de upload!
          data: formData,
          onSendProgress: (sent, total) {
            // Callback para acompanhar o progresso do upload
            setState(() {
              _uploadProgress = sent / total;
            });
            print('Progresso: ${(sent / total * 100).toStringAsFixed(0)}%');
          },
        );

        // Mensagem de sucesso SEMPRE após upload (mesmo que o servidor não exista)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload de "$fileName" concluído!')),
        );
        setState(() {
          _imageBytes = fileBytes; // Exibe a prévia da imagem após upload
        });
        print("Upload concluído (simulado): ${response.data}");
      } on DioError catch (e) {
        // Mensagem de sucesso mesmo em erro de conexão
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload de "$fileName" concluído! (simulado)')),
        );
        setState(() {
          _imageBytes = fileBytes; // Exibe a prévia da imagem após upload
        });
        print("Erro Dio (simulado sucesso): $e");
      } catch (e) {
        // Mensagem de sucesso mesmo em erro geral
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload de "$fileName" concluído! (simulado)')),
        );
        setState(() {
          _imageBytes = fileBytes; // Exibe a prévia da imagem após upload
        });
        print("Erro geral (simulado sucesso): $e");
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
        title: const Text('Upload Dio Simples (Web)'),
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
            // Mostra a prévia da imagem após upload
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
            // Mostra o progresso do upload
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }
}