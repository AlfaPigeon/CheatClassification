import 'package:eventify/eventify.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:scmeet/model/user.dart';

class PeerConnection extends EventEmitter {
  MediaStream? localStream;
  late MediaStream? remoteStream;
  RTCVideoRenderer renderer = RTCVideoRenderer();

  RTCPeerConnection? rtcPeerConnection;
  RTCPeerConnection? pythonConnection;
  int connectionCount = 0;
  User user = Get.find();

  PeerConnection({required this.localStream});

  final Map<String, dynamic> configuration = {
    'iceServers': [
      {
        "urls": [
          'stun:stun.l.google.com:19302',
          'stun:stun1.l.google.com:19302'
        ],
      }
    ]
  };
  final Map<String, dynamic> loopbackConstraints = {
    "mandatory": {},
    "optional": [
      {"DtlsSrtpKeyAgreement": true},
    ],
  };

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };

  Future<void> start() async {
    rtcPeerConnection =
        await createPeerConnection(configuration, loopbackConstraints);
    localStream?.getTracks().forEach((track) {
      rtcPeerConnection?.addTrack(track, localStream!);
    });
    //rtcPeerConnection.addTrack(localStream);
    rtcPeerConnection!.onAddStream = _onAddStream;
    rtcPeerConnection!.onRemoveStream = _onRemoveStream;
    rtcPeerConnection!.onRenegotiationNeeded = _onRenegotiationNeeded;
    rtcPeerConnection!.onIceCandidate = _onIceCandidate;
    await renderer.initialize();
    emit('connected');
  }

  void _onAddStream(MediaStream stream) {
    remoteStream = stream;
    renderer.srcObject = stream;
    //renderer.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;
    emit('stream-changed');
  }

  void _onRemoveStream(MediaStream stream) {
    remoteStream = null;
  }

  void _onRenegotiationNeeded() {
    emit('negotiationneeded');
  }

  void _onIceCandidate(RTCIceCandidate candidate) {
    emit('candidate', null, candidate);
  }

  Future<RTCSessionDescription?> createOffer() async {
    if (rtcPeerConnection != null) {
      try {
        final RTCSessionDescription? sdp =
            await rtcPeerConnection?.createOffer(offerSdpConstraints);
        await rtcPeerConnection?.setLocalDescription(sdp!);
        return sdp;
        // ignore: empty_catches
      } catch (error) {}
    }
    return null;
  }

  Future<void> setOfferSdp(RTCSessionDescription sdp) async {
    if (rtcPeerConnection != null) {
      await rtcPeerConnection?.setRemoteDescription(sdp);
    }
  }

  Future<RTCSessionDescription?> createAnswer() async {
    if (rtcPeerConnection != null) {
      final RTCSessionDescription? sdp =
          await rtcPeerConnection?.createAnswer(offerSdpConstraints);
      await rtcPeerConnection?.setLocalDescription(sdp!);
      return sdp;
    }
    return null;
  }

  Future<void> setAnswerSdp(RTCSessionDescription sdp) async {
    if (rtcPeerConnection != null) {
      await rtcPeerConnection?.setRemoteDescription(sdp);
    }
  }

  Future<void> setCandidate(RTCIceCandidate candidate) async {
    if (rtcPeerConnection != null) {
      await rtcPeerConnection?.addCandidate(candidate);
    }
  }

  void close() {
    if (rtcPeerConnection != null) {
      rtcPeerConnection?.close();
      rtcPeerConnection = null;
    }
    renderer.dispose();
    localStream = null;
    remoteStream = null;
  }
}
