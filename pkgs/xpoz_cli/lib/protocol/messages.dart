class Handshake {
  final String tunnelId;
  final int localPort;
  Handshake({required this.tunnelId, required this.localPort});
  Map<String, dynamic> toJson() => {
    'type': 'handshake',
    'tunnelId': tunnelId,
    'localPort': localPort,
  };
}

class HttpResponseMessage {
  static Map<String, dynamic> tooManyRequests(String requestId) => {
    'type': 'http_response',
    'requestId': requestId,
    'statusCode': 429,
    'headers': {'content-type': 'text/plain'},
    'body': {'encoding': 'utf8', 'data': 'Too Many Requests'},
  };

  static Map<String, dynamic> error(String requestId, String msg) => {
    'type': 'http_response',
    'requestId': requestId,
    'statusCode': 502,
    'headers': {'content-type': 'text/plain'},
    'body': {'encoding': 'utf8', 'data': 'Bad Gateway: $msg'},
  };
}
