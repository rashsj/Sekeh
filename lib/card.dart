part of 'main.dart';

class CardView extends StatelessWidget {
  final String? photoUrl;
  const CardView({super.key, this.photoUrl});
  @override
  Widget build(BuildContext context) {
    final t = store.theme;
    final standee = store.format == 'standee';
    final H = standee ? 1419.0 : 1000.0;
    final qrS = standee ? 620.0 : 470.0;
    final qrX = (1000 - qrS) / 2;
    final qrY = standee ? 214.0 : 178.0;
    final medY = standee ? 70.0 : 60.0;
    final medR = standee ? 54.0 : 44.0;
    final nameY = standee ? 880.0 : 690.0;
    final divY = standee ? 985.0 : 772.0;
    final tagY = standee ? 1015.0 : 800.0;
    final phY = standee ? 1085.0 : 850.0;
    final walY = standee ? 1155.0 : 900.0;
    final ctaY = standee ? 1255.0 : 940.0;

    Widget centered(double y, Widget child) => Positioned(top: y, left: 30, right: 30, child: Center(child: child));

    return AspectRatio(
      aspectRatio: 1000 / H,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: 1000, height: H,
          child: Stack(children: [
            Positioned.fill(child: photoUrl != null
                ? Image.network(photoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: t.bg))))
                : DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: t.bg, begin: Alignment.topLeft, end: Alignment.bottomRight)))),
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [t.deep.withOpacity(.5), t.deep.withOpacity(.34), t.deep.withOpacity(.76)])))),
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(radius: .78, colors: [Colors.transparent, Colors.black.withOpacity(.45)], stops: [.55, 1])))),
            Positioned.fill(child: Padding(padding: const EdgeInsets.all(26), child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(36), border: Border.all(color: kGold, width: 2.2))))),
            Positioned.fill(child: Padding(padding: const EdgeInsets.all(35), child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(29), border: Border.all(color: kGold.withOpacity(.5), width: .9))))),
            for (final p in [[20.0, 20.0], [968.0, 20.0], [20.0, H - 32], [968.0, H - 32]])
              Positioned(left: p[0], top: p[1], child: Transform.rotate(angle: .785, child: Container(width: 12, height: 12, color: kGold))),
            centered(medY, medallion(medR)),
            Positioned(left: qrX, top: qrY, child: qrPanel(qrS)),
            centered(nameY, ShaderMask(shaderCallback: (r) => const LinearGradient(colors: [kGold2, kGold], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(r), child: Text(store.bizName, textAlign: TextAlign.center, style: lalez(standee ? 74 : 58)))),
            centered(divY, divider(standee ? 360 : 300)),
            if (store.tagline.isNotEmpty) centered(tagY, Text(store.tagline, textAlign: TextAlign.center, style: markazi(standee ? 36 : 30, Colors.white.withOpacity(.9)))),
            if (store.showPhone) centered(phY, Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 70, height: 1.5, color: kGold),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text(localPhone(store.phone), style: inter(standee ? 40 : 30, Colors.white))),
              Container(width: 70, height: 1.5, color: kGold),
            ])),
            if (store.showWallet) centered(walY, Text(store.walletId, style: inter(standee ? 26 : 20, Colors.white.withOpacity(.8)))),
            centered(ctaY, Text('اسکن کنید و مستقیم پول بفرستید', textAlign: TextAlign.center, style: vaz(standee ? 33 : 23, c: t.accent, w: FontWeight.w800))),
            if (standee) centered(1330, Text('سِکّه • کیف پول دیجیتال افغانستان', style: markazi(22, Colors.white.withOpacity(.8)))),
          ]),
        ),
      ),
    );
  }
  Widget medallion(double r) {
    final inner = store.logoBytes != null
        ? Image.memory(store.logoBytes!, width: r * 2, height: r * 2, fit: BoxFit.cover)
        : Container(width: r * 2, height: r * 2, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [kGold2, kGold])), child: Center(child: Text('سکه', style: GoogleFonts.lalezar(fontSize: r * .8, color: const Color(0xFF6B4708)))));
    return Container(
      width: r * 2 + 16, height: r * 2 + 16,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kGold, width: 4)),
      child: ClipOval(child: inner),
    );
  }
  Widget qrPanel(double s) {
    return Container(
      width: s, height: s,
      decoration: BoxDecoration(color: const Color(0xFFFFFDF6), borderRadius: BorderRadius.circular(42), border: Border.all(color: kGold, width: 2)),
      child: Stack(children: [
        Padding(padding: const EdgeInsets.all(30), child: QrImageView(data: payload(), version: QrVersions.auto, size: s - 60, errorCorrectionLevel: QrErrorCorrectLevel.H, backgroundColor: const Color(0xFFFFFDF6))),
        Center(child: Container(
          width: s * .23, height: s * .23,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: kGold, width: 3)),
          child: ClipOval(child: store.logoBytes != null
              ? Image.memory(store.logoBytes!, fit: BoxFit.cover)
              : Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [kGold2, kGold])), child: Center(child: Text('سکه', style: GoogleFonts.lalezar(fontSize: s * .075, color: const Color(0xFF6B4708)))))),
        )),
      ]),
    );
  }
  Widget divider(double w) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: w / 2 - 30, height: 1.6, color: kGold),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Transform.rotate(angle: .785, child: Container(width: 14, height: 14, color: kGold))),
    Container(width: w / 2 - 30, height: 1.6, color: kGold),
  ]);
}

class CardPage extends StatefulWidget {
  const CardPage({super.key});
  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final GlobalKey boundary = GlobalKey();
  late TextEditingController nameC, tagC, phoneC, walC;
  String? url;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: store.bizName);
    tagC = TextEditingController(text: store.tagline);
    phoneC = TextEditingController(text: store.phone);
    walC = TextEditingController(text: store.walletId);
    loadPhoto();
  }
  Future<void> loadPhoto() async {
    final t = store.theme;
    final u = store.photoUrls.containsKey(t.id) ? store.photoUrls[t.id] : await wikiThumb(t.wiki);
    store.photoUrls[t.id] = u;
    if (mounted) setState(() => url = u);
  }
  Future<Uint8List> png() async {
    final b = boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 1600 / b.size.width);
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    return bd!.buffer.asUint8List();
  }
  Future<void> save() async {
    setState(() => busy = true);
    try {
      final bytes = await png();
      final d = await getApplicationDocumentsDirectory();
      final f = File('${d.path}/sekkeh-${store.format}.png');
      await f.writeAsBytes(bytes);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ذخیره شد: ${f.path}')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در ذخیره')));
    }
    if (mounted) setState(() => busy = false);
  }
  Future<void> share() async {
    final bytes = await png();
    final d = await getTemporaryDirectory();
    final f = File('${d.path}/sekkeh-card.png');
    await f.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(f.path)], text: 'کارت کسب‌وکار سِکّه — ${store.bizName}');
  }
  Future<void> printCard() async {
    final bytes = await png();
    final w = store.format == 'standee' ? 148.0 : 120.0;
    final h = store.format == 'standee' ? 210.0 : 120.0;
    await Printing.layoutPdf(onLayout: (f) async {
      final doc = pw.Document();
      doc.addPage(pw.Page(pageFormat: PdfPageFormat(w * PdfPageFormat.mm, h * PdfPageFormat.mm), build: (c) => pw.Center(child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain))));
      return doc.save();
    });
  }
  Future<void> pickLogo() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (x == null) return;
    store.logoBytes = await x.readAsBytes();
    store.touch();
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final t = store.theme;
        return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 110), children: [
          Text('کارت کسب‌وکار و کیوآر', style: vaz(22, w: FontWeight.w900)),
          Text('مربع برای استند کوچک • ایستاده A5 برای استند رومیزی', style: vaz(11.5, c: kMut)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kS1, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(.08))),
            child: RepaintBoundary(key: boundary, child: CardView(photoUrl: url)),
          ),
          if (busy) const Padding(padding: EdgeInsets.all(10), child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)))),
          const SizedBox(height: 14),
          SegmentedButton<String>(
            segments: const [ButtonSegment(value: 'square', label: Text('مربع')), ButtonSegment(value: 'standee', label: Text('ایستاده'))],
            selected: {store.format},
            onSelectionChanged: (v) { store.format = v.first; store.touch(); setState(() {}); },
          ),
          const SizedBox(height: 12),
          SizedBox(height: 54, child: ListView(scrollDirection: Axis.horizontal, children: List.generate(kThemes.length, (i) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () { store.themeIndex = i; store.touch(); loadPhoto(); },
              child: Container(width: 54, height: 54, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: kThemes[i].bg), border: Border.all(color: i == store.themeIndex ? Colors.white : Colors.transparent, width: 3))),
            ),
          )))),
          const SizedBox(height: 14),
          field('نام کسب‌وکار', nameC, (v) { store.bizName = v; store.touch(); }),
          field('شعار', tagC, (v) { store.tagline = v; store.touch(); }),
          field('شمارهٔ کیف پول', phoneC, (v) { store.phone = v; store.touch(); }, ltr: true),
          field('شناسهٔ کیف پول', walC, (v) { store.walletId = v; store.touch(); }, ltr: true),
          Row(children: [
            Expanded(child: SwitchListTile(value: store.showPhone, onChanged: (v) { store.showPhone = v; store.touch(); }, title: Text('نمایش شماره', style: vaz(12)), activeColor: t.accent, contentPadding: EdgeInsets.zero)),
            Expanded(child: SwitchListTile(value: store.showWallet, onChanged: (v) { store.showWallet = v; store.touch(); }, title: Text('نمایش شناسه', style: vaz(12)), activeColor: t.accent, contentPadding: EdgeInsets.zero)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: pickLogo, icon: const Icon(Icons.image_rounded, size: 18), label: Text('لوگو', style: vaz(13, w: FontWeight.w800)))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton.icon(onPressed: printCard, style: FilledButton.styleFrom(backgroundColor: kGold, foregroundColor: const Color(0xFF2B2108)), icon: const Icon(Icons.print_rounded, size: 18), label: Text('چاپ', style: vaz(13, w: FontWeight.w800)))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: FilledButton.icon(onPressed: save, style: FilledButton.styleFrom(backgroundColor: t.bg[1]), icon: const Icon(Icons.download_rounded, size: 18), label: Text('ذخیره عکس', style: vaz(13, c: Colors.white, w: FontWeight.w800)))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: share, icon: const Icon(Icons.share_rounded, size: 18), label: Text('اشتراک', style: vaz(13, w: FontWeight.w800)))),
          ]),
        ]));
      },
    );
  }
  Widget field(String label, TextEditingController c, Function(String) set, {bool ltr = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: vaz(11.5, c: kMut, w: FontWeight.w800)),
      const SizedBox(height: 5),
      TextField(controller: c, onChanged: set, textDirection: ltr ? TextDirection.ltr : TextDirection.rtl, style: vaz(13), decoration: InputDecoration(filled: true, fillColor: kS1, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    ]),
  );
}
// END-OF-CARD
