import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  late WebSocketChannel _channel;

  void connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  void sendRole(String role) {
    _channel.sink.add("ROLE:$role");
  }

  void sendFrame(Uint8List bytes) {
    _channel.sink.add(bytes);
  }

  Stream get stream => _channel.stream;

  void dispose() {
    _channel.sink.close();
  }
}
