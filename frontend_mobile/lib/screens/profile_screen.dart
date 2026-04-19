import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppConstants.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Voter Profile",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: AppConstants.navy,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppConstants.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Cryptographic ID Card
            _buildSovereignCard(user),
            
            const SizedBox(height: 24),
            
            // Status Panel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildStatusPanel(),
            ),
            
            const SizedBox(height: 24),
            
            // Profile Details Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                   _buildSectionHeader("PERSONAL IDENTITY"),
                  _buildDetailCard("FULL NAME", user?.name ?? "-", Icons.person_rounded),
                  _buildDetailCard("FATHER'S NAME", user?.fatherName ?? "-", Icons.family_restroom_rounded),
                  _buildDetailCard("GENDER", user?.gender ?? "-", Icons.wc_rounded),
                  _buildDetailCard("DATE OF BIRTH", user?.dob ?? "-", Icons.calendar_today_rounded),
                  _buildDetailCard("AGE", user?.age.toString() ?? "-", Icons.numbers_rounded),
                  
                  const SizedBox(height: 16),
                  _buildSectionHeader("ELECTION DETAILS"),
                  _buildDetailCard("EPIC NUMBER", user?.epicNumber ?? user?.voterId ?? "-", Icons.badge_rounded),
                  _buildDetailCard("CONSTITUENCY", user?.constituency ?? "-", Icons.how_to_vote_rounded),
                  _buildDetailCard("POLLING STATION", user?.pollingStation ?? "-", Icons.business_rounded),
                  
                  const SizedBox(height: 16),
                  _buildSectionHeader("CONTACT & ADDRESS"),
                  _buildDetailCard("PHONE", user?.phone ?? "-", Icons.phone_iphone_rounded),
                  _buildDetailCard("FULL ADDRESS", user?.address ?? "-", Icons.location_on_rounded),
                  _buildDetailCard("DISTRICT", user?.district ?? "-", Icons.map_rounded),
                  _buildDetailCard("STATE", user?.state ?? "-", Icons.public_rounded),
                  _buildDetailCard("PINCODE", user?.pincode ?? "-", Icons.mark_as_unread_rounded),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            // Security Seal
            const Icon(Icons.shield_rounded, color: Color(0xFFE2E8F0), size: 100),
            const SizedBox(height: 16),
            Text(
              "SMARTVOTE OFFICIAL SYSTEM\nBLOCKCHAIN VERIFIED IDENTITY",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppConstants.textLight,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppConstants.primaryBlue,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSovereignCard(dynamic user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppConstants.navy, Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppConstants.navy.withOpacity(0.3),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -50,
              child: Icon(Icons.verified_rounded, size: 250, color: Colors.white.withOpacity(0.03)),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 32),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "DIGITAL IDENTITY",
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                          ),
                          Text(
                            "STATUS: ACTIVE",
                            style: GoogleFonts.inter(color: AppConstants.success, fontSize: 9, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name?.toUpperCase() ?? "VOTER NAME",
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.fiber_manual_record, color: AppConstants.success, size: 10),
                          const SizedBox(width: 8),
                          Text(
                            "EPIC: ${user?.epicNumber ?? user?.voterId ?? 'UNREGISTERED'}",
                            style: GoogleFonts.inter(color: AppConstants.textLight, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatusItem("Identity", "VERIFIED", AppConstants.success),
          _buildStatusItem("Account", "SECURE", AppConstants.primaryBlue),
          _buildStatusItem("System", "STABLE", AppConstants.textSlate),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppConstants.textLight)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConstants.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppConstants.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: AppConstants.textLight, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(
                  value, 
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppConstants.navy),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
