import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/voting_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'confirmation_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  String? _selectedCandidateId;
  bool _isSuccessNavigating = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<VotingProvider>(context, listen: false).fetchCandidates()
    );
  }

  void _handleSubmit() async {
    if (_selectedCandidateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a candidate first")),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User session error. Please login again.")),
      );
      return;
    }

    // Step 1: Request 4-Digit PIN
    final pin = await _showPinDialog();
    if (pin == null) return; // User cancelled

    // Step 2: Verify PIN
    final isPinCorrect = await auth.verifyPin(pin);
    if (!isPinCorrect) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? "Incorrect PIN. Please check and try again."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // Step 3: Proceed with Voting
    final success = await Provider.of<VotingProvider>(context, listen: false)
        .submitVote(_selectedCandidateId!, userId);

    if (success && mounted) {
      _isSuccessNavigating = true;
      // LOCK the local state immediately
      auth.markAsVotedLocally();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
        (route) => false,
      );
    } else if (!success && mounted) {
       final error = Provider.of<VotingProvider>(context, listen: false).error;
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? "Submission failed")),
      );
    }
  }

  Future<String?> _showPinDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const Icon(Icons.lock_outline_rounded, color: AppConstants.primaryBlue, size: 40),
            const SizedBox(height: 16),
            Text(
              "Security Verification",
              style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppConstants.navy),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter your 4-digit PIN to confirm your vote.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppConstants.textSlate, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              obscureText: true,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 12),
              maxLength: 4,
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: GoogleFonts.inter(color: AppConstants.textSlate, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("CONFIRM VOTE", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voting = Provider.of<VotingProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    // Security Shield: If user has already voted, push them back
    if (auth.user?.hasVoted == true && !_isSuccessNavigating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Pick Your Candidate",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: voting.isVotingOpen ? const Color(0xFFF1F5F9) : const Color(0xFFFEF2F2),
              child: Row(
                children: [
                  Icon(
                    voting.isVotingOpen ? Icons.info_outline_rounded : Icons.lock_clock_rounded, 
                    color: voting.isVotingOpen ? const Color(0xFF2563EB) : const Color(0xFFEF4444), 
                    size: 18
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      voting.isVotingOpen 
                        ? "Please select one candidate to proceed. Your vote is secure."
                        : voting.error ?? "Voting is currently locked by the administration.",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: voting.isVotingOpen ? const Color(0xFF475569) : const Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: voting.isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  itemCount: voting.candidates.length,
                  itemBuilder: (context, index) {
                    final candidate = voting.candidates[index];
                    final isSelected = _selectedCandidateId == candidate.id;

                    return FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: Duration(milliseconds: 100 * index),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCandidateId = candidate.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected 
                                  ? const Color(0xFF2563EB).withOpacity(0.1) 
                                  : Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Candidate Image & Symbol
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: Image.network(
                                        candidate.image ?? "https://via.placeholder.com/150",
                                        width: 72,
                                        height: 72,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  if (candidate.symbolUrl != null)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            candidate.symbolUrl!,
                                            width: 28,
                                            height: 28,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              
                              // Names
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      candidate.name,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w800, 
                                        fontSize: 18,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        if (candidate.logo != null) ...[
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFFF1F5F9)),
                                            ),
                                            child: Image.network(
                                              candidate.logo!,
                                              width: 28,
                                              height: 28,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isSelected ? const Color(0xFF2563EB).withOpacity(0.1) : const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              candidate.party.toUpperCase(),
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1.1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Selection indicator
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected 
                                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                                  : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
          
          // Bottom Action
          Container(
            padding: const EdgeInsets.all(24).copyWith(bottom: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: voting.isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
              : FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 400),
                  child: ElevatedButton(
                    onPressed: voting.isVotingOpen ? _handleSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: voting.isVotingOpen ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                      foregroundColor: voting.isVotingOpen ? Colors.white : const Color(0xFF94A3B8),
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(voting.isVotingOpen ? Icons.check_circle_outline_rounded : Icons.lock_outline_rounded, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          voting.isVotingOpen ? "Submit My Vote" : "Voting Locked",
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
