import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'dart:typed_data';
import 'datadisplayscreen.dart';

class DataInputScreen extends StatefulWidget {
  final String encryptionKey;

  const DataInputScreen({super.key, required this.encryptionKey});

  @override
  State<DataInputScreen> createState() => _DataInputScreenState();
}

class _DataInputScreenState extends State<DataInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Generate the encryption key from the user password (same as previous key)
  Uint8List _generateKey(String key) {
    final bytes = utf8.encode(key);
    List<int> keyBytes = bytes.length >= 32
        ? bytes.sublist(0, 32)
        : List<int>.from(bytes + List.filled(32 - bytes.length, 0));
    return Uint8List.fromList(keyBytes);
  }

  // Encrypt text using AES encryption
  Map<String, String> _encryptText(String text, Uint8List key) {
    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(key)));
    final iv = encrypt.IV.fromLength(16);
    final encrypted = encrypter.encrypt(text, iv: iv);
    return {
      'encrypted': encrypted.base64,
      'iv': iv.base64,
    };
  }

  // Store encrypted data in secure storage
  Future<void> _storeData() async {
    final name = _nameController.text;
    final number = _numberController.text;

    if (name.isEmpty || number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    final encryptionKey = _generateKey(widget.encryptionKey);

    final encryptedName = _encryptText(name, encryptionKey);
    final encryptedNumber = _encryptText(number, encryptionKey);

    await _secureStorage.write(
        key: 'encrypted_name', value: encryptedName['encrypted']);
    await _secureStorage.write(key: 'name_iv', value: encryptedName['iv']);
    await _secureStorage.write(
        key: 'encrypted_number', value: encryptedNumber['encrypted']);
    await _secureStorage.write(key: 'number_iv', value: encryptedNumber['iv']);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Data stored securely')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Name & Number')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Enter Name'),
            ),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Enter Number'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _storeData,
              child: const Text('Store Data'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DataDisplayScreen(
                      encryptionKey: widget.encryptionKey,
                    ),
                  ),
                );
              },
              child: const Text('View Stored Data'),
            ),
          ],
        ),
      ),
    );
  }
}
