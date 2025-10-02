import 'package:dio/dio.dart';

Future<void> uploadFile(File file) async {
  Dio dio = Dio();

  FormData formData = FormData.fromMap({
    "file": await MultipartFile.fromFile(file.path, filename: "upload.jpg"),
  });

  await dio.post(
    "https://meu-servidor.com/upload",
    data: formData,
    onSendProgress: (sent, total) {
      print("${(sent / total * 100).toStringAsFixed(0)}%");
    },
  );
}
