// ignore_for_file: avoid_function_literals_in_foreach_calls, avoid_unnecessary_containers, unused_local_variable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scmeet/controller/meeting_controller.dart';
import 'package:scmeet/webrtc/connection.dart';
import 'package:scmeet/widget/remote_connection.dart';

class RemoteVideoPageView extends StatefulWidget {
  final List<Connection> connections;
  // ignore: prefer_collection_literals
  final Map<String, int>? odResults;

  const RemoteVideoPageView({Key? key, required this.connections, required this.odResults})
      : super(key: key);

  @override
  State createState() => _RemoteVideoPageViewState();
}

class _RemoteVideoPageViewState extends State<RemoteVideoPageView> {


  MeetingController meetingController = Get.find();

  Widget _buildRemoteViewPage(int start) {
    var widgets = <Widget>[];
    var end = start + 1;
    var length = widget.connections.length;
    widget.connections
        //.sublist(start, end <= length ? end : length)
        .forEach((connection) {

      int objDetResult = 0;


      for(int i = 0; i < meetingController.allUsers.length; i++) {
        if(connection.name == meetingController.allUsers[i].name) {
          widget.odResults!.forEach((key, value) {
              if(key == meetingController.allUsers[i].id) {
                objDetResult = value;
              }
          });
          }
        }

      widgets.add(
        Container(
          //width: 600,
          //height: 500,
          child: RemoteConnection(
            renderer: connection.renderer,
            connection: connection,
            length: length
          ),
        ),
      );
    });

    return Center(
      child: buildBody(widgets),
    );
  }

  Widget buildBody(var widgets) {
    List<Widget> rows = [];
    List<Widget> cols = [];
    var widgetCount = 0;
    for (int i = 0;
        i < (widgets.length / sqrt(widgets.length).ceil()).ceil();
        i++) {
      for (int j = 0; j < sqrt(widgets.length).ceil(); j++) {
        if (widgetCount < widgets.length) {
          cols.add(widgets[widgetCount]);
          widgetCount++;
        }
      }
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: cols,
      ));

      cols = [];
    }

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rows,
      ),
    );
  }

  List<Widget> _buildRemoteViewPages() {
    var widgets = <Widget>[];
    for (int start = 0; start < widget.connections.length; start = start + 1) {
      widgets.add(_buildRemoteViewPage(start));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: _buildRemoteViewPages(),
    );
  }
}
