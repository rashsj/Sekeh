part of 'main.dart';

const _ops = [['roshan', 'روشن', Color(0xFF22C55E)], ['awcc', 'افغان بیسیم', Color(0xFF3B82F6)], ['etisalat', 'اتصالات', Color(0xFF84CC16)], ['salaam', 'سلام', Color(0xFFF97316)], ['atoma', 'آتوما', Color(0xFFFACC15)]];
const _packs = [['۱ گیگ', '۷ روز', 99], ['۳ گیگ', '۳۰ روز', 299], ['۷ گیگ', '۳۰ روز', 499], ['۱۵ گیگ', '۳۰ روز', 899]];
const _agents = [['شهر نو', 'کابل، شهر نو', 45000], ['کارته چهار', 'کابل، کارته چهار', 32000], ['مندوی', 'کابل، مندوی', 60000], ['خیرخانه', 'کابل، خیرخانه', 25000]];

void openFlow(BuildContext context, String type) {
  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: kS1, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))), builder: (_) => FlowSheet(type: type));
}

class FlowSheet extends StatefulWidget {
  final String type;
  const FlowSheet({super.key, required this.type});
  @override
  State<FlowSheet> createState() => _FlowSheetState();
}
class _FlowSheetState extends State<FlowSheet> {
  int step = 0; int amount = 0; String op = 'roshan'; int pack = 1; int agent = 0; String customer = ''; int? bill; String? toName; String? toDest; bool bank = false; String? code; int codeLeft = 900; Timer? codeTimer;
  String get title => {'transfer': 'حواله پول', 'topup': 'شارژ کیف پول', 'charge': 'خرید کریدت', 'bill': 'پرداخت بل', 'net': 'بسته انترنت', 'cashout': 'برداشت از نماینده', 'receive': 'دریافت پول'}[widget.type]!;
  int get fee => widget.type == 'transfer' && bank ? 15 : widget.type == 'cashout' ? 10 : 0;
  int get total => widget.type == 'charge' ? amount : widget.type == 'net' ? (_packs[pack][2] as int) : widget.type == 'bill' ? (bill ?? 0) : amount + fee;
  @override
  void dispose() { codeTimer?.cancel(); super.dispose(); }
  void key(String k) { setState(() { if (k == 'del') amount ~/= 10; else { final add = k == '000' ? 3 : 1; if ('$amount'.length + add <= 9) amount = amount * (add == 3 ? 1000 : 10) + (k == '000' ? 0 : int.parse(k)); } }); }
  void commit() {
    if (widget.type == 'cashout') {
      code = '${100000 + DateTime.now().microsecondsSinceEpoch % 900000}';
      store.cashout = {'code': code, 'amount': amount, 'agent': _agents[agent][0]};
      store.txs.insert(0, Tx('برداشت از ${_agents[agent][0]}', 'cashout', (-(amount + 10)).toDouble(), DateTime.now(), 'کیف پول', _agents[agent][1] as String));
      store.balance -= (amount + 10).toDouble();
      codeTimer = Timer.periodic(const Duration(seconds: 1), (t) { if (!mounted) { t.cancel(); return; } setState(() => codeLeft--); if (codeLeft <= 0) { t.cancel(); refund(); } });
    } else {
      final double amt = (widget.type == 'topup' ? amount : -total).toDouble();
      store.txs.insert(0, Tx(title, widget.type == 'topup' ? 'topup' : widget.type, amt, DateTime.now(), bank ? 'حواله APSS' : 'کیف پول', toDest ?? ''));
      store.balance += amt;
    }
    store.touch();
    setState(() => step = 9);
  }
  void refund() {
    final c = store.cashout; if (c == null) return;
    final double back = ((c['amount'] as int) + 10).toDouble();
    store.balance += back;
    store.txs.insert(0, Tx('برگشت برداشت', 'refund', back, DateTime.now()));
    store.cashout = null; store.touch();
    if (mounted) setState(() => step = 8);
  }
  @override
  Widget build(BuildContext context) {
    final t = store.theme;
    return Padding(padding: EdgeInsets.fromLTRB(18, 12, 18, MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 42, height: 4.5, decoration: BoxDecoration(color: kMut.withOpacity(.4), borderRadius: BorderRadius.circular(99))),
      const SizedBox(height: 12),
      Row(children: [if (step > 0 && step < 9) IconButton(onPressed: () => setState(() => step--), icon: const Icon(Icons.chevron_right_rounded, color: kInk)) else const SizedBox(width: 40), Expanded(child: Text(title, textAlign: TextAlign.center, style: vaz(16, w: FontWeight.w900))), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: kMut))]),
      const SizedBox(height: 12),
      Flexible(child: SingleChildScrollView(child: body(t))),
    ]));
  }
  Widget body(GemTheme t) {
    if (step == 9) return success(t);
    if (step == 8) return refunded();
    if (code != null && widget.type == 'cashout' && step == 3) return codeView(t);
    switch (widget.type) {
      case 'receive': return receive(t);
      case 'transfer': return step == 0 ? dest(t) : step == 1 ? keypad(t) : confirm(t);
      case 'topup': return step == 0 ? keypad(t) : confirm(t);
      case 'charge': return step == 0 ? charge(t) : confirm(t);
      case 'bill': return step == 0 ? billForm(t) : confirm(t);
      case 'net': return step == 0 ? netForm(t) : confirm(t);
      case 'cashout': return step == 0 ? agents(t) : step == 1 ? keypad(t) : confirm(t);
    }
    return const SizedBox();
  }
  Widget dest(GemTheme t) => Column(children: [
    SegmentedButton<bool>(segments: const [ButtonSegment(value: false, label: Text('کیف پول')), ButtonSegment(value: true, label: Text('حساب بانکی'))], selected: {bank}, onSelectionChanged: (v) => setState(() => bank = v.first)),
    const SizedBox(height: 12),
    if (!bank) ...[
      GroupCard(child: Column(children: [
        for (final c in [['سمیرا رحیمی', '+93 799 ••• 456'], ['نجیب‌الله نوری', '+93 728 ••• 233'], ['مریم کریمی', '+93 700 ••• 654'], ['پدر', '+93 700 ••• 000']])
          ListTile(leading: CircleAvatar(backgroundColor: t.bg[1], child: Text(c[0][0], style: vaz(14, c: Colors.white, w: FontWeight.w800))), title: Text(c[0], style: vaz(13.5, w: FontWeight.w700)), subtitle: Text(c[1], style: inter(11, kMut)), trailing: const Icon(Icons.chevron_left_rounded, color: kMut), onTap: () => setState(() { toName = c[0]; toDest = c[1]; step = 1; })),
      ])),
    ] else ...[
      TextField(onChanged: (v) => setState(() => toDest = v), style: vaz(13), decoration: InputDecoration(hintText: 'شماره حساب', hintStyle: vaz(12, c: kMut), filled: true, fillColor: kS2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
      const SizedBox(height: 10),
      TextField(onChanged: (v) => setState(() => toName = v), style: vaz(13), decoration: InputDecoration(hintText: 'نام صاحب حساب', hintStyle: vaz(12, c: kMut), filled: true, fillColor: kS2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, height: 48, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: t.bg[1]), onPressed: (toDest != null && toDest!.length >= 8) ? () => setState(() { toName = toName ?? 'حساب بانکی'; step = 1; }) : null, child: Text('ادامه', style: vaz(14, c: Colors.white, w: FontWeight.w800)))),
    ],
  ]);
  Widget keypad(GemTheme t) => Column(children: [
    Text(faNum(group(amount)), style: vaz(38, w: FontWeight.w900)),
    Text('افغانی', style: vaz(13, c: kMut)),
    const SizedBox(height: 6),
    Text('موجودی: ${money(store.balance)}${fee > 0 ? ' • کارمزد ${money(fee)}' : ''}', style: vaz(11, c: amount + fee > store.balance ? kCoral : kMut)),
    const SizedBox(height: 10),
    Wrap(spacing: 8, children: [500, 1000, 2000].map((v) => ActionChip(label: Text(faNum(group(v)), style: vaz(12, c: kInk, w: FontWeight.w700)), backgroundColor: kS2, onPressed: () => setState(() => amount = v))).toList()),
    const SizedBox(height: 10),
    Keypad(onKey: key),
    const SizedBox(height: 10),
    SizedBox(width: double.infinity, height: 48, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: t.bg[1]), onPressed: amount >= 100 && amount + fee <= store.balance ? () => setState(() => step++) : null, child: Text('ادامه', style: vaz(14, c: Colors.white, w: FontWeight.w800)))),
  ]);
  Widget charge(GemTheme t) => Column(children: [
    Wrap(spacing: 8, runSpacing: 8, children: _ops.map((o) => ChoiceChip(label: Text(o[1] as String, style: vaz(11, c: op == o[0] ? Colors.white : kInk, w: FontWeight.w700)), selected: op == o[0], selectedColor: t.bg[1], onSelected: (_) => setState(() => op = o[0] as String))).toList()),
    const SizedBox(height: 12),
    GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 9, crossAxisSpacing: 9, childAspectRatio: 2.1, children: [50, 100, 200, 500].map((v) => GestureDetector(onTap: () => setState(() => amount = v), child: Container(decoration: BoxDecoration(color: amount == v ? kGold.withOpacity(.12) : kS2, borderRadius: BorderRadius.circular(16), border: Border.all(color: amount == v ? kGold : Colors.white.withOpacity(.08), width: 1.5)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(money(v), style: vaz(15, c: amount == v ? kGold : kInk, w: FontWeight.w900)), Text('+۱۰٪ بونس', style: vaz(9.5, c: kMut))])))).toList()),
    const SizedBox(height: 12),
    SizedBox(width: double.infinity, height: 48, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: t.bg[1]), onPressed: amount > 0 && amount <= store.balance ? () => setState(() => step++) : null, child: Text('پرداخت', style: vaz(14, c: Colors.white, w: FontWeight.w800)))),
  ]);
  Widget billForm(GemTheme t) => Column(children: [
    TextField(onChanged: (v) => setState(() => customer = v), keyboardType: TextInputType.number, style: vaz(13), decoration: InputDecoration(hintText: 'شماره مشتری / شماره بل', hintStyle: vaz(12, c: kMut), filled: true, fillColor: kS2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
    const SizedBox(height: 12),
    SizedBox(width: double.infinity, height: 48, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: t.bg[1]), onPressed: customer.replaceAll(RegExp(r'[^0-9]'), '').length >= 6 ? () => setState(() { bill = 850 + (int.tryParse(customer.substring(customer.length - 4)) ?? 137) * 17 % 900; step++; }) : null, child: Text('استعلام بل', style: vaz(14, c: Colors.white, w: FontWeight.w800)))),
  ]);
  Widget netForm(GemTheme t) => Column(children: [
    for (var i = 0; i < _packs.length; i++)
      GestureDetector(onTap: () => setState(() => pack = i), child: Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: pack == i ? kCyan.withOpacity(.09) : kS2, borderRadius: BorderRadius.circular(17), border: Border.all(color: pack == i ? kCyan : Colors.white.withOpacity(.08), width: 1.5)), child: Row(children: [
        Icon(pack == i ? Icons.radio_button_checked : Icons.radio_button_off, color: pack == i ? kCyan : kMut, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_packs[i][0] as String, style: vaz(14, w: FontWeight.w900)), Text(_packs[i][1] as String, style: vaz(10.5, c: kMut))])),
        Text(money(_packs[i][2] as int), style: vaz(13, c: kCyan, w: FontWeight.w900)),
      ]))),
    const SizedBox(height: 6),
    SizedBox(width: double.infinity, height: 48, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: t.bg[1]), onPressed: (_packs[pack][2] as int) <= store.balance ? () => setState(() => step++) : null, child: Text('پرداخت', style: vaz(14, c: Colors.white, w: FontWeight.w800)))),
  ]);
  Widget agents(GemTheme t) => GroupCard(child: Column(children: [
    for (var i = 0; i < _agents.length; i++)
      ListTile(leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: kGold.withOpacity(.14), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.storefront_rounded, color: kGold, size: 20)), title: Text(_agents[i][0] as String, style: vaz(14, w: FontWeight.w800)), subtitle: Text('${_agents[i][1]} • نقد ${faNum(group(_agents[i][2] as int))}', style: vaz(11, c: kMut)), trailing: const Icon(Icons.chevron_left_rounded, color: kMut), onTap: () => setState(() { agent = i; step = 1; })),
  ]));
  Widget confirm(GemTheme t) => Column(children: [
    GroupCard(child: Column(children: [
      if (toName != null) detailRow('به', toName!),
      if (toDest != null) detailRow('مقصد', toDest!),
      detailRow('مبلغ', money(total)),
      detailRow('کارمزد', fee > 0 ? money(fee) : 'رایگان'),
      detailRow('مجموع', money(total)),
    ])),
    const SizedBox(height: 14),
    SlideConfirm(label: 'برای پرداخت بکشید', onDone: commit),
  ]);
  Widget codeView(GemTheme t) => Column(children: [
    Text(faNum(code!), style: inter(34, kGold)),
    const SizedBox(height: 10),
    Text('کود را به نماینده نشان دهید • تذکره همراه', style: vaz(11.5, c: kMut)),
    const SizedBox(height: 8),
    Text('اعتبار: ${faNum('${codeLeft ~/ 60}')}:${faNum('${codeLeft % 60}'.padLeft(2, '0'))}', style: vaz(13, c: kGold, w: FontWeight.w800)),
    const SizedBox(height: 14),
    SizedBox(width: double.infinity, height: 48, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: kCoral.withOpacity(.2)), onPressed: refund, child: Text('لغو برداشت', style: vaz(14, c: kCoral, w: FontWeight.w800)))),
  ]);
  Widget refunded() => Column(children: [const Icon(Icons.refresh_rounded, color: kMint, size: 56), const SizedBox(height: 10), Text('پول برگشت داده شد', style: vaz(16, w: FontWeight.w900)), const SizedBox(height: 12), SizedBox(width: double.infinity, height: 48, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: store.theme.bg[1]), onPressed: () => Navigator.pop(context), child: Text('باشه', style: vaz(14, c: Colors.white, w: FontWeight.w800))))]);
  Widget success(GemTheme t) => Column(children: [
    TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: 1), duration: const Duration(milliseconds: 600), curve: Curves.elasticOut, builder: (c, v, _) => Transform.scale(scale: v, child: Container(width: 92, height: 92, decoration: BoxDecoration(shape: BoxShape.circle, color: kMint.withOpacity(.14), border: Border.all(color: kMint, width: 3)), child: const Icon(Icons.check_rounded, color: kMint, size: 54)))),
    const SizedBox(height: 14),
    Text(widget.type == 'cashout' ? 'کود برداشت آماده است' : 'پرداخت موفق', style: vaz(18, w: FontWeight.w900)),
    const SizedBox(height: 8),
    Text(money(total), style: vaz(28, c: kGold, w: FontWeight.w900)),
    const SizedBox(height: 6),
    Text('موجودی جدید: ${money(store.balance)}', style: vaz(11.5, c: kMint)),
    const SizedBox(height: 16),
    SizedBox(width: double.infinity, height: 48, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: t.bg[1]), onPressed: () => Navigator.pop(context), child: Text('بازگشت', style: vaz(14, c: Colors.white, w: FontWeight.w800)))),
  ]);
  Widget receive(GemTheme t) => Column(children: [
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: QrImageView(data: payload(), version: QrVersions.auto, size: 180, backgroundColor: Colors.white)),
    const SizedBox(height: 12),
    Text('فرید احمدزی — کیف پول سِکّه', style: vaz(13, w: FontWeight.w900)),
    const SizedBox(height: 12),
    GroupCard(child: Column(children: [detailRow('شماره', localPhone(store.phone)), detailRow('شناسه', store.walletId)])),
    const SizedBox(height: 12),
    SizedBox(width: double.infinity, height: 48, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: t.bg[1]), onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CardPage())); }, child: Text('ساخت کارت کسب‌وکار', style: vaz(14, c: Colors.white, w: FontWeight.w800)))),
  ]);
}
// END-OF-FLOWS
