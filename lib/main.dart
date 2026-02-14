import 'package:bw_pm/app.dart';
import 'package:bw_pm/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
