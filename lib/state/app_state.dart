import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_data.dart';
import '../data/models.dart';

/// Central app state (auth, accounts, transactions, settings).
class AppState extends ChangeNotifier {
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  String userName = 'Faisal Khan';
  String userId = 'faisukhan01';
  String maskedMobile = '03•• ••• 2101';

  bool balanceHidden = false;
  ThemeMode themeMode = ThemeMode.light;
  bool biometricsEnabled = true;
  bool notificationsEnabled = true;

  late List<Account> accounts;
  late List<Txn> txns;
  late List<Beneficiary> beneficiaries;

  String? selectedAccountId;
  int _seq = 100;

  Future<void> init() async {
    accounts = MockData.accounts();
    txns = MockData.transactions();
    beneficiaries = MockData.beneficiaries();
    selectedAccountId = accounts.first.id;
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      _loggedIn = p.getBool('logged_in') ?? false;
      balanceHidden = p.getBool('balance_hidden') ?? false;
      biometricsEnabled = p.getBool('biometrics') ?? true;
      notificationsEnabled = p.getBool('notifications') ?? true;
      final String tm = p.getString('theme_mode') ?? 'light';
      themeMode = tm == 'dark'
          ? ThemeMode.dark
          : tm == 'system'
              ? ThemeMode.system
              : ThemeMode.light;
    } catch (_) {
      // Preferences unavailable (first run / web) — keep defaults.
    }
  }

  Future<void> _persist() async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      await p.setBool('logged_in', _loggedIn);
      await p.setBool('balance_hidden', balanceHidden);
      await p.setBool('biometrics', biometricsEnabled);
      await p.setBool('notifications', notificationsEnabled);
      await p.setString(
        'theme_mode',
        themeMode == ThemeMode.dark
            ? 'dark'
            : themeMode == ThemeMode.system
                ? 'system'
                : 'light',
      );
    } catch (_) {}
  }

  // ---------- Auth ----------

  Future<bool> login(String user, String pass) async {
    if (user.trim().isEmpty || pass.trim().length < 4) return false;
    userId = user.trim();
    _loggedIn = true;
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _loggedIn = false;
    await _persist();
    notifyListeners();
  }

  // ---------- Settings ----------

  void toggleBalanceHidden() {
    balanceHidden = !balanceHidden;
    _persist();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _persist();
    notifyListeners();
  }

  void setBiometrics(bool value) {
    biometricsEnabled = value;
    _persist();
    notifyListeners();
  }

  void setNotifications(bool value) {
    notificationsEnabled = value;
    _persist();
    notifyListeners();
  }

  // ---------- Accounts & transactions ----------

  Account get selectedAccount =>
      accounts.firstWhere((Account a) => a.id == selectedAccountId,
          orElse: () => accounts.first);

  void selectAccount(String id) {
    selectedAccountId = id;
    notifyListeners();
  }

  List<Txn> txnsFor(String accountId) {
    final List<Txn> list =
        txns.where((Txn t) => t.accountId == accountId).toList();
    list.sort((Txn a, Txn b) => b.date.compareTo(a.date));
    return list;
  }

  List<Txn> get recentTxns {
    final List<Txn> list = List<Txn>.from(txns);
    list.sort((Txn a, Txn b) => b.date.compareTo(a.date));
    return list;
  }

  double get totalPkrBalance {
    double sum = 0;
    for (final Account a in accounts) {
      if (a.currency == 'PKR') sum += a.balance;
    }
    return sum;
  }

  // ---------- Money movement (demo) ----------

  bool transfer(TransferDraft d) {
    if (d.amount <= 0) return false;
    final int idx = accounts.indexWhere((Account a) => a.id == d.fromAccountId);
    if (idx < 0) return false;
    final Account from = accounts[idx];
    if (from.currency != 'PKR' || from.balance < d.amount) return false;

    final DateTime now = DateTime.now();
    _seq++;
    final String ref =
        'FT${now.millisecondsSinceEpoch.toString().substring(7)}$_seq';

    accounts[idx] = from.copyWith(balance: from.balance - d.amount);
    txns.insert(
      0,
      Txn(
        id: 'x$_seq',
        accountId: from.id,
        title: d.bank.startsWith('Meezan')
            ? 'Transfer to ${d.toName}'
            : 'IBFT to ${d.toName} – ${d.bank}',
        channel: d.channel,
        ref: ref,
        type: TxnType.debit,
        amount: d.amount,
        date: now,
      ),
    );

    final int destIdx =
        accounts.indexWhere((Account a) => a.number == d.toAccount);
    if (destIdx >= 0) {
      final Account dest = accounts[destIdx];
      accounts[destIdx] = dest.copyWith(balance: dest.balance + d.amount);
      txns.insert(
        0,
        Txn(
          id: 'x${_seq}c',
          accountId: dest.id,
          title: 'Received from $userName',
          channel: d.channel,
          ref: ref,
          type: TxnType.credit,
          amount: d.amount,
          date: now,
        ),
      );
    }
    notifyListeners();
    return true;
  }

  bool payBill(BillDraft d) {
    if (d.amount <= 0) return false;
    final int idx = accounts.indexWhere((Account a) => a.id == d.fromAccountId);
    if (idx < 0) return false;
    final Account from = accounts[idx];
    if (from.currency != 'PKR' || from.balance < d.amount) return false;

    final DateTime now = DateTime.now();
    _seq++;
    final String ref =
        'BE${now.millisecondsSinceEpoch.toString().substring(7)}$_seq';

    accounts[idx] = from.copyWith(balance: from.balance - d.amount);
    txns.insert(
      0,
      Txn(
        id: 'x$_seq',
        accountId: from.id,
        title: '${d.company} Bill – ${d.consumerNo}',
        channel: 'Bill Payment',
        ref: ref,
        type: TxnType.debit,
        amount: d.amount,
        date: now,
      ),
    );
    notifyListeners();
    return true;
  }

  bool topUp(String operator, String mobile, double amount, String fromId) {
    if (amount <= 0) return false;
    final int idx = accounts.indexWhere((Account a) => a.id == fromId);
    if (idx < 0) return false;
    final Account from = accounts[idx];
    if (from.currency != 'PKR' || from.balance < amount) return false;

    final DateTime now = DateTime.now();
    _seq++;
    final String ref =
        'MT${now.millisecondsSinceEpoch.toString().substring(7)}$_seq';

    accounts[idx] = from.copyWith(balance: from.balance - amount);
    txns.insert(
      0,
      Txn(
        id: 'x$_seq',
        accountId: from.id,
        title: 'Mobile Top-up – $operator $mobile',
        channel: 'Top-up',
        ref: ref,
        type: TxnType.debit,
        amount: amount,
        date: now,
      ),
    );
    notifyListeners();
    return true;
  }

  void addBeneficiary(String name, String bank, String accountNo, String iban) {
    _seq++;
    beneficiaries = [
      Beneficiary(
        id: 'b$_seq',
        name: name,
        bank: bank,
        accountNo: accountNo,
        iban: iban,
      ),
      ...beneficiaries,
    ];
    notifyListeners();
  }
}
