import 'package:flutter/material.dart';
import '../models/device.dart';
import '../api.dart'; // For sending presets to the device
import '../presets_database.dart'; // Import the presets database
import '../effects_database.dart';
import '../palettes_database.dart';

class PresetsScreen extends StatefulWidget {
  final Device device;

  const PresetsScreen({super.key, required this.device});

  @override
  State<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends State<PresetsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Preset> allPresets = PresetDatabase.presets; // Updated to use the getter
  List<Preset> filteredPresets = [];
  final TextEditingController _searchController = TextEditingController();
  String _currentCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentCategory = _getCategoryFromIndex(_tabController.index);
        _filterPresets();
      });
    });
    filteredPresets = allPresets;
    _searchController.addListener(_filterPresets);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getCategoryFromIndex(int index) {
    switch (index) {
      case 0:
        return 'All';
      case 1:
        return 'Test';
      case 2:
        return 'Holidays';
      case 3:
        return 'Accents';
      case 4:
        return 'Sports';
      case 5:
        return 'Events';
      default:
        return 'All';
    }
  }

  void _filterPresets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPresets = PresetDatabase.getPresetsByCategory(_currentCategory)
          .where((preset) => preset.name.toLowerCase().contains(query))
          .toList();
    });
  }

  void _selectPreset(Preset selectedPreset) async {
    setState(() {
      for (var preset in allPresets) {
        preset.isSelected = preset == selectedPreset;
      }
    });

    // Send the preset to the device
    try {
      await setPreset(widget.device.ip, selectedPreset.toSettings());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Applied preset: ${selectedPreset.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to apply preset: $e')),
      );
    }
  }

  Map<String, dynamic> _getEffectByName(String effectName) {
    return EffectsDatabase.effectsDatabase.firstWhere(
      (e) => e['name'].toString().toLowerCase() == effectName.toLowerCase(),
      orElse: () => {
        'name': 'Unknown',
        'flags': [],
        'colors': [],
        'parameters': [],
      },
    );
  }

  Map<String, dynamic> _getPaletteById(int paletteId) {
    return PalettesDatabase.palettesDatabase.firstWhere(
      (p) => p['id'] == paletteId,
      orElse: () => {
        'name': 'Unknown',
        'colors': [],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.device.name} Presets'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Presets',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Test'),
              Tab(text: 'Holidays'),
              Tab(text: 'Accents'),
              Tab(text: 'Sports'),
              Tab(text: 'Events'),
            ],
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: filteredPresets.length,
              itemBuilder: (context, index) {
                final preset = filteredPresets[index];
                final effect = _getEffectByName(preset.effectName);
                final palette = preset.paletteId != null ? _getPaletteById(preset.paletteId!) : null;

                return Card(
                  elevation: preset.isSelected ? 8.0 : 2.0,
                  color: preset.isSelected ? Colors.blue[100] : null,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: InkWell(
                    onTap: () => _selectPreset(preset),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            preset.icon,
                            size: 40,
                            color: preset.isSelected ? Colors.blue : Colors.grey,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  preset.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  preset.description,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Effect: ${effect['name']}',
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                                Text(
                                  'Flags: ${(effect['flags'] as List).isNotEmpty ? (effect['flags'] as List).map((flag) => flag == '1D' ? '📏' : flag == '2D' ? '▦' : flag == 'Music' ? '♫' : '♪').join(', ') : 'None'}',
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                                Text(
                                  'Colors: ${effect['colors'] != null && (effect['colors'] as List).isNotEmpty ? (effect['colors'] as List).join(', ') : '🎨'}',
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                                Text(
                                  'Parameters: ${(effect['parameters'] as List).isNotEmpty ? (effect['parameters'] as List).join(', ') : 'None'}',
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                                Text(
                                  'Colors/Palette: ${preset.getColorsOrPalette()}',
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                                if (palette != null) ...[
                                  Text(
                                    'Palette Colors: ${palette['colors'] != null && (palette['colors'] as List).isNotEmpty ? (palette['colors'] as List).join(', ') : 'Custom'}',
                                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}