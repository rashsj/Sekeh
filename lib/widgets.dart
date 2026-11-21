part of 'main.dart';

/* ---------- shine ---------- */
class Shine extends StatefulWidget {
  final Widget child; final double radius; final int seconds;
  const Shine({super.key, required this.child, this.radius = 20, this.seconds = 6});
  @override
  State<Shine> createState() => _ShineState();
}
class _ShineState extends State<Shine> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: Duration(seconds: widget.seconds))..repeat();
  @override
  void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(widget.radius), child: Stack(children: [
    widget.child,
    Positioned.fill(child: IgnorePointer(child: LayoutBuilder(builder: (context, k) {
      final w = k.maxWidth.isFinite ? k.maxWidth : 300.0, h = k.maxHeight.isFinite ? k.maxHeight : 200.0;
      return AnimatedBuilder(animation: c, builder: (context, _) {
        if (c.value < .74) return const SizedBox.shrink();
        final p = (c.value - .74) / .26;
        return Stack(children: [Positioned(left: -90 + (w + 180) * p, top: -h * .25, child: Transform.rotate(angle: .35, child: Container(width: 52, height: h * 1.5, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(.32), Colors.white.withOpacity(0)])))))]);
      });
    }))),
  ]));
}

/* ---------- icon ---------- */
class SekkehIcon extends StatelessWidget {
  final double size; final int? style; final int? pal;
  const SekkehIcon({super.key, required this.size, this.style, this.pal});
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: CustomPaint(painter: IconPainter(style ?? store.iconStyle, pal ?? store.iconPal)));
}

class IconPainter extends CustomPainter {
  final int style, pal;
  IconPainter(this.style, this.pal);
  @override
  void paint(Canvas cv, Size s) {
    final t = kThemes[pal % kThemes.length];
    final u = s.width / 512;
    cv.save(); cv.scale(u);
    final r = RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 512, 512), const Radius.circular(114));
    cv.drawRRect(r, Paint()..shader = ui.Gradient.linear(const Offset(0, 0), const Offset(512, 512), t.bg));
    cv.save(); cv.clipRRect(r);
    cv.drawCircle(const Offset(430, 86), 150, Paint()..color = Colors.white.withOpacity(.07));
    cv.drawCircle(const Offset(70, 450), 120, Paint()..color = Colors.black.withOpacity(.12));
    cv.restore();
    final gold = ui.Gradient.linear(const Offset(130, 120), const Offset(380, 380), [kGold2, kGold, const Color(0xFFC98A16)]);
    if (style == 1) {
      final p = Path()..moveTo(256, 108)..lineTo(392, 214)..lineTo(316, 400)..lineTo(196, 400)..lineTo(120, 214)..close();
      cv.drawPath(p, Paint()..shader = gold);
      cv.drawPath(p, Paint()..style = PaintingStyle.stroke..strokeWidth = 6..color = const Color(0xFF8A5B00).withOpacity(.35));
      _txt(cv, 'س', 256, 330, 96);
    } else if (style == 2) {
      cv.drawCircle(const Offset(256, 256), 132, Paint()..style = PaintingStyle.stroke..strokeWidth = 22..shader = gold);
      _txt(cv, 'س', 256, 308, 140, shader: gold);
    } else {
      cv.save(); cv.translate(256, 268); cv.rotate(-.31);
      cv.drawOval(Rect.fromCenter(center: Offset.zero, width: 352, height: 120), Paint()..style = PaintingStyle.stroke..strokeWidth = 15..shader = ui.Gradient.linear(const Offset(-176, 0), const Offset(176, 0), [Colors.white.withOpacity(.95), t.bg[2].withOpacity(.55)]));
      cv.restore();
      cv.drawCircle(const Offset(256, 248), 126, Paint()..shader = gold);
      cv.drawCircle(const Offset(256, 248), 104, Paint()..style = PaintingStyle.stroke..strokeWidth = 7..color = const Color(0xFF8A5B00).withOpacity(.35));
      _txt(cv, 'س', 256, 300, 132);
      cv.save(); cv.translate(216, 196); cv.rotate(-.49);
      cv.drawOval(Rect.fromCenter(center: Offset.zero, width: 80, height: 36), Paint()..color = Colors.white.withOpacity(.33)); cv.restore();
      final arc = Path()..moveTo(120, 330)..quadraticBezierTo(256, 408, 392, 324);
      cv.drawPath(arc, Paint()..style = PaintingStyle.stroke..strokeWidth = 15..strokeCap = StrokeCap.round..shader = ui.Gradient.linear(const Offset(120, 330), const Offset(392, 324), [Colors.white.withOpacity(.95), t.bg[2].withOpacity(.6)]));
      cv.drawCircle(const Offset(392, 322), 13, Paint()..color = Colors.white.withOpacity(.95));
    }
    cv.restore();
  }
  void _txt(Canvas cv, String s, double x, double y, double fs, {Shader? shader}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontFamily: GoogleFonts.lalezar().fontFamily, fontSize: fs, color: shader == null ? const Color(0xFF6B4708) : null, foreground: shader == null ? null : (Paint()..shader = shader))),
      textDirection: TextDirection.rtl)..layout();
    tp.paint(cv, Offset(x - tp.width / 2, y - tp.height * .82));
  }
  @override
  bool shouldRepaint(covariant IconPainter o) => o.style != style || o.pal != pal;
}

/* ---------- mascot ---------- */
class Mascot extends StatefulWidget {
  const Mascot({super.key});
  @override
  State<Mascot> createState() => _MascotState();
}
class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController idle = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  bool blink = false; Timer? bt;
  @override
  void initState() { super.initState(); bt = Timer.periodic(const Duration(milliseconds: 3200), (_) { if (!mounted) return; setState(() => blink = true); Timer(const Duration(milliseconds: 150), () { if (mounted) setState(() => blink = false); }); }); }
  @override
  void dispose() { bt?.cancel(); idle.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => SizedBox(width: 104, height: 92, child: AnimatedBuilder(animation: Listenable.merge([pointer, idle]), builder: (context, _) => CustomPaint(painter: MascotPainter(pointer.value, blink, idle.value))));
}

class MascotPainter extends CustomPainter {
  final Offset pt; final bool blink; final double idle;
  MascotPainter(this.pt, this.blink, this.idle);
  @override
  void paint(Canvas cv, Size s) {
    final u = s.width / 200;
    cv.save(); cv.scale(u);
    Offset dir = Offset(Math.sin(idle * 6.28) * 3, Math.cos(idle * 4.4) * 2);
    final box = mascotKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && pt.dx > -500) {
      final c = box.localToGlobal(Offset(s.width / 2, s.height * .6));
      final d = pt - c; final len = d.distance;
      if (len > 1) { final k = (len < 200 ? len / 200 : 1.0); dir = Offset(d.dx / len * 7 * k, d.dy / len * 6 * k); }
    }
    final skin = Paint()..shader = ui.Gradient.linear(const Offset(0, 20), const Offset(0, 150), [const Color(0xFFFBE3C6), const Color(0xFFE7BE93)]);
    final line = Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0xFFD2A377);
    for (final hx in [51.0, 149.0]) {
      final hr = RRect.fromRectAndRadius(Rect.fromLTWH(hx - 17, 126, 34, 26), const Radius.circular(13));
      cv.drawRRect(hr, skin); cv.drawRRect(hr, line);
      for (var i = 0; i < 3; i++) cv.drawLine(Offset(hx - 8 + i * 8, 131), Offset(hx - 8 + i * 8, 146), Paint()..strokeWidth = 1.6..color = const Color(0xFFD2A377));
    }
    cv.drawOval(Rect.fromCenter(center: const Offset(36, 92), width: 22, height: 28), skin);
    cv.drawOval(Rect.fromCenter(center: const Offset(164, 92), width: 22, height: 28), skin);
    final head = Rect.fromCenter(center: const Offset(100, 86), width: 132, height: 124);
    cv.drawOval(head, skin); cv.drawOval(head, line);
    final cap = Path()..moveTo(34, 76)..quadraticBezierTo(44, 20, 100, 20)..quadraticBezierTo(156, 20, 166, 76)..quadraticBezierTo(136, 54, 100, 54)..quadraticBezierTo(64, 54, 34, 76)..close();
    cv.drawPath(cap, Paint()..color = const Color(0xFF2A2140));
    final t = store.theme;
    final band = Path()..moveTo(34, 74)..quadraticBezierTo(100, 44, 166, 74)..quadraticBezierTo(160, 54, 144, 44)..quadraticBezierTo(100, 24, 56, 44)..quadraticBezierTo(40, 54, 34, 74)..close();
    cv.drawPath(band, Paint()..shader = ui.Gradient.linear(const Offset(34, 40), const Offset(166, 76), [t.bg[1], t.bg[2]]));
    cv.drawCircle(const Offset(100, 30), 8, Paint()..color = kGold2);
    for (final ex in [74.0, 126.0]) {
      cv.drawPath(Path()..moveTo(ex - 18, 64)..quadraticBezierTo(ex, 56, ex + 18, 62), Paint()..style = PaintingStyle.stroke..strokeWidth = 5.5..strokeCap = StrokeCap.round..color = const Color(0xFF2A2140));
      final eye = Rect.fromCenter(center: Offset(ex, 92), width: 38, height: 42);
      cv.drawOval(eye, Paint()..color = Colors.white);
      cv.save(); cv.clipPath(Path()..addOval(eye));
      if (blink) { cv.drawRect(eye.inflate(2), skin); }
      else {
        cv.drawCircle(Offset(ex + dir.dx, 92 + dir.dy), 10.5, Paint()..color = const Color(0xFF241C3A));
        cv.drawCircle(Offset(ex + dir.dx - 4, 88 + dir.dy), 3.4, Paint()..color = Colors.white.withOpacity(.95));
      }
      cv.restore();
      cv.drawOval(eye, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = const Color(0xFFD2A377));
    }
    cv.drawOval(Rect.fromCenter(center: const Offset(52, 110), width: 24, height: 14), Paint()..color = const Color(0xFFFF9BA8).withOpacity(.45));
    cv.drawOval(Rect.fromCenter(center: const Offset(148, 110), width: 24, height: 14), Paint()..color = const Color(0xFFFF9BA8).withOpacity(.45));
    cv.drawPath(Path()..moveTo(100, 100)..quadraticBezierTo(105, 107, 98, 110), Paint()..style = PaintingStyle.stroke..strokeWidth = 2.6..strokeCap = StrokeCap.round..color = const Color(0xFFD2A377));
    cv.drawPath(Path()..moveTo(88, 120)..quadraticBezierTo(100, 132, 112, 120), Paint()..style = PaintingStyle.stroke..strokeWidth = 3.6..strokeCap = StrokeCap.round..color = const Color(0xFF8A5A3B));
    cv.restore();
  }
  @override
  bool shouldRepaint(covariant MascotPainter o) => true;
}

/* ---------- basics ---------- */
class GemFab extends StatelessWidget {
  final VoidCallback onTap;
  const GemFab({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kBg, width: 3), boxShadow: [BoxShadow(color: kGold.withOpacity(.5), blurRadius: 16, offset: const Offset(0, 5))]), child: ClipOval(child: Shine(radius: 99, seconds: 5, child: SizedBox(width: 52, height: 52, child: CustomPaint(painter: IconPainter(store.iconStyle, store.iconPal)))))));
}

class Keypad extends StatelessWidget {
  final Function(String) onKey; final bool round;
  const Keypad({super.key, required this.onKey, this.round = false});
  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.ltr, child: GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.8, children: ['1','2','3','4','5','6','7','8','9','000','0','del'].map((k) => GestureDetector(onTap: () { tap(); onKey(k); }, child: Container(decoration: BoxDecoration(color: kS2, borderRadius: BorderRadius.circular(round ? 99 : 16)), child: Center(child: k == 'del' ? const Icon(Icons.backspace_rounded, color: kInk, size: 22) : Text(faNum(k), style: vaz(k == '000' ? 16 : 22, w: FontWeight.w800)))))).toList()));
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
    return LayoutBuilder(builder: (context, k) {
      final max = (k.maxWidth - 58).clamp(40.0, 600.0);
      return GestureDetector(
        onHorizontalDragUpdate: (d) { if (done) return; setState(() => p = (p - d.delta.dx).clamp(0.0, max)); if (p >= max * .96) { done = true; okBuzz(); widget.onDone(); } },
        onHorizontalDragEnd: (_) { if (!done) setState(() => p = 0); },
        child: Container(height: 58, decoration: BoxDecoration(color: kS2, borderRadius: BorderRadius.circular(17)), child: Stack(children: [
          Positioned(right: 0, top: 0, bottom: 0, child: Container(width: p + 54, decoration: BoxDecoration(color: t.accent.withOpacity(.25), borderRadius: BorderRadius.circular(17)))),
          Center(child: Text(done ? 'در حال پردازش…' : '‹‹‹  ${widget.label}', style: vaz(13, c: kMut, w: FontWeight.w800))),
          Positioned(right: 4 + p, top: 4, child: Container(width: 50, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: LinearGradient(colors: done ? [kMint, const Color(0xFF20B981)] : [t.bg[1], t.bg[2]])), child: done ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))) : const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 24))),
        ])),
      );
    });
  }
}

class GroupCard extends StatelessWidget {
  final Widget child;
  const GroupCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: kS1, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.07))), child: child);
}

class SectionTitle extends StatelessWidget {
  final String title; final String? action; final VoidCallback? onAction;
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(2, 20, 2, 10), child: Row(children: [Text(title, style: vaz(15, w: FontWeight.w900)), const Spacer(), if (action != null) GestureDetector(onTap: onAction, child: Text(action!, style: vaz(12, c: store.theme.accent, w: FontWeight.w800)))]));
}

Widget detailRow(String k, String v) => Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), child: Row(children: [Text(k, style: vaz(12, c: kMut)), const SizedBox(width: 12), Expanded(child: Text(v, textAlign: TextAlign.end, style: vaz(12.5, w: FontWeight.w700)))]));

class TxTile extends StatelessWidget {
  final Tx tx;
  const TxTile({super.key, required this.tx});
  @override
  Widget build(BuildContext context) {
    final pos = tx.amount > 0; final c = pos ? kMint : store.theme.accent;
    return InkWell(onTap: () { tap(); txDetail(context, tx); }, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11), child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withOpacity(.15), borderRadius: BorderRadius.circular(14)), child: Icon(pos ? Icons.south_west_rounded : Icons.north_east_rounded, color: c, size: 20)),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(tx.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: vaz(13, w: FontWeight.w700)), const SizedBox(height: 3), Text('${tx.method} • ${faNum(tx.time.hour.toString().padLeft(2, '0'))}:${faNum(tx.time.minute.toString().padLeft(2, '0'))}', style: vaz(10.5, c: kMut))])),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [Text('${pos ? '+' : '−'} ${faNum(group(tx.amount))}', style: vaz(13, c: pos ? kMint : kInk, w: FontWeight.w900)), Text(tx.status == 'pending' ? 'در انتظار' : 'افغانی', style: vaz(9, c: tx.status == 'pending' ? kGold : kMut))]),
    ])));
  }
}

void txDetail(BuildContext context, Tx tx) {
  final pos = tx.amount > 0;
  showModalBottomSheet(context: context, backgroundColor: kS1, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))), builder: (c) => Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(c).padding.bottom + 20), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 42, height: 4.5, decoration: BoxDecoration(color: kMut, borderRadius: BorderRadius.circular(99))),
    const SizedBox(height: 14),
    Text(tx.title, style: vaz(16, w: FontWeight.w900)), const SizedBox(height: 8),
    Text('${pos ? '+' : '−'} ${money(tx.amount.abs())}', style: vaz(26, c: pos ? kMint : kGold, w: FontWeight.w900)), const SizedBox(height: 12),
    GroupCard(child: Column(mainAxisSize: MainAxisSize.min, children: [detailRow('تاریخ', '${faNum('${tx.time.day}')}/${faNum('${tx.time.month}')}/${faNum('${tx.time.year}')}'), detailRow('منبع', tx.method), if (tx.peer.isNotEmpty) detailRow('طرف', tx.peer), detailRow('پیگیری', tx.ref)])),
    const SizedBox(height: 16),
    SizedBox(width: double.infinity, height: 48, child: OutlinedButton(onPressed: () => Navigator.pop(c), child: Text('بستن', style: vaz(14, w: FontWeight.w800)))),
  ])));
}

class WeekChart extends StatelessWidget {
  const WeekChart({super.key});
  @override
  Widget build(BuildContext context) {
    const vals = [420, 180, 650, 300, 890, 240, 520];
    const cols = [kCyan, kViolet, kCoral, kMint, kGold, kAmber, Color(0xFF4CC9F0)];
    return GroupCard(child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [Text('خرج ۷ روز', style: vaz(13, w: FontWeight.w800)), const Spacer(), Text(money(3200), style: vaz(11, c: kMut))]),
      const SizedBox(height: 14),
      SizedBox(height: 116, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(7, (i) => Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text(faNum('${vals[i]}'), style: vaz(8, c: kMut)), const SizedBox(height: 3),
        Container(width: 22, height: (86.0 * vals[i] / 890).clamp(8.0, 86.0), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: LinearGradient(colors: [cols[i], cols[i].withOpacity(.35)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
        const SizedBox(height: 6),
        Text(['ش','ی','د','س','چ','پ','ج'][i], style: vaz(10, c: kMut, w: FontWeight.w700)),
      ]))))),
    ])));
  }
}
// END-OF-WIDGETS
