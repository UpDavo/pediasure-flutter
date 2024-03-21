import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:camera/camera.dart'; // Importa el paquete de la cámara
import 'IaGenerationScreen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:funvas/funvas.dart';
import 'package:pediasure_flutter/src/fuvas_anim.dart';
import 'dart:async';

class ReviewPhotoScreen extends StatefulWidget {
  @override
  _ReviewPhotoScreenState createState() => _ReviewPhotoScreenState();
}

class _ReviewPhotoScreenState extends State<ReviewPhotoScreen> {
  bool _photoTaken = false;
  late final File _imageFile;

  void _updatePhotoTaken(bool value) {
    setState(() {
      _photoTaken = value;
    });
  }

  void _updatePhoto(XFile imageFile) {
    setState(() {
      _imageFile = File(imageFile.path);
    });
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
              height: screenHeight / 1.7,
              decoration: BoxDecoration(
                color: Color(0xFF592276),
              ),
              // child: FunvasContainer(
              //   funvas: Forty(),
              // ),
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
            padding: EdgeInsets.fromLTRB(35.0, 40.0, 35.0, 150),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20, left: 50),
                    child: Image.asset(
                      'assets/logofinal.png',
                      width: screenWidth * 0.30,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        BounceInRight(
                          delay: Duration(milliseconds: 100),
                          onFinish: (direction) => print('$direction'),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 30.0),
                            width: 500,
                            height: 350,
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
                                padding: EdgeInsets.only(top: 20, bottom: 20),
                                child: Column(
                                  children: [
                                    ///
                                    Expanded(
                                      child: CameraWidget(
                                          updatePhotoTaken: _updatePhotoTaken,
                                          updatePhoto: _updatePhoto),
                                    ),
                                  ],
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
            padding: EdgeInsets.symmetric(horizontal: 470.0, vertical: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  width: 320,
                  height: 40.0,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_photoTaken) {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              duration: Duration(milliseconds: 300),
                              child: ProcessingScreen(imageFile: _imageFile),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Debes tomar la foto primero para continuar',
                              ),
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color(0xFF592276),
                        ),
                      ),
                      child: Text(
                        'Continuar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 320,
                  height: 40,
                  margin: EdgeInsets.only(bottom: 25),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                      ),
                      child: Text(
                        'Regresar',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 17, color: Color(0xFF592276)),
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

class CameraWidget extends StatefulWidget {
  final Function(bool) updatePhotoTaken;
  final Function(XFile) updatePhoto;

  CameraWidget({required this.updatePhotoTaken, required this.updatePhoto});

  @override
  _CameraWidgetState createState() => _CameraWidgetState(
      updatePhotoTaken: updatePhotoTaken, updatePhoto: updatePhoto);
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _imageFile;
  bool _showCountdown = false;
  int _countdown = 2;
  bool _isCameraInitialized = false;

  // Callback function to update photoTaken state
  final Function(bool) updatePhotoTaken;
  final Function(XFile) updatePhoto;

  _CameraWidgetState(
      {required this.updatePhotoTaken, required this.updatePhoto});

  @override
  void initState() {
    super.initState();
    _initializeCameraIfNeeded();
  }

  Future<void> _initializeCameraIfNeeded() async {
    if (!_isCameraInitialized) {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _controller.setFlashMode(FlashMode.off);
      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  // Método para tomar una foto
  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      setState(() {
        _showCountdown = true;
      });
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (_countdown > 0) {
          setState(() {
            _countdown--;
          });
        } else {
          timer.cancel();
          _captureImage();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _captureImage() async {
    final XFile image = await _controller.takePicture();
    setState(() {
      _imageFile = image;
      _showCountdown = false;
      _countdown = 2;
      // Marcar que se ha tomado una foto
      updatePhotoTaken(true);
      updatePhoto(image);
    });
  }

  void _retakePicture() {
    setState(() {
      _imageFile = null;
      updatePhotoTaken(false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized ||
        _controller == null ||
        !_controller.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            width: 500,
            height: 405,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                _imageFile != null
                    ? Image.file(
                        File(_imageFile!.path),
                        fit: BoxFit.cover,
                      )
                    : CameraPreview(_controller),
                if (_imageFile == null)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.only(
                      //       topLeft: Radius.circular(20),
                      //       topRight: Radius.circular(20),
                      //       bottomLeft: Radius.circular(20),
                      //       bottomRight: Radius.circular(
                      //           0), // Ajusta este valor si deseas que la esquina inferior derecha no sea redondeada
                      //     ),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: Colors.grey.withOpacity(0.5),
                      //         spreadRadius: 1,
                      //         blurRadius: 4,
                      //         offset: Offset(0,
                      //             2), // Cambia la posición de la sombra según sea necesario
                      //       ),
                      //     ],
                      //   ),
                      //   padding: EdgeInsets.all(10),
                      //   // Agrega relleno alrededor del texto
                      //   child: Text(
                      //     'Tap a la cámara para tomar la fotografía',
                      //     textAlign: TextAlign.center,
                      //     style: TextStyle(fontSize: 6, color: Color(0xFF592276)),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 5, bottom: 20),
                        child: InkWell(
                          onTap: _takePicture,
                          child: Image.asset(
                            'assets/camara.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      onPressed: _retakePicture,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                      ),
                      child: Text(
                        'Retomar foto',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 10, color: Color(0xFF592276)),
                      ),
                    ),
                  ),
                if (_showCountdown)
                  Center(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _countdown > 0 ? '$_countdown' : '¡Sonríe!',
                          style: TextStyle(
                            fontSize: 50,
                            color: Color(0xFF592276),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
