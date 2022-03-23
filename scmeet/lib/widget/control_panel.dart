import 'package:flutter/material.dart';
import 'package:scmeet/constants.dart';
import 'package:scmeet/widget/custom_button.dart';

class ControlPanel extends StatelessWidget {
  final bool videoEnabled;
  final bool audioEnabled;
  final bool isConnectionFailed;
  final bool isChatOpen;
  final VoidCallback onVideoToggle;
  final VoidCallback onAudioToggle;
  final VoidCallback onReconnect;
  final VoidCallback onChatToggle;
  final VoidCallback onLeave;
  final VoidCallback select;
  final VoidCallback end;
  final VoidCallback host;

  const ControlPanel({Key? key, 
    required this.onAudioToggle,
    required this.onVideoToggle,
    required this.videoEnabled,
    required this.audioEnabled,
    required this.onReconnect,
    required this.isConnectionFailed,
    required this.onChatToggle,
    required this.isChatOpen,
    required this.onLeave,
    required this.select,
    required this.end,
    required this.host,
  }) : super(key: key);

  List<Widget> buildControls() {
    if (!isConnectionFailed) {
      return <Widget>[
        const Image(
          height: 50,
         image: AssetImage('assets/logo2.png')
        ),
        IconButton(
          onPressed: onVideoToggle,
          icon: Icon(videoEnabled ? Icons.videocam : Icons.videocam_off),
          color: Colors.white,
          iconSize: 32.0,
        ),
        IconButton(
          onPressed: onAudioToggle,
          icon: Icon(audioEnabled ? Icons.mic : Icons.mic_off),
          color: Colors.white,
          iconSize: 32.0,
        ),
        IconButton(
          onPressed: onChatToggle,
          icon:
              Icon(isChatOpen ? Icons.speaker_notes_off : Icons.speaker_notes),
          color: Colors.white,
          iconSize: 32.0,
        ),
        IconButton(       
          onPressed: select,
          icon: const Icon(Icons.link_rounded), 
          color: Colors.white,
          iconSize: 32.0,
        ),
        
        IconButton(
          onPressed: onLeave,
          icon: const Icon(Icons.meeting_room), 
          color: Colors.white,
          iconSize: 32.0,
        ),

        IconButton(
          onPressed: end,
          icon: const Icon(Icons.cancel_presentation), 
          color: Color.fromARGB(255, 241, 56, 42),
          iconSize: 32.0,
        ),
    //    if (host == true){
     
        //}

        /*
        if (isHost()) {
      widgets.add(
        CustomButton(
          text: 'End',
          onTap: onEnd,
          width: MediaQuery.of(context).size.width / 4,
        ),
      );
    }
        */ 
      ];
    } else {
      return <Widget>[
        CustomButton(
          text: 'Reconnect',
          onTap: onReconnect,
          width: 50,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    var widgets = buildControls();
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widgets,
      ),
      color: Color.fromARGB(255, 51, 84, 116),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width / 20,
    );
  }
}
