import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/device.dart';
import '../api.dart';
import '../presets_database.dart';
import 'preset_card.dart';
import 'bottom_drawer.dart';
import 'timers_screen.dart';

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
  Preset? selectedPreset;
  bool _isSearchExpanded = false;
  bool _isPoweredOn = true; // Default power state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentCategory = _getCategoryFromIndex(_tabController.index);
        _filterPresets();
      });
    });
    filteredPresets = allPresets;
    _searchController.addListener(_filterPresets);
    _checkInitialPowerState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _checkInitialPowerState() async {
    try {
      final state = await getState(widget.device.ip);
      setState(() {
        _isPoweredOn = state['on'] ?? true;
      });
    } catch (e) {
      print('Error checking initial power state: $e');
    }
  }

  String _getCategoryFromIndex(int index) {
    switch (index) {
      case 0:
        return 'Custom';
      case 1:
        return 'All';
      case 2:
        return 'Christmas';
      case 3:
        return 'Halloween';
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

  void _selectPreset(Preset preset) async {
    setState(() {
      for (var p in allPresets) {
        p.isSelected = p == preset;
      }
      selectedPreset = preset;
    });

    final settings = _convertPresetToSettings(preset);
    try {
      await setPreset(widget.device.ip, settings);
    } catch (e) {
      print('Failed to apply preset: $e');
    }
  }

  void _onSettingsModified() {
    setState(() {
      for (var preset in allPresets) {
        preset.isSelected = false;
      }
      selectedPreset = null;
    });
  }

  void _togglePower(bool value) async {
    setState(() {
      _isPoweredOn = value;
    });
    try {
      await setPower(widget.device.ip, value);
    } catch (e) {
      print('Failed to toggle power: $e');
    }
  }

  Map<String, dynamic> _convertPresetToSettings(Preset preset) {
    final colorList = preset.colors?.map((hex) => hexToRgb(hex)).toList() ?? [[255, 255, 255, 0]];
    final segments = [
      {
        'id': 0,
        'start': 0,
        'stop': 1000,
        'grp': 1,
        'spc': 0,
        'of': 0,
        'on': true,
        'bri': 255,
        'col': colorList.length > 1 ? colorList : [colorList[0], [0, 0, 0, 0], [0, 0, 0, 0]],
        'fx': preset.fx,
        'sx': preset.sx ?? 128,
        'ix': preset.ix ?? 128,
        'pal': preset.paletteId ?? 0,
        'c1': preset.c1 ?? 128,
        'c2': preset.c2 ?? 128,
        'c3': preset.c3 ?? 16,
        'sel': true,
        'rev': false,
        'mi': false,
      },
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

  // In PresetsScreen (_PresetsScreenState)
void _openSettingsDrawer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF2D3436),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sync, color: Colors.white70),
              title: const Text(
                'Sync',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                print('Sync option selected');
                // Add sync functionality here
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer, color: Colors.white70),
              title: const Text(
                'Timers',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimersScreen(device: widget.device),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white70),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                print('Settings option selected');
                // Add additional settings functionality here
              },
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2526),
      appBar: AppBar(
        title: Text('${widget.device.name} Presets'),
        backgroundColor: const Color(0xFF2D3436),
        actions: [
          Row(
            children: [
              Switch(
                value: _isPoweredOn,
                activeColor: Colors.blue,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.white30,
                onChanged: _togglePower,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                tooltip: 'Settings',
                onPressed: () => _openSettingsDrawer(context),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isSearchExpanded ? 200 : 40,
                      child: _isSearchExpanded
                          ? TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search Presets',
                                hintStyle: const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white70),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white70),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.search, color: Colors.white70),
                              onPressed: () {
                                setState(() {
                                  _isSearchExpanded = true;
                                });
                              },
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3436),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white70),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _tabController.index,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF2D3436),
                            items: [
                              DropdownMenuItem(
                                value: 0,
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.white70, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Custom',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: _tabController.index == 0 ? Colors.white : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Row(
                                  children: [
                                    const Icon(Icons.all_inclusive, color: Colors.white70, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'All',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: _tabController.index == 1 ? Colors.white : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Row(
                                  children: [
                                    const Icon(Icons.local_florist, color: Colors.white70, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Christmas',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: _tabController.index == 2 ? Colors.white : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 3,
                                child: Row(
                                  children: [
                                    const Icon(Icons.nights_stay, color: Colors.white70, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Halloween',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: _tabController.index == 3 ? Colors.white : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (newIndex) {
                              if (newIndex != null) {
                                setState(() {
                                  _tabController.index = newIndex;
                                  _currentCategory = _getCategoryFromIndex(newIndex);
                                  _filterPresets();
                                });
                              }
                            },
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0).copyWith(bottom: 100),
                  itemCount: filteredPresets.length,
                  itemBuilder: (context, index) {
                    final preset = filteredPresets[index];
                    return PresetCard(
                      preset: preset,
                      onTap: () => _selectPreset(preset),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomDrawer(
              deviceIp: widget.device.ip,
              selectedPreset: selectedPreset,
              onSettingsModified: _onSettingsModified,
            ),
          ),
        ],
      ),
    );
  }
}