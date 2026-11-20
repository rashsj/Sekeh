part of 'main.dart';

class GemFab extends StatelessWidget {
  final VoidCallback onTap;
  const GemFab({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kBg, width: 3), boxShadow: [BoxShadow(color: kGold.withOpacity(.45), blurRadius: 14, offset: const Offset(0, 4))]),
        child: ClipOval(
          child: Image.asset('assets/logo.png', fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [kGold2, kGold])), child: const Center(child: Icon(Icons.add_rounded, size: 26, color: Color(0xFF6B4708))))),
        ),
      ),
    );
  }
}

class Keypad extends StatelessWidget {
  final Function(String) onKey; final bool round;
  const Keypad({super.key, required this.onKey, this.round = false});
  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', 'del'];
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GridView.count(
        crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.8,
        children: keys.map((k) => GestureDetector(
          onTap: () => onKey(k),
          child: Container(
            decoration: BoxDecoration(color: kS2, borderRadius: BorderRadius.circular(round ? 99 : 16)),
            child: Center(child: k == 'del' ? const Icon(Icons.backspace_rounded, color: kInk, size: 22) : Text(faNum(k), style: vaz(k == '000' ? 16 : 22, w: FontWeight.w800))),
          ),
        )).toList(),
      ),
    );
  }
}

class SlideConfirm extends StatefulWidget {
  final String label; final VoidCallback onDone;
  const SlideConfirm({super.key, required this.label, required this.onDone});
  @override
  State<SlideConfirm> createState() => _SlideConfirmState();
}
class _SlideConfirmState extends State<SlideConfirm> {
  double p = 0; bool done = false;
  @override
  Widget build(BuildContext context) {
    final t = store.theme;
    return LayoutBuilder(builder: (context, cons) {
      final max = (cons.maxWidth - 58).clamp(40.0, 600.0);
      return GestureDetector(
        onHorizontalDragUpdate: (d) { if (done) return; setState(() => p = (p - d.delta.dx).clamp(0.0, max)); if (p >= max * .96) { done = true; widget.onDone(); } },
        onHorizontalDragEnd: (_) { if (!done) setState(() => p = 0); },
        child: Container(
          height: 58,
          decoration: BoxDecoration(color: kS2, borderRadius: BorderRadius.circular(17)),
          child: Stack(children: [
            Positioned(right: 0, top: 0, bottom: 0, child: Container(width: p + 54, decoration: BoxDecoration(color: t.accent.withOpacity(.25), borderRadius: BorderRadius.circular(17)))),
            Center(child: Text(done ? 'در حال پردازش…' : '‹‹‹  ${widget.label}', style: vaz(13, c: kMut, w: FontWeight.w800))),
            Positioned(right: 4 + p, top: 4, child: Container(width: 50, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: LinearGradient(colors: done ? [kMint, const Color(0xFF20B981)] : [t.bg[1], t.bg[2]])), child: done ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))) : const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 24))),
          ]),
        ),
      );
    });
  }
}

class GroupCard extends StatelessWidget {
  final Widget child;
  const GroupCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: kS1, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.07))),
        child: child,
      );
}

class SectionTitle extends StatelessWidget {
  final String title; final String? action; final VoidCallback? onAction;
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 20, 2, 10),
        child: Row(children: [
          Text(title, style: vaz(15, w: FontWeight.w900)),
          const Spacer(),
          if (action != null) GestureDetector(onTap: onAction, child: Text(action!, style: vaz(12, c: store.theme.accent, w: FontWeight.w800))),
        ]),
      );
}

Widget detailRow(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(children: [Text(k, style: vaz(12, c: kMut)), const SizedBox(width: 12), Expanded(child: Text(v, textAlign: TextAlign.end, style: vaz(12.5, w: FontWeight.w700)))]),
    );

class TxTile extends StatelessWidget {
  final Tx tx;
  const TxTile({super.key, required this.tx});
  @override
  Widget build(BuildContext context) {
    final pos = tx.amount > 0;
    final c = pos ? kMint : store.theme.accent;
    return InkWell(
      onTap: () => txDetail(context, tx),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withOpacity(.15), borderRadius: BorderRadius.circular(14)), child: Icon(pos ? Icons.south_west_rounded : Icons.north_east_rounded, color: c, size: 20)),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(tx.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: vaz(13, w: FontWeight.w700)),
            const SizedBox(height: 3),
            Text('${tx.method} • ${faNum(tx.time.hour.toString().padLeft(2, '0'))}:${faNum(tx.time.minute.toString().padLeft(2, '0'))}', style: vaz(10.5, c: kMut)),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
            Text('${pos ? '+' : '−'} ${faNum(group(tx.amount))}', style: vaz(13, c: pos ? kMint : kInk, w: FontWeight.w900)),
            Text('افغانی', style: vaz(9, c: kMut)),
          ]),
        ]),
      ),
    );
  }
}

void txDetail(BuildContext context, Tx tx) {
  final pos = tx.amount > 0;
  showModalBottomSheet(
    context: context, backgroundColor: kS1, isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (c) => Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(c).padding.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 42, height: 4.5, decoration: BoxDecoration(color: kMut, borderRadius: BorderRadius.circular(99))),
        const SizedBox(height: 14),
        Text(tx.title, style: vaz(16, w: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('${pos ? '+' : '−'} ${money(tx.amount.abs())}', style: vaz(26, c: pos ? kMint : kGold, w: FontWeight.w900)),
        const SizedBox(height: 12),
        GroupCard(child: Column(mainAxisSize: MainAxisSize.min, children: [
          detailRow('تاریخ', '${faNum('${tx.time.day}')}/${faNum('${tx.time.month}')}/${faNum('${tx.time.year}')}'),
          detailRow('منبع', tx.method),
          if (tx.peer.isNotEmpty) detailRow('طرف', tx.peer),
          detailRow('پیگیری', tx.ref),
        ])),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, height: 48, child: OutlinedButton(onPressed: () => Navigator.pop(c), child: Text('بستن', style: vaz(14, w: FontWeight.w800)))),
      ]),
    ),
  );
}

class WeekChart extends StatelessWidget {
  const WeekChart({super.key});
  @override
  Widget build(BuildContext context) {
    final t = store.theme;
    const vals = [420, 180, 650, 300, 890, 240, 520];
    const mx = 890;
    return GroupCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [Text('خرج ۷ روز', style: vaz(13, w: FontWeight.w800)), const Spacer(), Text(money(3200), style: vaz(11, c: kMut))]),
          const SizedBox(height: 14),
          SizedBox(
            height: 112,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(7, (i) {
              final hh = (94.0 * vals[i] / mx).clamp(8.0, 94.0);
              return Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(width: 22, height: hh, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: LinearGradient(colors: i == 6 ? [kGold2, kGold] : [t.accent, t.bg[1]], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
                const SizedBox(height: 7),
                Text(['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'][i], style: vaz(10, c: kMut, w: FontWeight.w700)),
              ]));
            })),
          ),
        ]),
      ),
    );
  }
}
// END-OF-WIDGETS
