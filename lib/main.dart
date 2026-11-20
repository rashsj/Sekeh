import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

part 'widgets.dart';
part 'home.dart';
part 'flows.dart';
part 'card.dart';
part 'profile.dart';

const String kBuildTag = String.fromEnvironment('BUILD_TAG', defaultValue: 'dev');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (d) => Container(color: const Color(0xFF8B1D1D), padding: const EdgeInsets.all(6), alignment: Alignment.center, child: Text(d.exceptionAsString(), textDirection: TextDirection.ltr, style: const TextStyle(color: Colors.white, fontSize: 10)));
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarColor: Color(0xFF141B3C), systemNavigationBarIconBrightness: Brightness.light));
  runApp(const SekkehApp());
}

const Color kGold = Color(0xFFF5B93E), kGold2 = Color(0xFFFFDD93), kInk = Color(0xFFF2F5FF), kMut = Color(0xFFA3ADD4);
const Color kBg = Color(0xFF0B1026), kS1 = Color(0xFF141B3C), kS2 = Color(0xFF1D2650), kS3 = Color(0xFF2A3568);
const Color kMint = Color(0xFF3ED9A0), kCoral = Color(0xFFFF6B81), kCyan = Color(0xFF2DD4BF), kViolet = Color(0xFF8B7CFF), kAmber = Color(0xFFFFB84D);

class GemTheme {
  final String id, name, place, wiki;
  final List<Color> bg;
  final Color deep, accent;
  const GemTheme(this.id, this.name, this.place, this.wiki, this.bg, this.deep, this.accent);
}

const List<GemTheme> kThemes = [
  GemTheme('lapis', 'لاجورد • بند امیر', 'بند امیر، بامیان', 'Band-e_Amir_National_Park', [Color(0xFF0B1B4D), Color(0xFF4F46E5), Color(0xFF2DD4BF)], Color(0xFF070F2E), Color(0xFFFFDD93)),
  GemTheme('ruby', 'لعل • پامیر', 'پامیر، بدخشان', 'Pamir_Mountains', [Color(0xFF2A0714), Color(0xFFC2185B), Color(0xFFFF7A9C)], Color(0xFF1A040C), Color(0xFFFFDD93)),
  GemTheme('emerald', 'زمرد • پنجشیر', 'درهٔ پنجشیر', 'Panjshir_Valley', [Color(0xFF03271A), Color(0xFF0E8F5E), Color(0xFF5BE3A8)], Color(0xFF02180F), Color(0xFFFFE9B0)),
  GemTheme('sapphire', 'یاقوت • هندوکش', 'هندوکش، کابل', 'Hindu_Kush', [Color(0xFF0A0A22), Color(0xFF4338CA), Color(0xFF818CF8)], Color(0xFF06061A), Color(0xFFBFE3FF)),
  GemTheme('saffron', 'زعفران • هرات', 'مناره‌های هرات', 'Citadel_of_Herat', [Color(0xFF2A1604), Color(0xFFC2691A), Color(0xFFFFC46B)], Color(0xFF1A0E02), Color(0xFFFFDD93)),
  GemTheme('turquoise', 'فیروزه • مزار', 'روضهٔ شریف، مزارشریف', 'Shrine_of_Ali', [Color(0xFF032A31), Color(0xFF0E7C8C), Color(0xFF4FD8E8)], Color(0xFF02181C), Color(0xFFFFE9B0)),
];

class Tx {
  final String title, cat, method, peer, ref;
  final double amount;
  final DateTime time;
  String status;
  Tx(this.title, this.cat, this.amount, this.time, [this.method = 'کیف پول', this.peer = '']) : ref = 'AF${DateTime.now().microsecondsSinceEpoch % 1000000000}', status = 'ok';
}

class Notif {
  final IconData icon; final Color color; final String title, body; final DateTime time; bool read;
  Notif(this.icon, this.color, this.title, this.body, this.time, [this.read = false]);
}

class Store extends ChangeNotifier {
  int themeIndex = 0, iconStyle = 0, iconPal = 0;
  double balance = 22750;
  bool hideBalance = false, locked = false, sound = true, mascotOn = true;
  String pin = '1234', bizName = 'فروشگاه احمدی', tagline = 'پرداخت سریع و مطمئن با سِکّه';
  String phone = '0700123456', walletId = 'SEKKEH-0700', format = 'square';
  bool showPhone = true, showWallet = true;
  Uint8List? logoBytes;
  final Map<String, String?> photoUrls = {};
  final Set<String> loading = {};
  Map<String, dynamic>? cashout;
  final List<Notif> notifs = [
    Notif(Icons.work_rounded, kMint, 'معاش عقرب واریز شد', '۲۴٬۵۰۰ افغانی از طریق APSS', DateTime.now().subtract(const Duration(days: 2))),
    Notif(Icons.shield_rounded, kCyan, 'ورود به حساب', 'ورود موفق — کابل', DateTime.now().subtract(const Duration(hours: 6))),
    Notif(Icons.qr_code_2_rounded, kGold, 'کارت کسب‌وکار فعال شد', 'کیوآر اختصاصی بساز و چاپ کن', DateTime.now().subtract(const Duration(days: 1))),
  ];
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
  int get unread => notifs.where((n) => !n.read).length;
  void touch() => notifyListeners();
  void ensurePhoto(GemTheme t) {
    if (photoUrls.containsKey(t.id) || loading.contains(t.id)) return;
    loading.add(t.id);
    wikiThumb(t.wiki).then((u) { photoUrls[t.id] = u; loading.remove(t.id); touch(); });
  }
}

final Store store = Store();
final ValueNotifier<Offset> pointer = ValueNotifier<Offset>(const Offset(-999, -999));
final GlobalKey mascotKey = GlobalKey();

void tap() { if (store.sound) SystemSound.play(SystemSoundType.click); HapticFeedback.selectionClick(); }
void okBuzz() { if (store.sound) SystemSound.play(SystemSoundType.click); HapticFeedback.mediumImpact(); }

String faNum(String s) => s.replaceAllMapped(RegExp(r'[0-9]'), (m) => '۰۱۲۳۴۵۶۷۸۹'[int.parse(m.group(0)!)]);
String group(num v) { final s = v.abs().round().toString(); final b = StringBuffer(); for (int i = 0; i < s.length; i++) { if (i > 0 && (s.length - i) % 3 == 0) b.write('٬'); b.write(s[i]); } return b.toString(); }
String money(num v) => '${faNum(group(v))} افغانی';
String localPhone(String p) { final d = p.replaceAll(RegExp(r'[^0-9]'), ''); if (d.length < 10) return p; return '${d.substring(0, 4)} ${d.substring(4, 7)} ${d.substring(7)}'; }
String payload() => 'SEKKEH://pay?to=${Uri.encodeComponent(store.phone)}&biz=${Uri.encodeComponent(store.bizName)}';

Future<String?> wikiThumb(String title) async {
  try {
    final u = Uri.parse('https://en.wikipedia.org/w/api.php?action=query&format=json&origin=*&prop=pageimages&piprop=thumbnail&pithumbsize=1200&redirects=1&titles=${Uri.encodeComponent(title)}');
    final r = await http.get(u);
    return RegExp(r'"source":"(https:[^"]+)"').firstMatch(r.body)?.group(1);
  } catch (e) { return null; }
}

TextStyle vaz(double s, {Color c = kInk, FontWeight w = FontWeight.w500}) => GoogleFonts.vazirmatn(fontSize: s, color: c, fontWeight: w);
TextStyle lalez(double s, {Color c = Colors.white}) => GoogleFonts.lalezar(fontSize: s, color: c);
TextStyle markazi(double s, Color c) => GoogleFonts.markaziText(fontSize: s, color: c, fontWeight: FontWeight.w600);
TextStyle inter(double s, Color c) => GoogleFonts.inter(fontSize: s, color: c, fontWeight: FontWeight.w700, letterSpacing: 2);

class SekkehApp extends StatelessWidget {
  const SekkehApp({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: store, builder: (context, _) {
    final t = store.theme;
    return MaterialApp(
      debugShowCheckedModeBanner: false, title: 'سِکّه',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark, scaffoldBackgroundColor: kBg, colorScheme: ColorScheme.dark(primary: t.bg[1], secondary: t.accent, surface: kS1, onSurface: kInk), fontFamily: GoogleFonts.vazirmatn().fontFamily),
      home: const Gate(),
    );
  });
}

class Gate extends StatefulWidget {
  const Gate({super.key});
  @override
  State<Gate> createState() => _GateState();
}
class _GateState extends State<Gate> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  bool done = false;
  @override
  void initState() { super.initState(); Timer(const Duration(milliseconds: 2000), () { if (mounted) setState(() => done = true); }); }
  @override
  void dispose() { c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (done) return store.locked ? const Lock() : const Root();
    final mq = MediaQuery.of(context);
    return Scaffold(backgroundColor: kBg, body: SizedBox(width: mq.size.width, height: mq.size.height, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ScaleTransition(scale: CurvedAnimation(parent: c, curve: Curves.elasticOut), child: const SekkehIcon(size: 112)),
      const SizedBox(height: 20),
      FadeTransition(opacity: c, child: Text('سِکّه', style: lalez(40, c: kGold))),
      const SizedBox(height: 4),
      FadeTransition(opacity: c, child: Text('کیف پول دیجیتال افغانستان', style: vaz(13, c: kMut))),
      const SizedBox(height: 6),
      FadeTransition(opacity: c, child: Text('Beheshti Brothers', style: inter(11, kMut))),
      const SizedBox(height: 24),
      const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: kGold)),
      const SizedBox(height: 14),
      Text('build $kBuildTag', style: inter(9, kMut.withOpacity(.6))),
    ]))));
  }
}

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}
class _RootState extends State<Root> {
  int page = 0;
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final t = store.theme;
    store.ensurePhoto(t);
    final url = store.photoUrls[t.id];
    final has = url != null && url.isNotEmpty;
    final pages = <Widget>[const Home(), const TxPage(), const CardPage(), const Profile()];
    return Scaffold(
      backgroundColor: kBg,
      body: SizedBox(
        width: mq.size.width, height: mq.size.height,
        child: Column(children: [
          Expanded(
            child: Listener(
              onPointerDown: (e) { pointer.value = e.position; },
              onPointerMove: (e) { pointer.value = e.position; },
              child: Stack(children: [
                Positioned.fill(child: DecoratedBox(
                  decoration: BoxDecoration(color: kBg,
                    image: has ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover, opacity: .18, onError: (_, __) {}) : null,
                    gradient: has ? null : LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [t.bg[0], kBg])),
                  child: IndexedStack(index: page, children: pages),
                )),
                if (store.mascotOn && page == 0)
                  Positioned(top: 0, left: 14, child: IgnorePointer(child: Mascot(key: mascotKey))),
              ]),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: kS1, border: Border(top: BorderSide(color: Colors.white.withOpacity(.08)))),
            padding: EdgeInsets.fromLTRB(6, 8, 6, mq.padding.bottom + 10),
            child: Row(children: [
              navItem(0, Icons.home_rounded, 'خانه'),
              navItem(1, Icons.receipt_long_rounded, 'تراکنش‌ها'),
              Expanded(child: Center(child: GemFab(onTap: () { tap(); quickMenu(context); }))),
              navItem(2, Icons.qr_code_2_rounded, 'کارت من'),
              navItem(3, Icons.person_rounded, 'پروفایل'),
            ]),
          ),
        ]),
      ),
    );
  }
  Widget navItem(int i, IconData ic, String label) {
    final on = page == i; final t = store.theme;
    return Expanded(child: InkWell(onTap: () { tap(); setState(() => page = i); }, borderRadius: BorderRadius.circular(14), child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(ic, size: 23, color: on ? t.accent : kMut), const SizedBox(height: 3),
      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: vaz(9.5, c: on ? t.accent : kMut, w: FontWeight.w700)),
      const SizedBox(height: 3),
      Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: on ? t.accent : Colors.transparent)),
    ]))));
  }
}

class Lock extends StatefulWidget {
  const Lock({super.key});
  @override
  State<Lock> createState() => _LockState();
}
class _LockState extends State<Lock> {
  String buf = ''; bool err = false;
  void key(String k) {
    tap();
    setState(() { if (k == 'del') { if (buf.isNotEmpty) buf = buf.substring(0, buf.length - 1); } else if (buf.length < 4) buf += k; });
    if (buf.length == 4) Timer(const Duration(milliseconds: 160), () {
      if (buf == store.pin) { okBuzz(); store.locked = false; store.touch(); }
      else { setState(() { err = true; buf = ''; }); Timer(const Duration(milliseconds: 600), () { if (mounted) setState(() => err = false); }); }
    });
  }
  @override
  Widget build(BuildContext context) {
    final t = store.theme; final mq = MediaQuery.of(context);
    return Scaffold(backgroundColor: kBg, body: SizedBox(width: mq.size.width, height: mq.size.height, child: SafeArea(child: Center(child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SekkehIcon(size: 64), const SizedBox(height: 14),
      Text('فرید احمدزی', style: vaz(17, w: FontWeight.w900)), const SizedBox(height: 4),
      Text('رمز ۴ رقمی را وارد کنید', style: vaz(12, c: kMut)), const SizedBox(height: 18),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 15, height: 15, decoration: BoxDecoration(shape: BoxShape.circle, color: i < buf.length ? t.accent : Colors.transparent, border: Border.all(color: err ? kCoral : kMut, width: 2))))),
      const SizedBox(height: 8),
      SizedBox(height: 20, child: Text(err ? 'رمز اشتباه است' : '', style: vaz(12, c: kCoral, w: FontWeight.w700))),
      SizedBox(width: 262, child: Keypad(onKey: key, round: true)),
      const SizedBox(height: 12),
      Text('رمز پیش‌فرض: ۱۲۳۴', style: vaz(10.5, c: kMut)),
    ]))))));
  }
}
// END-OF-MAIN
