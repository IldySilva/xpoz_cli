import 'package:args/command_runner.dart';
import 'commands/http_command.dart';
import 'commands/version_command.dart';

CommandRunner buildRunner() {
  final runner =
      CommandRunner("xpoz", "Expose local services securely with Xpoz.")
        ..addCommand(HttpCommand())
        ..addCommand(VersionCommand());
  return runner;
}
