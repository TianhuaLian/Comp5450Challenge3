// pins.dart — 两投一局 + 正式计分（不会在第一投后就重摆）
import 'package:flutter/material.dart';
import 'dart:math';
import '../../score/score.dart';     // 记得放好 ScoreManager

void main() => runApp(const BowlingPinsApp());

// ────────── APP ROOT ──────────
class BowlingPinsApp extends StatelessWidget {
  const BowlingPinsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Bowling Game',
    theme: ThemeData(primarySwatch: Colors.blueGrey),
    home: const BowlingGamePage(),
  );
}

// ────────── PAGE ──────────
class BowlingGamePage extends StatefulWidget {
  const BowlingGamePage({super.key});
  @override
  State<BowlingGamePage> createState() => _BowlingGamePageState();
}

class _BowlingGamePageState extends State<BowlingGamePage>
    with TickerProviderStateMixin {
  // ── 尺寸参数 ──
  final double laneWidth = 300;
  final double pinScale = 1.8;
  late final double pinW, pinH;
  final double vSpacing = 20, hSpacing = 50;
  final double ballRadius = 20;

  // ── 球状态 ──
  double ballAngle = 0;
  Offset ballPos = Offset.zero, ballVel = Offset.zero;
  bool ballMoving = false;

  // ── 局状态 ──
  int rollInFrame = 0;         // 0=第一投，1=第二投
  int knockedThisRoll = 0;

  // ── 计分器 ──
  final ScoreManager scoreManager = ScoreManager();

  // ── 瓶子数据 ──
  final List<PinData> pins = [];
  late List<PinData> initialPins;

  // ── 动画 ──
  late final AnimationController _ballCtl;
  final _rand = Random();

  // ───────────────── LIFE CYCLE ────────────────
  @override
  void initState() {
    super.initState();
    pinW = 20 * pinScale;
    pinH = 40 * pinScale;

    _ballCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateGame);

    _setupPins();
    ballPos = Offset(laneWidth / 2, 400);
  }

  @override
  void dispose() {
    _ballCtl.dispose();
    for (final p in pins) p.dispose();
    super.dispose();
  }

  // ───────────────── PIN SETUP ────────────────
  void _setupPins() {
    for (final p in pins) p.dispose();
    pins.clear();

    _addRow(4, 0, 100);
    _addRow(3, 1, 100);
    _addRow(2, 2, 100);
    _addRow(1, 3, 100);

    initialPins = pins.map((e) => e.copyWith()).toList();
    knockedThisRoll = 0;
    rollInFrame = 0;               // 新局从第一投开始
  }

  void _addRow(int count, int rowIdx, double baseTop) {
    final rowW = (count - 1) * hSpacing + pinW;
    final firstX = laneWidth / 2 - rowW / 2 + pinW / 2;
    final y = baseTop + pinH / 2 + rowIdx * vSpacing;

    for (int i = 0; i < count; i++) {
      final rc = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
      final tc = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
      pins.add(PinData(
        position: Offset(firstX + i * hSpacing, y),
        rotation: 0,
        isHit: false,
        isFalling: false,
        canCauseChainReaction: false,
        translation: Offset.zero,
        rotationController: rc,
        rotationAnimation: Tween<double>(begin: 0, end: 0).animate(rc),
        translationController: tc,
        translationAnimation: Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(tc),
      ));
    }
  }

  // ───────────────── CONTROL ────────────────
  void _throwBall() {
    if (ballMoving) return;
    setState(() => knockedThisRoll = 0);

    ballMoving = true;
    final rad = ballAngle * pi / 180;
    ballVel = Offset(sin(rad) * 8, -cos(rad) * 8);
    _ballCtl.repeat();
  }

  void _resetGame() {
    setState(() {
      scoreManager.reset();
      _setupPins();
      ballPos = Offset(laneWidth / 2, 400);
      ballVel = Offset.zero;
      ballMoving = false;
      _ballCtl.stop();
    });
  }

  // ───────────────── FRAME LOGIC 关键函数 ─────
  void _handleEndOfRoll() {
    // 1) 计算击倒数并计入得分
    knockedThisRoll = pins.where((p) => p.isHit).length;
    scoreManager.recordRoll(knockedThisRoll);

    // 2) 是否 Strike ？
    final bool strike = (rollInFrame == 0 && knockedThisRoll == 10);

    if (strike || rollInFrame == 1) {
      // ① Strike（第一次全倒） 或 ② 第二投结束  → 本局结束，重摆
      _setupPins();
    } else {
      // 第一投但未全倒 → 只清倒下的瓶子
      pins.removeWhere((p) => p.isHit);
      // 留下站立的瓶子进入第二投
    }

    // 3) 更新 rollInFrame
    rollInFrame = (strike || rollInFrame == 1) ? 0 : 1;
  }

  // ───────────────── UPDATE LOOP ─────────────
  void _updateGame() {
    if (!ballMoving) return;
    setState(() {
      ballPos += ballVel;

      // 左右墙
      if (ballPos.dx - ballRadius <= 0 || ballPos.dx + ballRadius >= laneWidth) {
        ballVel = Offset(-ballVel.dx * 0.7, ballVel.dy);
        ballPos = Offset(ballPos.dx.clamp(ballRadius, laneWidth - ballRadius), ballPos.dy);
      }

      // 球飞出上下边界 → 本投结束
      if (ballPos.dy + ballRadius <= 0 || ballPos.dy - ballRadius >= 1000) {
        ballMoving = false;
        _ballCtl..stop()..reset();
        ballPos = Offset(laneWidth / 2, 400);
        _handleEndOfRoll();
        return;
      }

      _checkCollisions();
    });
  }

  // ───────────────── COLLISIONS ──────────────
  void _checkCollisions() {
    for (final pin in pins) {
      if (pin.isHit) continue;
      final pinRect = Rect.fromLTWH(
          pin.position.dx - pinW / 2, pin.position.dy - pinH, pinW, pinH);
      if (!Rect.fromCircle(center: ballPos, radius: ballRadius).overlaps(pinRect)) continue;

      final angle = _rand.nextBool() ? -pi / 2 : pi / 2;
      final dx = (angle < 0 ? -1 : 1) * (_rand.nextDouble() * 15 + 15);
      final dy = -(_rand.nextDouble() * 30 + 30);
      _startPinAnim(pin, angle, Offset(dx, dy));
      ballVel *= 0.8;
    }
  }

  void _startPinAnim(PinData pin, double angle, Offset trans) {
    pin.isHit = true;
    pin.rotationAnimation = Tween<double>(begin: pin.rotationAnimation!.value, end: angle)
        .animate(CurvedAnimation(parent: pin.rotationController!, curve: Curves.easeOut));
    pin.translationAnimation = Tween<Offset>(begin: pin.translationAnimation!.value, end: trans)
        .animate(CurvedAnimation(parent: pin.translationController!, curve: Curves.easeOutCubic));
    pin.rotationController!..reset()..forward();
    pin.translationController!..reset()..forward();
  }

  // ───────────────── UI ──────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Column(
      children: [Expanded(child: _buildLane()), _buildPanel()],
    ),
  );

  Widget _buildLane() => Center(
    child: Container(
      width: laneWidth,
      color: Colors.brown[200],
      child: Stack(children: [
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Container(height: 2, color: Colors.white.withOpacity(0.5)),
        ),
        // 瓶子
        ...pins.map((pin) => AnimatedBuilder(
          animation: pin.rotationAnimation!,
          builder: (_, __) => AnimatedBuilder(
            animation: pin.translationAnimation!,
            builder: (_, __) {
              final left = pin.position.dx - pinW / 2 + pin.translationAnimation!.value.dx;
              final top = pin.position.dy - pinH + pin.translationAnimation!.value.dy;
              return Positioned(
                left: left,
                top: top,
                child: Transform.rotate(
                  angle: pin.rotationAnimation!.value,
                  alignment: Alignment.bottomCenter,
                  child: PinImage(scale: pinScale),
                ),
              );
            },
          ),
        )),
        // 球
        Positioned(
          left: ballPos.dx - ballRadius,
          top: ballPos.dy - ballRadius,
          child: Container(
            width: ballRadius * 2,
            height: ballRadius * 2,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3, spreadRadius: 1)],
            ),
          ),
        ),
      ]),
    ),
  );

  Widget _buildPanel() => Container(
    padding: const EdgeInsets.all(16),
    color: Colors.grey[200],
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('Throw Angle: ${ballAngle.toStringAsFixed(1)}°'),
      Slider(
        min: -45,
        max: 45,
        value: ballAngle,
        onChanged: (v) => setState(() => ballAngle = v),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ElevatedButton(onPressed: _throwBall, child: const Text('Throw')),
        ElevatedButton(onPressed: _resetGame, child: const Text('Reset')),
      ]),
      const SizedBox(height: 10),
      Text('Roll: ${rollInFrame + 1}/2'),
      Text('Knocked Down: $knockedThisRoll',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text('totall: ${scoreManager.totalScore}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ]),
  );
}

// ───────────────── MODEL ───────────────────
class PinData {
  final Offset position;
  double rotation;
  bool isHit;
  bool isFalling;
  bool canCauseChainReaction;
  Offset translation;

  AnimationController? rotationController;
  Animation<double>? rotationAnimation;
  AnimationController? translationController;
  Animation<Offset>? translationAnimation;

  PinData({
    required this.position,
    required this.rotation,
    required this.isHit,
    required this.isFalling,
    required this.canCauseChainReaction,
    required this.translation,
    this.rotationController,
    this.rotationAnimation,
    this.translationController,
    this.translationAnimation,
  });

  PinData copyWith() => PinData(
    position: position,
    rotation: rotation,
    isHit: isHit,
    isFalling: isFalling,
    canCauseChainReaction: canCauseChainReaction,
    translation: translation,
  );

  void dispose() {
    rotationController?.dispose();
    translationController?.dispose();
  }
}

class PinImage extends StatelessWidget {
  final double scale;
  const PinImage({Key? key, this.scale = 1.0}) : super(key: key);
  @override
  Widget build(BuildContext context) => Image.network(
    'https://i.imgur.com/cTVjcFA.png',
    width: 20 * scale,
    height: 40 * scale,
    fit: BoxFit.contain,
  );
}
