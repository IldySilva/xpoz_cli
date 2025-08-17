import 'dart:io';
import 'package:args/args.dart';
import 'package:xpoz/server.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'port',
      abbr: 'p',
      defaultsTo: '8080',
      help: 'Port to run the server on',
    )
    ..addOption(
      'domain',
      abbr: 'd',
      defaultsTo: 'xpoz.xyz',
      help: 'Domain name for the server',
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help');

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _showHelp(parser);
      return;
    }

    final port = int.tryParse(results['port'] as String);
    final domain = results['domain'] as String;

    if (port == null) {
      print('Error: Invalid port number');
      exit(1);
    }

    final server = XpozServer(port: port, domain: domain);
    await server.start();

    ProcessSignal.sigint.watch().listen((_) async {
      print('\nShutting down server...');
      await server.stop();
      exit(0);
    });

    while (true) {
      await Future.delayed(Duration(seconds: 1));
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

void _showHelp(ArgParser parser) {
  print('xpoz server - Tunneling server');
  print('');
  print('Usage: dart bin/server.dart [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  dart bin/server.dart                    # Run on localhost:8080');
  print('  dart bin/server.dart -p 9000           # Run on port 9000');
  print('  dart bin/server.dart -d example.com    # Use example.com as domain');
}
