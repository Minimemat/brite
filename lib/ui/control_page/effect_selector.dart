import 'package:flutter/material.dart';
import '../../models/effect_metadata.dart';

class EffectSelector extends StatelessWidget {
  final List<EffectMetadata> effects;
  final String selectedEffectIndex;
  final ValueChanged<String> onEffectChanged;

  EffectSelector({
    required this.effects,
    required this.selectedEffectIndex,
    required this.onEffectChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Convert the selectedEffectIndex to an integer to get the effect name
    int index = int.tryParse(selectedEffectIndex) ?? 0;
    // Ensure the index is within bounds
    if (index < 0 || index >= effects.length) {
      index = 0;
    }
    String selectedEffectName = effects[index].name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Effect', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        DropdownButton<String>(
          value: selectedEffectName,
          onChanged: (value) {
            // Find the effect with the selected name and get its ID
            final selectedEffect = effects.firstWhere((effect) => effect.name == value);
            final newIndex = selectedEffect.id.toString();
            onEffectChanged(newIndex);
          },
          items: effects.map((effect) {
            return DropdownMenuItem<String>(
              value: effect.name,
              child: Text(effect.name),
            );
          }).toList(),
        ),
      ],
    );
  }
}