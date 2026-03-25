import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_database/firebase_database.dart';

class SoilPage extends StatefulWidget {
  const SoilPage({super.key});

  @override
  State<SoilPage> createState() => _SoilPageState();
}

class _SoilPageState extends State<SoilPage>
    with SingleTickerProviderStateMixin {

  // ── Animated gauge values (0 → actual) ───────────────────────────────────
  double _animPh = 0;
  double _animEc = 0;
  double _animSm = 0;
  double _animSt = 0;

  // ── Actual values from Firebase ───────────────────────────────────────────
  double _ph = 0;
  double _ec = 0;
  double _sm = 0;
  double _st = 0;

  // ── UI State ──────────────────────────────────────────────────────────────
  bool _isSampling = false;   // true = show loading screen
  bool _hasAnimated = false;  // run needle animation only once per START
  Timer? _loadingTimer;       // 7 sec countdown

  late AnimationController _needleController;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    // Needle sweep animation
    _needleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _progress = CurvedAnimation(
      parent: _needleController,
      curve: Curves.easeOutCubic,
    );
    _progress.addListener(() {
      setState(() {
        _animPh = _ph * _progress.value;
        _animEc = _ec * _progress.value;
        _animSm = _sm * _progress.value;
        _animSt = _st * _progress.value;
      });
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _needleController.dispose();
    super.dispose();
  }

  // ── Parse helper ──────────────────────────────────────────────────────────
  double _parse(dynamic w) {
    if (w == null) return 0.0;
    if (w is num) return w.toDouble();
    return double.tryParse(w.toString()) ?? 0.0;
  }

  // ── Run needle animation ──────────────────────────────────────────────────
  void _runNeedleAnimation() {
    _needleController.reset();
    _needleController.forward();
  }

  // ── START button ──────────────────────────────────────────────────────────
  Future<void> _onStart() async {
    HapticFeedback.mediumImpact();

    // Reset gauges to 0 and show loading screen
    setState(() {
      _isSampling = true;
      _hasAnimated = false;
      _animPh = 0;
      _animEc = 0;
      _animSm = 0;
      _animSt = 0;
    });

    // Write sampling flag to Firebase (triggers ESP32)
    try {
      await FirebaseDatabase.instance.ref('SensorData').update({
        "sampling": true,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}

    // After 7 seconds: stop loading, show gauges with animation
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 7), () {
      if (mounted) {
        HapticFeedback.lightImpact();
        setState(() {
          _isSampling = false;
          _hasAnimated = true;
        });
        _runNeedleAnimation();
      }
    });
  }

  // ── RESET button ──────────────────────────────────────────────────────────
  Future<void> _onReset() async {
    HapticFeedback.heavyImpact();

    _loadingTimer?.cancel();
    _needleController.reset();

    setState(() {
      _isSampling = false;
      _hasAnimated = false;
      _animPh = 0;
      _animEc = 0;
      _animSm = 0;
      _animSt = 0;
    });

    try {
      await FirebaseDatabase.instance.ref('SensorData').set({
        "pH": 0.0,
        "ec_value": 0.0,
        "humidity": 0.0,
        "temperature": 0.0,
        "sampling": false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sensor data reset'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ── Good / Bad status ─────────────────────────────────────────────────────
  ({String label, Color color}) _status(String sensor, double value) {
    switch (sensor) {
      case 'PH':
        if (value == 0) return (label: '—', color: Colors.white38);
        return (value >= 6.0 && value <= 7.5)
            ? (label: 'Good', color: Colors.greenAccent)
            : (label: 'Bad', color: Colors.redAccent);
      case 'EC':
        if (value == 0) return (label: '—', color: Colors.white38);
        return (value >= 0.8 && value <= 3.0)
            ? (label: 'Good', color: Colors.greenAccent)
            : (label: 'Bad', color: Colors.redAccent);
      case 'SM':
        if (value == 0) return (label: '—', color: Colors.white38);
        return (value >= 40 && value <= 70)
            ? (label: 'Good', color: Colors.greenAccent)
            : (label: 'Bad', color: Colors.redAccent);
      case 'ST':
        if (value == 0) return (label: '—', color: Colors.white38);
        return (value >= 18 && value <= 30)
            ? (label: 'Good', color: Colors.greenAccent)
            : (label: 'Bad', color: Colors.redAccent);
      default:
        return (label: '—', color: Colors.white38);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Header ────────────────────────────────────────────────
                _glassBubble(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Soil Analysis",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_isSampling) const _PulsingDot(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Body ──────────────────────────────────────────────────
                Expanded(
                  child: _isSampling
                      ? _buildLoadingView()
                      : _buildGaugeStream(),
                ),

                const SizedBox(height: 20),

                // ── Buttons ───────────────────────────────────────────────
                Row(
                  children: [
                    _buildActionButton(
                        "START", Colors.greenAccent, _onStart),
                    const SizedBox(width: 16),
                    _buildActionButton(
                        "RESET", Colors.redAccent, _onReset),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Loading screen ────────────────────────────────────────────────────────
  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated soil icon
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1.1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
              border: Border.all(
                  color: Colors.greenAccent.withOpacity(0.5), width: 2),
            ),
            child: const Icon(Icons.grass_rounded,
                color: Colors.greenAccent, size: 48),
          ),
        ),

        const SizedBox(height: 28),

        // Spinner
        const SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            color: Colors.greenAccent,
            strokeWidth: 3,
          ),
        ),

        const SizedBox(height: 24),

        // Text
        _glassBubble(
          padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          child: const Column(
            children: [
              Text(
                "Reading Sensors...",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "Please wait a moment",
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Countdown progress bar
        const _CountdownBar(durationSeconds: 7),
      ],
    );
  }

  // ── Firebase stream → gauge grid ──────────────────────────────────────────
  Widget _buildGaugeStream() {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('SensorData').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        if (!snapshot.hasData ||
            snapshot.data!.snapshot.value == null) {
          return const Center(
            child: Text("No Soil Data Available",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          );
        }

        final value = snapshot.data!.snapshot.value;
        if (value is! Map) {
          return Center(
              child: Text('Unexpected data: $value',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14)));
        }

        final data = Map<String, dynamic>.from(value as Map);

        // Pull latest values from Firebase
        _ph = _parse(data['ph'] ?? data['pH']);
        _ec = _parse(data['ec'] ?? data['ec_value']);
        _sm = _parse(data['sm'] ?? data['humidity']);
        _st = _parse(data['st'] ?? data['temperature']);

        // Page first load (no START pressed) — show data directly
        if (!_hasAnimated) {
          _animPh = _ph;
          _animEc = _ec;
          _animSm = _sm;
          _animSt = _st;
        }

        return GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _buildGaugeCard(
              label: "PH", unit: "", value: _animPh,
              actualValue: _ph, min: 0, max: 14,
              ranges: [
                GaugeRange(startValue: 0, endValue: 6,
                    color: Colors.redAccent.withOpacity(0.45)),
                GaugeRange(startValue: 6, endValue: 7.5,
                    color: Colors.greenAccent.withOpacity(0.45)),
                GaugeRange(startValue: 7.5, endValue: 14,
                    color: Colors.orangeAccent.withOpacity(0.45)),
              ],
            ),
            _buildGaugeCard(
              label: "EC", unit: " mS", value: _animEc,
              actualValue: _ec, min: 0, max: 5,
              ranges: [
                GaugeRange(startValue: 0, endValue: 0.8,
                    color: Colors.redAccent.withOpacity(0.45)),
                GaugeRange(startValue: 0.8, endValue: 3.0,
                    color: Colors.greenAccent.withOpacity(0.45)),
                GaugeRange(startValue: 3.0, endValue: 5,
                    color: Colors.orangeAccent.withOpacity(0.45)),
              ],
            ),
            _buildGaugeCard(
              label: "SM", unit: "%", value: _animSm,
              actualValue: _sm, min: 0, max: 100,
              ranges: [
                GaugeRange(startValue: 0, endValue: 40,
                    color: Colors.redAccent.withOpacity(0.45)),
                GaugeRange(startValue: 40, endValue: 70,
                    color: Colors.greenAccent.withOpacity(0.45)),
                GaugeRange(startValue: 70, endValue: 100,
                    color: Colors.orangeAccent.withOpacity(0.45)),
              ],
            ),
            _buildGaugeCard(
              label: "ST", unit: "°C", value: _animSt,
              actualValue: _st, min: 0, max: 50,
              ranges: [
                GaugeRange(startValue: 0, endValue: 18,
                    color: Colors.blueAccent.withOpacity(0.45)),
                GaugeRange(startValue: 18, endValue: 30,
                    color: Colors.greenAccent.withOpacity(0.45)),
                GaugeRange(startValue: 30, endValue: 50,
                    color: Colors.redAccent.withOpacity(0.45)),
              ],
            ),
          ],
        );
      },
    );
  }

  // ── Gauge card ────────────────────────────────────────────────────────────
  Widget _buildGaugeCard({
    required String label,
    required String unit,
    required double value,
    required double actualValue,
    required double min,
    required double max,
    required List<GaugeRange> ranges,
  }) {
    final st = _status(label, actualValue);
    return _glassBubble(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Status chip
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: st.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: st.color.withOpacity(0.6)),
                  ),
                  child: Text(st.label,
                      style:
                          TextStyle(color: st.color, fontSize: 11)),
                ),
              ],
            ),
          ),
          // Radial gauge
          Expanded(
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: min,
                  maximum: max,
                  showLabels: false,
                  showTicks: false,
                  ranges: ranges,
                  axisLineStyle: const AxisLineStyle(
                    thickness: 0.18,
                    cornerStyle: CornerStyle.bothCurve,
                    thicknessUnit: GaugeSizeUnit.factor,
                    color: Colors.white24,
                  ),
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: value,
                      needleLength: 0.58,
                      needleColor: Colors.white,
                      knobStyle: const KnobStyle(
                        color: Colors.greenAccent,
                        sizeUnit: GaugeSizeUnit.factor,
                        knobRadius: 0.07,
                      ),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        "${value.toStringAsFixed(1)}$unit",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      angle: 90,
                      positionFactor: 0.75,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action button ─────────────────────────────────────────────────────────
  Widget _buildActionButton(
      String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: _glassBubble(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ),
        ),
      ),
    );
  }
}

// ── Countdown progress bar ────────────────────────────────────────────────
class _CountdownBar extends StatefulWidget {
  final int durationSeconds;
  const _CountdownBar({required this.durationSeconds});

  @override
  State<_CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<_CountdownBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final remaining =
                  ((1 - _c.value) * widget.durationSeconds).ceil();
              return Text("$remaining sec",
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 12));
            },
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) => LinearProgressIndicator(
                value: _c.value,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation(Colors.greenAccent),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing dot ───────────────────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.greenAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.6),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Glass bubble ──────────────────────────────────────────────────────────
Widget _glassBubble({
  required Widget child,
  double? height,
  EdgeInsetsGeometry? padding,
  List<Color>? gradientColors,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        height: height,
        padding: padding,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ??
                [
                  Colors.white.withAlpha((0.15 * 255).round()),
                  Colors.white.withAlpha((0.05 * 255).round()),
                ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withAlpha((0.2 * 255).round()),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}