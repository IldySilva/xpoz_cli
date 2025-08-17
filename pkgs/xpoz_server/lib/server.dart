import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:xpoz/health_check.dart';
import 'package:xpoz/notfound.dart';

class XpozServer {
  final int port;
  final String domain;
  final Map<String, TunnelConnection> _tunnels = {};
  final Map<String, PendingRequest> _pendingRequests = {};
  HttpServer? _httpServer;

  XpozServer({this.port = 8080, this.domain = 'localhost'});

  Future<void> start() async {
    await _startUnifiedServer();

    print('🚀 xpoz server started');
    print('HTTP/WebSocket server: http://app.$domain:${port + 1}/');
    print('WebSocket endpoint: ws://ws.$domain:${port + 1}/');
    print('Domain configured for: $domain');
    print('Ready to accept tunnel connections...');
  }

  Future<void> _startUnifiedServer() async {
    final handler = _createUnifiedHandler();
    _httpServer = await serve(handler, InternetAddress.anyIPv4, port + 1);
  }

  Handler _createUnifiedHandler() {
    return (Request request) async {
      final host = request.headers['host'];
      final subdomain = _extractSubdomain(host);
      final path = request.url.path;
      final originalHost = request.headers['x-forwarded-host'] ?? host;

      print('=== REQUEST DEBUG ===');
      print('Host header: $host');
      print('X-Forwarded-Host: ${request.headers['x-forwarded-host']}');
      print('Original host: $originalHost');
      print('Path: $path');
      print('Extracted subdomain: $subdomain');
      print('Upgrade header: ${request.headers['upgrade']}');
      print('All headers: ${request.headers}');
      print('=====================');

      // WebSocket endpoint - funciona com qualquer subdomínio
      if (subdomain == '_ws' || subdomain == 'ws' || path == "ws") {
        if (request.headers['upgrade']?.toLowerCase() == 'websocket') {
          print('🔌 WebSocket connection request from: $host');
          final handler = webSocketHandler((WebSocketChannel webSocket, _) {
            _handleTunnelConnection(webSocket);
          });
          return handler(request);
        }
        return Response.badRequest(
          body: 'WebSocket upgrade required. Use wss://ws.$host/',
          headers: {'content-type': 'text/plain'},
        );
      }

      // Rota de status do servidor
      if (path == '_status') {
        return Response.ok(
          jsonEncode({
            'status': 'running',
            'domain': domain,
            'activeTunnels': _tunnels.length,
            'currentHost': host,
            'extractedSubdomain': subdomain,
            'websocketEndpoint': 'wss://$host/_ws',
            'tunnels': _tunnels.keys.toList(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      if (path == '_tunnels') {
        final jsonList = _tunnels.entries.map((entry) {
          return {
            'id': entry.key,
            'localPort': entry.value.localPort,
            'connectedSince': entry.value.createdAt.toIso8601String(),
            'publicUrl': 'https://${entry.key}.$domain',
            'websocketUrl': 'wss://${entry.key}.$domain/_ws',
          };
        }).toList();

        return Response.ok(
          jsonEncode({'activeTunnels': jsonList}),
          headers: {'content-type': 'application/json'},
        );
      }

      if (subdomain == 'hc') {
        return healthCheck(domain: domain, host: host, subdomain: subdomain);
      }
      if (subdomain == null || !_tunnels.containsKey(subdomain)) {
        return tunnelNotFound();
      }

      return await _forwardRequest(subdomain, request);
    };
  }

  String? _extractSubdomain(String? host) {
    if (host == null) return null;

    final hostWithoutPort = host.split(':')[0];
    final parts = hostWithoutPort.split('.');

    print('DEBUG _extractSubdomain:');
    print('  Original host: $host');
    print('  Host without port: $hostWithoutPort');
    print('  Parts: $parts');
    print('  Domain: $domain');

    // Para desenvolvimento local: tunnelId.localhost
    if (parts.length >= 2 && parts.sublist(1).join('.') == domain) {
      final subdomain = parts[0];
      print('  Extracted subdomain (local): $subdomain');
      return subdomain;
    }

    // Para domínios reais: tunnelId.domain.com
    final domainParts = domain.split('.');
    print('  Domain parts: $domainParts');

    if (parts.length > domainParts.length) {
      final expectedDomain = parts.sublist(1).join('.');
      print('  Expected domain: $expectedDomain');

      if (expectedDomain == domain) {
        final subdomain = parts[0];
        print('  Extracted subdomain (real): $subdomain');
        return subdomain;
      }
    }

    print('  No subdomain extracted');
    return null;
  }

  void _handleTunnelConnection(WebSocketChannel webSocket) {
    print('🔌 New tunnel connection established');

    webSocket.stream.listen(
      (message) => _handleTunnelMessage(webSocket, message),
      onError: (error) => print('❌ Tunnel connection error: $error'),
      onDone: () => _handleTunnelDisconnect(webSocket),
    );
  }

  void _handleTunnelMessage(WebSocketChannel webSocket, dynamic message) {
    try {
      final data = jsonDecode(message);

      switch (data['type']) {
        case 'handshake':
          _handleHandshake(webSocket, data);
          break;

        case 'http_response':
          _handleHttpResponse(data);
          break;

        case 'ping':
          webSocket.sink.add(jsonEncode({
            'type': 'pong',
            'timestamp': DateTime.now().toIso8601String(),
            'originalTimestamp': data['timestamp'],
          }));
          break;

        default:
          print('🤔 Unknown message type: ${data['type']}');
      }
    } catch (e) {
      print('❌ Error handling tunnel message: $e');
      webSocket.sink.add(
        jsonEncode({'type': 'error', 'message': 'Invalid message format'}),
      );
    }
  }

  void _handleHandshake(WebSocketChannel webSocket, Map<String, dynamic> data) {
    final tunnelId = data['tunnelId'];
    final localPort = data['localPort'];

    if (tunnelId == null) {
      webSocket.sink.add(
        jsonEncode({'type': 'error', 'message': 'Missing tunnelId'}),
      );
      return;
    }

    // Create tunnel connection
    final tunnel = TunnelConnection(
      id: tunnelId,
      webSocket: webSocket,
      localPort: localPort,
    );

    _tunnels[tunnelId] = tunnel;

    // Generate public URLs
    final publicUrl = 'https://$tunnelId.$domain';
    final wsUrl = 'wss://$tunnelId.$domain/_ws';

    print('✅ Tunnel registered: $tunnelId -> localhost:$localPort');
    print('   Public URL: $publicUrl');
    print('   WebSocket URL: $wsUrl');

    // Send confirmation
    webSocket.sink.add(
      jsonEncode({
        'type': 'tunnel_ready',
        'publicUrl': publicUrl,
        'websocketUrl': wsUrl,
        'tunnelId': tunnelId,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  void _handleHttpResponse(Map<String, dynamic> data) {
    final requestId = data['requestId'];
    final pendingRequest = _pendingRequests.remove(requestId);

    if (pendingRequest == null) {
      print('Warning: Received response for unknown request: $requestId');
      return;
    }

    try {
      // Extract response data
      final statusCode = data['statusCode'] ?? 200;
      final reasonPhrase = data['reasonPhrase'];
      final headers = Map<String, String>.from(data['headers'] ?? {});
      final bodyData = data['body'];

      // Process response body
      dynamic responseBody;
      if (bodyData != null) {
        if (bodyData['encoding'] == 'base64') {
          // Binary data
          responseBody = base64Decode(bodyData['data']);
        } else {
          // Text data
          responseBody = bodyData['data'] ?? '';
        }
      } else {
        responseBody = '';
      }

      // Ensure proper content-length header
      if (responseBody is Uint8List) {
        headers['content-length'] = responseBody.length.toString();
      } else if (responseBody is String) {
        final bytes = utf8.encode(responseBody);
        headers['content-length'] = bytes.length.toString();
        responseBody = bytes;
      }

      // Remove conflicting headers
      headers.remove('transfer-encoding');

      // Create response
      final response = Response(
        statusCode,
        body: responseBody,
        headers: headers,
      );

      // Complete the pending request
      pendingRequest.completer.complete(response);
    } catch (e) {
      print('Error processing HTTP response: $e');
      pendingRequest.completer.complete(
        Response.internalServerError(
          body: 'Error processing response from tunnel client',
        ),
      );
    }
  }

  Future<Response> _forwardRequest(String tunnelId, Request request) async {
    print("🔄 FORWARDING: ${request.url.host}${request.url.path}");

    final tunnel = _tunnels[tunnelId];
    if (tunnel == null) {
      return Response.notFound('Tunnel not found');
    }

    try {
      // Generate request ID
      final requestId = _generateRequestId();

      // Read request body with proper binary handling
      final bodyBytes = await request.read().fold<Uint8List>(
            Uint8List(0),
            (previous, element) =>
                Uint8List.fromList([...previous, ...element]),
          );

      // Prepare body data
      Map<String, dynamic>? bodyData;
      if (bodyBytes.isNotEmpty) {
        final contentType = request.headers['content-type'] ?? '';

        if (_isBinaryContent(contentType, bodyBytes)) {
          bodyData = {'encoding': 'base64', 'data': base64Encode(bodyBytes)};
        } else {
          bodyData = {'encoding': 'utf8', 'data': utf8.decode(bodyBytes)};
        }
      }

      // Create pending request
      final pendingRequest = PendingRequest();
      _pendingRequests[requestId] = pendingRequest;

      // Prepare headers (remove proxy-specific headers)
      final forwardHeaders = Map<String, String>.from(request.headers);
      forwardHeaders.remove('host');
      forwardHeaders['host'] = 'localhost:${tunnel.localPort}';

      // Forward request to client
      final requestData = {
        'type': 'http_request',
        'requestId': requestId,
        'method': request.method,
        'path': request.url.path,
        'query': request.url.query,
        'headers': forwardHeaders,
        'body': bodyData,
      };

      tunnel.webSocket.sink.add(jsonEncode(requestData));

      // Wait for response with timeout
      return await pendingRequest.completer.future.timeout(
        Duration(seconds: 60), // Increased timeout for large files
        onTimeout: () {
          _pendingRequests.remove(requestId);
          return Response(
            504,
            body: '<h1>504 Gateway Timeout</h1>'
                '<p>The tunnel client took too long to respond.</p>',
            headers: {'content-type': 'text/html'},
          );
        },
      );
    } catch (e) {
      print('Error forwarding request: $e');
      return Response(
        502,
        body: '<h1>502 Bad Gateway</h1>'
            '<p>Error communicating with tunnel client: $e</p>',
        headers: {'content-type': 'text/html'},
      );
    }
  }

  bool _isBinaryContent(String contentType, Uint8List bytes) {
    final binaryTypes = [
      'image/',
      'video/',
      'audio/',
      'application/octet-stream',
      'application/pdf',
      'application/zip',
      'application/x-',
      'font/',
    ];

    if (binaryTypes.any((type) => contentType.toLowerCase().startsWith(type))) {
      return true;
    }

    // For multipart/form-data, check if it contains binary data
    if (contentType.toLowerCase().startsWith('multipart/')) {
      return true; // Safer to treat as binary
    }

    // Quick binary detection for small samples
    if (bytes.isEmpty) return false;

    final sampleSize = math.min(512, bytes.length);
    final sample = bytes.take(sampleSize);

    int nullBytes = 0;
    int controlBytes = 0;

    for (int byte in sample) {
      if (byte == 0) nullBytes++;
      if (byte < 32 && byte != 9 && byte != 10 && byte != 13) controlBytes++;
    }

    // If more than 1% null bytes or 3% control chars, consider binary
    return (nullBytes / sampleSize > 0.01) ||
        (controlBytes / sampleSize > 0.03);
  }

  void _handleTunnelDisconnect(WebSocketChannel webSocket) {
    // Find and remove the tunnel
    final tunnelEntry = _tunnels.entries
        .where((entry) => entry.value.webSocket == webSocket)
        .firstOrNull;

    if (tunnelEntry != null) {
      print('❌ Tunnel disconnected: ${tunnelEntry.key}');
      _tunnels.remove(tunnelEntry.key);

      // Cancel any pending requests for this tunnel
      _pendingRequests.removeWhere((requestId, pendingRequest) {
        if (!pendingRequest.completer.isCompleted) {
          pendingRequest.completer.complete(
            Response.internalServerError(body: 'Tunnel disconnected'),
          );
        }
        return true; // Remove all for now - in production, track by tunnel
      });
    }
  }

  String _generateRequestId() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        16,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Future<void> stop() async {
    await _httpServer?.close();

    // Close all tunnel connections
    for (final tunnel in _tunnels.values) {
      tunnel.webSocket.sink.close();
    }

    _tunnels.clear();
    _pendingRequests.clear();

    print('Server stopped');
  }
}

class TunnelConnection {
  final String id;
  final WebSocketChannel webSocket;
  final int localPort;
  final DateTime createdAt;

  TunnelConnection({
    required this.id,
    required this.webSocket,
    required this.localPort,
  }) : createdAt = DateTime.now();
}

class PendingRequest {
  final Completer<Response> completer = Completer<Response>();
  final DateTime createdAt = DateTime.now();
}

// Extension to add firstOrNull method
extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
