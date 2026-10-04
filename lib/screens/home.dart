import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'accounts.dart';
import 'payments.dart';
import 'qr.dart';
import 'transfer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
    final Account account = app.selectedAccount;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Header ----------
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: MColors.green,
                borderRadius: const BorderRadius.only(
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
                              'Assalam-u-Alaikum,',
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
            // ---------- Balance card ----------
            Transform.translate(
              offset: const Offset(0, -8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BalanceCard(account: account),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: app.accounts.length,
                    itemBuilder: (BuildContext _, int i) {
                      final Account a = app.accounts[i];
                      final bool sel = a.id == app.selectedAccountId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            '${a.currency} ${maskAccount(a.number)}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: sel
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : MColors.ink),
                            ),
                          ),
                          selected: sel,
                          onSelected: (_) => app.selectAccount(a.id),
                          selectedColor: MColors.green,
                          backgroundColor:
                              isDark ? MColors.darkCard : Colors.white,
                          side: BorderSide(
                            color: sel
                                ? MColors.green
                                : Theme.of(context).dividerColor,
                          ),
                          showCheckmark: false,
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
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
                            label: 'Bill\nPayments',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const PaymentsScreen()),
                            ),
                          ),
                        ),
                        Expanded(
                          child: QuickAction(
                            icon: Icons.phone_android_rounded,
                            label: 'Mobile\nTop-up',
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
            const SizedBox(height: 22),
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
