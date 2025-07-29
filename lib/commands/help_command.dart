import 'package:args/command_runner.dart';

class HelperCommand extends Command {
  @override
  String get description => "expose a local port via http tunel.";

  @override
  String get name => "help";

  @override
  Future run() async {
    print('xpoz - Secure tunneling to localhost');
    print('');
    print('Usage: xpoz [options] <protocol> <port>');
    print('');
    print('Examples:');
    print('  xpoz http 3000     # Expose localhost:3000 via HTTP tunnel');
    print('');
    print('Options:');
    print(argParser.usage);
  }
}
