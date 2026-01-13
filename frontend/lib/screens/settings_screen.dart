import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Font', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            RadioListTile<AppFont>(
              title: const Text('Default'),
              value: AppFont.system,
              groupValue: accessibility.font,
              onChanged: (v) => accessibility.setFont(v!),
            ),
            RadioListTile<AppFont>(
              title: const Text('OpenDyslexic'),
              value: AppFont.openDyslexic,
              groupValue: accessibility.font,
              onChanged: (v) => accessibility.setFont(v!),
            ),

            const SizedBox(height: 24),
            const Text('Text Size', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            SegmentedButton<FontSizeOption>(
              segments: const [
                ButtonSegment(value: FontSizeOption.small, label: Text('Small')),
                ButtonSegment(value: FontSizeOption.medium, label: Text('Medium')),
                ButtonSegment(value: FontSizeOption.large, label: Text('Large')),
              ],
              selected: {accessibility.fontSize},
              onSelectionChanged: (v) {
                accessibility.setFontSize(v.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
