import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scmeet/webrtc/connection.dart';
import 'package:scmeet/widget/remote_connection.dart';

class RemoteVideoPageView extends StatefulWidget {
  final List<Connection> connections;

  const RemoteVideoPageView({Key? key, required this.connections})
      : super(key: key);

  @override
  State createState() => _RemoteVideoPageViewState();
}

class _RemoteVideoPageViewState extends State<RemoteVideoPageView> {
  Widget _buildRemoteViewPage(int start) {
    var widgets = <Widget>[];
    var end = start + 1;
    var length = widget.connections.length;
    print("length => $length");
    print("end => $end");
    widget.connections
        //.sublist(start, end <= length ? end : length)
        .forEach((connection) {
      print("connections name => ${connection.name}");
      print("connections name => ${connection.renderer}");
      widgets.add(
        Container(
          //width: 600,
          //height: 500,
          child: RemoteConnection(
            renderer: connection.renderer,
            connection: connection,
            length: length,
          ),
        ),
      );
    });

    return Center(
      child: OrientationBuilder(builder: (context, orientation) {
        return orientation == Orientation.portrait
            ? ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 50,
                    //color: Colors.amber[colorCodes[index]],
                    child: Center(child: widgets[index]),
                  );
                })
            /* Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: widgets,
              )*/
            : buildBody(widgets);
        /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: widgets,
              );*/
      }),
    );
  }

  Widget buildBody(var widgets) {
    print("ceil => ${sqrt(widgets.length).ceil()}");
    print(
        "columns => ${(widgets.length / sqrt(widgets.length).ceil()).ceil()}");
    print(widgets.length);
    List<Widget> rows = [];
    List<Widget> cols = [];
    var widgetCount = 0;
    for (int i = 0;
        i < (widgets.length / sqrt(widgets.length).ceil()).ceil();
        i++) {
      for (int j = 0; j < sqrt(widgets.length).ceil(); j++) {
        if (widgetCount < widgets.length) {
          cols.add(widgets[widgetCount]);
          print(widgetCount);
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
