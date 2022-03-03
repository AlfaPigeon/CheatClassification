import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:scmeet/webrtc/peer_connection.dart';

class Connection extends PeerConnection {
  String userId;
  String connectionType;
  String name;
  bool videoEnabled = true;
  bool audioEnabled = true;

  Connection(
      {required this.userId,
      required this.connectionType,
      required this.name,
      required this.audioEnabled,
      required this.videoEnabled,
      required MediaStream? stream})
      : super(localStream: stream);

  void toggleVideo(bool val) {
    videoEnabled = val;
  }

  void toggleAudio(bool val) {
    audioEnabled = val;
  }
}
