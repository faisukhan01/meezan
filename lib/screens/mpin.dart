import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'login.dart';
import 'shell.dart';

// ---------------------------------------------------------------------------
// PIN dots + keypad (shared)
// ---------------------------------------------------------------------------

class _PinDots extends StatelessWidget {
  final int filled;
  final bool error;
  const _PinDots({required this.filled, this.error = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(4, (int i) {
        final bool on = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 15,
          height: 15,
          margin: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on
                ? (error ? MColors.danger : MColors.green)
                : Colors.transparent,
            border: Border.all(
              color: error ? MColors.danger : MColors.green,
              width: 1.8,
            ),
          ),
        );
      }),
    );
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  final Widget? aux; // left-bottom slot (biometric)
  final bool onDark;
  const _Keypad({
    required this.onKey,
    required this.onBackspace,
    this.aux,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color digitColor = onDark ? Colors.white : MColors.ink;
    final Color iconColor = onDark ? Colors.white70 : MColors.ink;

    Widget box(Widget child, {VoidCallback? onTap}) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            child: child,
          ),
        );

    Widget num(String n) => box(
          Text(
            n,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: digitColor,
            ),
          ),
          onTap: () => onKey(n),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final List<String> row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ]) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              num(row[0]),
              const SizedBox(width: 20),
              num(row[1]),
              const SizedBox(width: 20),
              num(row[2]),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: aux,
            ),
            const SizedBox(width: 20),
            num('0'),
            const SizedBox(width: 20),
            box(
              Icon(Icons.backspace_outlined, size: 24, color: iconColor),
              onTap: onBackspace,
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Create MPIN (first login)
// ---------------------------------------------------------------------------

class CreateMpinScreen extends StatefulWidget {
  const CreateMpinScreen({super.key});

  @override
  State<CreateMpinScreen> createState() => _CreateMpinScreenState();
}

class _CreateMpinScreenState extends State<CreateMpinScreen> {
  String _pin = '';
  String? _firstPin;
  bool _error = false;
  bool _saving = false;

  void _onKey(String k) {
    if (_pin.length >= 4 || _saving) return;
    setState(() {
      _pin += k;
      _error = false;
    });
    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 180), _handleComplete);
    }
  }

  void _onBackspace() {
    if (_saving) return;
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _handleComplete() {
    if (!mounted) return;
    final AppState app = context.read<AppState>();
    if (_firstPin == null) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
      });
      return;
    }
    if (_pin == _firstPin) {
      setState(() => _saving = true);
      app.setMpin(_pin);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const Shell()),
        (Route<dynamic> r) => false,
      );
    } else {
      setState(() {
        _error = true;
        _pin = '';
        _firstPin = null;
      });
      showSnack(context, 'MPIN did not match. Please try again.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool confirmStep = _firstPin != null;
    return Scaffold(
      appBar: AppBar(title: Text(confirmStep ? 'Confirm MPIN' : 'Create MPIN')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 26),
            const MeezanEmblem(size: 56),
            const SizedBox(height: 18),
            Text(
              confirmStep
                  ? 'Re-enter your 4-digit MPIN to confirm'
                  : 'Create a 4-digit MPIN for quick login',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: MColors.ink,
              ),
            ),
            const SizedBox(height: 28),
            _PinDots(filled: _pin.length, error: _error),
            const Spacer(),
            _Keypad(onKey: _onKey, onBackspace: _onBackspace),
            const SizedBox(height: 16),
            const Text(
              'Demo app — your MPIN is stored on this device only.',
              style: TextStyle(fontSize: 11.5, color: MColors.subtle),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MPIN entry (quick login on subsequent launches)
// ---------------------------------------------------------------------------

class MpinEntryScreen extends StatefulWidget {
  const MpinEntryScreen({super.key});

  @override
  State<MpinEntryScreen> createState() => _MpinEntryScreenState();
}

class _MpinEntryScreenState extends State<MpinEntryScreen> {
  String _pin = '';
  bool _error = false;

  void _onKey(String k) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += k;
      _error = false;
    });
    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 180), _verify);
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _verify() {
    if (!mounted) return;
    final AppState app = context.read<AppState>();
    if (app.mpin != null && app.mpin == _pin) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const Shell()),
        (Route<dynamic> r) => false,
      );
    } else {
      setState(() {
        _error = true;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [MColors.green, MColors.greenDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 44),
              const BrandLockup(dark: true, emblemSize: 62),
              const SizedBox(height: 30),
              const Text(
                'Enter your MPIN',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                app.userName,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 26),
              _PinDots(filled: _pin.length, error: _error),
              const SizedBox(height: 10),
              SizedBox(
                height: 18,
                child: _error
                    ? const Text(
                        'Incorrect MPIN. Please try again.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFB4A9),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const Spacer(),
              _Keypad(
                onKey: _onKey,
                onBackspace: _onBackspace,
                onDark: true,
                aux: app.biometricsEnabled
                    ? InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute<void>(
                                builder: (_) => const Shell()),
                            (Route<dynamic> r) => false,
                          );
                        },
                        child: const SizedBox(
                          width: 64,
                          height: 64,
                          child: Icon(
                            Icons.fingerprint_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  final AppState app2 = context.read<AppState>();
                  app2.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                    (Route<dynamic> r) => false,
                  );
                },
                child: Text(
                  'Use password instead',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
