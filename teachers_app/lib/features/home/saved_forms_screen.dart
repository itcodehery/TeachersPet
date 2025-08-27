import 'package:flutter/material.dart';

class SavedFormsScreen extends StatelessWidget {
  const SavedFormsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Forms')),
      body: const Center(child: Text('No saved forms yet.')),
    );
  }
}
