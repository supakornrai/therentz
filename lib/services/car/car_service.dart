import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> uploadToCloudinary(File image) async {
  final url = Uri.parse(
    "https://api.cloudinary.com/v1_1/dvphm62a4/image/upload",
  );

  var request = http.MultipartRequest('POST', url);

  request.fields['upload_preset'] = 'Pic_Therentz';

  request.files.add(await http.MultipartFile.fromPath('file', image.path));

  var response = await request.send();

  var res = await http.Response.fromStream(response);

  if (res.statusCode == 200) {
    var data = jsonDecode(res.body);

    if (data["secure_url"] != null) {
      return data["secure_url"];
    }

    throw Exception("Cloudinary response missing URL");
  } else {
    throw Exception("Upload failed: ${res.body}");
  }
}
