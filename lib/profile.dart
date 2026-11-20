part of 'main.dart';

void notifSheet(BuildContext context) {
  showModalBottomSheet(context: context, backgroundColor: kS1, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))), builder: (c) => Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(c).padding.bottom + 20), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Row(children: [Text('اعلان‌ها', style: vaz(16, w: FontWeight.w900)), const Spacer(), TextButton(onPressed: () { for (final n in store.notifs) n.read = true; store.touch(); Navigator.pop(c); }, child: Text('خواندن همه', style: vaz(12, c: store.theme.accent, w: FontWeight.w800)))]),
    const SizedBox(height: 10),
    GroupCard(child: Column(mainAxisSize: MainAxisSize.min, children: store.notifs.map((n) => ListTile(leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: n.color.withOpacity(.14), borderRadius: BorderRadius.circular(12)), child: Icon(n.icon, color: n.color, size: 20)), title: Text(n.title, style: vaz(13.5, w: FontWeight.w800)), subtitle: Text(n.body, style: vaz(11, c: kMut)), trailing: n.read ? null : Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: store.theme.accent)), onTap: () { n.read = true; store.touch(); Navigator.pop(c); })).toList())),
  ])));
}

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) {
    final t = store.theme;
    return SafeArea(bottom: false, child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
      Center(child: Column(children: [
        const SekkehIcon(size: 76), const SizedBox(height: 10),
        Text('فرید احمدزی', style: vaz(19, w: FontWeight.w900)),
        Text('+93 700 123 456', style: inter(12, kMut)), const SizedBox(height: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [kGold2, kGold]), borderRadius: BorderRadius.circular(99)), child: Text('تایید شده با تذکره', style: vaz(10.5, c: const Color(0xFF2B2108), w: FontWeight.w900))),
      ])),
      const SizedBox(height: 18),
      Row(children: [stat(faNum('${store.txs.length}'), 'تراکنش', t.accent), const SizedBox(width: 8), stat('۱۲۴۰', 'امتیاز', t.accent), const SizedBox(width: 8), stat('طلایی', 'سطح', kGold)]),
      const SizedBox(height: 10),
      GroupCard(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [Row(children: [Text('۶۲٪ تا پلاتینیوم', style: vaz(11.5, w: FontWeight.w800)), const Spacer(), Text('۷۶۰ امتیاز', style: vaz(11, c: kMut))]), const SizedBox(height: 9), ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: .62, minHeight: 7, backgroundColor: kS2, color: kGold))]))),
      const SectionTitle('کسب‌وکار و ظاهر'),
      GroupCard(child: Column(mainAxisSize: MainAxisSize.min, children: [
        row(Icons.qr_code_2_rounded, kGold, 'کارت کسب‌وکار و کیوآر', store.bizName, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CardPage()))),
        row(Icons.auto_awesome_rounded, kViolet, 'استودیوی آیکون', '۳ سبک • ۶ رنگ • خروجی PNG', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IconStudio()))),
        row(Icons.palette_rounded, t.accent, 'تم‌ها', t.name, () => themeSheet(context)),
        row(Icons.emoji_emotions_rounded, kCyan, 'عروسک نگاه‌کن', store.mascotOn ? 'روشن' : 'خاموش', () { store.mascotOn = !store.mascotOn; store.touch(); }),
      ])),
      const SectionTitle('حساب و امنیت'),
      GroupCard(child: Column(mainAxisSize: MainAxisSize.min, children: [
        row(Icons.support_agent_rounded, kCyan, 'پشتیبانی', 'گفت‌وگو با سِپیدار', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Support()))),
        row(Icons.volume_up_rounded, kGold, 'صدا و لرزش', store.sound ? 'روشن' : 'خاموش', () { store.sound = !store.sound; store.touch(); }),
        row(Icons.lock_rounded, t.accent, 'قفل برنامه', 'رمز ۴ رقمی', () { store.locked = true; store.touch(); }),
        row(Icons.info_rounded, kGold, 'درباره سِکّه', 'build $kBuildTag • Beheshti Brothers', () => showDialog(context: context, builder: (c) => AlertDialog(backgroundColor: kS1, title: Text('سِکّه افغانستان', style: vaz(16, w: FontWeight.w900)), content: Text('طراحی و توسعه: Beheshti Brothers\nتیم افغان‌های مقیم ایران\nهمکاری ماهانه (ارجح) یا پروژه‌ای\nbuild $kBuildTag', style: vaz(13, c: kMut)), actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text('بستن', style: vaz(13, c: t.accent, w: FontWeight.w800)))]))),
      ])),
    ]));
  }
  Widget stat(String v, String l, Color c) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 13), decoration: BoxDecoration(color: kS1, borderRadius: BorderRadius.circular(17), border: Border.all(color: Colors.white.withOpacity(.07))), child: Column(children: [Text(v, style: vaz(15, c: c, w: FontWeight.w900)), const SizedBox(height: 3), Text(l, style: vaz(10, c: kMut))])));
  Widget row(IconData ic, Color c, String title, String sub, VoidCallback onTap) => ListTile(onTap: () { tap(); onTap(); }, leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withOpacity(.15), borderRadius: BorderRadius.circular(12)), child: Icon(ic, color: c, size: 20)), title: Text(title, style: vaz(14, w: FontWeight.w800)), subtitle: Text(sub, style: vaz(11, c: kMut)), trailing: const Icon(Icons.chevron_left_rounded, color: kMut, size: 20));
  void themeSheet(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: kS1, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))), builder: (c) => Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(c).padding.bottom + 20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('تم‌های تصویری', style: vaz(16, w: FontWeight.w900)), const SizedBox(height: 14),
      GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.5, children: List.generate(kThemes.length, (i) {
        final th = kThemes[i]; store.ensurePhoto(th); final u = store.photoUrls[th.id];
        return GestureDetector(onTap: () { tap(); store.themeIndex = i; store.iconPal = i; store.touch(); Navigator.pop(c); }, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: i == store.themeIndex ? Colors.white : Colors.transparent, width: 3)), child: ClipRRect(borderRadius: BorderRadius.circular(13), child: Stack(children: [
          Positioned.fill(child: (u != null && u.isNotEmpty) ? Image.network(u, fit: BoxFit.cover, errorBuilder: (_, __, ___) => DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: th.bg)))) : DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: th.bg)))),
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(.7)])))),
          Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(th.name, style: vaz(10, c: Colors.white, w: FontWeight.w800)))),
        ]))));
      })),
    ])));
  }
}

class IconStudio extends StatefulWidget {
  const IconStudio({super.key});
  @override
  State<IconStudio> createState() => _IconStudioState();
}
class _IconStudioState extends State<IconStudio> {
  final GlobalKey k = GlobalKey();
  Future<void> export() async {
    final b = k.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 1024 / b.size.width);
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = bd!.buffer.asUint8List();
    final d = await getTemporaryDirectory();
    final f = File('${d.path}/sekkeh-icon-1024.png');
    await f.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(f.path)], text: 'آیکون سِکّه — این فایل را با نام assets/logo.png در ریپو بگذار');
  }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: kBg, appBar: AppBar(backgroundColor: kS1, title: Text('استودیوی آیکون', style: vaz(15, w: FontWeight.w900))), body: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 28), children: [
    Center(child: RepaintBoundary(key: k, child: SekkehIcon(size: 220))),
    const SizedBox(height: 18),
    SegmentedButton<int>(segments: const [ButtonSegment(value: 0, label: Text('سکه')), ButtonSegment(value: 1, label: Text('جواهر')), ButtonSegment(value: 2, label: Text('مینیمال'))], selected: {store.iconStyle}, onSelectionChanged: (v) { tap(); store.iconStyle = v.first; store.touch(); setState(() {}); }),
    const SizedBox(height: 14),
    SizedBox(height: 56, child: ListView(scrollDirection: Axis.horizontal, children: List.generate(kThemes.length, (i) => Padding(padding: const EdgeInsets.only(left: 9), child: GestureDetector(onTap: () { tap(); store.iconPal = i; store.touch(); setState(() {}); }, child: Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: kThemes[i].bg), border: Border.all(color: i == store.iconPal ? Colors.white : Colors.transparent, width: 3)))))))),
    const SizedBox(height: 16),
    Row(children: [const SekkehIcon(size: 64), const SizedBox(width: 14), const SekkehIcon(size: 40), const SizedBox(width: 14), const SekkehIcon(size: 28)]),
    const SizedBox(height: 18),
    SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(onPressed: export, style: FilledButton.styleFrom(backgroundColor: kGold, foregroundColor: const Color(0xFF2B2108)), icon: const Icon(Icons.download_rounded), label: Text('خروجی PNG ۱۰۲۴', style: vaz(14, w: FontWeight.w900)))),
    const SizedBox(height: 10),
    Text('این PNG را با نام assets/logo.png در ریپو جایگزین کن تا آیکون خود APK هم عوض شود.', textAlign: TextAlign.center, style: vaz(11, c: kMut)),
  ]));
}

class Support extends StatefulWidget {
  const Support({super.key});
  @override
  State<Support> createState() => _SupportState();
}
class _SupportState extends State<Support> {
  final List<Map<String, dynamic>> msgs = [{'me': false, 't': 'سلام 👋 من سِپیدار هستم. دربارهٔ حواله، کریدت، بل یا کارت کسب‌وکار بپرس.'}];
  final ctrl = TextEditingController();
  String bot(String v) {
    if (v.contains('کارت') || v.contains('کیوآر')) return 'از «کارت من» کیوآر اختصاصی بساز، مربع یا ایستاده، و چاپ کن.';
    if (v.contains('حواله')) return 'حواله بین کیف پول‌ها فوری؛ بانکی از طریق APSS تا ۲ ساعت کاری.';
    if (v.contains('کریدت')) return 'کریدت فوری می‌رسد؛ اگر نرسید شماره و اپراتور را چک کن.';
    if (v.contains('آیکون')) return 'از پروفایل → استودیوی آیکون، PNG بگیر و در ریپو بگذار.';
    return 'یادداشت کردم ✍️ شماره پیگیری را بفرست تا بررسی کنم.';
  }
  void send() { final v = ctrl.text.trim(); if (v.isEmpty) return; tap(); setState(() => msgs.add({'me': true, 't': v})); ctrl.clear(); Future.delayed(const Duration(milliseconds: 800), () { if (mounted) setState(() => msgs.add({'me': false, 't': bot(v)})); }); }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: kBg, appBar: AppBar(backgroundColor: kS1, title: Text('پشتیبانی', style: vaz(16, w: FontWeight.w900))), body: Column(children: [
    Expanded(child: ListView(padding: const EdgeInsets.all(16), children: msgs.map((m) => Align(alignment: (m['me'] as bool) ? Alignment.centerLeft : Alignment.centerRight, child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), constraints: const BoxConstraints(maxWidth: 300), decoration: BoxDecoration(color: (m['me'] as bool) ? store.theme.bg[1] : kS1, borderRadius: BorderRadius.circular(18)), child: Text(m['t'] as String, style: vaz(13, c: (m['me'] as bool) ? Colors.white : kInk))))).toList())),
    Padding(padding: EdgeInsets.fromLTRB(12, 6, 12, MediaQuery.of(context).padding.bottom + 12), child: Row(children: [
      Expanded(child: TextField(controller: ctrl, style: vaz(13), decoration: InputDecoration(hintText: 'پیام…', hintStyle: vaz(12, c: kMut), filled: true, fillColor: kS1, border: OutlineInputBorder(borderRadius: BorderRadius.circular(99))))),
      const SizedBox(width: 8),
      IconButton(onPressed: send, style: IconButton.styleFrom(backgroundColor: store.theme.bg[1]), icon: const Icon(Icons.send_rounded, color: Colors.white)),
    ])),
  ]));
}
// END-OF-PROFILE
