import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Simple beautiful loading screen without animations
class BeautifulLoadingScreen extends StatelessWidget {
  final String? message;
  final Color primaryColor;
  final Color secondaryColor;
  final double size;

  const BeautifulLoadingScreen({
    Key? key,
    this.message,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.lightBlue,
    this.size = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingMessage = message ?? 'Loading...';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/coop_engage.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 40),

            // Loading spinner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SpinKitWave(
                color: primaryColor,
                size: size,
                type: SpinKitWaveType.start,
              ),
            ),
            const SizedBox(height: 30),

            // Loading message
            Text(
              loadingMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Advanced beautiful loading screen with animations
class BeautifulLoadingScreenV2 extends StatefulWidget {
  final String? message;
  final Color primaryColor;
  final Color secondaryColor;
  final double size;

  const BeautifulLoadingScreenV2({
    Key? key,
    this.message,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.lightBlue,
    this.size = 30.0,
  }) : super(key: key);

  @override
  State<BeautifulLoadingScreenV2> createState() =>
      _BeautifulLoadingScreenV2State();
}

class _BeautifulLoadingScreenV2State extends State<BeautifulLoadingScreenV2>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _dotsController;
  late Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _dotsAnimation = Tween<double>(
      begin: 0.0,
      end: 3.0, // Animate through 3 dots
    ).animate(CurvedAnimation(
      parent: _dotsController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _dotsController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.primaryColor;
    final secondary = widget.secondaryColor;
    final loadingSize = widget.size;
    final loadingMessage = widget.message ?? 'Loading...';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          // color: primary.withOpacity(0),
                          color: primary.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/coop_engage.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            // const SizedBox(height: 40),

            // // Beautiful animated spinner with custom colors
            // Container(
            //   padding: const EdgeInsets.all(20),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(20),
            //     boxShadow: [
            //       BoxShadow(
            //         color: primary.withOpacity(0.1),
            //         blurRadius: 20,
            //         offset: const Offset(0, 8),
            //       ),
            //     ],
            //   ),
            //   child: SpinKitWave(
            //     color: primary,
            //     size: loadingSize,
            //     type: SpinKitWaveType.start,
            //   ),
            // ),
            // const SizedBox(height: 30),

            // // Loading message with pulse animation
            // AnimatedBuilder(
            //   animation: _pulseAnimation,
            //   builder: (context, child) {
            //     return Opacity(
            //       opacity: 0.7 + (0.3 * _pulseAnimation.value),
            //       child: Text(
            //         loadingMessage,
            //         style: TextStyle(
            //           fontSize: 18,
            //           fontWeight: FontWeight.w600,
            //           color: Colors.grey.shade700,
            //           letterSpacing: 0.5,
            //         ),
            //         textAlign: TextAlign.center,
            //       ),
            //     );
            //   },
            // ),
            // const SizedBox(height: 20),

            // // Animated progress dots
            // AnimatedBuilder(
            //   animation: _dotsAnimation,
            //   builder: (context, child) {
            //     return Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: List.generate(3, (index) {
            //         final delay = index * 0.2;
            //         final progress = (_dotsAnimation.value - delay).clamp(0.0, 1.0);
            //         final opacity = (1.0 - progress).clamp(0.3, 1.0);

            //         return Container(
            //           margin: const EdgeInsets.symmetric(horizontal: 4),
            //           width: 10,
            //           height: 10,
            //           decoration: BoxDecoration(
            //             color: primary.withOpacity(opacity),
            //             shape: BoxShape.circle,
            //           ),
            //         );
            //       }),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
