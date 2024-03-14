import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'TakePhotoScreen.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:image_compare_slider/image_compare_slider.dart';
import 'package:funvas/funvas.dart';
import 'package:pediasure_flutter/src/fuvas_anim.dart';

class IntroductionScreen extends StatefulWidget {
  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
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
              decoration: const BoxDecoration(
                color: Color(0xFF592276),
              ),
              child: FunvasContainer(
                funvas: Forty(),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 45),
            width: 180,
            height: 60,
            // Altura de la insignia
            decoration: const BoxDecoration(
              // color: Colors.deepPurple,
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
            padding: const EdgeInsets.fromLTRB(35.0, 40.0, 35.0, 0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 70, left: 50),
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
                          padding: EdgeInsets.only(top: 20.0, bottom: 25.0),
                          child: Text(
                            'Bienvenido a la fuente de crecimiento',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 35.0, bottom: 20.0),
                          child: Image.asset(
                            'assets/items.png',
                            width: screenWidth * 0.60,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: 400,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        duration: Duration(milliseconds: 300),
                                        child: TakePhotoScreen(),
                                      ),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      const Color(0xFF592276),
                                    ),
                                  ),
                                  child: const Text(
                                    '¡Es hora de empezar!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Padding(
                          padding: EdgeInsets.only(
                              bottom: 70.0, left: 20, right: 20),
                          child: Text(
                            'La información o fotografías que se utilizarán en esta generación no serán utilizados para otros fines que el de este evento. La fotografía no se guarda en ninguna base de datos o disco físico. Cada foto es descartada después del proceso.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black38,
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
        ],
      ),
    );
  }
}
