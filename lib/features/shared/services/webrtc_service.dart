import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'}
    ]
  };

  Future<void> initialize({required bool isCaller}) async {
    _peerConnection = await createPeerConnection(_iceServers);

    if (isCaller) {
      // USER: capture media and send
      _localStream = await navigator.mediaDevices.getUserMedia({
        'video': true,
        'audio': false,
      });

      for (var track in _localStream!.getTracks()) {
        _peerConnection!.addTrack(track, _localStream!);
      }
    } else {
      // NAVIGATOR: just receive
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
        }
      };
    }

    // This is mock logic: skip signaling (add real signaling server for real apps)
  }

  MediaStream? getLocalStream() => _localStream; // used by User
  MediaStream? getRemoteStream() => _remoteStream; // used by Navigator

  void dispose() {
    _localStream?.dispose();
    _peerConnection?.close();
  }
}
