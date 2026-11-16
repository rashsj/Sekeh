import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(const SekkehApp());

const Color kGold = Color(0xFFF4B740);
const Color kGold2 = Color(0xFFFFD782);
const Color kInk = Color(0xFFF1F6FC);
const Color kMut = Color(0xFF9FB2C6);
const Color kBg = Color(0xFF081522);
const Color kS1 = Color(0xFF0F2236);
const Color kMint = Color(0xFF39D39B);

class GemTheme {
  final String id, name, place, wiki;
  final List<Color> bg;
  final Color deep, accent;
  const GemTheme(this.id, this.name, this.place, this.wiki, this.bg, this.deep, this.accent);
}

const List<GemTheme> kThemes = [
  GemTheme('lapis', 'لاجورد • بند امیر', 'بند امیر، بامیان', 'Band-e_Amir_National_Park',
      [Color(0xFF06182E), Color(0xFF0B2A5E), Color(0xFF1D5DBB)], Color(0xFF04101F), Color(0xFFFFD782)),
  GemTheme('ruby', 'لعل • پامیر', 'پامیر، بدخشان', 'Pamir_Mountains',
      [Color(0xFF2A0710), Color(0xFF4A0D22), Color(0xFFC2185B)], Color(0xFF1C040B), Color(0xFFFFD782)),
  GemTheme('emerald', 'زمرد • پنجشیر', 'درهٔ پنجشیر', 'Panjshir_Valley',
      [Color(0xFF03271A), Color(0xFF043523), Color(0xFF0E8F5E)], Color(0xFF02180F), Color(0xFFFFE9B0)),
  GemTheme('sapphire', 'یاقوت • هندوکش', 'هندوکش، کابل', 'Hindu_Kush',
      [Color(0xFF0A0A22), Color(0xFF1E1B6B), Color(0xFF4338CA)], Color(0xFF06061A), Color(0xFFBFE3FF)),
  GemTheme('saffron', 'زعفران • هرات', 'مناره‌های هرات', 'Citadel_of_Herat',
      [Color(0xFF2A1604), Color(0xFF5A2E08), Color(0xFFC2691A)], Color(0xFF1A0E02), Color(0xFFFFD782)),
  GemTheme('turquoise', 'فیروزه • مزار', 'روضهٔ شریف، مزارشریف', 'Shrine_of_Ali',
      [Color(0xFF032A31), Color(0xFF053A44), Color(0xFF0E7C8C)], Color(0xFF02181C), Color(0xFFFFE9B0)),
];

class Tx {
  final String title, cat, method, peer;
  final double amount;
  final DateTime time;
  Tx(this.title, this.cat, this.amount, this.time, [this.method = 'کیف پول', this.peer = '']);
}

class Store extends ChangeNotifier {
  int themeIndex = 0;
  bool hideBalance = false;
  double balance = 22750;
  String bizName = 'فروشگاه احمدی';
  String tagline = 'پرداخت سریع و مطمئن با سِکّه';
  String phone = '0700123456';
  String walletId = 'SEKKEH-0700';
  String format = 'square';
  bool showPhone = true, showWallet = true;
  Uint8List? logoBytes;
  final Map<String, String?> photoUrls = {};
  final List<Tx> txs = [
    Tx('مارکت کارته چهار', 'buy', -1250, DateTime.now().subtract(const Duration(hours: 3))),
    Tx('تاکسی کابل', 'transport', -180, DateTime.now().subtract(const Duration(hours: 6))),
    Tx('دریافت از سمیرا رحیمی', 'transfer', 3000, DateTime.now().subtract(const Duration(hours: 9)), 'کیف پول', '+93 799 ••• 456'),
    Tx('کریدت روشن', 'charge', -100, DateTime.now().subtract(const Duration(days: 1))),
    Tx('چای‌خانه صحت', 'food', -120, DateTime.now().subtract(const Duration(days: 1, hours: 5))),
    Tx('معاش عقرب', 'salary', 24500, DateTime.now().subtract(const Duration(days: 2)), 'حواله APSS'),
    Tx('بل برشنا', 'bill', -850, DateTime.now().subtract(const Duration(days: 2, hours: 4))),
    Tx('حواله به نجیب‌الله نوری', 'transfer', -2000, DateTime.now().subtract(const Duration(days: 3)), 'کیف پول', '+93 728 ••• 233'),
    Tx('بسته انترنت اتصالات', 'net', -499, DateTime.now().subtract(const Duration(days: 4))),
    Tx('هدیه از پدر', 'gift', 5000, DateTime.now().subtract(const Duration(days: 5))),
  ];
  GemTheme get theme => kThemes[themeIndex];
  void touch() => notifyListeners();
}

final Store store = Store();

String faNum(String s) => s.replaceAllMapped(RegExp(r'[0-9]'), (m) => '۰۱۲۳۴۵۶۷۸۹'[int.parse(m.group(0)!)]);
String group(num v) {
  final s = v.abs().round().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('٬');
    b.write(s[i]);
  }
  return b.toString();
}
String money(num v) => '${faNum(group(v))} افغانی';
String localPhone(String p) {
  final d = p.replaceAll(RegExp(r'[^0-9]'), '');
  if (d.length < 10) return p;
  return '${d.substring(0, 4)} ${d.substring(4, 7)} ${d.substring(7)}';
}
String payload() => 'SEKKEH://pay?to=${Uri.encodeComponent(store.phone)}&biz=${Uri.encodeComponent(store.bizName)}';

Future<String?> wikiThumb(String title) async {
  try {
    final u = Uri.parse('https://en.wikipedia.org/w/api.php?action=query&format=json&origin=*&prop=pageimages&piprop=thumbnail&pithumbsize=1400&redirects=1&titles=${Uri.encodeComponent(title)}');
    final r = await http.get(u);
    final m = RegExp(r'"source":"(https:[^"]+)"').firstMatch(r.body);
    return m?.group(1);
  } catch (e) {
    return null;
  }
}

TextStyle vaz(double s, {Color c = kInk, FontWeight w = FontWeight.w500}) => GoogleFonts.vazirmatn(fontSize: s, color: c, fontWeight: w);
TextStyle lalez(double s) => GoogleFonts.lalezar(fontSize: s, color: Colors.white);
TextStyle markazi(double s, Color c) => GoogleFonts.markaziText(fontSize: s, color: c, fontWeight: FontWeight.w600);
TextStyle inter(double s, Color c) => GoogleFonts.inter(fontSize: s, color: c, fontWeight: FontWeight.w700, letterSpacing: 2);

class SekkehApp extends StatelessWidget {
  const SekkehApp({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final t = store.theme;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'سِکّه',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: kBg,
            colorScheme: ColorScheme.dark(primary: t.bg[1], secondary: t.accent, surface: kS1, onSurface: kInk),
            fontFamily: GoogleFonts.vazirmatn().fontFamily,
          ),
          home: const Root(),
        );
      },
    );
  }
}

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int page = 0;
  final pages = const [Home(), TxPage(), CardPage(), Profile()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: page, children: pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 58, height: 58,
        child: FloatingActionButton(
          backgroundColor: kGold, foregroundColor: const Color(0xFF2B2108),
          shape: const CircleBorder(),
          onPressed: () => paySheet(context, 'حوالهٔ سریع', 'transfer'),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: kS1,
        selectedItemColor: store.theme.accent,
        unselectedItemColor: kMut,
        selectedLabelStyle: vaz(10, w: FontWeight.w700),
        unselectedLabelStyle: vaz(10, w: FontWeight.w700),
        currentIndex: page >= 2 ? page + 1 : page,
        onTap: (i) {
          if (i == 2) { paySheet(context, 'حوالهٔ سریع', 'transfer'); return; }
          setState(() => page = i > 2 ? i - 1 : i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'خانه'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'تراکنش‌ها'),
          BottomNavigationBarItem(icon: Icon(Icons.circle, color: Colors.transparent), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_2_rounded), label: 'کارت من'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'پروفایل'),
        ],
      ),
    );
  }
}

void paySheet(BuildContext context, String title, String cat) {
  final ctrl = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: kS1,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (c) => Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(c).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 42, height: 4.5, decoration: BoxDecoration(color: kMut.withOpacity(.4), borderRadius: BorderRadius.circular(99))),
        const SizedBox(height: 14),
        Text(title, style: vaz(17, w: FontWeight.w900)),
        const SizedBox(height: 14),
        TextField(
          controller: ctrl, keyboardType: TextInputType.number, style: vaz(15),
          decoration: InputDecoration(hintText: 'مبلغ (افغانی)', hintStyle: vaz(13, c: kMut), filled: true, fillColor: kBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity, height: 50,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: store.theme.bg[1]),
            onPressed: () {
              final v = double.tryParse(ctrl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
              if (v <= 0 || v > store.balance) {
                ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('مبلغ یا موجودی معتبر نیست')));
                return;
              }
              store.balance -= v;
              store.txs.insert(0, Tx(title, cat, -v, DateTime.now()));
              store.touch();
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title — ${money(v)} انجام شد ✓')));
            },
            child: Text('تایید و پرداخت', style: vaz(15, c: Colors.white, w: FontWeight.w800)),
          ),
        ),
      ]),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Set<String> loading = {};
  void fetchPhoto(GemTheme t) {
    if (store.photoUrls.containsKey(t.id) || loading.contains(t.id)) return;
    loading.add(t.id);
    wikiThumb(t.wiki).then((u) { store.photoUrls[t.id] = u; loading.remove(t.id); store.touch(); });
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final t = store.theme;
        fetchPhoto(t);
        final url = store.photoUrls[t.id];
        return SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 110), children: [
            Row(children: [
              CircleAvatar(radius: 23, backgroundColor: t.bg[1], child: Text('ف', style: vaz(18, c: Colors.white, w: FontWeight.w900))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('سلام، فرید 👋', style: vaz(17, w: FontWeight.w900)),
                Text(t.place, style: vaz(11, c: kMut)),
              ])),
              IconButton(onPressed: () { store.hideBalance = !store.hideBalance; store.touch(); }, icon: Icon(store.hideBalance ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: t.accent)),
            ]),
            const SizedBox(height: 16),
            balanceCard(t, url),
            const SizedBox(height: 16),
            Row(children: [
              qa(Icons.phone_android_rounded, 'کریدت', 'charge'),
              qa(Icons.bolt_rounded, 'بل‌ها', 'bill'),
              qa(Icons.wifi_rounded, 'انترنت', 'net'),
              qa(Icons.storefront_rounded, 'برداشت', 'cashout'),
            ]),
            const SizedBox(height: 22),
            Text('کارت‌های من', style: vaz(15, w: FontWeight.w900)),
            const SizedBox(height: 10),
            SizedBox(height: 170, child: ListView(scrollDirection: Axis.horizontal, children: [
              bankCard('سِکّه کارت', [kGold2, kGold, const Color(0xFFB8791A)], 'Visa', '۰۹/۱۴۰۸', true),
              bankCard('عزیزی بانک', [t.bg[1], t.bg[2]], 'Mastercard', '۰۵/۱۴۰۹', false),
            ])),
            const SizedBox(height: 22),
            Text('تراکنش‌های اخیر', style: vaz(15, w: FontWeight.w900)),
            const SizedBox(height: 6),
            ...store.txs.take(6).map((e) => txTile(context, e)),
          ]),
        );
      },
    );
  }
  Widget qa(IconData ic, String label, String cat) {
    final t = store.theme;
    return Expanded(
      child: GestureDetector(
        onTap: () => paySheet(context, label, cat),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: kS1, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.07))),
          child: Column(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: t.accent.withOpacity(.16), borderRadius: BorderRadius.circular(15)), child: Icon(ic, color: t.accent, size: 22)),
            const SizedBox(height: 8),
            Text(label, style: vaz(11, w: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
  Widget bankCard(String bank, List<Color> g, String net, String exp, bool goldText) {
    final c = goldText ? const Color(0xFF3A2A08) : Colors.white;
    return Container(
      width: 266, margin: const EdgeInsets.only(left: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: g, begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text(bank, style: vaz(13, c: c, w: FontWeight.w900)), const Spacer(), Icon(Icons.contactless_rounded, color: c.withOpacity(.85), size: 20)]),
        const Spacer(),
        Text('•••• •••• •••• ۳۳۶۵', style: inter(15, c)),
        const SizedBox(height: 12),
        Row(children: [Text('فرید احمدزی', style: vaz(10, c: c.withOpacity(.9), w: FontWeight.w700)), const Spacer(), Text('$net • $exp', style: vaz(9, c: c.withOpacity(.75)))]),
      ]),
    );
  }
}

Widget balanceCard(GemTheme t, String? url) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), gradient: LinearGradient(colors: t.bg, begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: t.bg[1].withOpacity(.5), blurRadius: 30, offset: const Offset(0, 14))]),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Stack(children: [
        if (url != null) Positioned.fill(child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox())),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [t.deep.withOpacity(.55), t.deep.withOpacity(.3), t.deep.withOpacity(.75)])))),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('موجودی کیف پول', style: vaz(12.5, c: Colors.white.withOpacity(.92))),
          const SizedBox(height: 8),
          Row(children: [
            Text(store.hideBalance ? '••••••' : faNum(group(store.balance)), style: vaz(33, c: Colors.white, w: FontWeight.w900)),
            const SizedBox(width: 7),
            Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('افغانی', style: vaz(13, c: Colors.white.withOpacity(.85)))),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: t.accent, border: Border.all(color: Colors.white.withOpacity(.6)))),
            const SizedBox(width: 6),
            Text(t.name, style: vaz(10, c: Colors.white.withOpacity(.92), w: FontWeight.w700)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: glassBtn(Icons.add_rounded, 'شارژ کیف پول', 'topup')),
            const SizedBox(width: 10),
            Expanded(child: glassBtn(Icons.send_rounded, 'حواله پول', 'transfer')),
          ]),
        ]),
      ]),
    ),
  );
}

Widget glassBtn(IconData ic, String label, String cat) => Builder(builder: (context) {
  return GestureDetector(
    onTap: () => paySheet(context, label, cat),
    child: Container(
      height: 44,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), gradient: LinearGradient(colors: [store.theme.bg[1], store.theme.bg[2]]), border: Border.all(color: Colors.white.withOpacity(.25))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ic, size: 17, color: Colors.white), const SizedBox(width: 7), Text(label, style: vaz(12.5, c: Colors.white, w: FontWeight.w800))]),
    ),
  );
});

Widget txTile(BuildContext context, Tx tx) {
  final pos = tx.amount > 0;
  final c = pos ? kMint : store.theme.accent;
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    leading: Container(width: 43, height: 43, decoration: BoxDecoration(color: c.withOpacity(.15), borderRadius: BorderRadius.circular(15)), child: Icon(pos ? Icons.south_west_rounded : Icons.north_east_rounded, color: c, size: 20)),
    title: Text(tx.title, style: vaz(13.5, w: FontWeight.w700)),
    subtitle: Text('${tx.method} • ${faNum(tx.time.hour.toString().padLeft(2, '0'))}:${faNum(tx.time.minute.toString().padLeft(2, '0'))}', style: vaz(11, c: kMut)),
    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text('${pos ? '+' : '−'} ${faNum(group(tx.amount))}', style: vaz(13.5, c: pos ? kMint : kInk, w: FontWeight.w900)),
      Text('افغانی', style: vaz(9, c: kMut)),
    ]),
    onTap: () => showModalBottomSheet(
      context: context, backgroundColor: kS1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (c2) => Padding(padding: const EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(tx.title, style: vaz(16, w: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('${pos ? '+' : '−'} ${money(tx.amount.abs())}', style: vaz(26, c: pos ? kMint : kGold, w: FontWeight.w900)),
        const SizedBox(height: 12),
        Text('منبع: ${tx.method}', style: vaz(12, c: kMut)),
        if (tx.peer.isNotEmpty) Text('طرف: ${tx.peer}', style: vaz(12, c: kMut)),
        const SizedBox(height: 18),
        SizedBox(width: double.infinity, height: 46, child: OutlinedButton(onPressed: () => Navigator.pop(c2), child: Text('بستن', style: vaz(14, w: FontWeight.w800)))),
      ])),
    ),
  );
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
    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 6), child: Align(alignment: Alignment.centerRight, child: Text('تراکنش‌ها', style: vaz(24, w: FontWeight.w900)))),
      Paddi
