//import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scmeet/constants.dart';
import 'package:scmeet/webrtc/connection.dart';
import 'package:scmeet/webrtc/message_format.dart';
import 'package:scmeet/widget/custom_button.dart';
import 'package:scmeet/widget/custom_text.dart';

typedef SendMessageCallback = void Function(String text);

class ChatScreen extends StatelessWidget {
  final List<MessageFormat> messages;
  final SendMessageCallback onSendMessage;
  final TextEditingController textEditingController = TextEditingController();
  final List<Connection?> connections;
  final String userId;
  final String userName;
  final _scrollcontroller = ScrollController();

  ChatScreen({Key? key, 
    required this.messages,
    required this.onSendMessage,
    required this.connections,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  List<Widget> _buildMessages() {
    // ignore: prefer_collection_literals
    final nameMap = Map<String, String>();
    // ignore: avoid_function_literals_in_foreach_calls
    connections.forEach((connection) {
      nameMap[connection!.userId] = connection.name;
    });
    return messages
        .map((message) => ListTile(
              title: Text(
                message.userId
                /*nameMap.containsKey(message.userId)
                    ? nameMap[message.userId]
                    : (message.userId == userId ? userName : '')*/,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                message.text,
                style: const TextStyle(fontSize: 24),
              ),
              isThreeLine: true,
            ))
        .toList();
  }

  void onSendClick() {
    var text = textEditingController.text;
    onSendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
   /* Timer(
      const Duration(seconds: 1),
      () =>
          _scrollcontroller.jumpTo(_scrollcontroller.position.maxScrollExtent),
    ); */
    return SizedBox(
      width: 100.0,
      child: Column(
        children: <Widget>[
          Center(
            child: CustomText(
              text: "Chat",
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: thirdColor,
            ), 
          ),
          Expanded(
            child: ListView(
              controller: _scrollcontroller,
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
                  width: MediaQuery.of(context).size.width / 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
