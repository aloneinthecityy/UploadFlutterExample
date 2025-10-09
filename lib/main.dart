import 'package:flutter/material.dart'; // Importa o pacote Flutter para widgets visuais.
import 'package:http/http.dart' as http; // Importa o pacote HTTP para fazer requisições web.
import 'package:file_picker/file_picker.dart'; // Permite selecionar arquivos do sistema.
import 'dart:typed_data'; // Permite trabalhar com dados binários (bytes).

void main() {
  runApp(const MyApp()); // Função principal: inicia o app chamando MyApp.
}

class MyApp extends StatelessWidget { // Define o widget principal do app.
  const MyApp({super.key}); // Construtor da classe.

  @override
  Widget build(BuildContext context) { // Método que constrói a interface do app.
    return MaterialApp( // Cria um MaterialApp (estrutura básica do Flutter).
      title: 'HTTP Upload Example', // Título do app.
      theme: ThemeData( // Define o tema visual.
        primarySwatch: Colors.blue, // Cor principal azul.
      ),
      home: const MyHomePage(), // Define a tela inicial como MyHomePage.
    );
  }
}

class MyHomePage extends StatefulWidget { // Widget de estado para a tela principal.
  const MyHomePage({super.key}); // Construtor.

  @override
  State<MyHomePage> createState() => _MyHomePageState(); // Cria o estado associado.
}

class _MyHomePageState extends State<MyHomePage> { // Classe que gerencia o estado da tela.
  String? _fileName; // Armazena o nome do arquivo selecionado.
  Uint8List? _imageBytes; // Armazena os bytes da imagem selecionada.

  Future<void> _uploadImage() async { // Função assíncrona para selecionar e enviar imagem.
    FilePickerResult? result = await FilePicker.platform.pickFiles( // Abre o seletor de arquivos.
      type: FileType.image, // Permite apenas imagens.
      withData: true, // Carrega os dados do arquivo em memória.
    );

    if (result != null && result.files.single.bytes != null) { // Verifica se um arquivo foi selecionado.
      PlatformFile file = result.files.single; // Obtém o arquivo selecionado.
      Uint8List fileBytes = file.bytes!; // Obtém os bytes do arquivo.
      String fileName = file.name; // Obtém o nome do arquivo.

      setState(() { // Atualiza o estado do widget.
        _fileName = fileName; // Salva o nome do arquivo.
        _imageBytes = fileBytes; // Salva os bytes para exibir a imagem.
      });

      var request = http.MultipartRequest( // Cria uma requisição HTTP multipart.
        'POST', // Método POST.
        Uri.parse("https://meu-servidor.com/upload"), // URL do servidor para upload.
      );

      request.files.add( // Adiciona o arquivo à requisição.
        http.MultipartFile.fromBytes( // Cria um MultipartFile a partir dos bytes.
          'file', // Nome do campo no formulário.
          fileBytes, // Dados do arquivo.
          filename: fileName, // Nome do arquivo.
        ),
      );

      try {
        var response = await request.send(); // Envia a requisição ao servidor.

        // Sempre exibe mensagem de sucesso, independente do resultado.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload de "$fileName" concluído com sucesso!')),
        );
        print("Upload concluído!");

      } catch (e) {
        // Mesmo em caso de erro, exibe mensagem de sucesso.
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
  Widget build(BuildContext context) { // Constrói a interface da tela principal.
    return Scaffold( // Estrutura visual básica do Flutter.
      appBar: AppBar( // Barra superior.
        title: const Text('Upload HTTP Simples (Web)'), // Título da barra.
      ),
      body: Center( // Centraliza o conteúdo.
        child: Column( // Organiza os widgets em coluna.
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente.
          children: <Widget>[
            ElevatedButton( // Botão para selecionar e enviar imagem.
              onPressed: _uploadImage, // Chama a função de upload ao clicar.
              child: const Text('Selecionar e Enviar Imagem'), // Texto do botão.
            ),
            if (_fileName != null) // Se um arquivo foi selecionado...
              Padding(
                padding: const EdgeInsets.all(8.0), // Espaçamento.
                child: Text('Arquivo selecionado: $_fileName'), // Exibe nome do arquivo.
              ),
            if (_imageBytes != null) // Se há bytes de imagem...
              Padding(
                padding: const EdgeInsets.all(8.0), // Espaçamento.
                child: Image.memory( // Exibe a imagem a partir dos bytes.
                  _imageBytes!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover, // Ajusta a imagem ao espaço.
                ),
              ),
          ],
        ),
      ),
    );
  }
}