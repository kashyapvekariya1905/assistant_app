import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NavigatorPage extends StatefulWidget {
  const NavigatorPage({super.key});

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  late WebSocketChannel _channel;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8080'));
    _channel.sink.add("ROLE:navigator");

    _channel.stream.listen((data) {
      if (data is Uint8List) {
        setState(() {
          _imageBytes = data;
        });
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigator View')),
      body: Center(
        child: _imageBytes == null
            ? const Text('Waiting for stream...')
            : Image.memory(_imageBytes!),
      ),
    );
  }
}
