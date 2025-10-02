import 'package:http/http.dart' as http;
import 'dart:io';

Future<void> uploadImage(File file) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse("https://meu-servidor.com/upload"),
  );

  request.files.add(
    await http.MultipartFile.fromPath('file', file.path),
  );

  var response = await request.send();

  if (response.statusCode == 200) {
    print("Upload concluído!");
  } else {
    print("Erro no upload: ${response.statusCode}");
  }
}
