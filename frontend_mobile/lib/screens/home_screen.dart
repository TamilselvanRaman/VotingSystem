import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/voting_provider.dart';
import '../utils/constants.dart';
import 'profile_screen.dart';
import 'voting_screen.dart';
import 'vote_verification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    Future.microtask(() {
      Provider.of<VotingProvider>(context, listen: false).fetchCandidates();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String days = d.inDays.toString().padLeft(2, '0');
    String hours = (d.inHours % 24).toString().padLeft(2, '0');
    String minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$days:$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final voting = Provider.of<VotingProvider>(context);
    final user = auth.user;

    // Compute countdown from Firestore endTime
    Duration? timeLeft;
    if (voting.endTime != null && voting.endTime!.isNotEmpty) {
      try {
        final endDt = DateTime.parse(voting.endTime!);
        final diff = endDt.difference(DateTime.now());
        timeLeft = diff.isNegative ? Duration.zero : diff;
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Dashboard",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_outline_rounded, color: Color(0xFF0F172A), size: 24),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Welcome Card
                    _buildWelcomeCard(user?.name ?? "Voter"),
                    const SizedBox(height: 24),
                    // Trust Metric
                    _buildTrustMetrics(),
                    const SizedBox(height: 24),
                    // Institutional Ticker
                    _buildInstitutionalTicker(),
                    const SizedBox(height: 24),
                    // Timer Card
                    _buildTimerCard(timeLeft),
                    const SizedBox(height: 48),
                    // Main Vote Action
                    _buildVoteButton(context, user?.hasVoted ?? false, voting.isVotingOpen),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Compliance Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_rounded, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 8),
                      Text(
                        "SECURE ENCRYPTED VOTING SYSTEM",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Your vote is private and protected by advanced security protocols. Any attempt to tamper with the system is blocked.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppConstants.navy,
        borderRadius: BorderRadius.circular(AppConstants.radius),
        boxShadow: [
          BoxShadow(
            color: AppConstants.navy.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppConstants.accent.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_rounded, color: AppConstants.accent, size: 14),
                const SizedBox(width: 8),
                Text(
                  "VERIFIED VOTER ACCESS",
                  style: GoogleFonts.inter(
                    color: AppConstants.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Hello,\n$name",
            style: GoogleFonts.inter(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1.1,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Official voting session is active. Please proceed to give your vote.",
            style: GoogleFonts.inter(
              color: AppConstants.textLight,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard("My Status", "Verified", Icons.workspace_premium_rounded, AppConstants.accent),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard("Identity", "100% Secure", Icons.fingerprint_rounded, AppConstants.success),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppConstants.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppConstants.textLight, letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppConstants.navy),
          ),
        ],
      ),
    );
  }

  Widget _buildInstitutionalTicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_rounded, color: AppConstants.primaryBlue, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Latest News: The general election voting process has started successfully.",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppConstants.textSlate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(Duration? timeLeft) {
    final hasTime = timeLeft != null;
    String days    = hasTime ? timeLeft.inDays.toString().padLeft(2, '0') : '--';
    String hours   = hasTime ? (timeLeft.inHours % 24).toString().padLeft(2, '0') : '--';
    String minutes = hasTime ? (timeLeft.inMinutes % 60).toString().padLeft(2, '0') : '--';
    String seconds = hasTime ? (timeLeft.inSeconds % 60).toString().padLeft(2, '0') : '--';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_rounded, size: 20, color: Color(0xFF2563EB)),
              const SizedBox(width: 12),
              Text(
                "VOTING ENDS IN",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF64748B),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeUnit(days, "DAYS"),
              _buildTimeDivider(),
              _buildTimeUnit(hours, "HOURS"),
              _buildTimeDivider(),
              _buildTimeUnit(minutes, "MINS"),
              _buildTimeDivider(),
              _buildTimeUnit(seconds, "SECS"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDivider() {
    return Container(
      height: 20,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildVoteButton(BuildContext context, bool hasVoted, bool isVotingOpen) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (hasVoted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppConstants.success.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppConstants.success.withOpacity(0.05),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppConstants.success, size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              "VOTE RECORDED",
              style: GoogleFonts.inter(
                color: AppConstants.navy,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "ID: #SV-RECEIPT-VERIFIED",
                style: GoogleFonts.firaCode(
                  color: AppConstants.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Your identity has already cast a vote in this session. Re-voting is strictly prohibited for security.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppConstants.textSlate,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // ── VOTING SUSPENDED state ──
    if (!isVotingOpen) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.05),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, color: Color(0xFFEF4444), size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              "VOTING SUSPENDED",
              style: GoogleFonts.inter(
                color: AppConstants.navy,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "PAUSED BY ADMINISTRATION",
                style: GoogleFonts.inter(
                  color: const Color(0xFFEF4444),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "The election has been temporarily paused by the administration. Please wait for the election to resume.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppConstants.textSlate,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // ── ACTIVE VOTE BUTTON ──
    return Column(
      children: [
        Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent && 
                (event.logicalKey == LogicalKeyboardKey.enter || 
                 event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
              // Trigger the same logic as Tap
              auth.generateAndSendVoteKey();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VoteVerificationScreen()),
              );
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTap: () {
              // Generate the secure key first
              auth.generateAndSendVoteKey();
              
              // Navigate to verification
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VoteVerificationScreen()),
              );
            },
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.1), width: 2),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.how_to_vote_rounded, color: Colors.white, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          "GIVE VOTE",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF22C55E))),
            const SizedBox(width: 12),
            Text(
              "SYSTEM SECURE",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
