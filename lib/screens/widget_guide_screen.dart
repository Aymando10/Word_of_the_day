// Intellectual property of Strauch Development. All rights reserved.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/word.dart';
import '../theme.dart';

/// Step-by-step guide to adding the widget to the iOS Home Screen.
///
/// Shown on first launch, and again from Settings.
class WidgetGuideScreen extends StatefulWidget {
  const WidgetGuideScreen({
    super.key,
    required this.onFinished,
    this.isFirstRun = false,
  });

  /// Called when the guide is completed, skipped or closed.
  final VoidCallback onFinished;

  /// First launch shows "Skip" and "Start learning"; from Settings it shows
  /// a close button and "Done".
  final bool isFirstRun;

  @override
  State<WidgetGuideScreen> createState() => _WidgetGuideScreenState();
}

class _GuideStep {
  const _GuideStep({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.scene,
    this.tip,
  });

  final String eyebrow;
  final String title;
  final String body;
  final String? tip;
  final _Scene scene;
}

enum _Scene { finished, touchAndHold, editMenu, gallery, placeAndDone }

const _steps = [
  _GuideStep(
    eyebrow: 'WELCOME',
    title: 'A new word, every day',
    body:
        'Add the Word of the Day widget to your Home Screen and a fresh '
        'word will be waiting each morning, without opening the app.',
    scene: _Scene.finished,
  ),
  _GuideStep(
    eyebrow: 'STEP 1',
    title: 'Touch and hold',
    body:
        'Touch and hold an empty spot on your Home Screen until the app '
        'icons start to jiggle.',
    scene: _Scene.touchAndHold,
  ),
  _GuideStep(
    eyebrow: 'STEP 2',
    title: 'Tap Edit, then Add Widget',
    body:
        'Tap Edit in the top-left corner and choose Add Widget. On older '
        'versions of iOS, tap the + button instead.',
    scene: _Scene.editMenu,
  ),
  _GuideStep(
    eyebrow: 'STEP 3',
    title: 'Find Word of the Day',
    body:
        'Search for "Word of the Day", swipe to choose a size, then tap '
        'Add Widget.',
    scene: _Scene.gallery,
  ),
  _GuideStep(
    eyebrow: 'STEP 4',
    title: 'Place it and tap Done',
    body:
        'Drag the widget wherever you like, then tap Done. It updates '
        'itself every midnight.',
    tip:
        'You can add it to your Lock Screen too: touch and hold the Lock '
        'Screen, tap Customize, then add a widget.',
    scene: _Scene.placeAndDone,
  ),
];

class _WidgetGuideScreenState extends State<WidgetGuideScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  bool get _isLast => _page == _steps.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      widget.onFinished();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = AppScope.of(context).today;

    return Scaffold(
      body: ForestBackground(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 52,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: widget.isFirstRun
                        ? AnimatedOpacity(
                            opacity: _isLast ? 0 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: TextButton(
                              onPressed: _isLast ? null : widget.onFinished,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.muted,
                              ),
                              child: const Text('Skip'),
                            ),
                          )
                        : IconButton(
                            tooltip: 'Close',
                            onPressed: widget.onFinished,
                            icon: const Icon(Icons.close, color: AppColors.muted),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _steps.length,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) =>
                      _GuidePage(step: _steps[index], word: word),
                ),
              ),
              const SizedBox(height: 12),
              _PageDots(count: _steps.length, index: _page),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.sage,
                      foregroundColor: AppColors.backgroundDeep,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(
                      !_isLast
                          ? 'Next'
                          : widget.isFirstRun
                          ? 'Start learning'
                          : 'Done',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidePage extends StatelessWidget {
  const _GuidePage({required this.step, required this.word});

  final _GuideStep step;
  final Word word;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: FittedBox(
                child: _PhoneMock(scene: step.scene, word: word),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(step.eyebrow, style: eyebrow(AppColors.gold)),
          const SizedBox(height: 8),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: serif.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            step.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.45,
              color: AppColors.muted,
            ),
          ),
          if (step.tip case final tip?) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.gold),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == index ? AppColors.gold : AppColors.outline,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Phone illustration
// ---------------------------------------------------------------------------

const double _cell = 38;
const double _gap = 10;
const double _widgetSize = _cell * 2 + _gap;

const _appColors = [
  Color(0xFF3F6B57), Color(0xFFD8BE85), Color(0xFF5D8A73), Color(0xFF4E7A8A),
  Color(0xFFB98D5F), Color(0xFF8DBF9E), Color(0xFF6F5E8C), Color(0xFFC9776A),
];

/// A stylised iPhone showing one step of adding the widget.
class _PhoneMock extends StatelessWidget {
  const _PhoneMock({required this.scene, required this.word});

  final _Scene scene;
  final Word word;

  bool get _jiggling => scene != _Scene.finished;
  bool get _hasWidget =>
      scene == _Scene.finished || scene == _Scene.placeAndDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 420,
      decoration: BoxDecoration(
        color: const Color(0xFF030806),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.outline, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x88000000), blurRadius: 40, offset: Offset(0, 20)),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E5A47), Color(0xFF15302A), Color(0xFF0B1A15)],
                  ),
                ),
              ),
            ),
            // Dynamic Island.
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 62,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 52,
              left: 14,
              right: 14,
              child: _HomeGrid(
                jiggling: _jiggling,
                widget: _hasWidget
                    ? _MiniWordWidget(
                        word: word,
                        highlighted: scene == _Scene.placeAndDone,
                      )
                    : null,
              ),
            ),
            const Positioned(left: 10, right: 10, bottom: 10, child: _Dock()),
            ..._overlays(),
          ],
        ),
      ),
    );
  }

  List<Widget> _overlays() {
    switch (scene) {
      case _Scene.finished:
        return const [];
      case _Scene.touchAndHold:
        return const [
          Positioned(left: 0, right: 0, bottom: 112, child: Center(child: _TouchPulse())),
        ];
      case _Scene.editMenu:
        return [
          const Positioned(top: 18, left: 12, child: _Pill('Edit', highlighted: true)),
          const Positioned(top: 18, right: 12, child: _Pill('Done')),
          Positioned(
            top: 46,
            left: 12,
            child: Container(
              width: 128,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xF21B2B25),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 16)],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MenuRow('Add Widget', Icons.add_box_outlined, highlighted: true),
                  _MenuRow('Customize', Icons.brush_outlined),
                  _MenuRow('Edit Pages', Icons.grid_view),
                ],
              ),
            ),
          ),
        ];
      case _Scene.gallery:
        return [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 300,
            child: _GallerySheet(word: word),
          ),
        ];
      case _Scene.placeAndDone:
        return const [
          Positioned(top: 18, left: 12, child: _Pill('Edit')),
          Positioned(top: 18, right: 12, child: _Pill('Done', highlighted: true)),
        ];
    }
  }
}

class _HomeGrid extends StatelessWidget {
  const _HomeGrid({required this.jiggling, required this.widget});

  final bool jiggling;
  final Widget? widget;

  Widget _app(int i) => _Jiggle(
    enabled: jiggling,
    seed: i,
    child: _AppIcon(color: _appColors[i % _appColors.length]),
  );

  Widget _row(int start) => Padding(
    padding: const EdgeInsets.only(top: _gap + 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [for (var i = 0; i < 4; i++) _app(start + i)],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget != null)
              _Jiggle(enabled: jiggling, seed: 99, child: widget!)
            else
              Column(
                children: [
                  Row(children: [_app(0), const SizedBox(width: _gap), _app(1)]),
                  const SizedBox(height: _gap),
                  Row(children: [_app(2), const SizedBox(width: _gap), _app(3)]),
                ],
              ),
            Column(
              children: [
                Row(children: [_app(4), const SizedBox(width: _gap), _app(5)]),
                const SizedBox(height: _gap),
                Row(children: [_app(6), const SizedBox(width: _gap), _app(7)]),
              ],
            ),
          ],
        ),
        _row(8),
        _row(12),
      ],
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cell,
      height: _cell,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _Dock extends StatelessWidget {
  const _Dock();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 4; i++)
            _AppIcon(color: _appColors[(i * 3 + 1) % _appColors.length]),
        ],
      ),
    );
  }
}

/// A miniature of the real Home Screen widget.
class _MiniWordWidget extends StatelessWidget {
  const _MiniWordWidget({
    required this.word,
    this.highlighted = false,
    this.scale = 1,
  });

  final Word word;
  final bool highlighted;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: _widgetSize * s,
      height: _widgetSize * s,
      padding: EdgeInsets.all(8 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * s),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF173126), Color(0xFF0A1913)],
        ),
        border: Border.all(
          color: highlighted ? AppColors.gold : const Color(0x33FFFFFF),
          width: highlighted ? 1.5 : 0.5,
        ),
        boxShadow: [
          if (highlighted)
            BoxShadow(color: AppColors.gold.withValues(alpha: 0.35), blurRadius: 14),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WORD OF THE DAY',
            style: TextStyle(
              fontSize: 4.6 * s,
              letterSpacing: 0.8 * s,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
          SizedBox(height: 5 * s),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              word.word,
              style: serif.copyWith(
                fontSize: 13 * s,
                fontWeight: FontWeight.w600,
                color: AppColors.cream,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 4 * s),
            width: 12 * s,
            height: 1 * s,
            color: AppColors.gold,
          ),
          Expanded(
            child: Text(
              word.definition,
              maxLines: 4,
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontSize: 6 * s,
                height: 1.3,
                color: AppColors.cream.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GallerySheet extends StatelessWidget {
  const _GallerySheet({required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF2101D18),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x88000000), blurRadius: 20)],
      ),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.gold, width: 1),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, size: 13, color: AppColors.muted),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Word of the Day',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: AppColors.cream),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _MiniWordWidget(word: word, scale: 1.35),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Dot(active: true),
              _Dot(active: false),
              _Dot(active: false),
            ],
          ),
          const Spacer(),
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 12),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              '+  Add Widget',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.backgroundDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.cream : AppColors.outline,
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, {this.highlighted = false});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.gold : Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (highlighted)
            BoxShadow(color: AppColors.gold.withValues(alpha: 0.5), blurRadius: 12),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: highlighted ? AppColors.backgroundDeep : AppColors.cream,
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.label, this.icon, {this.highlighted = false});

  final String label;
  final IconData icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? AppColors.gold : AppColors.cream;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.gold.withValues(alpha: 0.14) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ),
          Icon(icon, size: 12, color: color),
        ],
      ),
    );
  }
}

/// Gently rocks [child] like a Home Screen icon in edit mode.
class _Jiggle extends StatefulWidget {
  const _Jiggle({required this.enabled, required this.seed, required this.child});

  final bool enabled;
  final int seed;
  final Widget child;

  @override
  State<_Jiggle> createState() => _JiggleState();
}

class _JiggleState extends State<_Jiggle> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 260 + (widget.seed % 5) * 20),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_Jiggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.enabled && !_controller.isAnimating) {
      _controller
        ..value = (widget.seed % 7) / 7
        ..repeat(reverse: true);
    } else if (!widget.enabled) {
      _controller.stop();
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.rotate(
        angle: (_controller.value - 0.5) * (math.pi / 60),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Expanding ring showing where to touch and hold.
class _TouchPulse extends StatefulWidget {
  const _TouchPulse();

  @override
  State<_TouchPulse> createState() => _TouchPulseState();
}

class _TouchPulseState extends State<_TouchPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_controller.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 24 + 44 * t,
                height: 24 + 44 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 1 - t),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cream.withValues(alpha: 0.85),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.6),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
