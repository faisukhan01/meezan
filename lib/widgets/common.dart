import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';

// ---------------------------------------------------------------------------
// Brand emblem (original crescent + star artwork — not an official asset)
// ---------------------------------------------------------------------------

class MeezanEmblem extends StatelessWidget {
  final double size;
  final bool circle;
  const MeezanEmblem({super.key, this.size = 56, this.circle = true});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EmblemPainter(circle: circle),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  final bool circle;
  _EmblemPainter({required this.circle});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    if (circle) {
      final Rect r = Offset.zero & size;
      final Path clip = Path()..addOval(r);
      canvas.clipPath(clip);
      canvas.drawCircle(
          Offset(w / 2, h / 2), w / 2, Paint()..color = MColors.green);
      // Gold seal rings
      final Paint ring = Paint()
        ..color = MColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.045;
      canvas.drawCircle(Offset(w / 2, h / 2), w * 0.435, ring);
      final Paint ring2 = Paint()
        ..color = MColors.gold.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.018;
      canvas.drawCircle(Offset(w / 2, h / 2), w * 0.385, ring2);
    }

    final Paint gold = Paint()..color = MColors.gold;
    final Paint green = Paint()..color = MColors.green;

    // Crescent: gold circle with a green offset circle cut out.
    final Offset c1 = Offset(w * 0.455, h * 0.535);
    canvas.drawCircle(c1, w * 0.245, gold);
    final Offset c2 = Offset(w * 0.55, h * 0.49);
    canvas.drawCircle(c2, w * 0.215, green);

    // Star placed in the crescent opening.
    _drawStar(canvas, Offset(w * 0.635, h * 0.345), w * 0.07, gold);
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint p) {
    final Path path = Path();
    for (int i = 0; i < 10; i++) {
      final double angle = -math.pi / 2 + i * math.pi / 5;
      final double rad = i.isEven ? r : r * 0.42;
      final Offset pt = Offset(
        c.dx + rad * math.cos(angle),
        c.dy + rad * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Full brand lockup: emblem + wordmark + tagline.
class BrandLockup extends StatelessWidget {
  final double emblemSize;
  final bool dark;
  const BrandLockup({super.key, this.emblemSize = 84, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MeezanEmblem(size: emblemSize),
        SizedBox(height: emblemSize * 0.28),
        Text(
          'MEEZAN BANK',
          style: TextStyle(
            fontSize: emblemSize * 0.30,
            letterSpacing: emblemSize * 0.08,
            fontWeight: FontWeight.w800,
            color: dark ? Colors.white : MColors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ISLAMIC BANKING',
          style: TextStyle(
            fontSize: emblemSize * 0.13,
            letterSpacing: emblemSize * 0.08,
            fontWeight: FontWeight.w600,
            color: MColors.gold,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void showSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_outline,
              color: error ? Colors.redAccent.shade100 : MColors.gold,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
      ),
    );
}

// ---------------------------------------------------------------------------
// Balance card
// ---------------------------------------------------------------------------

class BalanceCard extends StatelessWidget {
  final Account account;
  final bool compact;
  const BalanceCard({super.key, required this.account, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MColors.green, MColors.greenDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MColors.green.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: MColors.gold.withOpacity(0.12),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -46,
            child: CircleAvatar(
              radius: 46,
              backgroundColor: Colors.white.withOpacity(0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const MeezanEmblem(size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${account.type} • ${maskAccount(account.number)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: app.toggleBalanceHidden,
                    icon: Icon(
                      app.balanceHidden
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                    tooltip: 'Toggle balance',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                app.balanceHidden ? 'PKR ••••••' : money(account.balance),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Available Balance • ${account.currency}',
                style: TextStyle(
                  color: MColors.gold.withOpacity(0.95),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Swipeable account page card (Home carousel — real-app style)
// ---------------------------------------------------------------------------

class AccountPageCard extends StatelessWidget {
  final Account account;
  final VoidCallback onViewDetails;
  const AccountPageCard({
    super.key,
    required this.account,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.fromLTRB(18, 12, 6, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MColors.green, MColors.greenDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MColors.green.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -26,
            top: -30,
            child: CircleAvatar(
              radius: 56,
              backgroundColor: MColors.gold.withOpacity(0.12),
            ),
          ),
          Positioned(
            left: 40,
            bottom: -48,
            child: CircleAvatar(
              radius: 44,
              backgroundColor: Colors.white.withOpacity(0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const MeezanEmblem(size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      account.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: app.toggleBalanceHidden,
                    icon: Icon(
                      app.balanceHidden
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 19,
                    ),
                    tooltip: 'Toggle balance',
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  '${account.type} • ${maskAccount(account.number)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11.5,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  app.balanceHidden
                      ? '${account.currency} ••••••'
                      : '${account.currency} ${money(account.balance, withSymbol: false)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  'Available Balance',
                  style: TextStyle(
                    color: MColors.gold.withOpacity(0.95),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: MColors.gold.withOpacity(0.6)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      account.currency,
                      style: const TextStyle(
                        color: MColors.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onViewDetails,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Account Details'),
                        Icon(Icons.chevron_right_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick action
// ---------------------------------------------------------------------------

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: MColors.green.withOpacity(0.09),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: MColors.green.withOpacity(0.18)),
              ),
              child: Icon(icon, color: MColors.green, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: MColors.ink,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: MColors.ink,
              ),
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: [
                  Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: MColors.green,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: MColors.green),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction tile
// ---------------------------------------------------------------------------

IconData _channelIcon(String channel) {
  switch (channel) {
    case 'IBFT':
      return Icons.swap_horiz_rounded;
    case 'Raast':
      return Icons.qr_code_2_rounded;
    case 'Bill Payment':
      return Icons.receipt_long_rounded;
    case 'Top-up':
      return Icons.phone_android_rounded;
    case 'ATM':
      return Icons.local_atm_rounded;
    case 'Payroll':
      return Icons.work_rounded;
    case 'Profit':
      return Icons.savings_rounded;
    case 'Debit Card':
      return Icons.credit_card_rounded;
    default:
      return Icons.payments_rounded;
  }
}

class TxnTile extends StatelessWidget {
  final Txn txn;
  final VoidCallback? onTap;
  const TxnTile({super.key, required this.txn, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool credit = txn.type == TxnType.credit;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 21,
        backgroundColor: credit
            ? MColors.green.withOpacity(0.10)
            : MColors.gold.withOpacity(0.16),
        child: Icon(
          _channelIcon(txn.channel),
          size: 20,
          color: credit ? MColors.green : MColors.goldDeep,
        ),
      ),
      title: Text(
        txn.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
          color: isDark ? Colors.white : MColors.ink,
        ),
      ),
      subtitle: Text(
        '${dayLabel(txn.date)} • ${txn.channel}',
        style: TextStyle(fontSize: 12, color: MColors.subtle),
      ),
      trailing: Text(
        money(txn.amount, signed: true),
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13.5,
          color: credit ? MColors.green : MColors.danger,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Account mini card (horizontal list on Home)
// ---------------------------------------------------------------------------

class AccountMiniCard extends StatelessWidget {
  final Account account;
  final VoidCallback onTap;
  const AccountMiniCard({super.key, required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? MColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const MeezanEmblem(size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    account.currency,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: MColors.goldDeep,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              account.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : MColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              maskAccount(account.number),
              style: const TextStyle(fontSize: 11, color: MColors.subtle),
            ),
            const SizedBox(height: 8),
            Text(
              app.balanceHidden
                  ? '${account.currency} ••••••'
                  : '${account.currency} ${money(account.balance, withSymbol: false)}',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: MColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Receipt page (shared success screen)
// ---------------------------------------------------------------------------

class ReceiptPage extends StatelessWidget {
  final String title;
  final String amountLine;
  final bool success;
  final List<List<String>> rows;
  const ReceiptPage({
    super.key,
    required this.title,
    required this.amountLine,
    required this.rows,
    this.success = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (success ? MColors.green : MColors.danger)
                      .withOpacity(0.12),
                ),
                child: Icon(
                  success
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: success ? MColors.green : MColors.danger,
                  size: 56,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : MColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                amountLine,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: MColors.green,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? MColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (int i = 0; i < rows.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                rows[i][0],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: MColors.subtle,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Text(
                                rows[i][1],
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : MColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i != rows.length - 1)
                        Divider(color: Theme.of(context).dividerColor),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: amountLine)),
                      child: const Text('Copy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).popUntil(
                        (Route<dynamic> r) => r.isFirst,
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info row (label / value) used in detail pages
// ---------------------------------------------------------------------------

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;
  const InfoRow({super.key, required this.label, required this.value, this.onCopy});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: MColors.subtle,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: GestureDetector(
              onTap: onCopy,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : MColors.ink,
                      ),
                    ),
                  ),
                  if (onCopy != null) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.copy_rounded, size: 15, color: MColors.subtle),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
