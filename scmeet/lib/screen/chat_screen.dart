//import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scmeet/constants.dart';
import 'package:scmeet/webrtc/connection.dart';
import 'package:scmeet/webrtc/message_format.dart';
import 'package:scmeet/widget/custom_button.dart';
import 'package:scmeet/widget/custom_text.dart';

import '../constants.dart';

typedef SendMessageCallback = void Function(String text);

class ChatScreen extends StatefulWidget {
  final List<MessageFormat> messages;
  final SendMessageCallback onSendMessage;
  final List<Connection?> connections;
  final String userId;
  final String userName;

  const ChatScreen({Key? key, 
    required this.messages,
    required this.onSendMessage,
    required this.connections,
    required this.userId,
    required this.userName,
  }) : super(key: key);

    @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  TextEditingController? textEditingController;
  
  @override
  initState() {
    super.initState();
    textEditingController = TextEditingController();
  }
  List<Widget> _buildMessages() {
    // ignore: prefer_collection_literals
    final nameMap = Map<String, String>();
    // ignore: avoid_function_literals_in_foreach_calls
    widget.connections.forEach((connection) {
      nameMap[connection!.userId] = connection.name;
    });
    return widget.messages
        .map((message) => ListTile(
              title: Text(
                message.userId,
                style: TextStyle(fontWeight: FontWeight.bold, color: fifthcolor), // chatte email kismi
                
              ),
              subtitle: Text(
                message.text,
                style: const TextStyle(fontSize: 24), //gonderilmis msj kismi
              ),
              isThreeLine: true,
            ))
        .toList();
  }

  void onSendClick() {
    var text = textEditingController!.text;
    widget.onSendMessage(text);
    setState(() {
      textEditingController!.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Expanded (
    child: Column(
          children: <Widget>[
            Center(
              child: CustomText(
                text: "Chat",
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: fifthcolor,
              ), 
            ),
            Expanded(
              child: ListView(
                children: ListTile.divideTiles(
                  context: context,
                  tiles: _buildMessages(),
                ).toList(),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: textEditingController,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 141, 40, 34),
                        fontSize: 20,
                      ),
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  CustomButton(
                    text: 'Send',
                    onTap: onSendClick,
                    width: MediaQuery.of(context).size.width / 5,
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

