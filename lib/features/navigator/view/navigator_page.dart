import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../services/socket_service.dart';
class NavigatorPage extends StatefulWidget {
  const NavigatorPage({super.key});
  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}
class _NavigatorPageState extends State<NavigatorPage> {
  final _socket = SocketService();
  Uint8List? _imageBytes;
  final List<Offset> _currentStroke = [];
  final List<List<Map<String, dynamic>>> _allStrokes = [];
  String _mode = 'draw';
  double _strokeWidth = 4.0;
  Color _drawColor = Colors.red;
  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }
  void _initializeSocket() {
    print("Aid: Initializing socket connection");
    _socket.connect('ws://localhost:8080');
    Future.delayed(const Duration(milliseconds: 500), () {
      _socket.sendRole('Aid');
    });
    _socket.onImageReceived = (data) {
      setState(() => _imageBytes = data);
    };
  }
  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }
  void _sendDrawings(Size size) {
    if (_currentStroke.isEmpty) {
      print("Aid: No current stroke to send");
      return;
    }
    print("Aid: Sending drawing with ${_currentStroke.length} points");
    print("Aid: Mode: $_mode, Color: ${_colorToHex(_drawColor)}, Stroke: $_strokeWidth");
    final strokeData = _currentStroke.map((point) => {
      'x': point.dx / size.width,
      'y': point.dy / size.height,
      'mode': _mode,
      'color': _colorToHex(_drawColor),
      'strokeWidth': _strokeWidth,
    }).toList();
    _allStrokes.add(strokeData);
    _socket.sendDrawingPoints(
      _currentStroke,
      size.width,
      size.height,
      _mode,
      color: _colorToHex(_drawColor),
      strokeWidth: _strokeWidth
    );
    setState(() {
      _currentStroke.clear();
    });
  }
  void _clearAllDrawings() {
    print("Aid: Clearing all drawings");
    _socket.sendClearCommand();
    setState(() {
      _allStrokes.clear();
      _currentStroke.clear();
    });
  }
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aid View'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => setState(() => _mode = 'draw'),
                  icon: const Icon(Icons.brush),
                  label: const Text('Draw'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mode == 'draw' ? Colors.blue : Colors.grey[300],
                    foregroundColor: _mode == 'draw' ? Colors.white : Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _mode = 'erase'),
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text('Erase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mode == 'erase' ? Colors.red : Colors.grey[300],
                    foregroundColor: _mode == 'erase' ? Colors.white : Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _clearAllDrawings,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_mode == 'draw') ...[
                  PopupMenuButton<Color>(
                    icon: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _drawColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    ),
                    onSelected: (color) => setState(() => _drawColor = color),
                    itemBuilder: (context) => [
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.purple,
                      Colors.orange,
                    ]
                        .map((color) => PopupMenuItem(
                              value: color,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (_mode == 'draw')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Text('Brush Size: '),
                  Expanded(
                    child: Slider(
                      value: _strokeWidth,
                      min: 1.0,
                      max: 10.0,
                      divisions: 9,
                      label: _strokeWidth.round().toString(),
                      onChanged: (value) => setState(() => _strokeWidth = value),
                    ),
                  ),
                  Text('${_strokeWidth.round()}'),
                ],
              ),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                onPanStart: (details) {
                  setState(() => _currentStroke.add(details.localPosition));
                },
                onPanUpdate: (details) {
                  setState(() => _currentStroke.add(details.localPosition));
                },
                onPanEnd: (_) => _sendDrawings(Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                )),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    children: [
                      if (_imageBytes != null)
                        Positioned.fill(
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text(
                              'Waiting for camera feed...',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ),
                        ),
                      CustomPaint(
                        painter: _DrawPainter(
                          currentStroke: _currentStroke,
                          allStrokes: _allStrokes,
                          mode: _mode,
                          strokeWidth: _strokeWidth,
                          color: _drawColor,
                        ),
                        size: Size.infinite,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _DrawPainter extends CustomPainter {
  final List<Offset> currentStroke;
  final List<List<Map<String, dynamic>>> allStrokes;
  final String mode;
  final double strokeWidth;
  final Color color;
  _DrawPainter({
    required this.currentStroke,
    required this.allStrokes,
    required this.mode,
    required this.strokeWidth,
    required this.color,
  });
  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in allStrokes) {
      if (stroke.isEmpty) continue;
      final paint = Paint()
        ..strokeWidth = (stroke.first['strokeWidth'] as double)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final strokeMode = stroke.first['mode'] as String;
      if (strokeMode == 'draw') {
        final colorHex = stroke.first['color'] as String;
        paint.color = _hexToColor(colorHex);
      } else {
        paint.color = Colors.white;
        paint.strokeWidth = (stroke.first['strokeWidth'] as double) * 2;
      }
      final path = Path();
      final firstPoint = stroke.first;
      path.moveTo(
        (firstPoint['x'] as double) * size.width,
        (firstPoint['y'] as double) * size.height,
      );
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(
          (stroke[i]['x'] as double) * size.width,
          (stroke[i]['y'] as double) * size.height,
        );
      }
      canvas.drawPath(path, paint);
    }
    if (currentStroke.isNotEmpty) {
      final paint = Paint()
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (mode == 'draw') {
        paint.color = color;
      } else {
        paint.color = Colors.white;
        paint.strokeWidth = strokeWidth * 2;
      }
      if (currentStroke.length > 1) {
        final path = Path();
        path.moveTo(currentStroke[0].dx, currentStroke[0].dy);
        for (int i = 1; i < currentStroke.length; i++) {
          path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }
  Color _hexToColor(String hex) {
    final hexColor = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
  @override
  bool shouldRepaint(covariant _DrawPainter oldDelegate) => true;
}
























// import 'dart:typed_data';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:vector_math/vector_math_64.dart' as vm;
// import '../../../services/socket_service.dart';

// class NavigatorPage extends StatefulWidget {
//   const NavigatorPage({super.key});

//   @override
//   State<NavigatorPage> createState() => _NavigatorPageState();
// }

// class _NavigatorPageState extends State<NavigatorPage> {
//   final _socket = SocketService();
//   Uint8List? _imageBytes;
//   final List<vm.Vector3> _current3DStroke = [];
//   final List<List<vm.Vector3>> _all3DStrokes = [];
//   String _mode = 'draw';
//   double _strokeWidth = 4.0;
//   Color _drawColor = Colors.red;
//   double _currentDepth = 2.0;
  
//   vm.Matrix4 _userViewMatrix = vm.Matrix4.identity();
//   vm.Matrix4 _userProjectionMatrix = vm.Matrix4.identity();
//   bool _hasUserPose = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeSocket();
//     _setupDefaultProjection();
//   }

//   void _setupDefaultProjection() {
//     const double fov = 60.0 * (math.pi / 180.0);
//     const double near = 0.1;
//     const double far = 100.0;
//     const double aspect = 16.0 / 9.0;
    
//     _userProjectionMatrix = vm.makePerspectiveMatrix(fov, aspect, near, far);
//   }

//   void _initializeSocket() {
//     print("Aid: Initializing socket connection");
//     _socket.connect('ws://localhost:8080');
//     Future.delayed(const Duration(milliseconds: 500), () {
//       _socket.sendRole('Aid');
//     });
    
//     _socket.onImageReceived = (data) {
//       setState(() => _imageBytes = data);
//     };
    
//     _socket.onCameraPoseReceived = (poseData) {
//       if (poseData['viewMatrix'] != null && poseData['projectionMatrix'] != null) {
//         setState(() {
//           _userViewMatrix = vm.Matrix4.fromList(List<double>.from(poseData['viewMatrix']));
//           _userProjectionMatrix = vm.Matrix4.fromList(List<double>.from(poseData['projectionMatrix']));
//           _hasUserPose = true;
//         });
//         print("Aid: Updated user camera pose");
//       }
//     };
//   }

//   @override
//   void dispose() {
//     _socket.dispose();
//     super.dispose();
//   }

//   void _send3DDrawings() {
//     if (_current3DStroke.isEmpty) {
//       print("Aid: No current 3D stroke to send");
//       return;
//     }
//     print("Aid: Sending 3D drawing with ${_current3DStroke.length} points");
//     print("Aid: Mode: $_mode, Color: ${_colorToHex(_drawColor)}, Stroke: $_strokeWidth");
    
//     _all3DStrokes.add(List.from(_current3DStroke));
//     _socket.sendDrawing3DPoints(
//       _current3DStroke,
//       _mode,
//       color: _colorToHex(_drawColor),
//       strokeWidth: _strokeWidth
//     );
    
//     setState(() {
//       _current3DStroke.clear();
//     });
//   }

//   void _clearAll3DDrawings() {
//     print("Aid: Clearing all 3D drawings");
//     _socket.sendClearCommand();
//     setState(() {
//       _all3DStrokes.clear();
//       _current3DStroke.clear();
//     });
//   }

//   vm.Vector3 _screenToWorld3D(Offset screenPoint, Size screenSize) {
//     if (!_hasUserPose) {
//       final normalizedX = (screenPoint.dx / screenSize.width - 0.5) * 4.0;
//       final normalizedY = (0.5 - screenPoint.dy / screenSize.height) * 4.0;
//       return vm.Vector3(normalizedX, normalizedY, _currentDepth);
//     }
    
//     return screenToWorld(screenPoint, _currentDepth, screenSize, _userViewMatrix, _userProjectionMatrix);
//   }

//   vm.Vector3 screenToWorld(Offset screenPoint, double depth, Size screenSize, vm.Matrix4 viewMatrix, vm.Matrix4 projectionMatrix) {
//     final normalizedX = (screenPoint.dx / screenSize.width) * 2.0 - 1.0;
//     final normalizedY = 1.0 - (screenPoint.dy / screenSize.height) * 2.0;
    
//     final clipSpace = vm.Vector4(normalizedX, normalizedY, -1.0, 1.0);
    
//     final inverseProjection = vm.Matrix4.copy(projectionMatrix);
//     inverseProjection.invert();
    
//     final eyeSpace = inverseProjection.transform(clipSpace);
//     eyeSpace.z = -depth;
//     eyeSpace.w = 1.0;
    
//     final inverseView = vm.Matrix4.copy(viewMatrix);
//     inverseView.invert();
    
//     final worldSpace = inverseView.transform(eyeSpace);
    
//     return vm.Vector3(worldSpace.x, worldSpace.y, worldSpace.z);
//   }

//   String _colorToHex(Color color) {
//     return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Aid 3D View'),
//         backgroundColor: Colors.blue[800],
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8.0),
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.3),
//                   spreadRadius: 1,
//                   blurRadius: 3,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () => setState(() => _mode = 'draw'),
//                       icon: const Icon(Icons.brush),
//                       label: const Text('3D Draw'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _mode == 'draw' ? Colors.blue : Colors.grey[300],
//                         foregroundColor: _mode == 'draw' ? Colors.white : Colors.black,
//                       ),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: () => setState(() => _mode = 'erase'),
//                       icon: const Icon(Icons.cleaning_services),
//                       label: const Text('3D Erase'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _mode == 'erase' ? Colors.red : Colors.grey[300],
//                         foregroundColor: _mode == 'erase' ? Colors.white : Colors.black,
//                       ),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: _clearAll3DDrawings,
//                       icon: const Icon(Icons.clear_all),
//                       label: const Text('Clear 3D'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange,
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                     if (_mode == 'draw') ...[
//                       PopupMenuButton<Color>(
//                         icon: Container(
//                           width: 30,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             color: _drawColor,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.black, width: 2),
//                           ),
//                         ),
//                         onSelected: (color) => setState(() => _drawColor = color),
//                         itemBuilder: (context) => [
//                           Colors.red,
//                           Colors.blue,
//                           Colors.green,
//                           Colors.yellow,
//                           Colors.purple,
//                           Colors.orange,
//                         ]
//                             .map((color) => PopupMenuItem(
//                                   value: color,
//                                   child: Container(
//                                     width: 40,
//                                     height: 40,
//                                     decoration: BoxDecoration(
//                                       color: color,
//                                       shape: BoxShape.circle,
//                                     ),
//                                   ),
//                                 ))
//                             .toList(),
//                       ),
//                     ],
//                   ],
//                 ),
//                 if (_mode == 'draw') ...[
//                   Row(
//                     children: [
//                       const Text('Brush Size: '),
//                       Expanded(
//                         child: Slider(
//                           value: _strokeWidth,
//                           min: 1.0,
//                           max: 10.0,
//                           divisions: 9,
//                           label: _strokeWidth.round().toString(),
//                           onChanged: (value) => setState(() => _strokeWidth = value),
//                         ),
//                       ),
//                       Text('${_strokeWidth.round()}'),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       const Text('Depth: '),
//                       Expanded(
//                         child: Slider(
//                           value: _currentDepth,
//                           min: 0.5,
//                           max: 10.0,
//                           divisions: 19,
//                           label: _currentDepth.toStringAsFixed(1),
//                           onChanged: (value) => setState(() => _currentDepth = value),
//                         ),
//                       ),
//                       Text(_currentDepth.toStringAsFixed(1)),
//                     ],
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           Expanded(
//             child: LayoutBuilder(
//               builder: (context, constraints) => GestureDetector(
//                 onPanStart: (details) {
//                   final world3D = _screenToWorld3D(
//                     details.localPosition,
//                     Size(constraints.maxWidth, constraints.maxHeight),
//                   );
//                   setState(() => _current3DStroke.add(world3D));
//                 },
//                 onPanUpdate: (details) {
//                   final world3D = _screenToWorld3D(
//                     details.localPosition,
//                     Size(constraints.maxWidth, constraints.maxHeight),
//                   );
//                   setState(() => _current3DStroke.add(world3D));
//                 },
//                 onPanEnd: (_) => _send3DDrawings(),
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: double.infinity,
//                   child: Stack(
//                     children: [
//                       if (_imageBytes != null)
//                         Positioned.fill(
//                           child: Image.memory(
//                             _imageBytes!,
//                             fit: BoxFit.cover,
//                           ),
//                         )
//                       else
//                         Container(
//                           color: Colors.grey[300],
//                           child: const Center(
//                             child: Text(
//                               'Waiting for camera feed...',
//                               style: TextStyle(fontSize: 18, color: Colors.grey),
//                             ),
//                           ),
//                         ),
//                       CustomPaint(
//                         painter: _Draw3DPainter(
//                           current3DStroke: _current3DStroke,
//                           all3DStrokes: _all3DStrokes,
//                           mode: _mode,
//                           strokeWidth: _strokeWidth,
//                           color: _drawColor,
//                           viewMatrix: _userViewMatrix,
//                           projectionMatrix: _userProjectionMatrix,
//                           screenSize: Size(constraints.maxWidth, constraints.maxHeight),
//                         ),
//                         size: Size.infinite,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _Draw3DPainter extends CustomPainter {
//   final List<vm.Vector3> current3DStroke;
//   final List<List<vm.Vector3>> all3DStrokes;
//   final String mode;
//   final double strokeWidth;
//   final Color color;
//   final vm.Matrix4 viewMatrix;
//   final vm.Matrix4 projectionMatrix;
//   final Size screenSize;

//   _Draw3DPainter({
//     required this.current3DStroke,
//     required this.all3DStrokes,
//     required this.mode,
//     required this.strokeWidth,
//     required this.color,
//     required this.viewMatrix,
//     required this.projectionMatrix,
//     required this.screenSize,
//   });

//   Offset _worldToScreen(vm.Vector3 worldPoint) {
//     final worldVec4 = vm.Vector4(worldPoint.x, worldPoint.y, worldPoint.z, 1.0);
    
//     final viewSpace = viewMatrix.transform(worldVec4);
//     final clipSpace = projectionMatrix.transform(viewSpace);
    
//     if (clipSpace.w == 0) return const Offset(-1000, -1000);
    
//     final ndcX = clipSpace.x / clipSpace.w;
//     final ndcY = clipSpace.y / clipSpace.w;
    
//     final screenX = (ndcX + 1.0) * 0.5 * screenSize.width;
//     final screenY = (1.0 - ndcY) * 0.5 * screenSize.height;
    
//     return Offset(screenX, screenY);
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (final stroke3D in all3DStrokes) {
//       if (stroke3D.isEmpty) continue;
      
//       final paint = Paint()
//         ..strokeWidth = strokeWidth
//         ..strokeCap = StrokeCap.round
//         ..strokeJoin = StrokeJoin.round
//         ..style = PaintingStyle.stroke
//         ..color = color;

//       final path = Path();
//       bool hasValidPoint = false;
      
//       for (int i = 0; i < stroke3D.length; i++) {
//         final screenPoint = _worldToScreen(stroke3D[i]);
        
//         if (screenPoint.dx >= -100 && screenPoint.dx <= size.width + 100 &&
//             screenPoint.dy >= -100 && screenPoint.dy <= size.height + 100) {
//           if (!hasValidPoint) {
//             path.moveTo(screenPoint.dx, screenPoint.dy);
//             hasValidPoint = true;
//           } else {
//             path.lineTo(screenPoint.dx, screenPoint.dy);
//           }
//         }
//       }
      
//       if (hasValidPoint) {
//         canvas.drawPath(path, paint);
//       }
//     }

//     if (current3DStroke.isNotEmpty) {
//       final paint = Paint()
//         ..strokeWidth = strokeWidth
//         ..strokeCap = StrokeCap.round
//         ..strokeJoin = StrokeJoin.round
//         ..style = PaintingStyle.stroke;

//       if (mode == 'draw') {
//         paint.color = color;
//       } else {
//         paint.color = Colors.white;
//         paint.strokeWidth = strokeWidth * 2;
//       }

//       if (current3DStroke.length > 1) {
//         final path = Path();
//         bool hasValidPoint = false;
        
//         for (int i = 0; i < current3DStroke.length; i++) {
//           final screenPoint = _worldToScreen(current3DStroke[i]);
          
//           if (screenPoint.dx >= -100 && screenPoint.dx <= size.width + 100 &&
//               screenPoint.dy >= -100 && screenPoint.dy <= size.height + 100) {
//             if (!hasValidPoint) {
//               path.moveTo(screenPoint.dx, screenPoint.dy);
//               hasValidPoint = true;
//             } else {
//               path.lineTo(screenPoint.dx, screenPoint.dy);
//             }
//           }
//         }
        
//         if (hasValidPoint) {
//           canvas.drawPath(path, paint);
//         }
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _Draw3DPainter oldDelegate) => true;
// }