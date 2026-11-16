part of 'main.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    final t = store.theme;
    store.ensurePhoto(t);
    final url = store.photoUrls[t.id];
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 120), children: [
      Row(children: [
        CircleAvatar(radius: 23, backgroundColor: t.bg[1], child: Text('ف', style: vaz(18, c: Colors.white, w: FontWeight.w900))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('سلام، فرید 👋', style: vaz(17, w: FontWeight.w900)), Text(t.place, style: vaz(11, c: kMut))])),
        IconButton(onPressed: () { store.hideBalance = !store.hideBalance; store.touch(); }, icon: Icon(store.hideBalance ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: t.accent)),
        Stack(children: [
          IconButton(onPressed: () => notifSheet(context), icon: const Icon(Icons.notifications_rounded, color: kInk)),
          if (store.unread > 0) Positioned(right: 6, top: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: kCoral, borderRadius: BorderRadius.circular(9)), child: Text(faNum('${store.unread}'), style: vaz(9, c: Colors.white, w: FontWeight.w900)))),
        ]),
      ]),
      const SizedBox(height: 16),
      balanceCard(t, url),
      const SizedBox(height: 16),
      Row(children: [
        qa(context, Icons.phone_android_rounded, 'کریدت', 'charge'),
        qa(context, Icons.bolt_rounded, 'بل‌ها', 'bill'),
        qa(context, Icons.wifi_rounded, 'انترنت', 'net'),
        qa(context, Icons.storefront_rounded, 'برداشت', 'cashout'),
      ]),
      SectionTitle('کارت‌های من', action: 'افزودن', onAction: () {}),
      SizedBox(height: 172, child: ListView(scrollDirection: Axis.horizontal, children: [
        bankCard('سِکّه کارت', [kGold2, kGold, const Color(0xFFB8791A)], 'Visa', '۰۹/۱۴۰۸', true),
        bankCard('عزیزی بانک', [t.bg[1], t.bg[2]], 'Mastercard', '۰۵/۱۴۰۹', false),
      ])),
      SectionTitle('فعالیت این هفته', action: 'جزئیات', onAction: () {}),
      const WeekChart(),
      SectionTitle('تراکنش‌های اخیر', action: 'همه', onAction: () {}),
      GroupCard(child: Column(children: store.txs.take(5).map((e) => TxTile(tx: e)).toList())),
    ]));
  }
  Widget qa(BuildContext context, IconData ic, String label, String type) {
    final t = store.theme;
    return Expanded(child: GestureDetector(onTap: () => openFlow(context, type), child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: kS1.withOpacity(.93), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.07))), child: Column(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: t.accent.withOpacity(.16), borderRadius: BorderRadius.circular(15)), child: Icon(ic, color: t.accent, size: 22)),
      const SizedBox(height: 8),
      Text(label, style: vaz(11, w: FontWeight.w700)),
    ]))));
  }
  Widget bankCard(String bank, List<Color> g, String net, String exp, bool goldText) {
    final c = goldText ? const Color(0xFF3A2A08) : Colors.white;
    return Padding(padding: const EdgeInsets.only(left: 12), child: Shine(radius: 20, child: Container(width: 266, padding: const EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: g, begin: Alignment.topLeft, end: Alignment.bottomRight)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text(bank, style: vaz(13, c: c, w: FontWeight.w900)), const Spacer(), Icon(Icons.contactless_rounded, color: c.withOpacity(.85), size: 20)]),
      const Spacer(),
      Text('•••• •••• •••• ۳۳۶۵', style: inter(15, c)),
      const SizedBox(height: 12),
      Row(children: [Text('فرید احمدزی', style: vaz(10, c: c.withOpacity(.9), w: FontWeight.w700)), const Spacer(), Text('$net • $exp', style: vaz(9, c: c.withOpacity(.75)))]),
    ]))));
  }
}

Widget balanceCard(GemTheme t, String? url) {
  return Shine(radius: 25, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), gradient: LinearGradient(colors: t.bg, begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: t.bg[1].withOpacity(.5), blurRadius: 30, offset: const Offset(0, 14))]), child: ClipRRect(borderRadius: BorderRadius.circular(25), child: Stack(children: [
    if (url != null) Positioned.fill(child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox())),
    Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [t.deep.withOpacity(.5), t.deep.withOpacity(.28), t.deep.withOpacity(.72)])))),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('موجودی کیف پول', style: vaz(12.5, c: Colors.white.withOpacity(.92))),
      const SizedBox(height: 8),
      Row(children: [
        Text(store.hideBalance ? '••••••' : faNum(group(store.balance)), style: vaz(33, c: Colors.white, w: FontWeight.w900)),
        const SizedBox(width: 7),
        Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('افغانی', style: vaz(13, c: Colors.white.withOpacity(.85)))),
      ]),
      const SizedBox(height: 6),
      Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: t.accent, border: Border.all(color: Colors.white.withOpacity(.6)))), const SizedBox(width: 6), Text(t.name, style: vaz(10, c: Colors.white.withOpacity(.92), w: FontWeight.w700))]),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: glassBtn(Icons.add_rounded, 'شارژ کیف پول', 'topup')),
        const SizedBox(width: 10),
        Expanded(child: glassBtn(Icons.send_rounded, 'حواله پول', 'transfer')),
      ]),
    ]),
  ]))));
}
Widget glassBtn(IconData ic, String label, String type) => Builder(builder: (context) => GestureDetector(onTap: () => openFlow(context, type), child: Container(height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), gradient: LinearGradient(colors: [store.theme.bg[1], store.theme.bg[2]]), border: Border.all(color: Colors.white.withOpacity(.25))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ic, size: 17, color: Colors.white), const SizedBox(width: 7), Text(label, style: vaz(12.5, c: Colors.white, w: FontWeight.w800))]))));

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
    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 6), child: Align(alignment: Alignment.centerRight, child: Text('تراکنش‌ها', style: vaz(24, w: FontWeight.w900)))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: TextField(onChanged: (v) => setState(() => q = v), style: vaz(13), decoration: InputDecoration(hintText: 'جست‌وجو…', hintStyle: vaz(12, c: kMut), prefixIcon: const Icon(Icons.search_rounded, color: kMut, size: 20), filled: true, fillColor: kS1, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))))),
      const SizedBox(height: 10),
      SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
        for (final e in [['all', 'همه'], ['in', 'دریافتی'], ['out', 'پرداختی']])
          Padding(padding: const EdgeInsets.only(left: 8), child: ChoiceChip(label: Text(e[1], style: vaz(12, c: f == e[0] ? Colors.white : kInk, w: FontWeight.w700)), selected: f == e[0], selectedColor: store.theme.bg[1], onSelected: (_) => setState(() => f = e[0]))),
      ])),
      Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 120), children: list.map((e) => TxTile(tx: e)).toList())),
    ]));
  }
}
// END-OF-HOME
