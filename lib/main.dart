import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'screens/splash.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  final AppState state = AppState();
  await state.init();
  runApp(MeezanApp(state: state));
}

class MeezanApp extends StatelessWidget {
  final AppState state;
  const MeezanApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: state,
      child: Consumer<AppState>(
        builder: (BuildContext context, AppState app, _) {
          return MaterialApp(
            title: 'Meezan Mobile (Educational UI Clone)',
            debugShowCheckedModeBanner: false,
            themeMode: app.themeMode,
            theme: buildTheme(dark: false),
            darkTheme: buildTheme(dark: true),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
