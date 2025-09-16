import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정', style: TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('여기는 설정 페이지입니다.'),
      ),
    );
  }
}
