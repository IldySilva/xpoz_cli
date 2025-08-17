import '../lib/runner.dart';

void main(List<String> arguments) async {
  var runner = buildRunner();
  await runner.run(arguments);
}
