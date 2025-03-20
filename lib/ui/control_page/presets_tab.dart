import 'package:flutter/material.dart';

class PresetsTab extends StatelessWidget {
  final Map<String, dynamic> presets;
  final ValueChanged<String> onPresetSelected;

  PresetsTab({
    required this.presets,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (presets.isEmpty) {
      return Center(child: Text('No presets available'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final presetId = presets.keys.elementAt(index);
        final presetName = presets[presetId].toString();
        return Card(
          child: ListTile(
            title: Text('Preset $presetId'),
            subtitle: Text(presetName),
            onTap: () => onPresetSelected(presetId),
          ),
        );
      },
    );
  }
}