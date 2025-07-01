import 'package:flutter/material.dart';
import 'app/app.dart';

void main() {
  runApp(const MyApp());
}


















// // import 'package:flutter/material.dart';
// // import 'dart:math' as math;

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: '3D Drawing App',
// //       theme: ThemeData(primarySwatch: Colors.blue),
// //       home: Drawing3DScreen(),
// //     );
// //   }
// // }

// // class Point3D {
// //   double x, y, z;
// //   Color color;
// //   double size;
  
// //   Point3D(this.x, this.y, this.z, {this.color = Colors.blue, this.size = 2.0});
// // }

// // class Camera3D {
// //   double angleX = 0.0;
// //   double angleY = 0.0;
// //   double distance = 500.0;
// //   double centerX = 0.0;
// //   double centerY = 0.0;
  
// //   Point2D project(Point3D point, double screenWidth, double screenHeight) {
// //     // Apply rotation
// //     double cosX = math.cos(angleX);
// //     double sinX = math.sin(angleX);
// //     double cosY = math.cos(angleY);
// //     double sinY = math.sin(angleY);
    
// //     // Rotate around Y axis
// //     double x1 = point.x * cosY - point.z * sinY;
// //     double z1 = point.x * sinY + point.z * cosY;
// //     double y1 = point.y;
    
// //     // Rotate around X axis
// //     double y2 = y1 * cosX - z1 * sinX;
// //     double z2 = y1 * sinX + z1 * cosX;
// //     double x2 = x1;
    
// //     // Perspective projection
// //     double perspective = distance / (distance + z2);
// //     double screenX = (x2 * perspective) + screenWidth / 2 + centerX;
// //     double screenY = (y2 * perspective) + screenHeight / 2 + centerY;
    
// //     return Point2D(screenX, screenY, perspective);
// //   }
  
// //   Point3D unproject(double screenX, double screenY, double screenWidth, double screenHeight) {
// //     // Convert screen coordinates to 3D world coordinates
// //     double worldX = (screenX - screenWidth / 2 - centerX);
// //     double worldY = (screenY - screenHeight / 2 - centerY);
// //     double worldZ = 0.0; // Draw on a plane in front of camera
    
// //     // Apply inverse rotation
// //     double cosX = math.cos(-angleX);
// //     double sinX = math.sin(-angleX);
// //     double cosY = math.cos(-angleY);
// //     double sinY = math.sin(-angleY);
    
// //     // Inverse rotate around X axis
// //     double y1 = worldY * cosX - worldZ * sinX;
// //     double z1 = worldY * sinX + worldZ * cosX;
// //     double x1 = worldX;
    
// //     // Inverse rotate around Y axis
// //     double x2 = x1 * cosY + z1 * sinY;
// //     double z2 = -x1 * sinY + z1 * cosY;
// //     double y2 = y1;
    
// //     return Point3D(x2, y2, z2);
// //   }
// // }

// // class Point2D {
// //   double x, y;
// //   double depth;
  
// //   Point2D(this.x, this.y, this.depth);
// // }

// // class Drawing3DScreen extends StatefulWidget {
// //   @override
// //   _Drawing3DScreenState createState() => _Drawing3DScreenState();
// // }

// // class _Drawing3DScreenState extends State<Drawing3DScreen> {
// //   List<List<Point3D>> strokes = [];
// //   List<Point3D> currentStroke = [];
// //   Camera3D camera = Camera3D();
// //   bool isDrawing = false;
// //   Color selectedColor = Colors.blue;
// //   double brushSize = 3.0;
  
// //   final List<Color> colors = [
// //     Colors.blue,
// //     Colors.red,
// //     Colors.green,
// //     Colors.purple,
// //     Colors.orange,
// //     Colors.pink,
// //     Colors.cyan,
// //     Colors.yellow,
// //   ];

// //   void _onScaleStart(ScaleStartDetails details) {
// //     setState(() {
// //       if (details.pointerCount == 1) {
// //         // Single finger - start drawing
// //         isDrawing = true;
// //         currentStroke = [];
        
// //         RenderBox renderBox = context.findRenderObject() as RenderBox;
// //         Size size = renderBox.size;
        
// //         Point3D worldPoint = camera.unproject(
// //           details.focalPoint.dx,
// //           details.focalPoint.dy,
// //           size.width,
// //           size.height,
// //         );
        
// //         worldPoint.color = selectedColor;
// //         worldPoint.size = brushSize;
// //         currentStroke.add(worldPoint);
// //       } else {
// //         // Multiple fingers - stop drawing if we were drawing
// //         if (isDrawing) {
// //           if (currentStroke.isNotEmpty) {
// //             strokes.add(List.from(currentStroke));
// //           }
// //           currentStroke.clear();
// //           isDrawing = false;
// //         }
// //       }
// //     });
// //   }

// //   void _onScaleUpdate(ScaleUpdateDetails details) {
// //     setState(() {
// //       if (details.pointerCount == 1 && isDrawing) {
// //         // Single finger - continue drawing
// //         RenderBox renderBox = context.findRenderObject() as RenderBox;
// //         Size size = renderBox.size;
        
// //         Point3D worldPoint = camera.unproject(
// //           details.focalPoint.dx,
// //           details.focalPoint.dy,
// //           size.width,
// //           size.height,
// //         );
        
// //         worldPoint.color = selectedColor;
// //         worldPoint.size = brushSize;
// //         currentStroke.add(worldPoint);
// //       } else if (details.pointerCount == 2) {
// //         // Two fingers - rotate and scale camera
// //         camera.angleY += details.focalPointDelta.dx * 0.01;
// //         camera.angleX += details.focalPointDelta.dy * 0.01;
// //         camera.distance = math.max(100, math.min(1000, camera.distance / details.scale));
// //       }
// //     });
// //   }

// //   void _onScaleEnd(ScaleEndDetails details) {
// //     setState(() {
// //       if (isDrawing) {
// //         if (currentStroke.isNotEmpty) {
// //           strokes.add(List.from(currentStroke));
// //         }
// //         currentStroke.clear();
// //         isDrawing = false;
// //       }
// //     });
// //   }

// //   void _clearDrawing() {
// //     setState(() {
// //       strokes.clear();
// //       currentStroke.clear();
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       appBar: AppBar(
// //         title: Text('3D Drawing'),
// //         backgroundColor: Colors.grey[900],
// //         actions: [
// //           IconButton(
// //             icon: Icon(Icons.clear),
// //             onPressed: _clearDrawing,
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           // Color palette
// //           Container(
// //             height: 60,
// //             padding: EdgeInsets.symmetric(vertical: 8),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: colors.map((color) {
// //                 return GestureDetector(
// //                   onTap: () => setState(() => selectedColor = color),
// //                   child: Container(
// //                     width: 40,
// //                     height: 40,
// //                     decoration: BoxDecoration(
// //                       color: color,
// //                       shape: BoxShape.circle,
// //                       border: Border.all(
// //                         color: selectedColor == color ? Colors.white : Colors.transparent,
// //                         width: 3,
// //                       ),
// //                     ),
// //                   ),
// //                 );
// //               }).toList(),
// //             ),
// //           ),
          
// //           // Brush size slider
// //           Padding(
// //             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
// //             child: Row(
// //               children: [
// //                 Text('Size: ', style: TextStyle(color: Colors.white)),
// //                 Expanded(
// //                   child: Slider(
// //                     value: brushSize,
// //                     min: 1.0,
// //                     max: 8.0,
// //                     divisions: 7,
// //                     onChanged: (value) => setState(() => brushSize = value),
// //                   ),
// //                 ),
// //                 Text('${brushSize.toInt()}', style: TextStyle(color: Colors.white)),
// //               ],
// //             ),
// //           ),
          
// //           // 3D Drawing Canvas
// //           Expanded(
// //             child: GestureDetector(
// //               onScaleStart: _onScaleStart,
// //               onScaleUpdate: _onScaleUpdate,
// //               onScaleEnd: _onScaleEnd,
// //               child: Container(
// //                 width: double.infinity,
// //                 height: double.infinity,
// //                 child: CustomPaint(
// //                   painter: Drawing3DPainter(
// //                     strokes: strokes,
// //                     currentStroke: currentStroke,
// //                     camera: camera,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
          
// //           // Instructions
// //           Container(
// //             padding: EdgeInsets.all(16),
// //             child: Text(
// //               'Single finger: Draw • Two fingers: Rotate & Zoom camera',
// //               style: TextStyle(color: Colors.white70, fontSize: 12),
// //               textAlign: TextAlign.center,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class Drawing3DPainter extends CustomPainter {
// //   final List<List<Point3D>> strokes;
// //   final List<Point3D> currentStroke;
// //   final Camera3D camera;
  
// //   Drawing3DPainter({
// //     required this.strokes,
// //     required this.currentStroke,
// //     required this.camera,
// //   });

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     // Draw coordinate system
// //     _drawCoordinateSystem(canvas, size);
    
// //     // Draw all completed strokes
// //     for (List<Point3D> stroke in strokes) {
// //       _drawStroke(canvas, size, stroke);
// //     }
    
// //     // Draw current stroke
// //     if (currentStroke.isNotEmpty) {
// //       _drawStroke(canvas, size, currentStroke);
// //     }
// //   }
  
// //   void _drawCoordinateSystem(Canvas canvas, Size size) {
// //     Paint axisPaint = Paint()
// //       ..strokeWidth = 1.0
// //       ..style = PaintingStyle.stroke;
    
// //     // X axis (red)
// //     axisPaint.color = Colors.red.withOpacity(0.3);
// //     Point2D origin = camera.project(Point3D(0, 0, 0), size.width, size.height);
// //     Point2D xAxis = camera.project(Point3D(100, 0, 0), size.width, size.height);
// //     if (origin.depth > 0 && xAxis.depth > 0) {
// //       canvas.drawLine(Offset(origin.x, origin.y), Offset(xAxis.x, xAxis.y), axisPaint);
// //     }
    
// //     // Y axis (green)
// //     axisPaint.color = Colors.green.withOpacity(0.3);
// //     Point2D yAxis = camera.project(Point3D(0, 100, 0), size.width, size.height);
// //     if (origin.depth > 0 && yAxis.depth > 0) {
// //       canvas.drawLine(Offset(origin.x, origin.y), Offset(yAxis.x, yAxis.y), axisPaint);
// //     }
    
// //     // Z axis (blue)
// //     axisPaint.color = Colors.blue.withOpacity(0.3);
// //     Point2D zAxis = camera.project(Point3D(0, 0, 100), size.width, size.height);
// //     if (origin.depth > 0 && zAxis.depth > 0) {
// //       canvas.drawLine(Offset(origin.x, origin.y), Offset(zAxis.x, zAxis.y), axisPaint);
// //     }
// //   }

// //   void _drawStroke(Canvas canvas, Size size, List<Point3D> stroke) {
// //     if (stroke.length < 2) {
// //       if (stroke.length == 1) {
// //         Point2D screenPoint = camera.project(stroke[0], size.width, size.height);
// //         if (screenPoint.depth > 0) {
// //           Paint pointPaint = Paint()
// //             ..color = stroke[0].color
// //             ..style = PaintingStyle.fill;
// //           canvas.drawCircle(
// //             Offset(screenPoint.x, screenPoint.y),
// //             stroke[0].size * screenPoint.depth,
// //             pointPaint,
// //           );
// //         }
// //       }
// //       return;
// //     }

// //     Paint paint = Paint()
// //       ..style = PaintingStyle.stroke
// //       ..strokeCap = StrokeCap.round
// //       ..strokeJoin = StrokeJoin.round;

// //     Path path = Path();
// //     bool pathStarted = false;

// //     for (int i = 0; i < stroke.length; i++) {
// //       Point2D screenPoint = camera.project(stroke[i], size.width, size.height);
      
// //       if (screenPoint.depth > 0) {
// //         paint.color = stroke[i].color.withOpacity(math.min(1.0, screenPoint.depth * 2));
// //         paint.strokeWidth = stroke[i].size * screenPoint.depth;
        
// //         if (!pathStarted) {
// //           path.moveTo(screenPoint.x, screenPoint.y);
// //           pathStarted = true;
// //         } else {
// //           path.lineTo(screenPoint.x, screenPoint.y);
// //         }
// //       }
// //     }

// //     if (pathStarted) {
// //       canvas.drawPath(path, paint);
// //     }
// //   }

// //   @override
// //   bool shouldRepaint(CustomPainter oldDelegate) => true;
// // }





// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'dart:math' as math;

// late List<CameraDescription> cameras;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   cameras = await availableCameras();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'AR 3D Drawing App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: ARDrawing3DScreen(),
//     );
//   }
// }

// class Point3D {
//   double x, y, z;
//   Color color;
//   double size;
  
//   Point3D(this.x, this.y, this.z, {this.color = Colors.blue, this.size = 2.0});
// }

// class Camera3D {
//   double angleX = 0.0;
//   double angleY = 0.0;
//   double distance = 300.0;
//   double centerX = 0.0;
//   double centerY = 0.0;
  
//   Point2D project(Point3D point, double screenWidth, double screenHeight) {
//     // Apply rotation
//     double cosX = math.cos(angleX);
//     double sinX = math.sin(angleX);
//     double cosY = math.cos(angleY);
//     double sinY = math.sin(angleY);
    
//     // Rotate around Y axis
//     double x1 = point.x * cosY - point.z * sinY;
//     double z1 = point.x * sinY + point.z * cosY;
//     double y1 = point.y;
    
//     // Rotate around X axis
//     double y2 = y1 * cosX - z1 * sinX;
//     double z2 = y1 * sinX + z1 * cosX;
//     double x2 = x1;
    
//     // Perspective projection
//     double perspective = distance / (distance + z2);
//     double screenX = (x2 * perspective) + screenWidth / 2 + centerX;
//     double screenY = (y2 * perspective) + screenHeight / 2 + centerY;
    
//     return Point2D(screenX, screenY, perspective);
//   }
  
//   Point3D unproject(double screenX, double screenY, double screenWidth, double screenHeight) {
//     // Convert screen coordinates to 3D world coordinates
//     double worldX = (screenX - screenWidth / 2 - centerX) * 0.5;
//     double worldY = (screenY - screenHeight / 2 - centerY) * 0.5;
//     double worldZ = 0.0; // Draw on a plane in front of camera
    
//     // Apply inverse rotation
//     double cosX = math.cos(-angleX);
//     double sinX = math.sin(-angleX);
//     double cosY = math.cos(-angleY);
//     double sinY = math.sin(-angleY);
    
//     // Inverse rotate around X axis
//     double y1 = worldY * cosX - worldZ * sinX;
//     double z1 = worldY * sinX + worldZ * cosX;
//     double x1 = worldX;
    
//     // Inverse rotate around Y axis
//     double x2 = x1 * cosY + z1 * sinY;
//     double z2 = -x1 * sinY + z1 * cosY;
//     double y2 = y1;
    
//     return Point3D(x2, y2, z2);
//   }
// }

// class Point2D {
//   double x, y;
//   double depth;
  
//   Point2D(this.x, this.y, this.depth);
// }

// class ARDrawing3DScreen extends StatefulWidget {
//   @override
//   _ARDrawing3DScreenState createState() => _ARDrawing3DScreenState();
// }

// class _ARDrawing3DScreenState extends State<ARDrawing3DScreen> {
//   List<List<Point3D>> strokes = [];
//   List<Point3D> currentStroke = [];
//   Camera3D camera = Camera3D();
//   bool isDrawing = false;
//   Color selectedColor = Colors.blue;
//   double brushSize = 3.0;
//   bool showCamera = true;
  
//   CameraController? cameraController;
//   bool isCameraInitialized = false;
  
//   final List<Color> colors = [
//     Colors.blue,
//     Colors.red,
//     Colors.green,
//     Colors.purple,
//     Colors.orange,
//     Colors.pink,
//     Colors.cyan,
//     Colors.yellow,
//     Colors.white,
//     Colors.black,
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     if (cameras.isNotEmpty) {
//       cameraController = CameraController(
//         cameras[0], // Use back camera
//         ResolutionPreset.medium,
//         enableAudio: false,
//       );
      
//       try {
//         await cameraController!.initialize();
//         if (mounted) {
//           setState(() {
//             isCameraInitialized = true;
//           });
//         }
//       } catch (e) {
//         print('Error initializing camera: $e');
//       }
//     }
//   }

//   @override
//   void dispose() {
//     cameraController?.dispose();
//     super.dispose();
//   }

//   void _onScaleStart(ScaleStartDetails details) {
//     setState(() {
//       if (details.pointerCount == 1) {
//         // Single finger - start drawing
//         isDrawing = true;
//         currentStroke = [];
        
//         RenderBox renderBox = context.findRenderObject() as RenderBox;
//         Size size = renderBox.size;
        
//         Point3D worldPoint = camera.unproject(
//           details.focalPoint.dx,
//           details.focalPoint.dy,
//           size.width,
//           size.height,
//         );
        
//         worldPoint.color = selectedColor;
//         worldPoint.size = brushSize;
//         currentStroke.add(worldPoint);
//       } else {
//         // Multiple fingers - stop drawing if we were drawing
//         if (isDrawing) {
//           if (currentStroke.isNotEmpty) {
//             strokes.add(List.from(currentStroke));
//           }
//           currentStroke.clear();
//           isDrawing = false;
//         }
//       }
//     });
//   }

//   void _onScaleUpdate(ScaleUpdateDetails details) {
//     setState(() {
//       if (details.pointerCount == 1 && isDrawing) {
//         // Single finger - continue drawing
//         RenderBox renderBox = context.findRenderObject() as RenderBox;
//         Size size = renderBox.size;
        
//         Point3D worldPoint = camera.unproject(
//           details.focalPoint.dx,
//           details.focalPoint.dy,
//           size.width,
//           size.height,
//         );
        
//         worldPoint.color = selectedColor;
//         worldPoint.size = brushSize;
//         currentStroke.add(worldPoint);
//       } else if (details.pointerCount == 2) {
//         // Two fingers - rotate and scale camera
//         camera.angleY += details.focalPointDelta.dx * 0.01;
//         camera.angleX += details.focalPointDelta.dy * 0.01;
//         camera.distance = math.max(100, math.min(800, camera.distance / details.scale));
//       }
//     });
//   }

//   void _onScaleEnd(ScaleEndDetails details) {
//     setState(() {
//       if (isDrawing) {
//         if (currentStroke.isNotEmpty) {
//           strokes.add(List.from(currentStroke));
//         }
//         currentStroke.clear();
//         isDrawing = false;
//       }
//     });
//   }

//   void _clearDrawing() {
//     setState(() {
//       strokes.clear();
//       currentStroke.clear();
//     });
//   }

//   void _toggleCamera() {
//     setState(() {
//       showCamera = !showCamera;
//     });
//   }

//   void _switchCamera() async {
//     if (cameras.length > 1) {
//       await cameraController?.dispose();
      
//       // Switch between front and back camera
//       final currentCamera = cameraController?.description;
//       final newCamera = cameras.firstWhere(
//         (camera) => camera != currentCamera,
//         orElse: () => cameras[0],
//       );
      
//       cameraController = CameraController(
//         newCamera,
//         ResolutionPreset.medium,
//         enableAudio: false,
//       );
      
//       try {
//         await cameraController!.initialize();
//         if (mounted) {
//           setState(() {});
//         }
//       } catch (e) {
//         print('Error switching camera: $e');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text('AR 3D Drawing'),
//         backgroundColor: Colors.grey[900],
//         actions: [
//           IconButton(
//             icon: Icon(showCamera ? Icons.videocam : Icons.videocam_off),
//             onPressed: _toggleCamera,
//           ),
//           if (cameras.length > 1)
//             IconButton(
//               icon: Icon(Icons.flip_camera_ios),
//               onPressed: _switchCamera,
//             ),
//           IconButton(
//             icon: Icon(Icons.clear),
//             onPressed: _clearDrawing,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Color palette
//           Container(
//             height: 60,
//             padding: EdgeInsets.symmetric(vertical: 8),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: colors.map((color) {
//                   return Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 4),
//                     child: GestureDetector(
//                       onTap: () => setState(() => selectedColor = color),
//                       child: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: color,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: selectedColor == color ? Colors.white : Colors.grey,
//                             width: selectedColor == color ? 3 : 1,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
          
//           // Brush size slider
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//             child: Row(
//               children: [
//                 Text('Size: ', style: TextStyle(color: Colors.white)),
//                 Expanded(
//                   child: Slider(
//                     value: brushSize,
//                     min: 1.0,
//                     max: 10.0,
//                     divisions: 9,
//                     onChanged: (value) => setState(() => brushSize = value),
//                   ),
//                 ),
//                 Text('${brushSize.toInt()}', style: TextStyle(color: Colors.white)),
//               ],
//             ),
//           ),
          
//           // AR Drawing Canvas
//           Expanded(
//             child: Stack(
//               children: [
//                 // Camera preview background
//                 if (showCamera && isCameraInitialized && cameraController != null)
//                   Positioned.fill(
//                     child: AspectRatio(
//                       aspectRatio: cameraController!.value.aspectRatio,
//                       child: CameraPreview(cameraController!),
//                     ),
//                   ),
                
//                 // 3D Drawing overlay
//                 Positioned.fill(
//                   child: GestureDetector(
//                     onScaleStart: _onScaleStart,
//                     onScaleUpdate: _onScaleUpdate,
//                     onScaleEnd: _onScaleEnd,
//                     child: Container(
//                       width: double.infinity,
//                       height: double.infinity,
//                       child: CustomPaint(
//                         painter: ARDrawing3DPainter(
//                           strokes: strokes,
//                           currentStroke: currentStroke,
//                           camera: camera,
//                           showCoordinates: !showCamera,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Instructions
//           Container(
//             padding: EdgeInsets.all(16),
//             child: Text(
//               'Single finger: Draw in 3D • Two fingers: Rotate & Zoom • Camera: Toggle AR view',
//               style: TextStyle(color: Colors.white70, fontSize: 12),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ARDrawing3DPainter extends CustomPainter {
//   final List<List<Point3D>> strokes;
//   final List<Point3D> currentStroke;
//   final Camera3D camera;
//   final bool showCoordinates;
  
//   ARDrawing3DPainter({
//     required this.strokes,
//     required this.currentStroke,
//     required this.camera,
//     this.showCoordinates = true,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Draw coordinate system only when camera is off
//     if (showCoordinates) {
//       _drawCoordinateSystem(canvas, size);
//     }
    
//     // Draw all completed strokes
//     for (List<Point3D> stroke in strokes) {
//       _drawStroke(canvas, size, stroke);
//     }
    
//     // Draw current stroke
//     if (currentStroke.isNotEmpty) {
//       _drawStroke(canvas, size, currentStroke);
//     }
    
//     // Draw crosshair in center for AR mode
//     if (!showCoordinates) {
//       _drawCrosshair(canvas, size);
//     }
//   }
  
//   void _drawCrosshair(Canvas canvas, Size size) {
//     Paint crosshairPaint = Paint()
//       ..color = Colors.white.withOpacity(0.5)
//       ..strokeWidth = 2.0
//       ..style = PaintingStyle.stroke;
    
//     double centerX = size.width / 2;
//     double centerY = size.height / 2;
//     double crossSize = 20;
    
//     // Draw crosshair
//     canvas.drawLine(
//       Offset(centerX - crossSize, centerY),
//       Offset(centerX + crossSize, centerY),
//       crosshairPaint,
//     );
//     canvas.drawLine(
//       Offset(centerX, centerY - crossSize),
//       Offset(centerX, centerY + crossSize),
//       crosshairPaint,
//     );
    
//     // Draw center dot
//     canvas.drawCircle(Offset(centerX, centerY), 2, crosshairPaint);
//   }
  
//   void _drawCoordinateSystem(Canvas canvas, Size size) {
//     Paint axisPaint = Paint()
//       ..strokeWidth = 2.0
//       ..style = PaintingStyle.stroke;
    
//     // X axis (red)
//     axisPaint.color = Colors.red.withOpacity(0.7);
//     Point2D origin = camera.project(Point3D(0, 0, 0), size.width, size.height);
//     Point2D xAxis = camera.project(Point3D(100, 0, 0), size.width, size.height);
//     if (origin.depth > 0 && xAxis.depth > 0) {
//       canvas.drawLine(Offset(origin.x, origin.y), Offset(xAxis.x, xAxis.y), axisPaint);
//     }
    
//     // Y axis (green)
//     axisPaint.color = Colors.green.withOpacity(0.7);
//     Point2D yAxis = camera.project(Point3D(0, 100, 0), size.width, size.height);
//     if (origin.depth > 0 && yAxis.depth > 0) {
//       canvas.drawLine(Offset(origin.x, origin.y), Offset(yAxis.x, yAxis.y), axisPaint);
//     }
    
//     // Z axis (blue)
//     axisPaint.color = Colors.blue.withOpacity(0.7);
//     Point2D zAxis = camera.project(Point3D(0, 0, 100), size.width, size.height);
//     if (origin.depth > 0 && zAxis.depth > 0) {
//       canvas.drawLine(Offset(origin.x, origin.y), Offset(zAxis.x, zAxis.y), axisPaint);
//     }
//   }

//   void _drawStroke(Canvas canvas, Size size, List<Point3D> stroke) {
//     if (stroke.length < 2) {
//       if (stroke.length == 1) {
//         Point2D screenPoint = camera.project(stroke[0], size.width, size.height);
//         if (screenPoint.depth > 0) {
//           Paint pointPaint = Paint()
//             ..color = stroke[0].color
//             ..style = PaintingStyle.fill;
//           canvas.drawCircle(
//             Offset(screenPoint.x, screenPoint.y),
//             stroke[0].size * math.max(0.5, screenPoint.depth),
//             pointPaint,
//           );
//         }
//       }
//       return;
//     }

//     Paint paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round;

//     for (int i = 0; i < stroke.length - 1; i++) {
//       Point2D point1 = camera.project(stroke[i], size.width, size.height);
//       Point2D point2 = camera.project(stroke[i + 1], size.width, size.height);
      
//       if (point1.depth > 0 && point2.depth > 0) {
//         double avgDepth = (point1.depth + point2.depth) / 2;
//         paint.color = stroke[i].color.withOpacity(math.min(1.0, avgDepth * 1.5));
//         paint.strokeWidth = stroke[i].size * math.max(0.5, avgDepth);
        
//         canvas.drawLine(
//           Offset(point1.x, point1.y),
//           Offset(point2.x, point2.y),
//           paint,
//         );
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }