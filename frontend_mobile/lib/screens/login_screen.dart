import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'register_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  final bool _isEpicMode = true;
  String? _maskedPhone;
  String? _resolvedPhone;

  void _handleOtpRequest() async {
    final input = _phoneController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your EPIC Number")),
      );
      return;
    }
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final resolvedPhone = await auth.getPhoneByEpic(input);
    if (resolvedPhone == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error ?? "EPIC Number not found.")),
        );
      }
      return;
    }
    final phoneToLogin = resolvedPhone;
    _resolvedPhone = resolvedPhone;

    // Only send OTP if number exists
    await auth.login(phoneToLogin, epicNumber: input);
    
    if (auth.error == null) {
      // Calculate masked phone
      String cleanPhone = phoneToLogin.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.startsWith('91')) cleanPhone = cleanPhone.substring(2);
      
      setState(() {
        _otpSent = true;
        _maskedPhone = "****${cleanPhone.length > 4 ? cleanPhone.substring(cleanPhone.length - 4) : cleanPhone}";
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP Sent successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!)),
      );
    }
  }

  void _handleLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.verifyOtp(
      _otpController.text.trim(),
    );

    if (success && mounted) {
      if (auth.user == null) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text("Profile not found. Redirecting to Registration..."),
             duration: Duration(seconds: 2),
             backgroundColor: AppConstants.primaryBlue,
           ),
         );
         
         await Future.delayed(const Duration(seconds: 2));
         
         if (mounted) {
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => RegisterScreen(
               phoneNumber: _resolvedPhone,
             )),
           );
         }
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? "Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              // Logo
              BounceInDown(
                duration: const Duration(milliseconds: 1000),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.verified_user_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back",
                      style: GoogleFonts.inter(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppConstants.navy,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Please login to cast your secure vote.",
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
              
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "EPIC NUMBER",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: const Color(0xFF2563EB),
                            letterSpacing: 1.2,
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
                        controller: _phoneController,
                        enabled: !_otpSent,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                           UpperCaseTextFormatter(),
                           LengthLimitingTextInputFormatter(12),
                        ],
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppConstants.navy),
                        decoration: InputDecoration(
                          hintText: "ABC1234567",
                          hintStyle: GoogleFonts.inter(color: AppConstants.textLight, fontWeight: FontWeight.w500),
                          prefixIcon: const Icon(Icons.badge_rounded, color: AppConstants.primaryBlue, size: 22),
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
                  ],
                ),
              ),
              
              if (_otpSent) ...[
                const SizedBox(height: 24),
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "register number to otp send successfully $_maskedPhone",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF065F46),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "OTP VERIFICATION",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
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
                            "USE CODE: ${auth.sentOtp ?? '...'}",
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
                Container(
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
                    controller: _otpController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                    ],
                    obscureText: true,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w800, letterSpacing: 8),
                    decoration: InputDecoration(
                      hintText: "••••••",
                      prefixIcon: const Icon(Icons.security_rounded, color: Color(0xFF64748B)),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 48),
              
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return auth.isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryBlue))
                    : Container(
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
                          onPressed: _otpSent ? _handleLogin : _handleOtpRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.navy,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_otpSent ? Icons.fingerprint_rounded : Icons.lock_open_rounded, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                _otpSent ? "LOG IN NOW" : "SEND OTP CODE",
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                      );
                },
              ),
              
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: "Register",
                          style: GoogleFonts.inter(
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
