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
      widgets.add(Container(
        child: RemoteConnection(
          renderer: connection.renderer,
          connection: connection,
        ),
      ));
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
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 50,
                    //color: Colors.amber[colorCodes[index]],
                    child: Center(child: widgets[index]),
                  );
                });
                /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: widgets,
              );*/
      }),
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
