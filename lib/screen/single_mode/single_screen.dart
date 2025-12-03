import 'package:flutter/material.dart';

class SingleScreen extends StatefulWidget {
  const SingleScreen({Key? key}) : super(key: key);

  @override
  State<SingleScreen> createState() => _SingleScreenState();
}

class _SingleScreenState extends State<SingleScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedMode = 'Marathon';
  bool _hasSavedState = false; // Replace with actual check from device storage

  @override
  void initState() {
    super.initState();
    // TODO: Check for saved game state in device storage
    // setState(() => _hasSavedState = true/false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Single Player')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Player Name:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter your name'),
            ),
            const SizedBox(height: 24),
            const Text('Play Mode:', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: _selectedMode,
              items: const [
                DropdownMenuItem(value: 'Marathon', child: Text('Marathon')),
                DropdownMenuItem(value: 'Sprint', child: Text('Sprint')),
                DropdownMenuItem(value: 'Ultra', child: Text('Ultra')),
                DropdownMenuItem(value: 'Zen', child: Text('Zen')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMode = value!;
                });
              },
            ),
            const SizedBox(height: 32),
            if (_hasSavedState)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Continue old game logic
                  },
                  child: const Text('Continue'),
                ),
              ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Start new game logic
                },
                child: const Text('New Game'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
