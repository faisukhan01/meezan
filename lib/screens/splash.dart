import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'login.dart';
import 'mpin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      final AppState app = context.read<AppState>();
      final Widget next;
      if (!app.loggedIn) {
        next = const LoginScreen();
      } else if (app.mpin == null) {
        next = const CreateMpinScreen();
      } else {
        next = const MpinEntryScreen();
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => next),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            BrandLockup(emblemSize: 100),
            SizedBox(height: 56),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: MColors.gold,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: MColors.green,
        padding: EdgeInsets.only(
          top: 14,
          bottom: MediaQuery.of(context).padding.bottom + 14,
        ),
        child: const Text(
          'Educational UI replica • Unaffiliated with Meezan Bank Ltd.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 11.5),
        ),
      ),
    );
  }
}
