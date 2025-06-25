import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../services/socket_service.dart';
late List<CameraDescription> _cameras;
class UserPage extends StatefulWidget {
  const UserPage({super.key});
  @override
  State<UserPage> createState() => _UserPageState();
}
class _UserPageState extends State<UserPage> {
  late CameraController _controller;
  late SocketService _socket = SocketService();
  Timer? _sendTimer;
  final List<List<Map<String, dynamic>>> _allDrawingStrokes = [];
  bool _showDrawings = true;
  bool _isInitialized = false;
  Size _canvasSize = Size.zero;
  @override
  void initState() {
    super.initState();
    initCamera();
  }
  Future<void> initCamera() async {
    print("User: Initializing camera and socket");
    try {
      _cameras = await availableCameras();
      _controller = CameraController(_cameras[0], ResolutionPreset.medium);
      await _controller.initialize();
      // _socket = SocketService();
      _socket.connect('ws://172.26.102.151:8080');
      await Future.delayed(const Duration(milliseconds: 1000));
      _socket.sendRole('user');
      _socket.onDrawReceived = (points) {
        print("User: Received drawing with ${points.length} points");
        print("User: Canvas size: $_canvasSize");
        if (points.isEmpty) {
          print("User: Ignoring empty points");
          return;
        }
        if (_canvasSize.width <= 0 || _canvasSize.height <= 0) {
          print("User: Canvas size not ready, delaying processing");
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_canvasSize.width > 0 && _canvasSize.height > 0) {
              _processDrawingPoints(points);
            }
          });
          return;
        }
        _processDrawingPoints(points);
      };
      _socket.onClearReceived = () {
        print("User: Received clear command");
        setState(() {
          _allDrawingStrokes.clear();
        });
      };
      _sendTimer = Timer.periodic(const Duration(milliseconds: 200), (_) async {
        try {
          if (_controller.value.isInitialized) {
            final file = await _controller.takePicture();
            final bytes = await file.readAsBytes();
            _socket.sendFrame(bytes);
          }
        } catch (e) {
          debugPrint("Capture error: $e");
        }
      });
      setState(() {
        _isInitialized = true;
      });
      print("User: Camera and socket initialization complete");
    } catch (e) {
      print("User: Initialization error: $e");
    }
  }
  void _processDrawingPoints(List<Map<String, dynamic>> points) {
    setState(() {
      final screenPoints = points.map((p) {
        final screenX = (p['x'] as double) * _canvasSize.width;
        final screenY = (p['y'] as double) * _canvasSize.height;
        print("User: Converting normalized (${p['x']}, ${p['y']}) to screen ($screenX, $screenY)");
        return {
          'x': screenX,
          'y': screenY,
          'mode': p['mode'] ?? 'draw',
          'color': p['color'] ?? '#FF0000',
          'strokeWidth': (p['strokeWidth'] as num?)?.toDouble() ?? 4.0,
        };
      }).toList();
      _allDrawingStrokes.add(screenPoints);
      print("User: Added stroke to display. Total strokes: ${_allDrawingStrokes.length}");
    });
  }
  void _updateCanvasSize(Size size) {
    if (_canvasSize != size) {
      print("User: Canvas size updated from $_canvasSize to $size");
      setState(() {
        _canvasSize = size;
      });
    }
  }
  @override
  void dispose() {
    _sendTimer?.cancel();
    if (_controller.value.isInitialized) {
      _controller.dispose();
    }
    _socket.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Camera'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showDrawings ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showDrawings = !_showDrawings),
            tooltip: _showDrawings ? 'Hide Drawings' : 'Show Drawings',
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              print("User: Debug info - Total strokes: ${_allDrawingStrokes.length}");
              print("User: Canvas size: $_canvasSize");
              print("User: Socket connected: ${_socket.isConnected}");
              print("User: Socket role: ${_socket.role}");
              for (int i = 0; i < _allDrawingStrokes.length; i++) {
                if (_allDrawingStrokes[i].isNotEmpty) {
                  final firstPoint = _allDrawingStrokes[i].first;
                  print("User: Stroke $i first point: (${firstPoint['x']}, ${firstPoint['y']})");
                }
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateCanvasSize(Size(constraints.maxWidth, constraints.maxHeight));
          });
          return Stack(
            children: [
              if (_isInitialized && _controller.value.isInitialized)
                Positioned.fill(child: CameraPreview(_controller))
              else
                const Center(child: CircularProgressIndicator()),
              if (_showDrawings)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DrawOverlayPainter(
                      allStrokes: _allDrawingStrokes,
                    ),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _socket.isConnected ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _socket.isConnected ? 'Connected' : 'Disconnected',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Role: ${_socket.role ?? 'unknown'}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Strokes: ${_allDrawingStrokes.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Size: ${_canvasSize.width.toInt()}x${_canvasSize.height.toInt()}',
                        style: const TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
              if (_allDrawingStrokes.isEmpty && _showDrawings)
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: const Text(
                      'Aid can draw on your screen to help guide you',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
class _DrawOverlayPainter extends CustomPainter {
  final List<List<Map<String, dynamic>>> allStrokes;
  _DrawOverlayPainter({
    required this.allStrokes,
  });
  @override
  void paint(Canvas canvas, Size size) {
    // print("DrawOverlayPainter: Painting ${allStrokes.length} strokes on canvas size: $size");
    for (int strokeIndex = 0; strokeIndex < allStrokes.length; strokeIndex++) {
      final stroke = allStrokes[strokeIndex];
      if (stroke.isEmpty) {
        // print("DrawOverlayPainter: Skipping empty stroke $strokeIndex");
        continue;
      }
      // print("DrawOverlayPainter: Drawing stroke $strokeIndex with ${stroke.length} points");
      final paint = Paint()
        ..strokeWidth = (stroke.first['strokeWidth'] as double)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final mode = stroke.first['mode'] as String;
      if (mode == 'draw') {
        final colorHex = stroke.first['color'] as String;
        paint.color = _hexToColor(colorHex).withOpacity(0.9);
        // print("DrawOverlayPainter: Draw mode - color: $colorHex");
      } else {
        paint.color = Colors.white.withOpacity(0.9);
        paint.strokeWidth = (stroke.first['strokeWidth'] as double) * 2;
        // print("DrawOverlayPainter: Erase mode");
      }
      if (stroke.length > 1) {
        final path = Path();
        final firstPoint = stroke[0];
        final startX = firstPoint['x'] as double;
        final startY = firstPoint['y'] as double;
        final clampedStartX = startX.clamp(0.0, size.width);
        final clampedStartY = startY.clamp(0.0, size.height);
        path.moveTo(clampedStartX, clampedStartY);
        // print("DrawOverlayPainter: Starting path at ($clampedStartX, $clampedStartY)");
        for (int i = 1; i < stroke.length; i++) {
          final point = stroke[i];
          final x = (point['x'] as double).clamp(0.0, size.width);
          final y = (point['y'] as double).clamp(0.0, size.height);
          path.lineTo(x, y);
        }
        canvas.drawPath(path, paint);
        // print("DrawOverlayPainter: Drew path with ${stroke.length} points");
      } else if (stroke.length == 1) {
        final point = stroke[0];
        final x = (point['x'] as double).clamp(0.0, size.width);
        final y = (point['y'] as double).clamp(0.0, size.height);
        canvas.drawCircle(
          Offset(x, y),
          paint.strokeWidth / 2,
          paint..style = PaintingStyle.fill,
        );
        // print("DrawOverlayPainter: Drew single point at ($x, $y)");
      }
    }
  }
  Color _hexToColor(String hex) {
    final hexColor = hex.replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16));
    }
    return Colors.red;
  }
  @override
  bool shouldRepaint(covariant _DrawOverlayPainter oldDelegate) {
    final shouldRepaint = allStrokes != oldDelegate.allStrokes;
    if (shouldRepaint) {
      // print("DrawOverlayPainter: Repainting due to stroke changes");
    }
    return shouldRepaint;
  }
}

















// import 'dart:async';
// import 'dart:math' as math;
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:vector_math/vector_math_64.dart' as vm;
// import '../../../services/socket_service.dart';

// late List<CameraDescription> _cameras;

// class UserPage extends StatefulWidget {
//   const UserPage({super.key});

//   @override
//   State<UserPage> createState() => _UserPageState();
// }

// class _UserPageState extends State<UserPage> {
//   late CameraController _controller;
//   late SocketService _socket;
//   Timer? _sendTimer;
//   final List<List<vm.Vector3>> _all3DStrokes = [];
//   bool _showDrawings = true;
//   bool _isInitialized = false;
//   Size _canvasSize = Size.zero;
  
//   vm.Matrix4 _viewMatrix = vm.Matrix4.identity();
//   vm.Matrix4 _projectionMatrix = vm.Matrix4.identity();
//   StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
//   StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
//   StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  
//   vm.Vector3 _gravity = vm.Vector3.zero();
//   vm.Vector3 _magnetic = vm.Vector3.zero();
//   vm.Vector3 _rotation = vm.Vector3.zero();

//   @override
//   void initState() {
//     super.initState();
//     initCamera();
//     _initializeSensors();
//     _setupProjectionMatrix();
//   }

//   void _initializeSensors() {
//     _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
//       setState(() {
//         _gravity = vm.Vector3(event.x, event.y, event.z);
//       });
//       _updateViewMatrix();
//     });

//     _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
//       setState(() {
//         _rotation.x += event.x * 0.01;
//         _rotation.y += event.y * 0.01;
//         _rotation.z += event.z * 0.01;
//       });
//       _updateViewMatrix();
//     });

//     _magnetometerSubscription = magnetometerEvents.listen((MagnetometerEvent event) {
//       setState(() {
//         _magnetic = vm.Vector3(event.x, event.y, event.z);
//       });
//       _updateViewMatrix();
//     });
//   }

//   void _setupProjectionMatrix() {
//     const double fov = 60.0 * (math.pi / 180.0);
//     const double near = 0.1;
//     const double far = 100.0;
//     const double aspect = 16.0 / 9.0;
    
//     _projectionMatrix = vm.makePerspectiveMatrix(fov, aspect, near, far);
//   }

//   void _updateViewMatrix() {
//     final rotX = vm.Matrix4.rotationX(_rotation.x);
//     final rotY = vm.Matrix4.rotationY(_rotation.y);
//     final rotZ = vm.Matrix4.rotationZ(_rotation.z);
    
//     _viewMatrix = rotZ * rotY * rotX;
    
//     if (_socket.isConnected) {
//       _socket.sendCameraPose(_viewMatrix, _projectionMatrix);
//     }
//   }

//   Future<void> initCamera() async {
//     print("User: Initializing camera and socket");
//     try {
//       _cameras = await availableCameras();
//       _controller = CameraController(_cameras[0], ResolutionPreset.medium);
//       await _controller.initialize();
//       _socket = SocketService();
//       _socket.connect('ws://localhost:8080');
//       await Future.delayed(const Duration(milliseconds: 1000));
//       _socket.sendRole('user');
      
//       _socket.onDraw3DReceived = (points) {
//         print("User: Received 3D drawing with ${points.length} points");
//         if (points.isEmpty) {
//           print("User: Ignoring empty points");
//           return;
//         }
//         _process3DDrawingPoints(points);
//       };
      
//       _socket.onClearReceived = () {
//         print("User: Received clear command");
//         setState(() {
//           _all3DStrokes.clear();
//         });
//       };
      
//       _sendTimer = Timer.periodic(const Duration(milliseconds: 200), (_) async {
//         try {
//           if (_controller.value.isInitialized) {
//             final file = await _controller.takePicture();
//             final bytes = await file.readAsBytes();
//             _socket.sendFrame(bytes);
//           }
//         } catch (e) {
//           debugPrint("Capture error: $e");
//         }
//       });
      
//       setState(() {
//         _isInitialized = true;
//       });
//       print("User: Camera and socket initialization complete");
//     } catch (e) {
//       print("User: Initialization error: $e");
//     }
//   }

//   void _process3DDrawingPoints(List<Map<String, dynamic>> points) {
//     setState(() {
//       final worldPoints = points.map((p) {
//         return vm.Vector3(
//           p['x'] as double,
//           p['y'] as double,
//           p['z'] as double,
//         );
//       }).toList();
//       _all3DStrokes.add(worldPoints);
//       print("User: Added 3D stroke to display. Total strokes: ${_all3DStrokes.length}");
//     });
//   }

//   void _updateCanvasSize(Size size) {
//     if (_canvasSize != size) {
//       print("User: Canvas size updated from $_canvasSize to $size");
//       setState(() {
//         _canvasSize = size;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _sendTimer?.cancel();
//     _accelerometerSubscription?.cancel();
//     _gyroscopeSubscription?.cancel();
//     _magnetometerSubscription?.cancel();
//     if (_controller.value.isInitialized) {
//       _controller.dispose();
//     }
//     _socket.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User AR Camera'),
//         backgroundColor: Colors.green[800],
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: Icon(_showDrawings ? Icons.visibility : Icons.visibility_off),
//             onPressed: () => setState(() => _showDrawings = !_showDrawings),
//             tooltip: _showDrawings ? 'Hide 3D Drawings' : 'Show 3D Drawings',
//           ),
//           IconButton(
//             icon: const Icon(Icons.info),
//             onPressed: () {
//               print("User: Debug info - Total 3D strokes: ${_all3DStrokes.length}");
//               print("User: Canvas size: $_canvasSize");
//               print("User: Socket connected: ${_socket.isConnected}");
//               print("User: Socket role: ${_socket.role}");
//               print("User: View matrix: ${_viewMatrix.storage}");
//             },
//           ),
//         ],
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _updateCanvasSize(Size(constraints.maxWidth, constraints.maxHeight));
//           });
//           return Stack(
//             children: [
//               if (_isInitialized && _controller.value.isInitialized)
//                 Positioned.fill(child: CameraPreview(_controller))
//               else
//                 const Center(child: CircularProgressIndicator()),
//               if (_showDrawings)
//                 Positioned.fill(
//                   child: CustomPaint(
//                     painter: _Draw3DOverlayPainter(
//                       all3DStrokes: _all3DStrokes,
//                       viewMatrix: _viewMatrix,
//                       projectionMatrix: _projectionMatrix,
//                       screenSize: Size(constraints.maxWidth, constraints.maxHeight),
//                     ),
//                     size: Size(constraints.maxWidth, constraints.maxHeight),
//                   ),
//                 ),
//               Positioned(
//                 top: 16,
//                 right: 16,
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.black54,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             width: 8,
//                             height: 8,
//                             decoration: BoxDecoration(
//                               color: _socket.isConnected ? Colors.green : Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             _socket.isConnected ? 'Connected' : 'Disconnected',
//                             style: const TextStyle(color: Colors.white, fontSize: 12),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Role: ${_socket.role ?? 'unknown'}',
//                         style: const TextStyle(color: Colors.white, fontSize: 10),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         '3D Strokes: ${_all3DStrokes.length}',
//                         style: const TextStyle(color: Colors.white, fontSize: 10),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         'AR Mode',
//                         style: const TextStyle(color: Colors.white, fontSize: 8),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (_all3DStrokes.isEmpty && _showDrawings)
//                 Positioned(
//                   bottom: 100,
//                   left: 16,
//                   right: 16,
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: const BoxDecoration(
//                       color: Colors.black54,
//                       borderRadius: BorderRadius.all(Radius.circular(8)),
//                     ),
//                     child: const Text(
//                       'Aid can draw in 3D space to help guide you',
//                       style: TextStyle(color: Colors.white, fontSize: 14),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class _Draw3DOverlayPainter extends CustomPainter {
//   final List<List<vm.Vector3>> all3DStrokes;
//   final vm.Matrix4 viewMatrix;
//   final vm.Matrix4 projectionMatrix;
//   final Size screenSize;

//   _Draw3DOverlayPainter({
//     required this.all3DStrokes,
//     required this.viewMatrix,
//     required this.projectionMatrix,
//     required this.screenSize,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     print("Draw3DOverlayPainter: Painting ${all3DStrokes.length} 3D strokes");
    
//     for (int strokeIndex = 0; strokeIndex < all3DStrokes.length; strokeIndex++) {
//       final stroke = all3DStrokes[strokeIndex];
//       if (stroke.isEmpty) {
//         print("Draw3DOverlayPainter: Skipping empty 3D stroke $strokeIndex");
//         continue;
//       }

//       final paint = Paint()
//         ..strokeWidth = 4.0
//         ..strokeCap = StrokeCap.round
//         ..strokeJoin = StrokeJoin.round
//         ..style = PaintingStyle.stroke
//         ..color = Colors.red.withOpacity(0.9);

//       if (stroke.length > 1) {
//         final path = Path();
//         bool firstPoint = true;
        
//         for (int i = 0; i < stroke.length; i++) {
//           final worldPoint = stroke[i];
//           final screenPoint = worldToScreen(worldPoint, size, viewMatrix, projectionMatrix);
          
//           if (screenPoint.x >= 0 && screenPoint.x <= size.width &&
//               screenPoint.y >= 0 && screenPoint.y <= size.height) {
//             if (firstPoint) {
//               path.moveTo(screenPoint.x, screenPoint.y);
//               firstPoint = false;
//             } else {
//               path.lineTo(screenPoint.x, screenPoint.y);
//             }
//           }
//         }
        
//         if (!firstPoint) {
//           canvas.drawPath(path, paint);
//         }
//       } else if (stroke.length == 1) {
//         final worldPoint = stroke[0];
//         final screenPoint = worldToScreen(worldPoint, size, viewMatrix, projectionMatrix);
        
//         if (screenPoint.x >= 0 && screenPoint.x <= size.width &&
//             screenPoint.y >= 0 && screenPoint.y <= size.height) {
//           canvas.drawCircle(
//             Offset(screenPoint.x, screenPoint.y),
//             paint.strokeWidth / 2,
//             paint..style = PaintingStyle.fill,
//           );
//         }
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _Draw3DOverlayPainter oldDelegate) {
//     return all3DStrokes != oldDelegate.all3DStrokes ||
//            viewMatrix != oldDelegate.viewMatrix ||
//            projectionMatrix != oldDelegate.projectionMatrix;
//   }
// }