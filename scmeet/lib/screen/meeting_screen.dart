import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;
import 'package:scmeet/constants.dart';
import 'package:scmeet/controller/meeting_controller.dart';
import 'package:scmeet/model/meeting_detail.dart';
import 'package:scmeet/model/user.dart';
import 'package:scmeet/screen/chat_screen.dart';
import 'package:scmeet/screen/home_screen.dart';
import 'package:scmeet/webrtc/meeting.dart';
import 'package:scmeet/webrtc/message_format.dart';
import 'package:scmeet/webrtc/python_connection.dart';
import 'package:scmeet/widget/control_panel.dart';
import 'package:scmeet/widget/custom_button.dart';
import 'package:scmeet/widget/remote_video_page_view.dart';
import 'package:http/http.dart' as http;

// ignore: constant_identifier_names
enum PopUpChoiceEnum { CopyId }

class PopUpChoice {
  PopUpChoiceEnum id;
  String title;

  PopUpChoice(this.id, this.title);
}

class MeetingScreen extends StatefulWidget {
  final String meetingId;
  final String name;
  final MeetingDetail meetingDetail;

  const MeetingScreen(
      {Key? key,
      required this.meetingId,
      required this.name,
      required this.meetingDetail})
      : super(key: key);

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  bool isValidMeeting = false;
  TextEditingController textEditingController = TextEditingController();
  // ignore: avoid_init_to_null
  Meeting? meeting = null;
  bool isConnectionFailed = false;
  String userId = "";
  final _localRenderer = RTCVideoRenderer();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  MeetingController meetingController = getx.Get.find();

  final Map<String, dynamic> mediaConstraints = {
    "audio": true,
    "video": {
      "mandatory": {
        "minWidth": '640', // Provide your own width, height and frame rate here
        "minHeight": '480',
        "minFrameRate": '30',
      },
      "facingMode": "user",
      "optional": [],
    }
  };
  final List<PopUpChoice> choices = [
    PopUpChoice(PopUpChoiceEnum.CopyId, 'Copy Meeting ID'),
  ];
  bool isChatOpen = false;
  List<MessageFormat> messages = [];
  final PageController pageController = PageController();
  User user = getx.Get.find();
  Timer? timer;
  Timer? pythonTimer;
  Timer? meetingTime;
  // ignore: prefer_collection_literals
  Map<String, int>? objDetResults = Map();
  MediaStream? pythonLocalStream;

  int time = 0;
  Duration duration = Duration();

  @override
  void initState() {
    super.initState();
    initRenderers();
    start();
    if (user.isHost == "1") {
      timer = Timer.periodic(const Duration(seconds: 10),
          (Timer t) => getObjectDetectionResults());
      print("timer set");
    }
    if (user.isHost == "0") {
      pythonTimer = Timer(
          const Duration(seconds: 10),
          () => connectToPython(
              pythonLocalStream, meetingController.connectionLength));
    }

    startTimer();
  }

  Widget buildClock() {
    String twoDigits(int n) => n.toString().padLeft(2,'0');
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return Text("$minutes:$seconds", style: myTextStyle(20, FontWeight.bold, thirdColor),);
  }

  void addTime() {
    final addSeconds = 1;

    setState(() {
      final seconds = duration.inSeconds + addSeconds;

      duration = Duration(seconds: seconds);
    });
  }

  void startTimer() {
  const oneSec = Duration(seconds: 1);
  meetingTime = Timer.periodic(
    oneSec,
    (_) => addTime()
  );
}

  void getObjectDetectionResults() async {
    var sqldata;
    await http
        .get(Uri.parse("http://kemalbayik.com/read_od_outputs.php"))
        .then((response) {
      sqldata = jsonDecode(response.body);
    });

    print("sqldata data $sqldata");
    for (int i = 0; i < sqldata["user_id"].length; i++) {
      if (objDetResults!.containsKey(sqldata["user_id"][i])) {
        print("UPDATEEE");
        objDetResults!.update(sqldata["user_id"][i],
            (value) => int.parse(sqldata["percentage"][i]));
      } else {
        objDetResults!.putIfAbsent(
            sqldata["user_id"][i], () => int.parse(sqldata["percentage"][i]));
      }
    }
    print("oBJ DET  resultss =>${objDetResults}");
    meetingController.updateOdResults(objDetResults!);
    print("od resultss =>${meetingController.odResults}");

    print(objDetResults!.keys);
    print(objDetResults!.values);
  }

  @override
  deactivate() {
    super.deactivate();
    _localRenderer.srcObject = null;
    _localRenderer.dispose();
    if(timer != null) {
      timer!.cancel();
    }
    if(pythonTimer != null) {
      pythonTimer!.cancel();
    }
    if(meetingTime != null) {
      meetingTime!.cancel();
    }
    if (meeting != null) {
      meeting?.destroy();
      meeting = null;
    }
  }

  initRenderers() async {
    await _localRenderer.initialize();
  }

  void goToHome() {
    getx.Get.off(const HomeScreen());
  }

  void start() async {
    userId = user.email.toString();
    MediaStream _localstream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localRenderer.srcObject = _localstream;
    //_localRenderer = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain as RTCVideoRenderer;
    meeting = Meeting(
      meetingId: widget.meetingDetail.id,
      stream: _localstream,
      userId: userId,
      name: widget.name,
    );

    print(
        "meeting connection length ============> ${meeting!.connections.length}");
    setState(() {
      pythonLocalStream = _localstream;
    });
    meeting?.on('open', null, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meeting?.on('connection', null, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meeting?.on('user-left', null, (ev, ctx) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meeting?.on('ended', null, (ev, ctx) {
      _localstream.dispose();
      meetingEndedEvent();
    });
    meeting?.on('connection-setting-changed', null, (ev, ctx) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meeting?.on('message', null, (ev, ctx) {
      setState(() {
        isConnectionFailed = false;
        messages.add(ev.eventData as MessageFormat);
      });
    });
    meeting?.on('stream-changed', null, (ev, ctx) {
      setState(() {
        isConnectionFailed = false;
      });
    });
    meeting?.on('failed', null, (ev, ctx) {
      const snackBar = SnackBar(content: Text('Connection Failed'));
      // ignore: deprecated_member_use
      scaffoldKey.currentState!.showSnackBar(snackBar);
      setState(() {
        isConnectionFailed = true;
      });
    });
    meeting?.on('not-found', null, (ev, ctx) {
      meetingEndedEvent();
    });
    setState(() {
      isValidMeeting = false;
    });
  }

  void meetingEndedEvent() {
    const snackBar = SnackBar(content: Text('Meeing Ended'));

    // ignore: deprecated_member_use
    scaffoldKey.currentState!.showSnackBar(snackBar);
    goToHome();
  }

  connectToPython(var _localstream, var length) {
    PythonConnection(localStream: _localstream, connectionLength: length)
        .start();
  }

  void exitClick() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  void onEnd() {
    if (meeting != null) {
      meeting?.leave();
      meeting?.end();
      meeting = null;
      goToHome();
    }
  }

  void onLeave() {
    if (meeting != null) {
      meeting?.leave();
      meeting = null;
      goToHome();
    }
  }

  void onVideoToggle() {
    if (meeting != null) {
      setState(() {
        meeting?.toggleVideo();
      });
    }
  }

  void onAudioToggle() {
    if (meeting != null) {
      setState(() {
        meeting?.toggleAudio();
      });
    }
  }

  bool isHost() {
    // ignore: unnecessary_null_comparison
    return meeting != null && widget.meetingDetail != null
        ? meeting!.userId == widget.meetingDetail.hostId
        : false;
  }

  bool isVideoEnabled() {
    return meeting != null ? meeting!.videoEnabled : false;
  }

  bool isAudioEnabled() {
    return meeting != null ? meeting!.audioEnabled : false;
  }

  void _select() async {
    final meetingId = widget.meetingId;
    const snackBar = SnackBar(content: Text('Copied'));
    String text = '';
    text = meetingId;
    await Clipboard.setData(ClipboardData(text: text));
    // ignore: deprecated_member_use
    scaffoldKey.currentState!.showSnackBar(snackBar);
  }

  void handleReconnect() {
    if (meeting != null) {
      meeting?.reconnect();
    }
  }

  void handleChatToggle() {
    setState(() {
      isChatOpen = !isChatOpen;
      //pageController.jumpToPage(isChatOpen ? 1 : 0);
    });
  }

  void handleSendMessage(String text) {
    if (meeting != null) {
      meeting?.sendUserMessage(text);
      final message = MessageFormat(
        userId: meeting!.userId,
        text: text,
      );
      setState(() {
        messages.add(message);
      });
    }
  }

  List<Widget> _buildActions() {
    var widgets = <Widget>[
      /* GestureDetector(
        onTap:() => onLeave ,
        child: const Icon(Icons.meeting_room), 
      ),*/
    ];
    if (isHost()) {
      widgets.add(
        CustomButton(
          text: 'End',
          onTap: onEnd,
          width: MediaQuery.of(context).size.width / 4,
        ),
      );
    }
    /* widgets.add(PopupMenuButton<PopUpChoice>(
      onSelected: _select,
      itemBuilder: (BuildContext context) {
        return choices.map((PopUpChoice choice) {
          return PopupMenuItem<PopUpChoice>(
            value: choice,
            child: Text(choice.title),
          );
        }).toList();
      },
    )); */
    return widgets;
  }

  Widget _buildMeetingRoom() {
    getTracks();
    return SafeArea(
      child: Row(
        //crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 45,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/background12.png'),
                  ),
                ),
              ),
              user.isHost == "1" ? SizedBox(
                width: MediaQuery.of(context).size.width - 45,
                child: Stack(
                  children: <Widget>[
                    meeting!.connections.isNotEmpty
                        ? RemoteVideoPageView(
                            connections: meeting!.connections,
                            odResults: objDetResults
                          )
                        : const Center(
                            child: Text(
                              '  Waiting for participants to join the meeting  ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromARGB(239, 207, 216, 220),
                                fontSize: 24.0,
                              ),
                            ),
                          ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 6,
                            height: MediaQuery.of(context).size.height / 5,
                            child: RTCVideoView(
                              _localRenderer,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitContain,
                            ),
                          ),
                          //Text(getTracks(), style: TextStyle(color: Colors.white),),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: buildClock(),
                    )
                  ],
                ),
              ) : Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 1.05,
                            height: MediaQuery.of(context).size.height / 1.1,
                            child: RTCVideoView(
                              _localRenderer,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitContain,
                            ),
                          ),
                          //Text(getTracks(), style: TextStyle(color: Colors.white),),
                        ],
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  getTracks() {
    String tr = "";

    meeting?.stream!.getVideoTracks().map((track) {
      print(" track =>  ${track.captureFrame()}");
      setState(() {
        tr = track.captureFrame().toString();
      });
    });

    return tr;
  }

  @override
  Widget build(BuildContext context) {
    return meeting == null
        ? Container(
            color: secondaryColor,
            child: const Center(
                child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                        strokeWidth: 15.0,
                        backgroundColor: Color.fromARGB(255, 51, 84, 116),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(235, 200, 163, 112))))),
          )
        : Scaffold(
            key: scaffoldKey,
            /*nameMapappBar: AppBar(
              title: const Text("Online Exam Inspection Platform"),
              backgroundColor: fourthColor, /*actions: _buildActions(),*/ 
            ),*/
            body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ControlPanel(
                onAudioToggle: onAudioToggle,
                onVideoToggle: onVideoToggle,
                videoEnabled: isVideoEnabled(),
                audioEnabled: isAudioEnabled(),
                isConnectionFailed: isConnectionFailed,
                onReconnect: handleReconnect,
                onChatToggle: handleChatToggle,
                isChatOpen: isChatOpen,
                onLeave: onLeave,
                end: onEnd,
                select: _select,
                host: isHost,
              ),
              isChatOpen
                  ? ChatScreen(
                      messages: messages,
                      onSendMessage: handleSendMessage,
                      connections: meeting!.connections,
                      userId: meeting!.userId,
                      userName: meeting!.name,
                    )
                  : _buildMeetingRoom(),
            ]));
  }
}
