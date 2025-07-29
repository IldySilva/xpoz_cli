import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class HttpProxy {
  final int localPort;
  HttpProxy(this.localPort);

  Future<Map<String, dynamic>> forward(Map<String, dynamic> data) async {
    final requestId = data['requestId'];
    final method = (data['method'] as String).toUpperCase();
    final path = data['path'];
    final query = data['query'] ?? '';
    final headers = Map<String, String>.from(data['headers'] ?? {});
    final body = data['body'];

    final fullPath = query.isNotEmpty ? '$path?$query' : path;
    final uri = Uri.parse('http://localhost:$localPort/$fullPath');

    final client = HttpClient()..autoUncompress = false;
    final req = await client.openUrl(method, uri);

    headers.forEach((k, v) {
      final lk = k.toLowerCase();
      if (lk == 'host' || lk == 'connection' || lk == 'transfer-encoding')
        return;
      req.headers.set(k, v);
    });

    if (body != null) {
      Uint8List bytes;
      if (body['encoding'] == 'base64') {
        bytes = base64Decode(body['data']);
      } else {
        bytes = utf8.encode(body['data'] ?? '');
      }
      if (bytes.isNotEmpty) req.add(bytes);
    }

    final resp = await req.close().timeout(const Duration(seconds: 30));
    final bb = BytesBuilder();
    await for (final chunk in resp) {
      bb.add(chunk);
    }
    final respBytes = bb.takeBytes();

    final respHeaders = <String, String>{};
    resp.headers.forEach((name, values) {
      final ln = name.toLowerCase();
      if (ln == 'transfer-encoding') return;
      respHeaders[name] = values.join(', ');
    });

    // binário vs texto
    final ct = respHeaders['content-type'] ?? '';
    Map<String, dynamic> bodyOut;
    if (_isBinary(ct, respBytes)) {
      bodyOut = {'encoding': 'base64', 'data': base64Encode(respBytes)};
    } else {
      bodyOut = {'encoding': 'utf8', 'data': utf8.decode(respBytes)};
    }

    return {
      'type': 'http_response',
      'requestId': requestId,
      'statusCode': resp.statusCode,
      'reasonPhrase': resp.reasonPhrase,
      'headers': respHeaders,
      'body': bodyOut,
    };
  }

  bool _isBinary(String contentType, Uint8List bytes) {
    final binaryTypes = [
      'image/',
      'video/',
      'audio/',
      'application/octet-stream',
      'application/pdf',
      'application/zip',
      'font/',
    ];
    if (binaryTypes.any((t) => contentType.toLowerCase().startsWith(t))) {
      return true;
    }
    final sample = bytes.length > 1024 ? bytes.sublist(0, 1024) : bytes;
    var nulls = 0, controls = 0;
    for (final b in sample) {
      if (b == 0) nulls++;
      if (b < 32 && b != 9 && b != 10 && b != 13) controls++;
    }
    return (nulls / sample.length > 0.01) || (controls / sample.length > 0.05);
  }
}
