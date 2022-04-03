import 'dart:convert';

import 'package:eventify/eventify.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:scmeet/webrtc/connection.dart';
import 'package:scmeet/webrtc/message_format.dart';
import 'package:scmeet/webrtc/message_payload.dart';
import 'package:scmeet/webrtc/payload_data.dart';
import 'package:scmeet/webrtc/transport.dart';

class Meeting extends EventEmitter {
  final String url = 'ws://3.65.205.17:8081/websocket/meeting';
  Transport? transport;
  String meetingId;
  List<Connection> connections = [];
  bool joined = false;
  bool connected = false;
  MediaStream? stream;
  String userId;
  String name;
  List<MessageFormat> messages = [];
  bool videoEnabled = true;
  bool audioEnabled = true;

  Meeting({required this.meetingId, required this.userId, required this.name, required this.stream}) {
    transport = Transport(
      url: formatUrl(meetingId),
      maxRetryCount: 3,
      canReconnect: true,
    );
    listenMessage();
  }

  String formatUrl(String id) {
    return '$url?id=$id';
  }

  MessagePayload parseMessage(dynamic data) {
    try {
      return MessagePayload.fromJson(json.decode(data));
    } catch (error) {
      return MessagePayload(type: 'unknown');
    }
  }

  void sendMessage(String type, dynamic data) {
    try {
      final String payload = json.encode({'type': type, 'data': data});
      if (transport != null) {
        transport?.send(payload);
      }
    // ignore: empty_catches
    } catch (error) {
      
    }
  }

  void listenMessage() {
    if (transport != null) {
      transport?.on('open', null, (ev, context) {
        connected = true;
        join();
      });
      transport?.on('message', null, (ev, context) {
        final payload = parseMessage(ev.eventData);
        handleMessage(payload);
      });
      transport?.on('closed', null, (ev, context) {
        connected = false;
      });
      transport?.on('failed', null, (ev, context) {
        reset();
        emit('failed');
      });
      transport?.connect();
    }
  }

  Connection? getConnection(String userId) {
    return connections.firstWhere((connection) => connection.userId == userId);
  }

  Future<Connection?> createConnection(UserJoinedData data) async {
    if (stream != null) {
      final connection = Connection(
        connectionType: 'incoming',
        userId: data.userId,
        name: data.name,
        stream: stream,
        audioEnabled: data.config.audioEnabled,
        videoEnabled: data.config.videoEnabled,
      );
      connection.on('connected', null, (ev, context) {
      });
      connection.on('candidate', null, (ev, context) {
        sendIceCandidate(connection.userId, ev.eventData as RTCIceCandidate);
      });
      connection.on('stream-changed', null, (ev, context) {
        emit('stream-changed');
      });
      connections.add(connection);
      await connection.start();
      emit('connection', null, connection);
      return connection;
    }
    return null;
  }

  void join() {
    sendMessage('join-meeting', {
      'name': name,
      'userId': userId,
      'config': {
        'audioEnabled': audioEnabled,
        'videoEnabled': videoEnabled,
      },
    });
  }

  void joinedMeeting(JoinedMeetingData data) {
    joined = true;
    userId = data.userId;
  }

  void userJoined(UserJoinedData data) async {
    final connection = await createConnection(data);
    if (connection != null) {
      sendConnectionRequest(connection.userId);
    }
  }

  void sendIceCandidate(String otherUserId, RTCIceCandidate candidate) {
    sendMessage('icecandidate', {
      'userId': userId,
      'otherUserId': otherUserId,
      'candidate': candidate.toMap(),
    });
  }

  void sendConnectionRequest(String otherUserId) {
    sendMessage('connection-request', {
      'name': name,
      'userId': userId,
      'otherUserId': otherUserId,
      'config': {
        'audioEnabled': audioEnabled,
        'videoEnabled': videoEnabled,
      },
    });
  }

  void receivedConnectionRequest(UserJoinedData data) async {
    final connection = await createConnection(data);
    if (connection != null) {
      sendOfferSdp(data.userId);
    }
  }

  void sendOfferSdp(String otherUserId) async {
    final connection = getConnection(otherUserId);
    if (connection != null) {
      final sdp = await connection.createOffer();
      sendMessage('offer-sdp', {
        'userId': userId,
        'otherUserId': otherUserId,
        'sdp': sdp?.toMap(),
      });
    }
  }

  void receivedOfferSdp(OfferSdpData data) {
    sendAnswerSdp(data.userId, data.sdp);
  }

  void sendAnswerSdp(String otherUserId, RTCSessionDescription sdp) async {
    final connection = getConnection(otherUserId);
    if (connection != null) {
      await connection.setOfferSdp(sdp);
      final answerSdp = await connection.createAnswer();
      sendMessage('answer-sdp', {
        'userId': userId,
        'otherUserId': otherUserId,
        'sdp': answerSdp?.toMap(),
      });
    }
  }

  void receivedAnswerSdp(AnswerSdpData data) async {
    final connection = getConnection(data.userId);
    if (connection != null) {
      await connection.setAnswerSdp(data.sdp);
    }
  }

  void setIceCandidate(IceCandidateData data) async {
    final connection = getConnection(data.userId);
    if (connection != null) {
      await connection.setCandidate(data.candidate);
    }
  }

  void userLeft(UserLeftData data) {
    final connection = getConnection(data.userId);
    if (connection != null) {
      emit('user-left', null, connection);
      connection.close();
      connections.removeWhere((element) => element.userId == connection.userId);
    }
  }

  void meetingEnded(MeetingEndedData data) {
    emit('ended');
    destroy();
  }

  void end() {
    sendMessage('end-meeting', {
      'userId': userId,
    });
    destroy();
  }

  void leave() {
    sendMessage('leave-meeting', {
      'userId': userId,
    });
    destroy();
  }

  bool toggleVideo() {
    if (stream != null) {
      final videoTrack = stream?.getVideoTracks()[0];
      if (videoTrack != null) {
        final bool videoEnabled = videoTrack.enabled = !videoTrack.enabled;
        this.videoEnabled = videoEnabled;
        sendMessage('video-toggle', {
          'userId': userId,
          'videoEnabled': videoEnabled,
        });
        return videoEnabled;
      }
    }
    return false;
  }

  bool toggleAudio() {
      final audioTrack = stream?.getAudioTracks()[0];
        final bool audioEnabled = audioTrack!.enabled = !audioTrack.enabled;
        this.audioEnabled = audioEnabled;
        sendMessage('audio-toggle', {
          'userId': userId,
          'audioEnabled': audioEnabled,
        });
        return audioEnabled;
    //return false;
  }

  void listenVideoToggle(VideoToggleData data) {
    final connection = getConnection(data.userId);
    if (connection != null) {
      connection.toggleVideo(data.videoEnabled);
      emit('connection-setting-changed');
    }
  }

  void listenAudioToggle(AudioToggleData data) {
    final connection = getConnection(data.userId);
    if (connection != null) {
      connection.toggleAudio(data.audioEnabled);
      emit('connection-setting-changed');
    }
  }

  void handleUserMessage(MessageData data) {
    messages.add(data.message);
    emit('message', null, data.message);
  }

  void sendUserMessage(String text) {
    sendMessage('message', {
      'userId': userId,
      'message': {
        'userId': userId,
        'text': text,
      },
    });
  }

  void handleNotFound() {
    emit('not-found');
  }

  stopStream() {
    if (stream != null) {
      print("Stream disposed");
      stream?.dispose();
    }
  }

  void handleMessage(MessagePayload payload) {
    switch (payload.type) {
      case 'joined-meeting':
        joinedMeeting(JoinedMeetingData.fromJson(payload.data));
        break;
      case 'user-joined':
        userJoined(UserJoinedData.fromJson(payload.data));
        break;
      case 'connection-request':
        receivedConnectionRequest(UserJoinedData.fromJson(payload.data));
        break;
      case 'offer-sdp':
        receivedOfferSdp(OfferSdpData.fromJson(payload.data));
        break;
      case 'answer-sdp':
        receivedAnswerSdp(AnswerSdpData.fromJson(payload.data));
        break;
      case 'user-left':
        userLeft(UserLeftData.fromJson(payload.data));
        break;
      case 'meeting-ended':
        meetingEnded(MeetingEndedData.fromJson(payload.data));
        break;
      case 'icecandidate':
        setIceCandidate(IceCandidateData.fromJson(payload.data));
        break;
      case 'video-toggle':
        listenVideoToggle(VideoToggleData.fromJson(payload.data));
        break;
      case 'audio-toggle':
        listenAudioToggle(AudioToggleData.fromJson(payload.data));
        break;
      case 'message':
        handleUserMessage(MessageData.fromJson(payload.data));
        break;
      case 'not-found':
        handleNotFound();
        break;
      default:
        break;
    }
  }

  void destroy() {
    if (transport != null) {
      transport?.destroy();
      transport = null;
    }
    // ignore: avoid_function_literals_in_foreach_calls
    connections.forEach((connection) {
      connection.close();
    });
    stopStream();
    connections = [];
    connected = false;
    stream = null;
    joined = false;
  }

  void reset() {
    connections = [];
    joined = false;
    connected = false;
  }

  void reconnect() {
    if (transport != null) {
      transport?.reconnect();
    }
  }
}
