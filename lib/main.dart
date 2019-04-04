import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  return runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Page()));
  }
}

class Page extends StatefulWidget {
  @override
  _St createState() => _St();
}

class _St extends State<Page> {
  List<Offset> p = [];
  var n = 'aries', st, da, _w, _h;
  Offset o;
  List<List<double>> s = [];
  List l = [];
  Set set = Set();

  @override
  void initState() {
    super.initState();
    _w = MediaQueryData.fromWindow(ui.window).size.width;
    _h = MediaQueryData.fromWindow(ui.window).size.height;

    _loadImg('img/star.png').then((s) {
      st = s;
    }).whenComplete(() {
      if (this.mounted) setState(() {});
    });

    _loadAst().then((v) {
      da = json.decode(v);
      setData("0");
    });
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
        body: Stack(children: <Widget>[
          Image.asset('img/bg.jpg', width: _w, fit: BoxFit.fill),
          Container(child: CustomPaint(painter: StarCanvas(_w, _h, p, s, st))),
          wid(1, 2),
          wid(1, 1),
          wid(0, 1),
          GestureDetector(onPanDown: (d) {
            p.add(Offset(d.globalPosition.dx, d.globalPosition.dy));
            setState(() {});
          }, onPanUpdate: (d) {
            o = Offset(d.globalPosition.dx, d.globalPosition.dy);
          }, onPanEnd: (d) {
            p.add(o);
            setState(() {});

            double sz, ez;
            for (int i = 0; i < p.length - 1; i += 2) {
              if (p[i] != null && p[i + 1] != null) {
                bool st = false, en = false;
                double w, h;
                for (int j = 0; j < s.length; j++) {
                  w = s[j][0] * _w;
                  h = s[j][1] * _h;

                  if ((p[i].dx - w).abs() <= 20 && (p[i].dy - h).abs() <= 20) {
                    p[i] = Offset(w, h);
                    sz = s[j][2];
                    st = true;
                  }
                  if ((p[i + 1].dx - w).abs() <= 20 &&
                      (p[i + 1].dy - h).abs() <= 20) {
                    p[i + 1] = Offset(w, h);
                    ez = s[j][2];
                    en = true;
                  }
                }
                if (!st) p[i] = null;
                if (!en) p[i + 1] = null;
              }

              if (p[i] != null && p[i + 1] != null && p[i] != p[i + 1])
                set..add('${sz}|${ez}')..add('${ez}|${sz}');
            }
            int n = 0;
            if (set.length == l.length) {
              for (String e in set) {
                for (int i = 0; i < l.length; i++) if (e == l[i]) n += 1;
              }
            }
            if (n > 0 && n == l.length)
              Scaffold.of(c)
                  .showSnackBar(SnackBar(content: Text(da['tip'].toString())));
          })
        ]));
  }

  Widget wid(l, b) {
    return Container(
        alignment: Alignment(l == 0 ? -1.0 : 1.0, 1.0),
        margin: EdgeInsets.fromLTRB(32, 0, 32, 32.0 + 84 * (b - 1)),
        child: GestureDetector(
            child: Container(
                width: 24,
                child: Image.asset(
                    'img/${l == 0 ? n : (b == 1 ? 'reset' : 'ram')}.png')),
            onTap: () {
              if (b == 2) setData(Random().nextInt(12).toString());
              p.clear();
              set.clear();
              setState(() {});
            }));
  }

  setData(r) {
    Map map = (da['ran'] as List).cast()[0][r];
    n = map['name'];
    l = map['res'] as List;
    List ls = da[n] as List;
    s.clear();
    for (int i = 0; i < ls.length; i++) {
      List<double> tl = [];
      tl..add(ls[i]['x'])..add(ls[i]['y'])..add((ls[i]['z']));
      s.add(tl);
    }
    setState(() {});
  }
}

class StarCanvas extends CustomPainter {
  List<Offset> p = [];
  List<List<double>> s = [];
  var st, w, h;

  StarCanvas(this.w, this.h, this.p, this.s, this.st);

  Paint pa = Paint()
    ..color = Colors.white
    ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < p.length - 1; i += 2) {
      if (p[i] != null && p[i + 1] != null && p[i] != p[i + 1])
        canvas.drawLine(p[i], p[i + 1], pa);
    }

    canvas.save();
    for (List<double> e in s) {
      canvas.translate(e[0] * w, e[1] * h);
      if (st != null) canvas.drawImage(st, Offset(-15.0, -15.0), pa);
      canvas.translate(-e[0] * w, -e[1] * h);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter o) {
    return true;
  }
}

Future<ui.Image> _loadImg(String s) async {
  ByteData bd = await rootBundle.load(s);
  var co = await ui.instantiateImageCodec(bd.buffer.asUint8List());
  FrameInfo fi = await co.getNextFrame();
  return fi.image;
}

Future<String> _loadAst() async {
  return await rootBundle.loadString('img/p.json');
}
