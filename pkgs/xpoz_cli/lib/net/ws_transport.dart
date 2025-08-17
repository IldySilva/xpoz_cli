import 'dart:convert';
import 'dart:io';

class WsTransport {
  final String url;
  WebSocket? _webSocket;
  void Function()? onPong;

  WsTransport(this.url);

  Stream get stream => _webSocket!.cast();

  Future connect() async {
    _webSocket = await WebSocket.connect(
      url,
    ).timeout(const Duration(seconds: 10));

    _webSocket!.pingInterval = Duration(seconds: 20);
  }

  void send(Map<String, dynamic> json) {
    _webSocket!.add(jsonEncode(json));
  }

  Future close() async {
    await _webSocket?.close();
  }
}
