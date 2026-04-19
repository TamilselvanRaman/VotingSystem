import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  final String? phoneNumber;
  const RegisterScreen({super.key, this.phoneNumber});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _voterIdController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  // Validation States
  bool _isVoterIdLoading = false;
  bool? _isVoterIdValid;
  String? _voterIdError;
  Map<String, dynamic>? _officialData;

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null) {
      _phoneController.text = widget.phoneNumber!;
    }
    _voterIdController.addListener(_onVoterIdChanged);
  }

  @override
  void dispose() {
    _voterIdController.removeListener(_onVoterIdChanged);
    _voterIdController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onVoterIdChanged() {
    if (_voterIdController.text.length > 5) {
      _debounceCheckVoterId();
    } else {
      setState(() {
        _isVoterIdValid = null;
        _voterIdError = null;
      });
    }
  }

  DateTime? _lastCheck;
  void _debounceCheckVoterId() async {
    final text = _voterIdController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isVoterIdLoading = true;
      _isVoterIdValid = null;
      _voterIdError = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // 1. Check if already in app (Duplicate Protection)
    final alreadyInApp = await auth.checkVoterInApp(text);
    if (alreadyInApp) {
      if (mounted) {
        setState(() {
          _isVoterIdLoading = false;
          _isVoterIdValid = false;
          _voterIdError = "Already registered. Please login.";
        });
      }
      return;
    }

    // 2. Check if in master list (search by epicNumber field)
    final query = await FirebaseFirestore.instance
        .collection('realVoterList')
        .where('epicNumber', isEqualTo: text.toUpperCase().trim())
        .get();
    
    // Also try checking by normalized ID as fallback
    final docId = text.replaceAll('/', '_').toUpperCase().trim();
    final docFallback = await FirebaseFirestore.instance.collection('realVoterList').doc(docId).get();

    bool exists = query.docs.isNotEmpty || docFallback.exists;

    if (mounted) {
      setState(() {
        _isVoterIdLoading = false;
        _isVoterIdValid = exists;
        _voterIdError = exists ? null : "Voter ID not found in records.";
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppConstants.primaryBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    final voterId = _voterIdController.text.trim();
    final dob = _dobController.text.trim();

    if (phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid 10-digit number")));
      return;
    }
    
    if (voterId.isEmpty || _isVoterIdValid != true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_voterIdError ?? "Please enter a valid Voter ID")));
      return;
    }

    if (dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select your Date of Birth")));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // Strict Verify Identity before OTP
    final officialData = await auth.verifyVoterIdentity(voterId, dob, phone);
    if (officialData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? "Voter details do not match official records."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Success - store data and send OTP
    _officialData = officialData;
    await auth.login(phone);

    if (auth.error == null) {
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Identity Verified. OTP Sent.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  void _handleRegister() async {
    if (_officialData == null) return;
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // First verify OTP
    final otpSuccess = await auth.verifyOtp(_otpController.text.trim());
    if (!otpSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? "Invalid OTP")));
      return;
    }

    // Finally register profile with official data
    final success = await auth.register(
      voterId: _voterIdController.text.trim(),
      phone: _phoneController.text.trim(),
      dob: _dobController.text.trim(),
      officialData: _officialData!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Complete! Welcome to SmartVote.")));
      Navigator.pushReplacementNamed(context, '/home');
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? "Registration failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create Profile",
                      style: GoogleFonts.inter(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppConstants.navy,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Join SmartVote and register as a verified voter.",
                      style: GoogleFonts.inter(
                        color: AppConstants.textSlate,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 300),
                child: _buildField("VOTER ID CARD NUMBER", "Enter your Voter ID", _voterIdController, Icons.badge_rounded),
              ),
              
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 450),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DATE OF BIRTH",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: const Color(0xFF2563EB),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppConstants.softShadow,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: AppConstants.primaryBlue, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              _dobController.text.isEmpty ? "Select Date of Birth" : _dobController.text,
                              style: GoogleFonts.inter(
                                color: _dobController.text.isEmpty ? AppConstants.textLight : AppConstants.navy,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 600),
                child: _buildPhoneField("PHONE NUMBER", "00000 00000", _phoneController, Icons.phone_iphone_rounded, enabled: !_otpSent),
              ),
              
              if (_otpSent) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "VERIFICATION CODE",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: const Color(0xFF2563EB),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "CODE: ${auth.sentOtp ?? '...'}",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF92400E),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSimpleInput("••••••", _otpController, Icons.security_rounded, isOtp: true),
                const SizedBox(height: 24),
              ],
              
              const SizedBox(height: 24),
              
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return auth.isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryBlue))
                    : FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 800),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.navy.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _otpSent ? _handleRegister : _handleSendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.navy,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 70),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _otpSent ? "CREATE ACCOUNT" : "SEND OTP CODE",
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                          ),
                        ),
                      );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, IconData icon, {bool enabled = true}) {
    // Determine the trailing icon based on validation state
    Widget trailing = const SizedBox.shrink();
    if (label.contains("VOTER ID")) {
      if (_isVoterIdLoading) {
        trailing = Container(
          key: const ValueKey('loading'),
          padding: const EdgeInsets.all(14),
          child: const SizedBox(
            width: 20, 
            height: 20, 
            child: CircularProgressIndicator(
              strokeWidth: 2.5, 
              color: AppConstants.primaryBlue,
              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryBlue),
            )
          ),
        );
      } else if (_isVoterIdValid == true) {
        trailing = const Icon(
          Icons.check_circle_rounded, 
          key: ValueKey('valid'),
          color: AppConstants.success, 
          size: 24
        );
      } else if (_isVoterIdValid == false) {
        trailing = const Icon(
          Icons.error_outline_rounded, 
          key: ValueKey('invalid'),
          color: Colors.redAccent, 
          size: 24
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: const Color(0xFF2563EB),
                letterSpacing: 1.2,
              ),
            ),
            if (_voterIdError != null && label.contains("VOTER ID"))
              AnimatedOpacity(
                opacity: _voterIdError != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _voterIdError!,
                  style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppConstants.softShadow,
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppConstants.navy),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: AppConstants.textLight, fontWeight: FontWeight.w500),
              prefixIcon: Icon(icon, color: AppConstants.primaryBlue, size: 22),
              suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: trailing,
              ),
              fillColor: Colors.transparent,
              filled: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppConstants.primaryBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPhoneField(String label, String hint, TextEditingController controller, IconData icon, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: const Color(0xFF2563EB),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppConstants.softShadow,
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppConstants.navy),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: AppConstants.textLight, fontWeight: FontWeight.w500),
              prefixIcon: Icon(icon, color: AppConstants.primaryBlue, size: 22),
              prefixText: "+91 ",
              prefixStyle: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppConstants.primaryBlue),
              fillColor: Colors.transparent,
              filled: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppConstants.primaryBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSimpleInput(String hint, TextEditingController controller, IconData icon, {bool isOtp = false}) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isOtp,
        style: GoogleFonts.inter(fontWeight: isOtp ? FontWeight.w800 : FontWeight.w600, letterSpacing: isOtp ? 8 : 0),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
