import 'package:eventify/eventify.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:scmeet/model/user.dart';

class PythonConnection extends EventEmitter {
  MediaStream? localStream;

  RTCPeerConnection? pythonConnection;
  int? connectionLength;
  User user = Get.find();
  int? port;

  PythonConnection({required this.localStream, required this.connectionLength});

  Future<void> start() async {
    print("python connection startt");
    port = 9094 + connectionLength!;
    print("port => $port");
    _makeCall();
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
                'http://217.131.34.131:${port.toString()}/offer'), // CHANGE URL HERE TO LOCAL SERVER
          );
          request.body = json.encode(
            {
              "sdp": des!.sdp,
              "type": des.type,
              "video_transform": "edges",
              "id": user.id.toString()
            },
          );
          request.headers.addAll(headers);

          http.StreamedResponse response = await request.send();

          String data = "";
          print("response eee => ${response.statusCode}");
          if (response.statusCode == 200) {
            data = await response.stream.bytesToString();
            var dataMap = json.decode(data);
            print(" data mappp ===> ${dataMap}");
            //print(" data mappp ===> ${dataMap['sdp']}");
            await pythonConnection!.setRemoteDescription(
              RTCSessionDescription(
                dataMap['sdp'],
                dataMap['type'],
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
      'iceServers': [
      {
        "urls": [
          'stun:stun.l.google.com:19302',
          'stun:stun1.l.google.com:19302'
        ],
      }
    ]
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
