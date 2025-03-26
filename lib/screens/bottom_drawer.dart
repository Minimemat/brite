import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../api.dart';
import '../presets_database.dart';
import '../effects_database.dart';
import '../palettes_database.dart';

class BottomDrawer extends StatefulWidget {
  final String deviceIp;
  final Preset? selectedPreset;
  final VoidCallback onSettingsModified;

  const BottomDrawer({
    super.key,
    required this.deviceIp,
    required this.selectedPreset,
    required this.onSettingsModified,
  });

  @override
  State<BottomDrawer> createState() => _BottomDrawerState();
}

class _BottomDrawerState extends State<BottomDrawer> {
  bool _isCardExpanded = false;

  Map<String, dynamic> _getEffectById(int fxId) {
    return EffectsDatabase.effectsDatabase.firstWhere(
      (e) => e['id'] == fxId,
      orElse: () => {'name': 'Unknown', 'flags': [], 'colors': [], 'parameters': []},
    );
  }

  Map<String, dynamic> _getPaletteById(int paletteId, List<Map<String, dynamic>> palettes) {
    return palettes.firstWhere(
      (p) => p['id'] == paletteId,
      orElse: () => {'name': 'Unknown', 'colors': []},
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getState(widget.deviceIp),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final state = snapshot.data!;
        final segments = state['seg'] as List<dynamic>? ?? [];
        final mainSegment = segments.isNotEmpty ? segments[state['mainseg'] ?? 0] : {};
        final effectId = mainSegment['fx'] ?? 0;
        final effect = _getEffectById(effectId);
        final effectName = effect['name'] as String;
        final paletteId = mainSegment['pal'] ?? 0;
        final colors = (mainSegment['col'] as List<dynamic>?)?.map((c) => c as List<dynamic>).toList() ?? [];
        final sx = mainSegment['sx'] ?? 128;
        final ix = mainSegment['ix'] ?? 128;
        final c1 = mainSegment['c1'] ?? 128;
        final c2 = mainSegment['c2'] ?? 128;
        final c3 = mainSegment['c3'] ?? 16;
        final o1 = mainSegment['o1'] ?? false;
        final o2 = mainSegment['o2'] ?? false;
        final o3 = mainSegment['o3'] ?? false;
        final effectColors = (effect['colors'] as List<dynamic>?) ?? [];
        final effectParameters = (effect['parameters'] as List<dynamic>?) ?? [];

        // Ensure colors list has at least 3 entries
        List<List<dynamic>> paddedColors = List.from(colors);
        while (paddedColors.length < 3) {
          paddedColors.add([0, 0, 0]); // Default to black
        }

        // Update palettes with selected colors using PalettesDatabase
        final updatedPalettes = PalettesDatabase.updatePalettesWithSelectedColors(paddedColors);
        final palette = _getPaletteById(paletteId, updatedPalettes);
        final paletteName = palette['name'] as String;
        final paletteColors = palette['colors'] as List<dynamic>? ?? [];

        // Determine the number of colors to show and swatch details
        int numColorsToShow;
        List<String> swatchLabels = [];
        List<List<dynamic>> swatchColors = [];
        if ([2, 3, 4, 5].contains(paletteId)) {
          // Override for palettes 2-5
          if (paletteId == 2) { // Color 1
            numColorsToShow = 1;
            swatchLabels = ['Fx'];
            swatchColors = [paddedColors[0]];
          } else if (paletteId == 3) { // Colors 1&2
            numColorsToShow = 2;
            swatchLabels = ['Fx', 'Bg'];
            swatchColors = [paddedColors[0], paddedColors[1]];
          } else { // Color Gradient (4), Colors Only (5)
            numColorsToShow = 3;
            swatchLabels = ['Fx', 'Bg', 'Cs'];
            swatchColors = [paddedColors[0], paddedColors[1], paddedColors[2]];
          }
        } else {
          // Use effectColors for other palettes (including Default)
          numColorsToShow = effectColors.where((c) => c != 'Pal').length;
          swatchLabels = effectColors.where((c) => c != 'Pal').toList().cast<String>();
          swatchColors = List.generate(numColorsToShow, (index) {
            final colorIdx = {
              'Fx': 0,
              'Bg': 1,
              'Cs': 2,
              '1': 0,
              '2': 1,
              '3': 2,
              'Fg': 0,
            }[swatchLabels[index]] ?? 0;
            return paddedColors[colorIdx];
          });
        }

        // Determine if we should show the palette gradient in the top preview
        final showPaletteGradientInTopBox = paletteId != 0; // Not "Default"

        // Determine the display name
        String displayName;
        if (widget.selectedPreset != null) {
          displayName = widget.selectedPreset!.name;
        } else {
          displayName = '$effectName + $paletteName';
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isCardExpanded ? null : 70,
          constraints: _isCardExpanded ? const BoxConstraints(minHeight: 70) : null,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1F20),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, -2)),
            ],
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Collapsed view
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70, width: 1),
                          borderRadius: BorderRadius.circular(8),
                          gradient: showPaletteGradientInTopBox && paletteColors.isNotEmpty
                              ? LinearGradient(
                                  colors: paletteColors.map<Color>((c) {
                                    final rgb = (c['color'] as String)
                                        .replaceAll(RegExp(r'rgb\(|\)'), '')
                                        .split(',')
                                        .map(int.parse)
                                        .toList();
                                    return Color.fromRGBO(rgb[0], rgb[1], rgb[2], 1);
                                  }).toList(),
                                  stops: paletteColors.map<double>((c) => (c['stop'] as num) / 100).toList(),
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                        ),
                        child: !showPaletteGradientInTopBox
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  numColorsToShow > 3 ? 3 : numColorsToShow,
                                  (index) {
                                    if (index >= paddedColors.length) return const SizedBox.shrink();
                                    final color = paddedColors[index];
                                    return Container(
                                      width: 12,
                                      height: 12,
                                      margin: const EdgeInsets.symmetric(horizontal: 1),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(color[0], color[1], color[2], 1),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isCardExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isCardExpanded = !_isCardExpanded;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Expanded view
                if (_isCardExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Color swatches with labels inside
                        if (numColorsToShow > 0)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: List.generate(numColorsToShow, (index) {
                              final colorType = swatchLabels[index];
                              final color = swatchColors[index];
                              final isFx = colorType == 'Fx';
                              final usePaletteGradient = isFx && paletteColors.isNotEmpty && paletteId != 0; // Modified condition
                              final isFirstSwatch = index == 0;
                              final isClickablePalette = [2, 3, 4, 5].contains(paletteId);
                              // Allow clicking when paletteId is 0 (Default) or for specific palettes on first swatch
                              final allowClicking = (isFx && paletteId == 0) || (!isFx || !usePaletteGradient || (isFirstSwatch && isClickablePalette));
                              return GestureDetector(
                                onTap: allowClicking
                                    ? () async {
                                        final newColor = await PalettesDatabase.showColorPicker(
                                          context,
                                          Color.fromRGBO(color[0], color[1], color[2], 1),
                                        );
                                        if (newColor != null) {
                                          final newColors = List.from(paddedColors);
                                          final colorIdx = {
                                            'Fx': 0,
                                            'Bg': 1,
                                            'Cs': 2,
                                            '1': 0,
                                            '2': 1,
                                            '3': 2,
                                            'Fg': 0,
                                          }[colorType] ?? 0;
                                          newColors[colorIdx] = PalettesDatabase.colorToRgb(newColor);
                                          await setPreset(widget.deviceIp, {
                                            'seg': [{
                                              'col': newColors,
                                              'fx': effectId,
                                              'pal': paletteId,
                                              'sx': sx,
                                              'ix': ix,
                                              'c1': c1,
                                              'c2': c2,
                                              'c3': c3,
                                              'o1': o1,
                                              'o2': o2,
                                              'o3': o3,
                                            }],
                                          });
                                          widget.onSettingsModified();
                                          setState(() {});
                                        }
                                      }
                                    : null,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: usePaletteGradient
                                        ? LinearGradient(
                                            colors: paletteColors.map<Color>((c) {
                                              final rgb = (c['color'] as String)
                                                  .replaceAll(RegExp(r'rgb\(|\)'), '')
                                                  .split(',')
                                                  .map(int.parse)
                                                  .toList();
                                              return Color.fromRGBO(rgb[0], rgb[1], rgb[2], 1);
                                            }).toList(),
                                            stops: paletteColors.map<double>((c) => (c['stop'] as num) / 100).toList(),
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          )
                                        : null,
                                    color: !usePaletteGradient ? Color.fromRGBO(color[0], color[1], color[2], 1) : null,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white70, width: 1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      colorType,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: usePaletteGradient
                                            ? Colors.white
                                            : (color[0] * 0.299 + color[1] * 0.587 + color[2] * 0.114) > 128
                                                ? Colors.black
                                                : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        const SizedBox(height: 8),
                        // Effect and Palette selectors side by side
                        Row(
                          children: [
                            // Effect Modifier Dropdown
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Effect:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4A4A4A),
                                      border: Border.all(color: Colors.white70),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: effectId,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF4A4A4A),
                                        items: EffectsDatabase.effectsDatabase.map((effect) {
                                          return DropdownMenuItem<int>(
                                            value: effect['id'] as int,
                                            child: Text(
                                              effect['name'] as String,
                                              style: const TextStyle(fontSize: 16, color: Colors.white), // Changed from 14 to 16
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (newEffectId) async {
                                          if (newEffectId != null) {
                                            await setPreset(widget.deviceIp, {
                                              'seg': [{
                                                'col': paddedColors,
                                                'fx': newEffectId,
                                                'pal': paletteId,
                                                'sx': sx,
                                                'ix': ix,
                                                'c1': c1,
                                                'c2': c2,
                                                'c3': c3,
                                                'o1': o1,
                                                'o2': o2,
                                                'o3': o3,
                                              }],
                                            });
                                            widget.onSettingsModified();
                                            setState(() {});
                                          }
                                        },
                                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Palette Dropdown
                            if (effectColors.contains('Pal'))
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Palette:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4A4A4A),
                                        border: Border.all(color: Colors.white70),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: paletteId,
                                          isExpanded: true,
                                          dropdownColor: const Color(0xFF4A4A4A),
                                          items: updatedPalettes.map((palette) {
                                            final paletteColors = palette['colors'] as List<dynamic>? ?? [];
                                            final paletteId = palette['id'] as int;
                                            return DropdownMenuItem<int>(
                                              value: paletteId,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          palette['name'] as String,
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        if (paletteId != 0)
                                                          const SizedBox(height: 4),
                                                        if (paletteId != 0)
                                                          Container(
                                                            height: 10,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(4),
                                                              gradient: paletteColors.isNotEmpty
                                                                  ? LinearGradient(
                                                                      colors: paletteColors.map<Color>((c) {
                                                                        final rgb = (c['color'] as String)
                                                                            .replaceAll(RegExp(r'rgb\(|\)'), '')
                                                                            .split(',')
                                                                            .map(int.parse)
                                                                            .toList();
                                                                        return Color.fromRGBO(rgb[0], rgb[1], rgb[2], 1);
                                                                      }).toList(),
                                                                      stops: paletteColors
                                                                          .map<double>((c) => (c['stop'] as num) / 100)
                                                                          .toList(),
                                                                      begin: Alignment.centerLeft,
                                                                      end: Alignment.centerRight,
                                                                    )
                                                                  : null,
                                                              color: paletteColors.isEmpty ? Colors.grey : null,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (newPaletteId) async {
                                            if (newPaletteId != null) {
                                              await setPreset(widget.deviceIp, {
                                                'seg': [{
                                                  'col': paddedColors,
                                                  'fx': effectId,
                                                  'pal': newPaletteId,
                                                  'sx': sx,
                                                  'ix': ix,
                                                  'c1': c1,
                                                  'c2': c2,
                                                  'c3': c3,
                                                  'o1': o1,
                                                  'o2': o2,
                                                  'o3': o3,
                                                }],
                                              });
                                              widget.onSettingsModified();
                                              setState(() {});
                                            }
                                          },
                                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Parameter sliders and switches
                        effectParameters.isNotEmpty
                            ? Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: effectParameters.asMap().entries.map((entry) {
                                  final paramIndex = entry.key;
                                  final param = entry.value;
                                  final paramKey = param.toLowerCase();
                                  final isSwitch = ['overlay', 'one color'].contains(paramKey);
                                  final paramValue = {
                                    'speed': sx,
                                    'intensity': ix,
                                    'width': ix,
                                    'size': ix,
                                    'saturation': ix,
                                    'duty cycle': ix,
                                    'fade time': ix,
                                    'smooth': ix,
                                    'gap size': ix,
                                    'wave width': ix,
                                    'dissolve speed': ix,
                                    'repeat speed': ix,
                                    'random': c1,
                                    '# of dots': c1,
                                    'fade rate': ix,
                                    'frequency': sx,
                                    'blink duration': ix,
                                    'spawn speed': ix,
                                    'fade speed': ix,
                                    '# of flashers': c1,
                                    'trail': ix,
                                    'us style': c1,
                                    'spread': ix,
                                    'zone size': ix,
                                    'spawning rate': ix,
                                    'one color': o1,
                                    'cooling': c1,
                                    'spark rate': c2,
                                    'boost': c3,
                                    'hue': ix,
                                    'cycle speed': sx,
                                    'gravity': c1,
                                    'firing side': c2,
                                    '# of balls': c1,
                                    'phase': sx,
                                    '% of fill': ix,
                                    'wave #': ix,
                                    'twinkle rate': ix,
                                    'duration': sx,
                                    'eye fade time': ix,
                                    'fg size': ix,
                                    'bg size': ix,
                                    'glitter color': c3,
                                    'chance': c1,
                                    'fragments': c2,
                                    'time [min]': sx,
                                    'scale': ix,
                                    'zones': ix,
                                    'gap size': ix,
                                    '# of shadows': c1,
                                    'shift speed': sx,
                                    'blend speed': ix,
                                    'blur': ix,
                                    'dance': ix,
                                    'color speed': sx,
                                    'overlay': o1,
                                  }[paramKey] ?? (isSwitch ? false : 128);

                                  if (isSwitch) {
                                    return Container(
                                      width: (MediaQuery.of(context).size.width - 48) / 2,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$param',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Switch(
                                            value: paramValue as bool,
                                            activeColor: Colors.blue,
                                            onChanged: (newValue) async {
                                              final newSettings = {
                                                'seg': [{
                                                  'col': paddedColors,
                                                  'fx': effectId,
                                                  'pal': paletteId,
                                                  'sx': sx,
                                                  'ix': ix,
                                                  'c1': c1,
                                                  'c2': c2,
                                                  'c3': c3,
                                                  'o1': paramKey == 'overlay' || paramKey == 'one color' ? newValue : o1,
                                                  'o2': o2,
                                                  'o3': o3,
                                                }],
                                              };
                                              await setPreset(widget.deviceIp, newSettings);
                                              widget.onSettingsModified();
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return Container(
                                    width: (MediaQuery.of(context).size.width - 48) / 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$param: $paramValue',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Slider(
                                          min: 0,
                                          max: 255,
                                          value: paramValue.toDouble(),
                                          activeColor: Colors.blue,
                                          inactiveColor: Colors.white30,
                                          label: paramValue.round().toString(),
                                          divisions: 255,
                                          thumbColor: Colors.blue,
                                          onChanged: (newValue) async {
                                            final newSettings = {
                                              'seg': [{
                                                'col': paddedColors,
                                                'fx': effectId,
                                                'pal': paletteId,
                                                'sx': paramKey == 'speed' ? newValue.round() : sx,
                                                'ix': [
                                                  'intensity',
                                                  'width',
                                                  'size',
                                                  'saturation',
                                                  'duty cycle',
                                                  'fade time',
                                                  'smooth',
                                                  'gap size',
                                                  'wave width',
                                                  'dissolve speed',
                                                  'repeat speed',
                                                  'blink duration',
                                                  'spawn speed',
                                                  'fade speed',
                                                  'trail',
                                                  'spread',
                                                  'zone size',
                                                  'spawning rate',
                                                  '% of fill',
                                                  'wave #',
                                                  'twinkle rate',
                                                  'duration',
                                                  'fg size',
                                                  'bg size',
                                                  'phase',
                                                  'shift speed',
                                                  '# of dots',
                                                  '# of flashers',
                                                  'us style',
                                                  'cooling',
                                                  'chance',
                                                  'gravity',
                                                  '# of balls',
                                                  '# of shadows'
                                                ].contains(paramKey)
                                                    ? newValue.round()
                                                    : ix,
                                                'c1': [
                                                  'random'
                                                ].contains(paramKey)
                                                    ? newValue.round()
                                                    : c1,
                                                'c2': ['spark rate', 'fragments', 'firing side'].contains(paramKey)
                                                    ? newValue.round()
                                                    : c2,
                                                'c3': ['boost', 'glitter color'].contains(paramKey) ? newValue.round() : c3,
                                                'o1': o1,
                                                'o2': o2,
                                                'o3': o3,
                                              }],
                                            };
                                            await setPreset(widget.deviceIp, newSettings);
                                            widget.onSettingsModified();
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}