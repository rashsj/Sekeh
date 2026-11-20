part of 'main.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    final t = store.theme;
    store.ensurePhoto(t);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(children: [
            CircleAvatar(radius: 22, backgroundColor: t.bg[1], child: Text('ف', style: vaz(17, c: Colors.white, w: FontWeight.w900))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text('سلام، فرید 👋', style: vaz(16, w: FontWeight.w900)),
              Text(t.place, style: vaz(11, c: kMut)),
            ])),
            IconButton(onPressed: () { store.hideBalance = !store.hideBalance; store.touch(); }, icon: Icon(store.hideBalance ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: t.accent)),
            IconButton(onPressed: () => notifSheet(context), icon: const Icon(Icons.notifications_rounded, color: kInk)),
          ]),
          const SizedBox(height: 16),
          const BalanceCard(),
          const SizedBox(height: 16),
          Row(children: [
            QaBtn(icon: Icons.phone_android_rounded, label: 'کریدت', type: 'charge'),
            QaBtn(icon: Icons.bolt_rounded, label: 'بل‌ها', type: 'bill'),
            QaBtn(icon: Icons.wifi_rounded, label: 'انترنت', type: 'net'),
            QaBtn(icon: Icons.storefront_rounded, label: 'برداشت', type: 'cashout'),
          ]),
          const SectionTitle('کارت‌های من'),
          SizedBox(
            height: 168,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              BankCardView(bank: 'سِکّه کارت', colors: const [kGold2, kGold, Color(0xFFB8791A)], net: 'Visa', exp: '۰۹/۱۴۰۸', goldText: true),
              BankCardView(bank: 'عزیزی بانک', colors: [t.bg[1], t.bg[2]], net: 'Mastercard', exp: '۰۵/۱۴۰۹', goldText: false),
            ]),
          ),
          const SectionTitle('فعالیت این هفته'),
          const WeekChart(),
          const SectionTitle('تراکنش‌های اخیر'),
          GroupCard(child: Column(mainAxisSize: MainAxisSize.min, children: store.txs.take(5).map((e) => TxTile(tx: e)).toList())),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class QaBtn extends StatelessWidget {
  final IconData icon; final String label, type;
  const QaBtn({super.key, required this.icon, required this.label, required this.type});
  @override
  Widget build(BuildContext context) {
    final t = store.theme;
    return Expanded(
      child: GestureDetector(
        onTap: () => openFlow(context, type),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: kS1, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.07))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: t.accent.withOpacity(.16), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: t.accent, size: 21)),
            const SizedBox(height: 8),
            Text(label, style: vaz(11, w: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

class BankCardView extends StatelessWidget {
  final String bank, net, exp; final List<Color> colors; final bool goldText;
  const BankCardView({super.key, required this.bank, required this.colors, required this.net, required this.exp, required this.goldText});
  @override
  Widget build(BuildContext context) {
    final c = goldText ? const Color(0xFF3A2A08) : Colors.white;
    return Container(
      width: 262, height: 168, margin: const EdgeInsets.only(left: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [Text(bank, style: vaz(13, c: c, w: FontWeight.w900)), const Spacer(), Icon(Icons.contactless_rounded, color: c, size: 20)]),
        const SizedBox(height: 34),
        Text('•••• •••• •••• ۳۳۶۵', style: inter(15, c)),
        const SizedBox(height: 16),
        Row(children: [Text('فرید احمدزی', style: vaz(10, c: c, w: FontWeight.w700)), const Spacer(), Text('$net • $exp', style: vaz(9, c: c))]),
      ]),
    );
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});
  @override
  Widget build(BuildContext context) {
    final t = store.theme;
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: t.bg, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: t.bg[1].withOpacity(.45), blurRadius: 26, offset: const Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text('موجودی کیف پول', style: vaz(12, c: Colors.white)),
        const SizedBox(height: 8),
        Row(children: [
          Text(store.hideBalance ? '••••••' : faNum(group(store.balance)), style: vaz(32, c: Colors.white, w: FontWeight.w900)),
          const SizedBox(width: 7),
          Text('افغانی', style: vaz(12.5, c: Colors.white)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Container(width: 11, height: 11, decoration: BoxDecoration(shape: BoxShape.circle, color: t.accent)),
          const SizedBox(width: 6),
          Text(t.name, style: vaz(10, c: Colors.white, w: FontWeight.w700)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: BalanceBtn(icon: Icons.add_rounded, label: 'شارژ کیف پول', type: 'topup')),
          const SizedBox(width: 10),
          Expanded(child: BalanceBtn(icon: Icons.send_rounded, label: 'حواله پول', type: 'transfer')),
        ]),
      ]),
    );
  }
}

class BalanceBtn extends StatelessWidget {
  final IconData icon; final String label, type;
  const BalanceBtn({super.key, required this.icon, required this.label, required this.type});
  @override
  Widget build(BuildContext context) {
    final t = store.theme;
    return GestureDetector(
      onTap: () => openFlow(context, type),
      child: Container(
        height: 42,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), gradient: LinearGradient(colors: [t.bg[1], t.bg[2]]), border: Border.all(color: Colors.white.withOpacity(.25))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: vaz(12, c: Colors.white, w: FontWeight.w800)),
        ]),
      ),
    );
  }
}

class TxPage extends StatefulWidget {
  const TxPage({super.key});
  @override
  State<TxPage> createState() => _TxPageState();
}
class _TxPageState extends State<TxPage> {
  String q = '', f = 'all';
  @override
  Widget build(BuildContext context) {
    var list = List<Tx>.from(store.txs);
    if (f == 'in') list = list.where((e) => e.amount > 0).toList();
    if (f == 'out') list = list.where((e) => e.amount < 0).toList();
    if (q.trim().isNotEmpty) list = list.where((e) => e.title.contains(q.trim())).toList();
    return SafeArea(
      bottom: false,
      child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 6), child: Align(alignment: Alignment.centerRight, child: Text('تراکنش‌ها', style: vaz(24, w: FontWeight.w900)))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: TextField(onChanged: (v) => setState(() => q = v), style: vaz(13), decoration: InputDecoration(hintText: 'جست‌وجو…', hintStyle: vaz(12, c: kMut), prefixIcon: const Icon(Icons.search_rounded, color: kMut, size: 20), filled: true, fillColor: kS1, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))))),
        const SizedBox(height: 10),
        SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          for (final e in const [['all', 'همه'], ['in', 'دریافتی'], ['out', 'پرداختی']])
            Padding(padding: const EdgeInsets.only(left: 8), child: ChoiceChip(label: Text(e[1], style: vaz(12, c: f == e[0] ? Colors.white : kInk, w: FontWeight.w700)), selected: f == e[0], selectedColor: store.theme.bg[1], onSelected: (_) => setState(() => f = e[0]))),
        ])),
        Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: list.map((e) => TxTile(tx: e)).toList())),
      ]),
    );
  }
}
// END-OF-HOME
