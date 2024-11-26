import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'dart:typed_data';

class DataDisplayScreen extends StatefulWidget {
  final String encryptionKey;

  const DataDisplayScreen({super.key, required this.encryptionKey});

  @override
  State<DataDisplayScreen> createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String _decryptedName = "";
  String _decryptedNumber = "";

  // Generate the encryption key from the user password
  Uint8List _generateKey(String password) {
    final bytes = utf8.encode(password);
    List<int> keyBytes = bytes.length >= 32
        ? bytes.sublist(0, 32)
        : List<int>.from(bytes + List.filled(32 - bytes.length, 0));
    return Uint8List.fromList(keyBytes);
  }

  // Decrypt text using AES encryption
  String _decryptText(String encryptedText, encrypt.IV iv, Uint8List key) {
    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(key)));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }

  // Load and decrypt the stored data
  Future<void> _loadData() async {
    String? encryptedName = await _secureStorage.read(key: 'encrypted_name');
    String? nameIv = await _secureStorage.read(key: 'name_iv');
    String? encryptedNumber =
        await _secureStorage.read(key: 'encrypted_number');
    String? numberIv = await _secureStorage.read(key: 'number_iv');

    if (encryptedName != null &&
        nameIv != null &&
        encryptedNumber != null &&
        numberIv != null) {
      final encryptionKey = _generateKey(widget.encryptionKey);

      // Decrypt the name and number
      final ivName = encrypt.IV.fromBase64(nameIv);
      final ivNumber = encrypt.IV.fromBase64(numberIv);

      final decryptedName = _decryptText(encryptedName, ivName, encryptionKey);
      final decryptedNumber =
          _decryptText(encryptedNumber, ivNumber, encryptionKey);

      setState(() {
        _decryptedName = decryptedName;
        _decryptedNumber = decryptedNumber;
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No data found')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stored Data')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $_decryptedName'),
            Text('Number: $_decryptedNumber'),
          ],
        ),
      ),
    );
  }
}
