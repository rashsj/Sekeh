part of 'main.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) {
    final t = store.theme;
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 110), children: [
      Center(child: Column(children: [
        CircleAvatar(radius: 44, backgroundColor: t.bg[1], child: Text('ف', style: vaz(30, c: Colors.white, w: FontWeight.w900))),
        const SizedBox(height: 10),
        Text('فرید احمدزی', style: vaz(19, w: FontWeight.w900)),
        Text('+93 700 123 456', style: inter(12, kMut)),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [kGold2, kGold]), borderRadius: BorderRadius.circular(99)), child: Text('تایید شده با تذکره', style: vaz(10.5, c: const Color(0xFF2B2108), w: FontWeight.w900))),
      ])),
      const SizedBox(height: 22),
      row(Icons.palette_rounded, kGold, 'تم‌ها', t.name, () => themeSheet(context)),
      row(Icons.support_agent_rounded, const Color(0xFF4CC9F0), 'پشتیبانی', 'گفت‌وگو با سِپیدار', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Support()))),
      row(Icons.info_rounded, kGold, 'درباره سِکّه', 'نسخهٔ ۳٫۳٫۰ • Beheshti Brothers', () => showDialog(context: context, builder: (c) => AlertDialog(
        backgroundColor: kS1,
        title: Text('سِکّه افغانستان', style: vaz(16, w: FontWeight.w900)),
        content: Text('طراحی و توسعه: Beheshti Brothers\nتیم افغان‌های مقیم ایران\nهمکاری ماهانه (ارجح) یا پروژه‌ای\nاستقرار on-prem در دیتاسنتر بانک', style: vaz(13, c: kMut)),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text('بستن', style: vaz(13, c: t.accent, w: FontWeight.w800)))],
      ))),
    ]));
  }
  Widget row(IconData ic, Color c, String title, String sub, VoidCallback onTap) => ListTile(
    onTap: onTap,
    leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withOpacity(.15), borderRadius: BorderRadius.circular(12)), child: Icon(ic, color: c, size: 20)),
    title: Text(title, style: vaz(14, w: FontWeight.w800)),
    subtitle: Text(sub, style: vaz(11, c: kMut)),
    trailing: const Icon(Icons.chevron_left_rounded, color: kMut, size: 20),
  );
  void themeSheet(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: kS1, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))), builder: (c) => Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(spacing: 10, runSpacing: 10, children: List.generate(kThemes.length, (i) => GestureDetector(
        onTap: () { store.themeIndex = i; store.touch(); Navigator.pop(c); },
        child: Container(width: 104, height: 76, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: kThemes[i].bg), border: Border.all(color: i == store.themeIndex ? Colors.white : Colors.transparent, width: 3)), child: Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(kThemes[i].name, textAlign: TextAlign.center, style: vaz(9.5, c: Colors.white, w: FontWeight.w800))))),
      ))),
    ));
  }
}

class Support extends StatefulWidget {
  const Support({super.key});
  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  final List<Map<String, dynamic>> msgs = [
    {'me': false, 't': 'سلام 👋 من سِپیدار هستم. دربارهٔ حواله، کریدت، بل یا کارت کسب‌وکار بپرس.'}
  ];
  final ctrl = TextEditingController();
  String bot(String v) {
    if (v.contains('کارت') || v.contains('کیوآر')) return 'از تب «کارت من» کیوآر اختصاصی بساز، اسم کسب‌وکار را بنویس و چاپ کن.';
    if (v.contains('حواله')) return 'حواله بین کیف پول‌ها فوری است؛ حواله بانکی از طریق APSS تا ۲ ساعت کاری.';
    if (v.contains('کریدت')) return 'کریدت معمولاً فوری می‌رسد؛ اگر نرسید شماره و اپراتور را چک کن.';
    return 'یادداشت کردم ✍️ شماره پیگیری را بفرست تا بررسی کنم.';
  }
  void send() {
    final v = ctrl.text.trim();
    if (v.isEmpty) return;
    setState(() => msgs.add({'me': true, 't': v}));
    ctrl.clear();
    Future.delayed(const Duration(milliseconds: 800), () { if (mounted) setState(() => msgs.add({'me': false, 't': bot(v)})); });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(backgroundColor: kS1, title: Text('پشتیبانی', style: vaz(16, w: FontWeight.w900))),
      body: Column(children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: msgs.map((m) => Align(
          alignment: (m['me'] as bool) ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), decoration: BoxDecoration(color: (m['me'] as bool) ? store.theme.bg[1] : kS1, borderRadius: BorderRadius.circular(18)), child: Text(m['t'] as String, style: vaz(13, c: (m['me'] as bool) ? Colors.white : kInk))),
        )).toList())),
        Padding(padding: const EdgeInsets.fromLTRB(12, 6, 12, 18), child: Row(children: [
          Expanded(child: TextField(controller: ctrl, style: vaz(13), decoration: InputDecoration(hintText: 'پیام…', hintStyle: vaz(12, c: kMut), filled: true, fillColor: kS1, border: OutlineInputBorder(borderRadius: BorderRadius.circular(99))))),
          const SizedBox(width: 8),
          IconButton(onPressed: send, style: IconButton.styleFrom(backgroundColor: store.theme.bg[1]), icon: const Icon(Icons.send_rounded, color: Colors.white)),
        ])),
      ]),
    );
  }
}
// END-OF-PROFILE
