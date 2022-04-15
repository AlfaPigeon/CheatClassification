import 'dart:async';
import 'dart:convert';
//import 'dart:io';

import 'package:eventify/eventify.dart';
//import 'package:universal_io/io.dart';
//import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Transport extends EventEmitter {
  WebSocketChannel? channel;
  String url;
  bool canReconnect = false;
  int retryCount = 0;
  int maxRetryCount = 1;
  Timer? timer;
  bool closed = false;

  Transport(
      {required this.url,
      required this.canReconnect,
      required this.maxRetryCount});

  void connect() async {
    try {
      if (retryCount <= maxRetryCount) {
        retryCount++;
        channel = WebSocketChannel.connect(
          Uri.parse(url),
        );
        listenEvents();
      } else {
        emit('failed');
      }
    } catch (error) {
      connect();
    }
  }

  void listenEvents() {
    if (channel != null) {
      channel?.stream.listen(handleMessage,
          onDone: handleClose, onError: handleError, cancelOnError: true);
      handleOpen();
    }
  }

  void remoteEvents() {}

  void handleOpen() {
    sendHeartbeat();
    emit('open');
  }

  void handleMessage(dynamic message) {
    emit('message', null, message);
  }

  void handleClose() {
    reset();
    if (!closed) {
      connect();
    }
  }

  void handleError(Object error) {
    reset();
    if (!closed) {
      connect();
    }
  }

  void send(String message) {
    if (channel != null) {
      channel?.sink.add(message);
    }
  }

  void sendHeartbeat() {
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      send(json.encode({'type': 'heartbeat'}));
    });
  }

  void reset() {
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
    if (channel != null) {
      channel?.sink.close();
      channel = null;
    }
  }

  void close() {
    closed = true;
    destroy();
  }

  void destroy() {
    reset();
    url = '';
  }

  void reconnect() {
    retryCount = 0;
    connect();
  }
}
