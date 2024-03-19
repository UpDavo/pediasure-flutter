import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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

Future<File> urlToFile(String imageUrl) async {
  final response = await http.get(Uri.parse(imageUrl));

  if (response.statusCode == 200) {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File('$tempPath/temp_image.jpg');
    await file.writeAsBytes(response.bodyBytes);

    return file;
  } else {
    throw Exception('Error al descargar la imagen: ${response.statusCode}');
  }
}

// Función para enviar la imagen a la API y obtener la respuesta
Future<Map<String, dynamic>?> sendImageToAPI(File imageFile) async {
  const String bearer =
      'Bearer key-1mhgZxkMVE0UR6PmQlZiF4zS6p7pgYtWOeotlbn2Vmk4HxlQHeWl6U6gnb31nxkZrMK1gf1XztevRjNuMmQojKIvsf6Xyjxx';
  const String prompt =
      'digitally captured photo showcasing a modern, high-quality depiction of a 10 years young man with a doctor suit. Utilize advanced digital techniques to ensure sharpness, clarity, and lifelike detail. focusing instead on a contemporary aesthetic. Employ a clean, crisp look with vibrant colors and realistic textures. Enhance the photo with subtle lighting and composition to highlight the professionalism and expertise of the doctor including the background. Aim for the highest quality and realism, presenting a compelling and authentic portrayal of modern healthcare.';
  const String negPrompt =
      '(lowres, low quality, worst quality:1.2), (text:1.2), watermark, painting, drawing, illustration, glitch, deformed, mutated, cross-eyed, ugly, disfigured (lowres, low quality, worst quality:1.2), (text:1.2), watermark, painting, drawing, illustration, glitch,deformed, mutated, cross-eyed, ugly, disfigured';
  const url = 'https://api.getimg.ai/v1/stable-diffusion/image-to-image';

  final headers = {
    'accept': 'application/json',
    'content-type': 'application/json',
    'authorization': bearer
  };
  final body = jsonEncode({
    'model': 'realistic-vision-v5-1',
    'prompt': prompt,
    'negative_prompt': negPrompt,
    'image': await imageToBase64(imageFile),
    "strength": 0.4,
    "steps": 25,
    "guidance": 9,
    "output_format": "jpeg",
    "scheduler": "dpmsolver++"
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

// Función para enviar la imagen a la API y obtener la respuesta
Future<Map<String, dynamic>?> sendImageToAPIReplicate(File imageFile) async {
  const String bearer = 'Token r8_2z0RFjKWdOHlHyeg1XSISgcU9T1ZXJL3UE0tP';
  const String prompt =
      'HDR photo of 7 years old young kid img, smiling for the viewer, wearing a doctor uniform, happy, late summer. High dynamic range, vivid, rich details, clear shadows and highlights, realistic, intense, enhanced contrast, highly detailed';
  const String negPrompt =
      'nsfw, lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry';
  const url = 'https://api.replicate.com/v1/predictions';
  String base64Image = await imageToBase64(imageFile);

  final headers = {
    'accept': 'application/json',
    'content-type': 'application/json',
    'authorization': bearer
  };
  final body = jsonEncode({
    "version":
        "ddfc2b08d209f9fa8c1eca692712918bd449f695dabb4a958da31802a9570fe4",
    "input": {
      "prompt": prompt,
      "negative_prompt": negPrompt,
      "input_image": "data:application/octet-stream;base64,$base64Image",
      "num_steps": 50,
      "guidance_scale": 5,
      "style_strength_ratio": 20,
      "num_outputs": 1,
      "style_name": "Photographic (Default)"
    }
  });

  final response =
      await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    var decodedJson = json.decode(response.body);

    if (decodedJson['urls'] != null) {
      var getUrl = decodedJson['urls']['get'];
      print(getUrl);

      var decodedGet;
      do {
        await Future.delayed(Duration(seconds: 2));
        final responseget = await http.get(Uri.parse(getUrl), headers: headers);
        decodedGet = json.decode(responseget.body);
        print(decodedGet['status']);
      } while (decodedGet == null || decodedGet['status'] != 'succeeded');

      var finaloutput = {'output': decodedGet['output'][0]};
      print(finaloutput);
      return finaloutput;
    } else {
      print('No se encontró la propiedad URL en la respuesta.');
      return null;
    }
  } else {
    print('Error en la solicitud: ${response.statusCode}');
    return null;
  }
}

// funcion para procesar la imagen
Future<File?> processImage(File imageFile) async {
  final response = await sendImageToAPIReplicate(imageFile);
  if (response != null && response.containsKey('output')) {
    String imageUrl = response['output'];
    File newImage = await urlToFile(imageUrl);

    // Rotar la imagen 90 grados
    img.Image image = img.decodeImage(newImage.readAsBytesSync())!;
    img.Image rotatedImage = img.copyRotate(image, angle: 0);

    // Convertir la imagen rotada de nuevo a un archivo
    File rotatedFile = File(imageFile.path.replaceAll('.jpg', '_rotated.jpg'));
    rotatedFile.writeAsBytesSync(img.encodeJpg(rotatedImage));

    print("Imagen saliente");
    print(rotatedFile);
    return rotatedFile;
  } else {
    return null;
  }
}
