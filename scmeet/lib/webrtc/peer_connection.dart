import 'package:eventify/eventify.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class PeerConnection extends EventEmitter {
  MediaStream? localStream;
  late MediaStream? remoteStream;
  RTCVideoRenderer renderer = RTCVideoRenderer();

  RTCPeerConnection? rtcPeerConnection;
  RTCPeerConnection? pythonConnection;

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
    print("startt");
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
    _makeCall();
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

  Future<void> _negotiateRemoteConnection() async {
    return pythonConnection!
        .createOffer()
        .then((offer) {
          return pythonConnection!.setLocalDescription(offer);
        })
        .then(_waitForGatheringComplete)
        .then((_) async {
          var des = await pythonConnection!.getLocalDescription();
          var headers = {
            'Content-Type': 'application/json',
          };
          var request = http.Request(
            'POST',
            Uri.parse(
                'http://127.0.0.1:9099/offer'), // CHANGE URL HERE TO LOCAL SERVER
          );
          request.body = json.encode(
            {
              "sdp": des!.sdp,
              "type": des.type,
              "video_transform": "edges",
            },
          );
          request.headers.addAll(headers);

          http.StreamedResponse response = await request.send();

          String data = "";
          print("response eee => ${response.statusCode}");
          if (response.statusCode == 200) {
            data = await response.stream.bytesToString();
            var dataMap = json.decode(data);
            print(" data mappp ===> $data");
            await pythonConnection!.setRemoteDescription(
              RTCSessionDescription(
                dataMap["sdp"],
                dataMap["type"],
              ),
            );
          } else {
            print(response.reasonPhrase);
          }
        });
  }

  Future<bool> _waitForGatheringComplete(_) async {
    print("WAITING FOR GATHERING COMPLETE");
    if (pythonConnection!.iceGatheringState ==
        RTCIceGatheringState.RTCIceGatheringStateComplete) {
      return true;
    } else {
      await Future.delayed(Duration(seconds: 1));
      return await _waitForGatheringComplete(_);
    }
  }

  Future<void> _makeCall() async {
    var configuration = <String, dynamic>{
      'sdpSemantics': 'unified-plan',
    };

    //* Create Peer Connection
    if (pythonConnection != null) return;
    pythonConnection = await createPeerConnection(
      configuration,
    );

    //pythonConnection!.onTrack = _onTrack;
    // _peerConnection!.onAddTrack = _onAddTrack;

    //* Create Data Channel
    /*_dataChannelDict = RTCDataChannelInit();
    _dataChannelDict!.ordered = true;
    _dataChannel = await pythonConnection!.createDataChannel(
      "chat",
      _dataChannelDict!,
    );
    _dataChannel!.onDataChannelState = _onDataChannelState;*/
    // _dataChannel!.onMessage = _onDataChannelMessage;

    final mediaConstraints = <String, dynamic>{
      'audio': false,
      'video': {
        'mandatory': {
          'minWidth':
              '500', // Provide your own width, height and frame rate here
          'minHeight': '500',
          'minFrameRate': '30',
        },
        // 'facingMode': 'user',
        'facingMode': 'environment',
        'optional': [],
      }
    };

    try {
      //var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      // _mediaDevicesList = await navigator.mediaDevices.enumerateDevices();
      //localStream = stream;
      // _localRenderer.srcObject = _localStream;

      localStream?.getTracks().forEach((element) {
        pythonConnection!.addTrack(element, localStream!);
      });

      print("NEGOTIATE");
      await _negotiateRemoteConnection();
    } catch (e) {
      print(e.toString());
    }
  }
}
