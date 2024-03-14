import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pediasure_flutter/IntroductionScreen.dart';
import 'ResultScreen.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pediasure_flutter/services/api_service.dart';
import 'package:image_compare_slider/image_compare_slider.dart';
import 'dart:math' as math;
import 'package:funvas/funvas.dart';
import 'package:pediasure_flutter/src/fuvas_anim.dart';
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class ProcessingScreen extends StatefulWidget {
  final File imageFile;

  ProcessingScreen({required this.imageFile});

  @override
  _ProcessingScreenState createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  late Future<File?> _processingFuture;
  bool _showLoader = true;
  late File? _processedFile;

  @override
  void initState() {
    super.initState();
    _processingFuture = processImage(widget.imageFile);
    _processingFuture.then((file) {
      setState(() {
        _processedFile = file;
      });
    });
  }

  Future<void> _printImage(File processedFile) async {
    final pdf = pw.Document();

    final image = pw.MemoryImage(
      File(widget.imageFile.path).readAsBytesSync(),
    );

    final image2 = pw.MemoryImage(
      File(processedFile.path).readAsBytesSync(),
    );

    final ByteData logoByteData = await rootBundle.load('assets/logofinal.png');
    final Uint8List logoBytes = logoByteData.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColors.purple,
            // Fondo morado
            padding: pw.EdgeInsets.symmetric(vertical: 40),
            // Espaciado vertical
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Logo
                pw.Image(pw.MemoryImage(logoBytes)),
                pw.SizedBox(height: 20),
                // Espaciado entre el logo y el texto
                // Texto "Esta es su versión, no ha pasado tanto tiempo"
                pw.Text(
                  'Esta es su versión, no ha pasado tanto tiempo',
                  style: pw.TextStyle(color: PdfColors.white),
                ),
                pw.SizedBox(height: 30),
                // Espaciado entre el texto y las imágenes
                // Imágenes
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 10),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Image(image),
                      pw.Image(image2),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final pdfFile = File('$tempPath/example.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: 'fotografía_ia.pdf',
      dynamicLayout: false,
      format: PdfPageFormat.a5.copyWith(
        marginLeft: 0,
        marginRight: 0,
        marginTop: 0,
        marginBottom: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: OvalBottomBorderClipper(),
            child: Container(
              width: screenWidth,
              height: screenHeight / 1.6,
              decoration: BoxDecoration(
                color: Color(0xFF592276),
              ),
              child: FunvasContainer(
                funvas: Forty(),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 45),
            width: 180,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/abbott.png',
                width: 100,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(35.0, 40.0, 35.0, 190),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 80, left: 50),
                    child: Image.asset(
                      'assets/logofinal.png',
                      width: screenWidth * 0.60,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 25.0),
                          child: Text(
                            'Esta es su versión, no ha pasado tanto tiempo',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        BounceInRight(
                          delay: Duration(milliseconds: 100),
                          onFinish: (direction) => print('$direction'),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 30.0),
                            width: 340,
                            height: 500,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 20,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: FutureBuilder<File?>(
                                  future: _processingFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 20),
                                            Text(
                                              'Procesando imagen...',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        'Error: ${snapshot.error}, Vuelva a intentarlo',
                                        style: TextStyle(color: Colors.red),
                                      );
                                    } else {
                                      final File processedFile = snapshot.data!;

                                      return Center(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 480,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: ImageCompareSlider(
                                                itemOne: Image.file(
                                                  widget.imageFile,
                                                ),
                                                itemTwo:
                                                    Image.file(processedFile),
                                                // Usar el processedFile si está disponible, de lo contrario, mostrar un contenedor vacío
                                                handleRadius: BorderRadius.all(
                                                  Radius.circular(50),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 120.0, vertical: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  width: 500,
                  height: 60.0,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: ElevatedButton(
                      onPressed: () => _printImage(_processedFile!),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color(0xFF592276),
                        ),
                      ),
                      child: Text(
                        '¡Vamos a imprimirla!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 500,
                  height: 60,
                  margin: EdgeInsets.only(bottom: 25),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => IntroductionScreen()),
                          (route) => false,
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                      ),
                      child: Text(
                        'Volver al Inicio',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 22, color: Color(0xFF592276)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
