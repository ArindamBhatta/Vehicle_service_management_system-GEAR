import 'package:flutter/material.dart';

class SplashScreenStateless extends StatelessWidget {
  const SplashScreenStateless({super.key});

  static const _totalDuration = Duration(milliseconds: 2200);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // responsive logo sizing
    final logoSize = size.width * 0.30;
    const maxLogoSize = 180.0;
    const minLogoSize = 90.0;
    final actualLogoSize = logoSize.clamp(minLogoSize, maxLogoSize);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: _totalDuration,
        curve: Curves.linear,
        builder: (context, t, child) {
          // t goes from 0.0 -> 1.0 over _totalDuration
          // We'll use Interval curves to stagger when each element becomes visible.

          // main logo: appear between 0.00 - 0.40
          final mainOpacity = Curves.easeOut
              .transformInterval(0.0, 0.40)
              .transform(t);
          final mainScale = Tween<double>(
            begin: 0.88,
            end: 1.0,
          ).transform(Curves.easeOut.transformInterval(0.0, 0.40).transform(t));

          // subtext image: appear between 0.40 - 0.70
          final subOpacity = Curves.easeOut
              .transformInterval(0.40, 0.70)
              .transform(t);
          final subTranslate =
              (1.0 -
                  Curves.easeOut.transformInterval(0.40, 0.70).transform(t)) *
              8.0;

          // bottom/fade content (like caption or background): appear between 0.80 - 1.00
          final footerOpacity = Curves.easeOut
              .transformInterval(0.80, 1.00)
              .transform(t);

          return Stack(
            children: [
              // Optional background image that fades in last (uncomment and supply an asset to use)
              // Opacity(
              //   opacity: footerOpacity,
              //   child: SizedBox.expand(
              //     child: Image.asset(
              //       'assets/images/splash_background.png',
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),

              // Centered logo + subtext
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // main logo (fade & scale)
                    Opacity(
                      opacity: mainOpacity.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: mainScale.clamp(0.0, 1.0),
                        child: Image.asset(
                          'assets/images/restomag_logo.png',
                          width: actualLogoSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    // subtext image (fade + slight upward motion)
                    Opacity(
                      opacity: subOpacity.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          subTranslate,
                        ), // slides up as it appears
                        child: Image.asset(
                          'assets/images/splash_text_img.png',
                          width: actualLogoSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // bottom caption or small text that fades in last (no button)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  minimum: EdgeInsets.symmetric(
                    horizontal: size.width * 0.08,
                    vertical: size.height * 0.02,
                  ),
                  child: Opacity(
                    opacity: footerOpacity.clamp(0.0, 1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome to RestoMag',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: size.width * 0.05,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Helper extension to allow Interval-like mapping on a value without creating
/// explicit animations. This uses the supplied start/end to map incoming t.
///
/// Usage:
///   Curves.easeOut.transformInterval(0.2, 0.6).transform(t)
extension _CurveInterval on Curve {
  Curve transformInterval(double start, double end) {
    assert(0.0 <= start && start <= 1.0 && 0.0 <= end && end <= 1.0);
    final dur = end - start;
    if (dur <= 0) return const AlwaysStoppedCurve();
    return _IntervalCurve(start, end, this);
  }
}

class AlwaysStoppedCurve extends Curve {
  const AlwaysStoppedCurve();
}

class _IntervalCurve extends Curve {
  final double start;
  final double end;
  final Curve parent;
  _IntervalCurve(this.start, this.end, this.parent);
  @override
  double transform(double t) {
    if (t <= start) return 0.0;
    if (t >= end) return 1.0;
    final localT = (t - start) / (end - start);
    return parent.transform(localT);
  }
}
