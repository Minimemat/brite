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
  List<Preset> allPresets = PresetDatabase.presets;
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

    // Convert preset to WLED-compatible settings
    final settings = _convertPresetToSettings(selectedPreset);

    try {
      await setPreset(widget.device.ip, settings);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Applied preset: ${selectedPreset.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to apply preset: $e')),
      );
    }
  }

  Map<String, dynamic> _convertPresetToSettings(Preset preset) {
    // Convert hex colors to RGB arrays
    final colorList = preset.colors?.map((hex) => hexToRgb(hex)).toList() ?? [[255, 255, 255, 0]];
    
    // Ensure at least one segment with colors
    final segments = [
      {
        'id': 0,
        'start': 0,
        'stop': 1000, // Default LED count, adjust if device-specific info available
        'grp': 1,
        'spc': 0,
        'of': 0,
        'on': true,
        'bri': 255,
        'col': colorList.length > 1 
            ? colorList 
            : [colorList[0], [0, 0, 0, 0], [0, 0, 0, 0]], // Add black for 2nd/3rd if single color
        'fx': preset.fx,
        'sx': preset.sx ?? 128,
        'ix': preset.ix ?? 128,
        'pal': preset.paletteId ?? 0,
        'sel': true,
        'rev': false,
        'mi': false,
      },
      // Terminate remaining segments
      for (int i = 1; i < 16; i++) {'stop': 0},
    ];

    return {
      'on': true,
      'bri': 150,
      'mainseg': 0,
      'seg': segments,
      'transition': 7,
    };
  }

  Map<String, dynamic> _getEffectById(int fxId) {
    return EffectsDatabase.effectsDatabase.firstWhere(
      (e) => e['id'] == fxId,
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
                final effect = _getEffectById(preset.fx);
                final palette = preset.paletteId != null ? _getPaletteById(preset.paletteId!) : null;

                return Card(
                  elevation: preset.isSelected ? 8.0 : 2.0,
                  color: preset.isSelected ? Colors.blue[900] : null,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: InkWell(
                    onTap: () => _selectPreset(preset),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Icon(
                                preset.icon,
                                size: 40,
                                color: preset.isSelected ? Colors.white : Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              if (preset.paletteId != null && preset.paletteId! > 6)
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    palette?['name'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: preset.isSelected ? Colors.white : Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              else
                                Container(
                                  width: 40,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: preset.isSelected ? Colors.white : Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(
                                          color: preset.colors != null && preset.colors!.isNotEmpty
                                              ? Color(int.parse('FF${preset.colors![0]}', radix: 16))
                                              : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(
                                          color: preset.colors != null && preset.colors!.length > 1
                                              ? Color(int.parse('FF${preset.colors![1]}', radix: 16))
                                              : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(
                                          color: preset.colors != null && preset.colors!.length > 2
                                              ? Color(int.parse('FF${preset.colors![2]}', radix: 16))
                                              : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  preset.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: preset.isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  preset.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: preset.isSelected ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Effect: ${effect['name']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: preset.isSelected ? Colors.white70 : Colors.black87,
                                  ),
                                ),
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