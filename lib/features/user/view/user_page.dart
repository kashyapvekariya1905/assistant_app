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
  late SocketService _socket;
  Timer? _sendTimer;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.max);
    await _controller.initialize();

    _socket = SocketService();
    _socket.connect('ws://localhost:8080');
    _socket.sendRole('user');

    _sendTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      try {
        final file = await _controller.takePicture();
        final bytes = await file.readAsBytes();
        _socket.sendFrame(bytes);
      } catch (e) {
        debugPrint("Capture error: \$e");
      }
    });

    setState(() {});
  }

  @override
  void dispose() {
    _sendTimer?.cancel();
    _controller.dispose();
    _socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Camera')),
      body: _controller.value.isInitialized
          ? CameraPreview(_controller)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
