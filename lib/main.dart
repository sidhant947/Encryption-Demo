import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'datainputscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Secure Storage Sidhant',
      home: EncryptionKeyScreen(),
    );
  }
}

class EncryptionKeyScreen extends StatefulWidget {
  const EncryptionKeyScreen({super.key});

  @override
  State<EncryptionKeyScreen> createState() => _EncryptionKeyScreenState();
}

class _EncryptionKeyScreenState extends State<EncryptionKeyScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final TextEditingController _keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkForEncryptionKey();
  }

  // Check if the encryption key is already set in your device
  Future<void> _checkForEncryptionKey() async {
    String? savedKey = await _secureStorage.read(key: 'user_key');
    if (savedKey != null && savedKey.isNotEmpty) {
      // If the key exists, this will navigate to the data screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DataInputScreen(encryptionKey: savedKey),
        ),
      );
    }
  }

  // Set the encryption key
  Future<void> _setEncryptionKey() async {
    String key = _keyController.text;
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a key')),
      );
    } else {
      await _secureStorage.write(key: 'user_key', value: key);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DataInputScreen(encryptionKey: key),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Encryption Key'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _keyController,
              decoration:
                  const InputDecoration(labelText: 'Enter Encryption Key'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setEncryptionKey,
              child: const Text('Set Key and Proceed'),
            ),
          ],
        ),
      ),
    );
  }
}
