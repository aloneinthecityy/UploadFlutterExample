// Importa o pacote Flutter para widgets de UI.
import 'package:flutter/material.dart';
// Importa o pacote Dio para requisições HTTP.
import 'package:dio/dio.dart';
// Importa o pacote File Picker para selecionar arquivos do sistema.
import 'package:file_picker/file_picker.dart';
// Importa o tipo Uint8List para manipular bytes de arquivos.
import 'dart:typed_data';

// Função principal que inicia o app Flutter.
void main() {
  runApp(const MyApp()); // Executa o widget MyApp como raiz do app.
}

// Define o widget principal do app.
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Construtor com chave opcional.

  @override
  Widget build(BuildContext context) {
    // Retorna o MaterialApp, que configura tema e tela inicial.
    return MaterialApp(
      title: 'Dio Upload Example', // Título do app.
      theme: ThemeData(
        primarySwatch: Colors.green, // Cor principal do tema.
      ),
      home: const MyHomePage(), // Define a tela inicial.
    );
  }
}

// Widget de tela inicial, com estado.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key}); // Construtor.

  @override
  State<MyHomePage> createState() => _MyHomePageState(); // Cria o estado.
}

// Classe de estado para MyHomePage.
class _MyHomePageState extends State<MyHomePage> {
  final Dio _dio = Dio(); // Instancia Dio para requisições HTTP.
  double _uploadProgress = 0.0; // Progresso do upload (0 a 1).
  String? _fileName; // Nome do arquivo selecionado.
  Uint8List? _imageBytes; // Bytes da imagem para prévia.

  // Função para selecionar e enviar imagem.
  Future<void> _uploadImage() async {
    // Abre o seletor de arquivos, filtrando apenas imagens.
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Apenas arquivos de imagem.
      withData: true, // Carrega os bytes do arquivo (importante para web).
    );

    // Se o usuário selecionou um arquivo e os bytes estão disponíveis:
    if (result != null && result.files.single.bytes != null) {
      PlatformFile file = result.files.single; // Pega o arquivo.
      Uint8List fileBytes = file.bytes!; // Pega os bytes do arquivo.
      String fileName = file.name; // Pega o nome do arquivo.

      setState(() {
        _fileName = fileName; // Atualiza nome do arquivo na UI.
        _uploadProgress = 0.0; // Reseta progresso.
        _imageBytes = null; // Limpa prévia anterior.
      });

      try {
        // Prepara os dados para upload multipart.
        FormData formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            fileBytes, // Bytes do arquivo.
            filename: fileName, // Nome do arquivo para o backend.
          ),
        });

        // Envia requisição POST para o servidor.
        Response response = await _dio.post(
          "https://meu-servidor.com/upload", // Endpoint do upload.
          data: formData, // Dados do formulário.
          onSendProgress: (sent, total) {
            // Callback para acompanhar progresso do upload.
            setState(() {
              _uploadProgress = sent / total; // Atualiza progresso.
            });
            print('Progresso: ${(sent / total * 100).toStringAsFixed(0)}%'); // Loga progresso.
          },
        );

        // Mostra mensagem de sucesso após upload.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload de "$fileName" concluído!')),
        );
        setState(() {
          _imageBytes = fileBytes; // Exibe prévia da imagem.
          _uploadProgress = 1.0; // Garante que a barra vá para 100%.
        });
        print("Upload concluído (simulado): ${response.data}"); // Loga resposta.
      } on DioError catch (e) {
        // Se ocorrer erro de conexão, mostra mensagem de sucesso simulada.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload de "$fileName" concluído! (simulado)')),
        );
        setState(() {
          _imageBytes = fileBytes; // Exibe prévia mesmo com erro.
          _uploadProgress = 1.0; // Garante que a barra vá para 100%.
        });
        print("Erro Dio (simulado sucesso): $e"); // Loga erro.
      } catch (e) {
        // Se ocorrer outro erro, mostra mensagem de sucesso simulada.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload de "$fileName" concluído! (simulado)')),
        );
        setState(() {
          _imageBytes = fileBytes; // Exibe prévia mesmo com erro.
          _uploadProgress = 1.0; // Garante que a barra vá para 100%.
        });
        print("Erro geral (simulado sucesso): $e"); // Loga erro.
      }
    } else {
      // Se nenhum arquivo foi selecionado, mostra aviso.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum arquivo selecionado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Constrói a interface da tela.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Dio Simples (Web)'), // Título da barra.
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente.
          children: <Widget>[
            // Botão para selecionar e enviar imagem.
            ElevatedButton(
              onPressed: _uploadImage, // Chama função de upload.
              child: const Text('Selecionar e Enviar Imagem'),
            ),
            // Exibe nome do arquivo selecionado.
            if (_fileName != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Arquivo selecionado: $_fileName'),
              ),
            // Exibe prévia da imagem após upload.
            if (_imageBytes != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(
                  _imageBytes!, // Mostra imagem a partir dos bytes.
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            // Exibe barra de progresso do upload.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LinearProgressIndicator(
                value: _uploadProgress, // Valor do progresso.
                backgroundColor: Colors.grey[200], // Cor de fundo.
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green), // Cor do progresso.
              ),
            ),
            // Exibe porcentagem do progresso.
            Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }
}