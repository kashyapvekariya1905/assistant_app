import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
class SocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _role;
  Function(Uint8List)? onImageReceived;
  Function(List<Map<String, dynamic>>)? onDrawReceived;
  Function()? onClearReceived;
  void connect(String url) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;
      print("Connecting to WebSocket: $url");
      _channel!.stream.listen(
        (data) {
          if (data is Uint8List) {
            onImageReceived?.call(data);
          } else if (data is String) {
            if (data.startsWith('ROLE_CONFIRMED:')) {
              final role = data.split(':')[1];
              print("Role confirmed: $role");
              _role = role;
              return;
            }
            try {
              final decoded = jsonDecode(data);
              print("Decoded JSON: $decoded");
              if (decoded['type'] == 'drawing') {
                final points = (decoded['points'] as List)
                    .map<Map<String, dynamic>>((p) => {
                          'x': (p['x'] as num).toDouble(),
                          'y': (p['y'] as num).toDouble(),
                          'mode': p['mode']?.toString() ?? 'draw',
                          'color': p['color']?.toString() ?? '#FF0000',
                          'strokeWidth': (p['strokeWidth'] as num?)?.toDouble() ?? 4.0,
                        })
                    .toList();
                print("Parsed drawing points: ${points.length} points");
                onDrawReceived?.call(points);
              } else if (decoded['type'] == 'clear') {
                onClearReceived?.call();
              }
            } catch (e) {
              print(e);
            }
          }
        },
        onError: (error) {
          print("WebSocket error: $error");
          _isConnected = false;
        },
        onDone: () {
          print("WebSocket connection closed");
          _isConnected = false;
        },
      );
    } catch (e) {
      print("Failed to connect to WebSocket: $e");
      _isConnected = false;
    }
  }
  void sendRole(String role) {
    if (_isConnected && _channel != null) {
      final message = "ROLE:$role";
      print("Sending role: $message");
      _channel!.sink.add(message);
      _role = role;
    } else {
      print("Cannot send role - not connected");
    }
  }
  void sendFrame(Uint8List bytes) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(bytes);
    } else {
      print("Cannot send frame - not connected");
    }
  }
  void sendDrawingPoints(
    List<Offset> points,
    double width,
    double height,
    String mode, {
    String color = '#FF0000',
    double strokeWidth = 4.0,
  }) {
    if (!_isConnected || _channel == null) {
      print("Cannot send drawing - not connected");
      return;
    }
    if (points.isEmpty) {
      print("No points to send");
      return;
    }
    try {
      final normalized = points
          .map((p) => {
                'x': p.dx / width,
                'y': p.dy / height,
                'mode': mode,
                'color': color,
                'strokeWidth': strokeWidth,
              })
          .toList();
      final message = {
        'type': 'drawing',
        'points': normalized,
        'from': _role ?? 'unknown',
      };
      final jsonMessage = jsonEncode(message);
      print("Sending drawing message: $jsonMessage");
      _channel!.sink.add(jsonMessage);
      print("Drawing sent successfully - ${points.length} points");
    } catch (e) {
      print("Failed to send drawing points: $e");
    }
  }
  void sendClearCommand() {
    if (!_isConnected || _channel == null) {
      print("Cannot send clear command - not connected");
      return;
    }
    try {
      final message = jsonEncode({
        'type': 'clear',
        'from': _role ?? 'unknown',
      });
      print("Sending clear command: $message");
      _channel!.sink.add(message);
    } catch (e) {
      print("Failed to send clear command: $e");
    }
  }
  bool get isConnected => _isConnected;
  String? get role => _role;
  void dispose() {
    print("Disposing WebSocket connection");
    _isConnected = false;
    _channel?.sink.close();
  }
}
String colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
}
Color hexToColor(String hex) {
  final hexColor = hex.replaceAll('#', '');
  return Color(int.parse('FF$hexColor', radix: 16));
}















// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:flutter/material.dart';
// import 'package:vector_math/vector_math_64.dart' as vm;

// class SocketService {
//   WebSocketChannel? _channel;
//   bool _isConnected = false;
//   String? _role;
//   Function(Uint8List)? onImageReceived;
//   Function(List<Map<String, dynamic>>)? onDraw3DReceived;
//   Function()? onClearReceived;
//   Function(Map<String, dynamic>)? onCameraPoseReceived;

//   void connect(String url) {
//     try {
//       _channel = WebSocketChannel.connect(Uri.parse(url));
//       _isConnected = true;
//       print("Connecting to WebSocket: $url");
//       _channel!.stream.listen(
//         (data) {
//           if (data is Uint8List) {
//             onImageReceived?.call(data);
//           } else if (data is String) {
//             if (data.startsWith('ROLE_CONFIRMED:')) {
//               final role = data.split(':')[1];
//               print("Role confirmed: $role");
//               _role = role;
//               return;
//             }
//             try {
//               final decoded = jsonDecode(data);
//               print("Decoded JSON: $decoded");
//               if (decoded['type'] == 'drawing3d') {
//                 final points = (decoded['points'] as List)
//                     .map<Map<String, dynamic>>((p) => {
//                           'x': (p['x'] as num).toDouble(),
//                           'y': (p['y'] as num).toDouble(),
//                           'z': (p['z'] as num).toDouble(),
//                           'mode': p['mode']?.toString() ?? 'draw',
//                           'color': p['color']?.toString() ?? '#FF0000',
//                           'strokeWidth': (p['strokeWidth'] as num?)?.toDouble() ?? 4.0,
//                         })
//                     .toList();
//                 print("Parsed 3D drawing points: ${points.length} points");
//                 onDraw3DReceived?.call(points);
//               } else if (decoded['type'] == 'clear') {
//                 onClearReceived?.call();
//               } else if (decoded['type'] == 'camera_pose') {
//                 onCameraPoseReceived?.call(decoded);
//               }
//             } catch (e) {
//               print(e);
//             }
//           }
//         },
//         onError: (error) {
//           print("WebSocket error: $error");
//           _isConnected = false;
//         },
//         onDone: () {
//           print("WebSocket connection closed");
//           _isConnected = false;
//         },
//       );
//     } catch (e) {
//       print("Failed to connect to WebSocket: $e");
//       _isConnected = false;
//     }
//   }

//   void sendRole(String role) {
//     if (_isConnected && _channel != null) {
//       final message = "ROLE:$role";
//       print("Sending role: $message");
//       _channel!.sink.add(message);
//       _role = role;
//     } else {
//       print("Cannot send role - not connected");
//     }
//   }

//   void sendFrame(Uint8List bytes) {
//     if (_isConnected && _channel != null) {
//       _channel!.sink.add(bytes);
//     } else {
//       print("Cannot send frame - not connected");
//     }
//   }

//   void sendDrawing3DPoints(
//     List<vm.Vector3> points,
//     String mode, {
//     String color = '#FF0000',
//     double strokeWidth = 4.0,
//   }) {
//     if (!_isConnected || _channel == null) {
//       print("Cannot send 3D drawing - not connected");
//       return;
//     }
//     if (points.isEmpty) {
//       print("No 3D points to send");
//       return;
//     }
//     try {
//       final pointsData = points
//           .map((p) => {
//                 'x': p.x,
//                 'y': p.y,
//                 'z': p.z,
//                 'mode': mode,
//                 'color': color,
//                 'strokeWidth': strokeWidth,
//               })
//           .toList();
//       final message = {
//         'type': 'drawing3d',
//         'points': pointsData,
//         'from': _role ?? 'unknown',
//       };
//       final jsonMessage = jsonEncode(message);
//       print("Sending 3D drawing message: $jsonMessage");
//       _channel!.sink.add(jsonMessage);
//       print("3D Drawing sent successfully - ${points.length} points");
//     } catch (e) {
//       print("Failed to send 3D drawing points: $e");
//     }
//   }

//   void sendCameraPose(vm.Matrix4 viewMatrix, vm.Matrix4 projectionMatrix) {
//     if (!_isConnected || _channel == null) {
//       print("Cannot send camera pose - not connected");
//       return;
//     }
//     try {
//       final message = {
//         'type': 'camera_pose',
//         'viewMatrix': viewMatrix.storage.toList(),
//         'projectionMatrix': projectionMatrix.storage.toList(),
//         'from': _role ?? 'unknown',
//       };
//       final jsonMessage = jsonEncode(message);
//       _channel!.sink.add(jsonMessage);
//     } catch (e) {
//       print("Failed to send camera pose: $e");
//     }
//   }

//   void sendClearCommand() {
//     if (!_isConnected || _channel == null) {
//       print("Cannot send clear command - not connected");
//       return;
//     }
//     try {
//       final message = jsonEncode({
//         'type': 'clear',
//         'from': _role ?? 'unknown',
//       });
//       print("Sending clear command: $message");
//       _channel!.sink.add(message);
//     } catch (e) {
//       print("Failed to send clear command: $e");
//     }
//   }

//   bool get isConnected => _isConnected;
//   String? get role => _role;

//   void dispose() {
//     print("Disposing WebSocket connection");
//     _isConnected = false;
//     _channel?.sink.close();
//   }
// }

// String colorToHex(Color color) {
//   return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
// }

// Color hexToColor(String hex) {
//   final hexColor = hex.replaceAll('#', '');
//   return Color(int.parse('FF$hexColor', radix: 16));
// }

// vm.Vector3 screenToWorld(Offset screenPoint, double depth, Size screenSize, vm.Matrix4 viewMatrix, vm.Matrix4 projectionMatrix) {
//   final normalizedX = (screenPoint.dx / screenSize.width) * 2.0 - 1.0;
//   final normalizedY = -((screenPoint.dy / screenSize.height) * 2.0 - 1.0);
  
//   final clipCoords = vm.Vector4(normalizedX, normalizedY, -1.0, 1.0);
//   final inverseProjection = vm.Matrix4.copy(projectionMatrix)..invert();
//   final eyeCoords = inverseProjection * clipCoords;
//   eyeCoords.xyz = eyeCoords.xyz / eyeCoords.w;
  
//   final worldCoords = (vm.Matrix4.copy(viewMatrix)..invert()) * vm.Vector4(eyeCoords.x, eyeCoords.y, eyeCoords.z, 1.0);
  
//   return vm.Vector3(worldCoords.x, worldCoords.y, worldCoords.z);
// }

// vm.Vector2 worldToScreen(vm.Vector3 worldPoint, Size screenSize, vm.Matrix4 viewMatrix, vm.Matrix4 projectionMatrix) {
//   final viewPoint = viewMatrix * vm.Vector4(worldPoint.x, worldPoint.y, worldPoint.z, 1.0);
//   final clipPoint = projectionMatrix * viewPoint;
  
//   if (clipPoint.w != 0) {
//     final ndcX = clipPoint.x / clipPoint.w;
//     final ndcY = clipPoint.y / clipPoint.w;
    
//     final screenX = (ndcX + 1.0) * 0.5 * screenSize.width;
//     final screenY = (1.0 - ndcY) * 0.5 * screenSize.height;
    
//     return vm.Vector2(screenX, screenY);
//   }
  
//   return vm.Vector2.zero();
// }