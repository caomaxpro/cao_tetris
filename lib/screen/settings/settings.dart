import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundOn = true;
  Color _bgColor = Colors.white;

  void _pickColor() async {
    // Simple color picker dialog
    final colors = [
      Colors.white,
      Colors.black,
      Colors.blue,
      Colors.green,
      Colors.pink,
    ];
    Color? selected = await showDialog<Color>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Pick background color'),
        children: colors
            .map(
              (c) => SimpleDialogOption(
                child: Container(height: 30, color: c),
                onPressed: () => Navigator.pop(context, c),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null) setState(() => _bgColor = selected);
  }

  void _clearMemory() {
    // TODO: Implement clear memory logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Game memory cleared!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Sound'),
              value: _soundOn,
              onChanged: (val) => setState(() => _soundOn = val),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Background color:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _pickColor,
                  child: Container(
                    width: 32,
                    height: 32,
                    color: _bgColor,
                    margin: const EdgeInsets.only(right: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _clearMemory,
                child: const Text('Clear Memory'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
