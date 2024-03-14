import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

// Función para convertir la imagen en base64
Future<String> imageToBase64(File imageFile) async {
  List<int> imageBytes = await imageFile.readAsBytes();
  return base64Encode(imageBytes);
}

// Función para convertir la imagen base64 en un archivo de imagen
Future<File> base64ToImage(String base64Image) async {
  Uint8List bytes = base64.decode(base64Image);
  String tempDir = Directory.systemTemp.path;
  File imageFile = File('$tempDir/image.jpg');
  await imageFile.writeAsBytes(bytes);
  return imageFile;
}

// Función para enviar la imagen a la API y obtener la respuesta
Future<Map<String, dynamic>?> sendImageToAPI(File imageFile) async {
  const String bearer =
      'Bearer key-1mhgZxkMVE0UR6PmQlZiF4zS6p7pgYtWOeotlbn2Vmk4HxlQHeWl6U6gnb31nxkZrMK1gf1XztevRjNuMmQojKIvsf6Xyjxx';
  const String prompt =
      'digitally captured photo showcasing a modern, high-quality depiction of a 10 years young man with a doctor suit. Utilize advanced digital techniques to ensure sharpness, clarity, and lifelike detail. focusing instead on a contemporary aesthetic. Employ a clean, crisp look with vibrant colors and realistic textures. Enhance the photo with subtle lighting and composition to highlight the professionalism and expertise of the doctor including the background. Aim for the highest quality and realism, presenting a compelling and authentic portrayal of modern healthcare.';
  const String negPrompt =
      '(lowres, low quality, worst quality:1.2), (text:1.2), watermark, painting, drawing, illustration, glitch, deformed, mutated, cross-eyed, ugly, disfigured (lowres, low quality, worst quality:1.2), (text:1.2), watermark, painting, drawing, illustration, glitch,deformed, mutated, cross-eyed, ugly, disfigured';
  const url = 'https://api.getimg.ai/v1/latent-consistency/image-to-image';

  final headers = {
    'accept': 'application/json',
    'content-type': 'application/json',
    'authorization': bearer
  };
  final body = jsonEncode({
    'model': 'lcm-realistic-vision-v5-1',
    'prompt': prompt,
    'negative_prompt': negPrompt,
    'image': await imageToBase64(imageFile)
  });

  final response =
      await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    print('Error en la solicitud: ${response.statusCode}');
    return null;
  }
}

// funcion para procesar la imagen
Future<File?> processImage(File imageFile) async {
  final response = await sendImageToAPI(imageFile);
  if (response != null && response.containsKey('image')) {
    String base64img = response['image'];
    File newImage = await base64ToImage(base64img);

    // Rotar la imagen 90 grados
    img.Image image = img.decodeImage(newImage.readAsBytesSync())!;
    img.Image rotatedImage = img.copyRotate(image, angle: 90);

    // Convertir la imagen rotada de nuevo a un archivo
    File rotatedFile = File(imageFile.path.replaceAll('.jpg', '_rotated.jpg'));
    rotatedFile.writeAsBytesSync(img.encodeJpg(rotatedImage));

    return rotatedFile;
  } else {
    return null;
  }
}
