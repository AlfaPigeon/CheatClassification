import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:scmeet/webrtc/message_format.dart';

class JoinedMeetingData {
  String userId;
  String name;

  JoinedMeetingData({required this.userId, required this.name});

  factory JoinedMeetingData.fromJson(dynamic json) {
    return JoinedMeetingData(
      userId: json['userId'],
      name: json['name'],
    );
  }
}

class Config {
  bool videoEnabled;
  bool audioEnabled;

  Config({required this.videoEnabled, required this.audioEnabled});
}

class UserJoinedData {
  String userId;
  String name;
  Config config;

  UserJoinedData({required this.userId, required this.name, required this.config});

  factory UserJoinedData.fromJson(dynamic json) {
    return UserJoinedData(
      userId: json['userId'],
      name: json['name'],
      config: Config(
        audioEnabled: json['config']['audioEnabled'],
        videoEnabled: json['config']['videoEnabled'],
      ),
    );
  }
}

class IncomingConnectionRequestData {
  String userId;
  String name;
  Config config;

  IncomingConnectionRequestData({required this.userId, required this.name, required this.config});

  factory IncomingConnectionRequestData.fromJson(dynamic json) {
    return IncomingConnectionRequestData(
      userId: json['userId'],
      name: json['name'],
      config: Config(
        audioEnabled: json['config']['audioEnabled'],
        videoEnabled: json['config']['videoEnabled'],
      ),
    );
  }
}

class OfferSdpData {
  String userId;
  RTCSessionDescription sdp;

  OfferSdpData({required this.userId, required this.sdp});

  factory OfferSdpData.fromJson(dynamic json) {
    return OfferSdpData(
      userId: json['userId'],
      sdp: RTCSessionDescription(json['sdp']['sdp'], json['sdp']['type']),
    );
  }
}

class AnswerSdpData {
  String userId;
  RTCSessionDescription sdp;

  AnswerSdpData({required this.userId, required this.sdp});

  factory AnswerSdpData.fromJson(dynamic json) {
    return AnswerSdpData(
      userId: json['userId'],
      sdp: RTCSessionDescription(json['sdp']['sdp'], json['sdp']['type']),
    );
  }
}

class MeetingEndedData {
  String userId;
  String name;

  MeetingEndedData({required this.userId, required this.name});

  factory MeetingEndedData.fromJson(dynamic json) {
    return MeetingEndedData(
      userId: json['userId'],
      name: json['name'],
    );
  }
}

class UserLeftData {
  String userId;
  String name;

  UserLeftData({required this.userId, required this.name});

  factory UserLeftData.fromJson(dynamic json) {
    return UserLeftData(
      userId: json['userId'],
      name: json['name'],
    );
  }
}

class IceCandidateData {
  String userId;
  RTCIceCandidate candidate;

  IceCandidateData({required this.userId, required this.candidate});

  factory IceCandidateData.fromJson(dynamic json) { 
    return IceCandidateData(
      userId: json['userId'],
      candidate: RTCIceCandidate(
        json['candidate']['candidate'],
        json['candidate']['sdpMid'],
        json['candidate']['sdpMLineIndex'],
      ),
    );
  }
}

class VideoToggleData {
  String userId;
  bool videoEnabled;

  VideoToggleData({required this.userId, required this.videoEnabled});

  factory VideoToggleData.fromJson(dynamic json) {
    return VideoToggleData(
      userId: json['userId'],
      videoEnabled: json['videoEnabled'],
    );
  }
}

class AudioToggleData {
  String userId;
  bool audioEnabled;

  AudioToggleData({required this.userId, required this.audioEnabled});

  factory AudioToggleData.fromJson(dynamic json) {
    return AudioToggleData(
      userId: json['userId'],
      audioEnabled: json['audioEnabled'],
    );
  }
}

class MessageData {
  String userId;
  MessageFormat message;

  MessageData({required this.userId, required this.message});

  factory MessageData.fromJson(dynamic json) {
    return MessageData(
      userId: json['userId'],
      message: MessageFormat(
        userId: json['message']['userId'],
        text: json['message']['text'],
      ),
    );
  }
}
