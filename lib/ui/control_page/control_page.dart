import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/device.dart';
import '../../models/wled_state.dart';
import '../../models/effect_metadata.dart';
import '../../services/wled_api_service.dart';
import 'main_tab.dart';
import 'presets_tab.dart';
import 'settings_tab.dart';

class ControlPage extends StatefulWidget {
  final Device device;

  ControlPage({required this.device});

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  late WledApiService apiService;
  WledState? state;
  List<EffectMetadata> effects = [];
  List<String> palettes = [];
  Map<String, dynamic> presets = {};
  int _selectedTabIndex = 0;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    apiService = WledApiService(widget.device.baseUrl);
    _loadInitialData();
    // Start polling for live updates every 5 seconds
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _pollDeviceState();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final fetchedEffects = await apiService.getEffects();
      final fetchedPalettes = await apiService.getPalettes();
      final fetchedPresets = await apiService.getPresets();
      final fetchedState = await apiService.getState();
      setState(() {
        effects = fetchedEffects;
        palettes = fetchedPalettes;
        presets = fetchedPresets;
        state = fetchedState;
      });
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() {
        effects = [
          EffectMetadata(id: 0, name: 'Solid', supportsPalette: false, colorCount: 3),
          EffectMetadata(id: 1, name: 'Blink', supportsPalette: true, colorCount: 1),
          EffectMetadata(id: 2, name: 'Rainbow', supportsPalette: true, colorCount: 1),
        ];
        palettes = ['Default', 'Rainbow', 'Party'];
        presets = {'1': 'Default', '2': 'Rainbow Cycle'};
        if (state == null) {
          state = WledState(
            on: true,
            brightness: 128,
            primaryColor: Colors.red,
            effect: '0',
            effectSpeed: 128,
            effectIntensity: 128,
            paletteIndex: 0,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _pollDeviceState() async {
    try {
      final updatedState = await apiService.getState();
      setState(() {
        state = updatedState;
      });
      // Optionally refresh effects and palettes if they might change
      final fetchedEffects = await apiService.getEffects();
      final fetchedPalettes = await apiService.getPalettes();
      setState(() {
        effects = fetchedEffects;
        palettes = fetchedPalettes;
      });
    } catch (e) {
      print('Error polling device state: $e');
    }
  }

  Future<void> _updateState(WledState newState) async {
    try {
      await apiService.setState(newState);
      // Fetch the latest state to ensure the UI reflects the device's actual state
      final updatedState = await apiService.getState();
      setState(() {
        state = updatedState;
      });
      // Refresh effects and palettes to ensure they are up-to-date
      final fetchedEffects = await apiService.getEffects();
      final fetchedPalettes = await apiService.getPalettes();
      setState(() {
        effects = fetchedEffects;
        palettes = fetchedPalettes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating state: $e')),
      );
    }
  }

  void _togglePower() {
    if (state != null) {
      final newState = WledState(
        on: !state!.on,
        brightness: state!.brightness,
        primaryColor: state!.primaryColor,
        secondaryColor: state!.secondaryColor,
        tertiaryColor: state!.tertiaryColor,
        effect: state!.effect,
        effectSpeed: state!.effectSpeed,
        effectIntensity: state!.effectIntensity,
        paletteIndex: state!.paletteIndex,
      );
      _updateState(newState);
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (state == null || effects.isEmpty || palettes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.device.name)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: [
          IconButton(
            icon: Icon(state!.on ? Icons.power : Icons.power_off),
            color: state!.on ? Colors.green : Colors.red,
            onPressed: _togglePower,
            tooltip: 'Power',
          ),
          IconButton(
            icon: Icon(Icons.timer),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Timers functionality coming soon!')),
              );
            },
            tooltip: 'Timers',
          ),
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sync functionality coming soon!')),
              );
            },
            tooltip: 'Sync',
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Info functionality coming soon!')),
              );
            },
            tooltip: 'Info',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          MainTab(
            state: state!,
            effects: effects,
            palettes: palettes,
            baseUrl: widget.device.baseUrl,
            onStateChanged: _updateState,
            doesEffectUsePalette: apiService.doesEffectUsePalette,
          ),
          PresetsTab(
            presets: presets,
            onPresetSelected: (presetId) {
              apiService.setState(WledState(
                on: state!.on,
                brightness: state!.brightness,
                primaryColor: state!.primaryColor,
                secondaryColor: state!.secondaryColor,
                tertiaryColor: state!.tertiaryColor,
                effect: state!.effect,
                effectSpeed: state!.effectSpeed,
                effectIntensity: state!.effectIntensity,
                paletteIndex: state!.paletteIndex,
              )..toJson()['pl'] = int.parse(presetId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Applied preset $presetId')),
              );
            },
          ),
          SettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: _onTabSelected,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Main',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Presets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}