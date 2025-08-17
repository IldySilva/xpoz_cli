import 'package:args/command_runner.dart';
import '../consts.dart';
import '../core/tunnel_client.dart';

class HttpCommand extends Command {
  @override
  final description = 'Expose a local port via HTTP tunnel.';

  @override
  String get name => "http";

  HttpCommand() {
    argParser.addOption(
      'server',
      abbr: 's',
      defaultsTo: defaultServerUrl,
      help: 'Server URL to connect to',
    );
  }

  @override
  Future run() async {
    if (argResults?['help'] == true) {
      print(usage);
      return;
    }

    if (argResults!.rest.isEmpty) {
      usageException('Usage: xpoz http <port>');
    }

    final port = int.tryParse(argResults!.rest[0]);
    if (port == null) {
      usageException('Port must be a number. Example: xpoz http 3000');
    }

    final server = argResults!['server'] as String;

    final client = TunnelClient(server, port);

    await client.start();
  }
}
