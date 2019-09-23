import 'dart:math' as math;
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> with AfterLayoutMixin<MyApp> {
  Offset copernicus = Offset(52.241942, 21.029117);
  Tangent tangent;
  final imageAngle = math.pi / 4.5;

  double get tangentAngle => (tangent?.angle ?? math.pi / 2) - math.pi / 2;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              bottom: 0,
              child: Image.asset(
                'assets/compass.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              child: StreamBuilder<double>(
                stream: FlutterCompass.events,
                builder: (context, snapshot) {
                  double angle = ((snapshot.data ?? 0) * (math.pi / 180) * -1);
                  return Transform.rotate(
                    angle: angle + imageAngle - tangentAngle,
                    alignment: Alignment(-0.05, -0.035),
                    child: ClipPath(
                      clipper: CompassClipper(),
                      child: Image.asset(
                        'assets/compass.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment(-0.05, -0.035),
              child: StreamBuilder<double>(
                stream: FlutterCompass.events,
                builder: (context, snapshot) {
                  double angle = ((snapshot.data ?? 0) * (math.pi / 180) * -1);
                  return Transform.rotate(
                    angle: angle - tangentAngle,
                    child: Transform.translate(
                      offset:
                          Offset(0, -MediaQuery.of(context).size.height / 3),
                      child: Transform.rotate(
                        angle: -(angle - tangentAngle),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.white,
                                Colors.white70,
                                Colors.white.withOpacity(0),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(56),
                            child: Image.asset(
                              'assets/flutter_europe.png',
                              width: 200,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    Location().getLocation().then((locationData) {
      setState(() {
        Offset myLocation =
            Offset(locationData.latitude, locationData.longitude);
        tangent = Tangent(
          Offset.zero,
          copernicus - myLocation,
        );
      });
    });
  }
}

class CompassClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;
    double centerX = width / 2 - 0.05 * width / 2;
    double centerY = height / 2 - 0.035 * height / 2;
    final path = Path();
    path.addOval(
      Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: height / 4,
      ),
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
