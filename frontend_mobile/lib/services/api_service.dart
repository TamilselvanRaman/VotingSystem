import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
  static Future<http.Response> requestOtp(String phone) async {
    return await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/request-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
  }

  static Future<http.Response> login(String phone, String otp) async {
    return await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
  }

  static Future<http.Response> register({
    required String voterId,
    required String phone,
    required String name,
    required String address,
    required String constituency,
    required String dob,
  }) async {
    return await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'voterId': voterId,
        'phone': phone,
        'name': name,
        'address': address,
        'constituency': constituency,
        'dob': dob,
      }),
    );
  }

  // User & Voting
  static Future<http.Response> getProfile() async {
    return await http.get(
      Uri.parse('${AppConstants.baseUrl}/auth/profile'),
      headers: await _getHeaders(),
    );
  }

  static Future<http.Response> getCandidates() async {
    return await http.get(
      Uri.parse('${AppConstants.baseUrl}/voting/candidates'),
      headers: await _getHeaders(),
    );
  }

  static Future<http.Response> submitVote(String candidateId) async {
    return await http.post(
      Uri.parse('${AppConstants.baseUrl}/voting/submit'),
      headers: await _getHeaders(),
      body: jsonEncode({'candidateId': candidateId}),
    );
  }
  
  static Future<http.Response> getSettings() async {
    // In a production app, we might check settings to see if voting is open
    // For this prototype, we'll assume a simple get analytics or similar if needed
    // But mostly we'll handle the 403 response from submitVote if closed
    return await http.get(
      Uri.parse('${AppConstants.baseUrl}/admin/analytics'), // Ideally a public settings endpoint
      headers: await _getHeaders(),
    );
  }
}
