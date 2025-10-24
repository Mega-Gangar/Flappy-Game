import 'package:flutter/material.dart';
import '../services/setting_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService settings = SettingsService();
  String _difficulty = 'normal';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() async {
    final currentDifficulty = await settings.difficulty;
    setState(() {
      _difficulty = currentDifficulty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF70C5CE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Difficulty Settings
            _buildSettingCard(
              title: 'DIFFICULTY',
              children: [
                _buildDifficultyOption(
                  title: 'EASY',
                  subtitle: 'Larger gaps, slower speed',
                  value: 'easy',
                  currentValue: _difficulty,
                  onChanged: (value) async {
                    await settings.setDifficulty(value);
                    setState(() {
                      _difficulty = value;
                    });
                  },
                  color: Colors.green,
                ),
                _buildDifficultyOption(
                  title: 'NORMAL',
                  subtitle: 'Balanced gameplay',
                  value: 'normal',
                  currentValue: _difficulty,
                  onChanged: (value) async {
                    await settings.setDifficulty(value);
                    setState(() {
                      _difficulty = value;
                    });
                  },
                  color: Colors.blue,
                ),
                _buildDifficultyOption(
                  title: 'HARD',
                  subtitle: 'Smaller gaps, faster speed',
                  value: 'hard',
                  currentValue: _difficulty,
                  onChanged: (value) async {
                    await settings.setDifficulty(value);
                    setState(() {
                      _difficulty = value;
                    });
                  },
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await settings.resetToDefaults();
                      _loadCurrentSettings(); // Reload settings after reset
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'RESET DEFAULTS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'SAVE & CLOSE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Game Info
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Current Difficulty: ${_difficulty.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getDifficultyDescription(_difficulty),
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDifficultyDescription(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'Larger pipe gaps and slower game speed for relaxed gameplay';
      case 'hard':
        return 'Smaller pipe gaps and faster game speed for maximum challenge';
      default:
        return 'Standard pipe gaps and speed for balanced gameplay';
    }
  }

  Widget _buildSettingCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF075E54),
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyOption({
    required String title,
    required String subtitle,
    required String value,
    required String currentValue,
    required ValueChanged<String> onChanged,
    required Color color,
  }) {
    final isSelected = currentValue == value;

    return Card(
      color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
      elevation: isSelected ? 4 : 1,
      child: ListTile(
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isSelected ? color : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'ACTIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : null,
        onTap: () => onChanged(value),
      ),
    );
  }
}