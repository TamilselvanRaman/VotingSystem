import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../utils/constants.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutExpo),
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.background,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, AppConstants.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Animated Success Seal
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildSuccessSeal(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Column(
                        children: [
                          Text(
                            "VOTE CAST SUCCESSFUL",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppConstants.success,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Thank You for Voting!",
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppConstants.navy,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Your selection has been hashed and stored permanently in the secure electoral records.",
                            style: GoogleFonts.inter(
                              color: AppConstants.textSlate,
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Premium Receipt Card with Slide Animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 1.5),
                        child: _buildDigitalCertificate(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Return Action
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildReturnButton(context),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildSecurityFooter(),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessSeal() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Triple pulsing waves
            for (int i = 1; i <= 3; i++)
              Container(
                width: 100 + (i * 20 * _pulseController.value),
                height: 100 + (i * 20 * _pulseController.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConstants.success.withOpacity(0.1 / i),
                ),
              ),
            // Main Circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppConstants.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.success.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.done_all_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDigitalCertificate() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: AppConstants.softShadow,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.qr_code_scanner_rounded, color: AppConstants.navy, size: 24),
                        Text(
                          "OFFICIAL RECEIPT",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppConstants.textLight,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildReceiptItem("RECEIPT ID", "#SV-${math.Random().nextInt(9999)}-${math.Random().nextInt(99)}XJ", isBold: true),
                    const Divider(height: 32, color: Color(0xFFF1F5F9)),
                    _buildReceiptItem("TIMESTAMP", "OCT 10, 2026 • 19:42 UTC"),
                    const Divider(height: 32, color: Color(0xFFF1F5F9)),
                    _buildReceiptItem("LOCATION", "SECURE CLOUD REGION-01"),
                    const SizedBox(height: 32),
                    
                    // Immutable Status Badge (Shimmer Effect Simulator)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppConstants.navy,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_clock_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            "IMMUTABLE RECORD STORED",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Custom Jagged Edge
              CustomPaint(
                size: const Size(double.infinity, 20),
                painter: JaggedEdgePainter(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptItem(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppConstants.textLight,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: AppConstants.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildReturnButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 70),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_filled, size: 24),
            const SizedBox(width: 12),
            Text(
              "Back to Dashboard",
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_rounded, color: AppConstants.success, size: 14),
            const SizedBox(width: 8),
            Text(
              "CONFIRMATION SENT TO REGISTERED PHONE",
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: AppConstants.textLight,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Powered by SmartVote Anti-Tamper Engine",
          style: GoogleFonts.inter(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: AppConstants.textLight.withOpacity(0.5),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class JaggedEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, 0);
    
    // Create jagged points
    double step = 10;
    for (double i = 0; i <= size.width; i += step) {
      path.lineTo(i, (i / step) % 2 == 0 ? 0 : 12);
    }
    
    path.lineTo(size.width, 0);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
