import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';
import 'login.dart';
import 'shell.dart';

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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => app.loggedIn ? const Shell() : const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [MeezanSplashTop, MeezanSplashBottom],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandLockup(dark: true),
            const SizedBox(height: 56),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: MeezanSplashGold,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 18),
        child: const Text(
          'Unofficial educational UI clone • demo data only',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 11.5),
        ),
      ),
    );
  }
}

const Color MeezanSplashTop = Color(0xFF0B6E3F);
const Color MeezanSplashBottom = Color(0xFF053D23);
const Color MeezanSplashGold = Color(0xFFC6A45C);
