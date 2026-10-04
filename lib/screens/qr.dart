import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/common.dart';

/// Decorative Raast QR screen — generates a deterministic pseudo-QR pattern
/// purely for the demo UI (it does not encode real payment data).
class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Raast QR')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? MColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const MeezanEmblem(size: 34),
                  const SizedBox(height: 8),
                  Text(
                    'FAISAL KHAN',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: isDark ? Colors.white : MColors.ink,
                    ),
                  ),
                  const Text(
                    'Meezan Bank • Raast ID: 03•• ••• 2101',
                    style: TextStyle(fontSize: 11.5, color: MColors.subtle),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(painter: _QrPainter()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: MColors.gold.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Scan to pay me via Raast (demo)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: MColors.goldDeep,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        showSnack(context, 'QR image saved to gallery (demo).'),
                    child: const Text('Save QR'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => showSnack(context,
                        'Camera scanner is not available in this demo build.'),
                    child: const Text('Scan to Pay'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: the QR pattern above is decorative and does not carry real payment data.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: MColors.subtle),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const int cells = 25;
    final double cell = size.width / cells;
    final Paint dark = Paint()..color = const Color(0xFF17251D);
    final Paint gold = Paint()..color = MColors.goldDeep;
    final Paint white = Paint()..color = Colors.white;

    final math.Random rnd = math.Random(21012001);

    for (int y = 0; y < cells; y++) {
      for (int x = 0; x < cells; x++) {
        final bool inFinder = (x < 7 && y < 7) ||
            (x >= cells - 7 && y < 7) ||
            (x < 7 && y >= cells - 7);
        if (inFinder) continue;
        if (rnd.nextBool()) {
          final Color c = (x + y) % 7 == 0 ? MColors.goldDeep : const Color(0xFF17251D);
          canvas.drawRect(
            Rect.fromPoints(
              Offset(x * cell, y * cell),
              Offset((x + 1) * cell, (y + 1) * cell),
            ),
            (c == MColors.goldDeep) ? gold : dark,
          );
        }
      }
    }

    // Finder squares (three corners)
    _finder(canvas, 0, 0, cell, dark, gold, white);
    _finder(canvas, cells - 7, 0, cell, dark, gold, white);
    _finder(canvas, 0, cells - 7, cell, dark, gold, white);
  }

  void _finder(Canvas canvas, int cx, int cy, double cell, Paint dark,
      Paint gold, Paint white) {
    canvas.drawRect(
      Rect.fromPoints(
        Offset(cx * cell, cy * cell),
        Offset((cx + 7) * cell, (cy + 7) * cell),
      ),
      dark,
    );
    canvas.drawRect(
      Rect.fromPoints(
        Offset((cx + 1) * cell, (cy + 1) * cell),
        Offset((cx + 6) * cell, (cy + 6) * cell),
      ),
      white,
    );
    canvas.drawRect(
      Rect.fromPoints(
        Offset((cx + 2) * cell, (cy + 2) * cell),
        Offset((cx + 5) * cell, (cy + 5) * cell),
      ),
      gold,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
