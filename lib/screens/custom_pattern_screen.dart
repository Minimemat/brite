import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../api.dart';

class CustomPatternScreen extends StatefulWidget {
  final String ip;
  final int ledCount;

  const CustomPatternScreen({
    required this.ip,
    this.ledCount = 1000,
    Key? key,
  }) : super(key: key);

  @override
  _CustomPatternScreenState createState() => _CustomPatternScreenState();
}

class _CustomPatternScreenState extends State<CustomPatternScreen> {
  List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.white,
    Colors.blue,
  ];
  int selectedEffect = 0;
  final Map<int, String> effects = {
    0: 'Solid',
    1: 'Blink',
    2: 'Breathe',
    3: 'Wipe',
    4: 'Rainbow',
    11: 'Chase',
    23: 'Twinkle',
  };

  void _addColor() {
    if (colors.length < 16) {
      setState(() {
        colors.add(Colors.grey);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 16 colors reached')),
      );
    }
  }

  void _removeColor() {
    if (colors.length > 1) {
      setState(() {
        colors.removeLast();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum 1 color required')),
      );
    }
  }

  void _changeColor(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick Color ${index + 1}'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: colors[index],
            onColorChanged: (color) {
              setState(() {
                colors[index] = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyPreset() async {
    try {
      final payload = createPresetFromColors(
        colors,
        selectedEffect,
        ledCount: widget.ledCount,
      );
      
      print('Applying preset with ${colors.length} segments and spacing ${colors.length > 1 ? colors.length - 1 : 0}');
      await setPreset(widget.ip, payload);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pattern applied successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to apply pattern: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Pattern'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _applyPreset,
            tooltip: 'Apply Pattern',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _removeColor,
                    icon: const Icon(Icons.remove_circle_outline),
                    tooltip: 'Remove Color',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${colors.length} Color${colors.length != 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: _addColor,
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Add Color',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: List.generate(
                    colors.length,
                    (index) => GestureDetector(
                      onTap: () => _changeColor(index),
                      child: Column(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors[index],
                              border: Border.all(
                                color: Colors.black54,
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '#${colors[index].value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        'Effect',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<int>(
                        value: selectedEffect,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            selectedEffect = value!;
                          });
                        },
                        items: effects.entries
                            .map((entry) => DropdownMenuItem<int>(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _applyPreset,
                icon: const Icon(Icons.check),
                label: const Text('Apply Pattern'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}