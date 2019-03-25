import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: StarPage());
  }
}

class StarPage extends StatefulWidget {
  @override
  _StarPageState createState() => _StarPageState();
}

class _StarPageState extends State<StarPage> {
  List<Offset> _p = [], _sp = [];
  var name = 'Aries', _st, data, _wid, _hig;
  Offset _ep;

  @override
  void initState() {
    super.initState();
    _wid = MediaQueryData.fromWindow(ui.window).size.width;
    _hig = MediaQueryData.fromWindow(ui.window).size.height;
    try {
      _loadImg('images/ic_star.png').then((st) {
        _st = st;
      }).whenComplete(() {
        if (this.mounted) {
          setState(() {});
        }
      });
    } catch (ex) {}
    _loadAst().then((val) {
      data = json.decode(val);
      setData(data[name] as List);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      Image.asset('images/ic_bg.jpg', width: _wid, fit: BoxFit.fill),
      Container(
          child: CustomPaint(painter: StarCanvas(_wid, _hig, _p, _sp, _st))),
      starWid(1, 2),
      starWid(1, 1),
      starWid(0, 1),
      GestureDetector(onPanDown: (d) {
        _p.add(Offset(d.globalPosition.dx, d.globalPosition.dy));
        setState(() {});
      }, onPanUpdate: (d) {
        _ep = Offset(d.globalPosition.dx, d.globalPosition.dy);
      }, onPanEnd: (d) {
        _p.add(_ep);
        setState(() {});
      })
    ]));
  }

  Widget starWid(l, b) {
    return Container(
        alignment: l == 0 ? Alignment.bottomLeft : Alignment.bottomRight,
        margin: EdgeInsets.only(
            bottom: 16.0 + 84 * (b - 1), right: 16.0, left: 16.0),
        child: GestureDetector(
            child: ClipOval(
                child: Container(
                    color: Colors.black54,
                    width: 56,
                    padding: EdgeInsets.all(16),
                    child: Image.asset(
                        'images/ic_${l == 0 ? name.toLowerCase() : (b == 1 ? 'reset' : 'ram')}.png'))),
            onTap: () {
              if (b == 2) {
                List<Map> rl = (data['Random'] as List).cast();
                name = rl[0][Random().nextInt(12).toString()];
                setData(data[name] as List);
              }
              reset();
            }));
  }

  void reset() {
    _p.clear();
    setState(() {});
  }

  void setData(li) {
    _sp.clear();
    for (int i = 0; i < li.length; i++) {
      _sp.add(Offset((li[i]['x']).toDouble(), li[i]['y'].toDouble()));
    }
    setState(() {});
  }
}

class StarCanvas extends CustomPainter {
  List<Offset> _p = [], _sp = [];
  var _st, _wid, _hig;

  StarCanvas(this._wid, this._hig, this._p, this._sp, this._st);

  Paint _pa = Paint()
    ..color = Colors.white
    ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _p.length - 1; i += 2) {
      if (_p[i] != null && _p[i + 1] != null) {
        bool st = false, en = false;
        for (int j = 0; j < _sp.length; j++) {
          if (_p[i].dx <= _sp[j].dx * _wid + 20 &&
              _p[i].dx >= _sp[j].dx * _wid - 20 &&
              _p[i].dy <= _sp[j].dy * _hig + 20 &&
              _p[i].dy >= _sp[j].dy * _hig - 20) {
            _p[i] = Offset(_sp[j].dx * _wid, _sp[j].dy * _hig);
            st = true;
          }
          if (_p[i + 1].dx <= _sp[j].dx * _wid + 20 &&
              _p[i + 1].dx >= _sp[j].dx * _wid - 20 &&
              _p[i + 1].dy <= _sp[j].dy * _hig + 20 &&
              _p[i + 1].dy >= _sp[j].dy * _hig - 20) {
            _p[i + 1] = Offset(_sp[j].dx * _wid, _sp[j].dy * _hig);
            en = true;
          }
        }
        if (!st) _p[i] = null;
        if (!en) _p[i + 1] = null;
      }
      if (_p[i] != null && _p[i + 1] != null)
        canvas.drawLine(_p[i], _p[i + 1], _pa);
    }

    canvas.save();
    for (int i = 0; i < _sp.length; i++) {
      canvas.translate(_sp[i].dx * _wid, _sp[i].dy * _hig);
      if (_st != null) canvas.drawImage(_st, Offset(-15.0, -15.0), _pa);
      canvas.translate(-_sp[i].dx * _wid, -_sp[i].dy * _hig);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

Future<ui.Image> _loadImg(String asset) async {
  ByteData bd = await rootBundle.load(asset);
  var co = await ui.instantiateImageCodec(bd.buffer.asUint8List());
  FrameInfo fi = await co.getNextFrame();
  return fi.image;
}

Future<String> _loadAst() async {
  return await rootBundle.loadString('images/points.json');
}
