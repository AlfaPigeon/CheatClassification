import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;
import 'package:scmeet/constants.dart';
import 'package:scmeet/model/meeting_detail.dart';
import 'package:scmeet/model/user.dart';
import 'package:scmeet/screen/chat_screen.dart';
import 'package:scmeet/screen/home_screen.dart';
import 'package:scmeet/webrtc/meeting.dart';
import 'package:scmeet/webrtc/message_format.dart';
import 'package:scmeet/widget/control_panel.dart';
import 'package:scmeet/widget/custom_button.dart';
import 'package:scmeet/widget/remote_video_page_view.dart';

// ignore: constant_identifier_names
enum PopUpChoiceEnum {CopyId }

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

  @override
  void initState() {
    super.initState();
    initRenderers();
    start();
  }

  @override
  deactivate() {
    super.deactivate();
    _localRenderer.dispose();
    if (meeting != null) {
      meeting?.destroy();
      meeting = null;
    }
  }

  initRenderers() async {
    await _localRenderer.initialize();
  }

  void goToHome() {
    getx.Get.to(const HomeScreen());
  }

  void start() async {
    userId = user.email;
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

  void exitClick() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  void onEnd() {
    if (meeting != null) {
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

  void _select(PopUpChoice choice) async {
    final meetingId = widget.meetingId;
    const snackBar = SnackBar(content: Text('Copied'));
    String text = '';
    if (choice.id == PopUpChoiceEnum.CopyId) {
      text = meetingId;
    } 
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
      pageController.jumpToPage(isChatOpen ? 1 : 0);
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
      CustomButton(
        text: 'Leave',
        onTap: onLeave,
        width: MediaQuery.of(context).size.width / 4,
      ),
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
    widgets.add(PopupMenuButton<PopUpChoice>(
      onSelected: _select,
      itemBuilder: (BuildContext context) {
        return choices.map((PopUpChoice choice) {
          return PopupMenuItem<PopUpChoice>(
            value: choice,
            child: Text(choice.title),
          );
        }).toList();
      },
    ));
    return widgets;
  }

  Widget _buildMeetingRoom() {
    return Stack(
      children: <Widget>[
        meeting!.connections.isNotEmpty
            ? RemoteVideoPageView(
                connections: meeting!.connections,
              )
            : const Center(
                child: Text(
                  'Waiting for participants to join the meeting',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 24.0,
                  ),
                ),
              ),
        Positioned(
          bottom: 10.0,
          right: 0.0,
          child: SizedBox(
            width: 150.0,
            height: 200.0,
            child: RTCVideoView(
              _localRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return meeting == null
        ? const CircularProgressIndicator()
        : Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: const Text("SC Meet"),
              actions: _buildActions(),
              backgroundColor: secondaryColor,
            ),
            body: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: <Widget>[
                _buildMeetingRoom(),
                 ChatScreen(
                  messages: messages,
                  onSendMessage: handleSendMessage,
                  connections: meeting!.connections,
                  userId: meeting!.userId,
                  userName: meeting!.name,
                ),
              ],
            ),
            bottomNavigationBar: ControlPanel(
              onAudioToggle: onAudioToggle,
              onVideoToggle: onVideoToggle,
              videoEnabled: isVideoEnabled(),
              audioEnabled: isAudioEnabled(),
              isConnectionFailed: isConnectionFailed,
              onReconnect: handleReconnect,
              onChatToggle: handleChatToggle,
              isChatOpen: isChatOpen,
            ),
          );
  }
}
