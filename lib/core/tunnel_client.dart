import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:xpoz_cli/core/heart_beat.dart';
import 'package:xpoz_cli/core/http_proxy.dart';
import 'package:xpoz_cli/net/ws_transport.dart';
import 'package:xpoz_cli/protocol/messages.dart';

class TunnelClient {
  final String serverUrl;
  final int localPort;
  bool _isConnected = false;

  late final WsTransport _ws;
  late final HeartBeat _hb;
  late final HttpProxy _httpProxy;

  TunnelClient(this.serverUrl, this.localPort);

  Future<void> start() async {
    try {
      print('Connecting to server: $serverUrl');
      _ws = WsTransport(serverUrl);
      _httpProxy = HttpProxy(localPort);
      await _ws.connect();

      final tunnelId = _generateTunnelID();

      _ws.send(Handshake(tunnelId: tunnelId, localPort: localPort).toJson());

      _hb = HeartBeat(onTimeout: () => _ws.close());
      _hb.start(() => _ws.send({'type': 'ping'}));
      _ws.onPong = _hb.onPong;

      await for (final msg in _ws.stream) {
        final data = jsonDecode(msg as String);
        switch (data['type']) {
          case 'tunnel_ready':
            print('✓ Tunnel established');
            print('Public URL: ${data['publicUrl']}');
            print('Forwarding: ${data['publicUrl']} -> localhost:$localPort');
            break;
          case 'http_request':
            _handleHttpRequest(data);
            break;
          case 'pong':
            _hb.onPong();
            break;
          case 'error':
            print('Server error: ${data['message']}');
            break;
        }
      }

      print('Tunnel is active! Press Ctrl+C to stop.');

      ProcessSignal.sigint.watch().listen((_) {
        print('\nShutting down tunnel...');
        _cleanup();
        exit(0);
      });

      while (_isConnected) {
        await Future.delayed(Duration(seconds: 1));
      }
    } catch (e) {
      print('Failed to connect: $e');
      exit(1);
    }
  }

  Future<void> _handleHttpRequest(Map<String, dynamic> data) async {
    try {
      final resp = await _httpProxy.forward(data);
      _ws.send(resp);
    } on Exception catch (e) {
      _ws.send(HttpResponseMessage.error(data['requestId'], e.toString()));
    }
  }

  String _generateTunnelID() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random();
    return List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
  }

  void _cleanup() {
    _isConnected = false;
    _ws.close();
  }
}
