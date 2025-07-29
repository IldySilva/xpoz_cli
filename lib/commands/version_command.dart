import 'package:args/command_runner.dart';
import 'package:xpoz_cli/consts.dart';

class VersionCommand extends Command {
  @override
  String get description => "Show the current version of xpoz";

  @override
  String get name => "version";

  VersionCommand() {
    argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Show version',
    );
  }

  @override
  run() {
    print(version);
  }
}
