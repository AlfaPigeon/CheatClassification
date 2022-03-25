import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:scmeet/constants.dart';
import 'package:scmeet/webrtc/connection.dart';
import 'package:scmeet/widget/custom_text.dart';

class RemoteConnection extends StatefulWidget {
  final RTCVideoRenderer renderer;
  final Connection? connection;
  final int length;

  // ignore: use_key_in_widget_constructors
  const RemoteConnection(
      {required this.renderer, required this.connection, required this.length});

  @override
  _RemoteConnectionState createState() => _RemoteConnectionState();
}

class _RemoteConnectionState extends State<RemoteConnection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: (MediaQuery.of(context).size.width - 100) /
            sqrt(widget.length).ceil(),
        height: (MediaQuery.of(context).size.height - 100) /
            (widget.length / sqrt(widget.length).ceil()).ceil(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white38,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: <Widget>[
              RTCVideoView(widget.renderer,
                  objectFit:
                      RTCVideoViewObjectFit.RTCVideoViewObjectFitContain),
              //Text(widget.renderer.toString()),
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      color: thirdColor,
                      child: CustomText(
                        text: widget.connection!.name,
                        fontSize: MediaQuery.of(context).size.width / 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      color: thirdColor,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            widget.connection!.videoEnabled
                                ? Icons.videocam
                                : Icons.videocam_off,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width / 30,
                          ),
                          const SizedBox(
                            width: 10,
                            height: 10,
                          ),
                          Icon(
                            widget.connection!.audioEnabled
                                ? Icons.mic
                                : Icons.mic_off,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width / 30,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: widget.connection!.videoEnabled
                    ? Colors.transparent
                    : thirdColor,
                child: Center(
                    child: CustomText(
                  text: widget.connection!.videoEnabled
                      ? ''
                      : widget.connection!.name,
                  fontSize: MediaQuery.of(context).size.width / 50,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
