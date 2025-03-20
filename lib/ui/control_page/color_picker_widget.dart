import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerWidget extends StatelessWidget {
  final String label;
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  ColorPickerWidget({
    required this.label,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Pick $label'),
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: initialColor,
                    onColorChanged: onColorChanged,
                    showLabel: true,
                    pickerAreaHeightPercent: 0.8,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Done'),
                  ),
                ],
              ),
            );
          },
          child: Container(
            width: 100,
            height: 100,
            color: initialColor,
            child: Center(child: Text('Tap to change')),
          ),
        ),
      ],
    );
  }
}