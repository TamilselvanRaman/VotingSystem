import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  static const String _base58Alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  /// Generates a unique 8-character Base58 key based on voter details.
  static String generateVoteKey({
    required String name,
    required String epic,
    required String dob,
    required String phone,
  }) {
    // Normalize and combine fields
    final input = "$name|$epic|$dob|$phone".toLowerCase().trim();
    final bytes = utf8.encode(input);
    
    // Create a deterministic hash
    final digest = sha256.convert(bytes);
    
    // Convert to Base58 and take 8 chars
    // We use a slice of the hash to ensure we have enough entropy but keep it short
    final b58 = _toBase58(digest.bytes);
    
    // Ensure we return exactly 8 characters from a stable starting point
    if (b58.length < 8) {
      return b58.padRight(8, 'X').toUpperCase();
    }
    return b58.substring(0, 8).toUpperCase();
  }

  static String _toBase58(List<int> bytes) {
    var x = BigInt.zero;
    for (var byte in bytes) {
      x = (x << 8) + BigInt.from(byte);
    }

    var res = '';
    while (x > BigInt.zero) {
      final remainder = x % BigInt.from(58);
      x = x ~/ BigInt.from(58);
      res = _base58Alphabet[remainder.toInt()] + res;
    }

    // Handle leading zeros (if any)
    for (var byte in bytes) {
      if (byte == 0) {
        res = _base58Alphabet[0] + res;
      } else {
        break;
      }
    }

    return res;
  }
}
