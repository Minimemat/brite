import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/wled_state.dart';
import '../../models/effect_metadata.dart';
import 'color_picker_widget.dart';
import 'effect_selector.dart';
import 'preview_widget.dart';

class MainTab extends StatefulWidget {
  final WledState state;
  final List<EffectMetadata> effects;
  final List<String> palettes;
  final String baseUrl;
  final Future<void> Function(WledState) onStateChanged;
  final Future<bool> Function(int) doesEffectUsePalette;

  MainTab({
    required this.state,
    required this.effects,
    required this.palettes,
    required this.baseUrl,
    required this.onStateChanged,
    required this.doesEffectUsePalette,
  });

  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> {
  bool _supportsPalette = false;
  int _currentPaletteIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounceTimer;
  WledState? _pendingState;

  @override
  void initState() {
    super.initState();
    _currentPaletteIndex = widget.state.paletteIndex;
    _checkPaletteUsage();
  }

  @override
  void didUpdateWidget(MainTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.effect != widget.state.effect) {
      _currentPaletteIndex = widget.state.paletteIndex;
      _checkPaletteUsage();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPaletteUsage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final effectIndex = int.tryParse(widget.state.effect) ?? 0;
      final supportsPalette = await widget.doesEffectUsePalette(effectIndex);
      setState(() {
        _supportsPalette = supportsPalette;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error checking palette usage: $e';
      });
    }
  }

  // Debounce method to limit API calls
  void _debounceUpdate(WledState newState) {
    _pendingState = newState;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 500), () async {
      if (_pendingState != null) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
        try {
          await widget.onStateChanged(_pendingState!);
          setState(() {
            _isLoading = false;
          });
        } catch (e) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error updating state: $e';
          });
        }
        _pendingState = null;
      }
    });
  }

  // Get the color count for the current effect
  int get _currentEffectColorCount {
    final effectIndex = int.tryParse(widget.state.effect) ?? 0;
    final effect = widget.effects.firstWhere(
      (e) => e.id == effectIndex,
      orElse: () => EffectMetadata.fallbackForIndex(effectIndex, 'Unknown'),
    );
    return effect.colorCount;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Effects Section
          EffectSelector(
            effects: widget.effects,
            selectedEffectIndex: widget.state.effect,
            onEffectChanged: (effectIndex) async {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              try {
                final newState = WledState(
                  on: widget.state.on,
                  brightness: widget.state.brightness,
                  primaryColor: widget.state.primaryColor,
                  secondaryColor: widget.state.secondaryColor,
                  tertiaryColor: widget.state.tertiaryColor,
                  effect: effectIndex,
                  effectSpeed: widget.state.effectSpeed,
                  effectIntensity: widget.state.effectIntensity,
                  paletteIndex: _currentPaletteIndex,
                );
                await widget.onStateChanged(newState);
                setState(() {
                  _isLoading = false;
                });
              } catch (e) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Error updating effect: $e';
                });
              }
            },
          ),
          SizedBox(height: 16),
          // Palette Selector
          Text('Palette', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Text(_errorMessage!, style: TextStyle(color: Colors.red))
          else
            DropdownButton<int>(
              value: _currentPaletteIndex.clamp(0, widget.palettes.length - 1),
              onChanged: _supportsPalette
                  ? (value) async {
                      setState(() {
                        _currentPaletteIndex = value!;
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      try {
                        final newState = WledState(
                          on: widget.state.on,
                          brightness: widget.state.brightness,
                          primaryColor: widget.state.primaryColor,
                          secondaryColor: widget.state.secondaryColor,
                          tertiaryColor: widget.state.tertiaryColor,
                          effect: widget.state.effect,
                          effectSpeed: widget.state.effectSpeed,
                          effectIntensity: widget.state.effectIntensity,
                          paletteIndex: _currentPaletteIndex,
                        );
                        await widget.onStateChanged(newState);
                        setState(() {
                          _isLoading = false;
                        });
                      } catch (e) {
                        setState(() {
                          _isLoading = false;
                          _errorMessage = 'Error updating palette: $e';
                        });
                      }
                    }
                  : null,
              items: widget.palettes.asMap().entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
            ),
          if (!_supportsPalette && !_isLoading && _errorMessage == null)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'This effect does not use palettes.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          SizedBox(height: 16),
          Text('Speed: ${widget.state.effectSpeed}'),
          Slider(
            min: 1,
            max: 255,
            value: widget.state.effectSpeed.toDouble(),
            onChanged: (value) {
              final newState = WledState(
                on: widget.state.on,
                brightness: widget.state.brightness,
                primaryColor: widget.state.primaryColor,
                secondaryColor: widget.state.secondaryColor,
                tertiaryColor: widget.state.tertiaryColor,
                effect: widget.state.effect,
                effectSpeed: value.toInt(),
                effectIntensity: widget.state.effectIntensity,
                paletteIndex: _currentPaletteIndex,
              );
              _debounceUpdate(newState);
            },
          ),
          Text('Intensity: ${widget.state.effectIntensity}'),
          Slider(
            min: 1,
            max: 255,
            value: widget.state.effectIntensity.toDouble(),
            onChanged: (value) {
              final newState = WledState(
                on: widget.state.on,
                brightness: widget.state.brightness,
                primaryColor: widget.state.primaryColor,
                secondaryColor: widget.state.secondaryColor,
                tertiaryColor: widget.state.tertiaryColor,
                effect: widget.state.effect,
                effectSpeed: widget.state.effectSpeed,
                effectIntensity: value.toInt(),
                paletteIndex: _currentPaletteIndex,
              );
              _debounceUpdate(newState);
            },
          ),
          SizedBox(height: 16),
          // Colors Section
          Text('Colors', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          // Primary Color (always shown)
          ColorPickerWidget(
            label: 'Primary Color',
            initialColor: widget.state.primaryColor,
            onColorChanged: (color) {
              final newState = WledState(
                on: widget.state.on,
                brightness: widget.state.brightness,
                primaryColor: color,
                secondaryColor: widget.state.secondaryColor,
                tertiaryColor: widget.state.tertiaryColor,
                effect: widget.state.effect,
                effectSpeed: widget.state.effectSpeed,
                effectIntensity: widget.state.effectIntensity,
                paletteIndex: _currentPaletteIndex,
              );
              _debounceUpdate(newState);
            },
          ),
          // Secondary Color (shown if colorCount >= 2)
          if (_currentEffectColorCount >= 2) ...[
            SizedBox(height: 8),
            ColorPickerWidget(
              label: 'Secondary Color',
              initialColor: widget.state.secondaryColor ?? Colors.black,
              onColorChanged: (color) {
                final newState = WledState(
                  on: widget.state.on,
                  brightness: widget.state.brightness,
                  primaryColor: widget.state.primaryColor,
                  secondaryColor: color,
                  tertiaryColor: widget.state.tertiaryColor,
                  effect: widget.state.effect,
                  effectSpeed: widget.state.effectSpeed,
                  effectIntensity: widget.state.effectIntensity,
                  paletteIndex: _currentPaletteIndex,
                );
                _debounceUpdate(newState);
              },
            ),
          ],
          // Tertiary Color (shown if colorCount >= 3)
          if (_currentEffectColorCount >= 3) ...[
            SizedBox(height: 8),
            ColorPickerWidget(
              label: 'Tertiary Color',
              initialColor: widget.state.tertiaryColor ?? Colors.black,
              onColorChanged: (color) {
                final newState = WledState(
                  on: widget.state.on,
                  brightness: widget.state.brightness,
                  primaryColor: widget.state.primaryColor,
                  secondaryColor: widget.state.secondaryColor,
                  tertiaryColor: color,
                  effect: widget.state.effect,
                  effectSpeed: widget.state.effectSpeed,
                  effectIntensity: widget.state.effectIntensity,
                  paletteIndex: _currentPaletteIndex,
                );
                _debounceUpdate(newState);
              },
            ),
          ],
          SizedBox(height: 16),
          PreviewWidget(state: widget.state),
        ],
      ),
    );
  }
}