import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'accounts.dart';
import 'payments.dart';
import 'qr.dart';
import 'transfer.dart';

String _initials(String name) {
  final List<String> parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return 'U';
  final String first = parts.first[0];
  final String second =
      parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
  return (first + second).toUpperCase();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController? _controller;
  int _page = 0;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _openNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        final List<Map<String, String>> items = [
          {
            'title': 'Salary credited',
            'body': 'PKR 185,000.00 credited to your Current Account.',
            'time': 'Today, 09:12 AM',
          },
          {
            'title': 'K-Electric bill generated',
            'body': 'Your bill of PKR 8,452.30 is due on the 15th.',
            'time': 'Yesterday, 06:40 PM',
          },
          {
            'title': 'Profit posted',
            'body': 'Riba-free profit PKR 712.45 added to Rozana Amdani.',
            'time': '2 days ago',
          },
        ];
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: items.length,
            itemBuilder: (BuildContext _, int i) => ListTile(
              leading: CircleAvatar(
                backgroundColor: MColors.green.withOpacity(0.1),
                child: const Icon(Icons.notifications_rounded,
                    color: MColors.green, size: 20),
              ),
              title: Text(
                items[i]['title']!,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: Text(
                '${items[i]['body']}\n${items[i]['time']}',
                style: const TextStyle(fontSize: 12.5),
              ),
              isThreeLine: true,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = context.watch<AppState>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Initialize the carousel controller once, starting on the selected account.
    if (_controller == null) {
      final int idx = app.accounts
          .indexWhere((Account a) => a.id == app.selectedAccountId);
      _page = idx < 0 ? 0 : idx;
      _controller = PageController(viewportFraction: 0.93, initialPage: _page);
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Header ----------
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: MColors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 12, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assalam-o-Alaikum,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              app.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const MeezanEmblem(size: 34),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: MColors.gold,
                        child: Text(
                          _initials(app.userName),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: MColors.greenDeep,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () => _openNotifications(context),
                            icon: const Icon(Icons.notifications_none_rounded,
                                color: Colors.white),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: MColors.gold,
                                shape: BoxShape.circle,
                                border: Border.all(color: MColors.green),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ---------- Swipeable account carousel ----------
            Transform.translate(
              offset: const Offset(0, -12),
              child: SizedBox(
                height: 212,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: app.accounts.length,
                  onPageChanged: (int i) {
                    setState(() => _page = i);
                    app.selectAccount(app.accounts[i].id);
                  },
                  itemBuilder: (BuildContext _, int i) => AccountPageCard(
                    account: app.accounts[i],
                    onViewDetails: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            AccountDetailPage(account: app.accounts[i]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // ---------- Page indicator dots ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < app.accounts.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? MColors.green
                          : MColors.subtle.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // ---------- Quick actions ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                decoration: BoxDecoration(
                  color: isDark ? MColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: QuickAction(
                            icon: Icons.swap_horiz_rounded,
                            label: 'Funds\nTransfer',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const TransferScreen()),
                            ),
                          ),
                        ),
                        Expanded(
                          child: QuickAction(
                            icon: Icons.receipt_long_rounded,
                            label: 'Utility\nBills',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const PaymentsScreen()),
                            ),
                          ),
                        ),
                        Expanded(
                          child: QuickAction(
                            icon: Icons.phone_android_rounded,
                            label: 'Mobile\nTop Up',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const PaymentsScreen(
                                        initialSection: 'topup',
                                      )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: QuickAction(
                            icon: Icons.qr_code_2_rounded,
                            label: 'Raast\nQR',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const QrScreen()),
                            ),
                          ),
                        ),
                        Expanded(
                          child: QuickAction(
                            icon: Icons.menu_book_rounded,
                            label: 'Cheque\nBook',
                            onTap: () => showSnack(
                                context,
                                'Cheque book request placed (demo) — delivery in 5 working days.'),
                          ),
                        ),
                        Expanded(
                          child: QuickAction(
                            icon: Icons.description_rounded,
                            label: 'Tax\nCertificate',
                            onTap: () => showSnack(context,
                                'Tax certificate for 2024 emailed to your address (demo).'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ---------- Promo banner (real-app marketing slot) ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: GestureDetector(
                onTap: () => showSnack(context,
                    'Roshan Digital Account — banking for overseas Pakistanis (demo).'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [MColors.goldDeep, MColors.gold],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: MColors.gold.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.flight_takeoff_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Roshan Digital Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'For overseas Pakistanis — open in minutes.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ---------- My accounts ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(
                title: 'My Accounts',
                actionLabel: 'View All',
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const AccountsScreen()),
                ),
              ),
            ),
            SizedBox(
              height: 118,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: app.accounts.length,
                itemBuilder: (BuildContext _, int i) => AccountMiniCard(
                  account: app.accounts[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => AccountDetailPage(account: app.accounts[i])),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            // ---------- Recent transactions ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(
                title: 'Recent Transactions',
                actionLabel: 'View All',
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const AccountsScreen()),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              decoration: BoxDecoration(
                color: isDark ? MColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: app.recentTxns.take(6).length,
                itemBuilder: (BuildContext _, int i) =>
                    TxnTile(txn: app.recentTxns[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
