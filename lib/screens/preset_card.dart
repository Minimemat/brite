import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../presets_database.dart';
import '../effects_database.dart';
import '../palettes_database.dart';

class PresetCard extends StatelessWidget {
  final Preset preset;
  final VoidCallback onTap;

  const PresetCard({
    super.key,
    required this.preset,
    required this.onTap,
  });

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
    final effect = _getEffectById(preset.fx);
    final effectColors = (effect['colors'] as List<dynamic>?) ?? [];
    final presetColors = preset.colors ?? [];
    final paletteId = preset.paletteId ?? 0;

    // Ensure presetColors has at least 3 entries
    List<String> paddedColors = List.from(presetColors);
    while (paddedColors.length < 3) {
      paddedColors.add('000000'); // Default to black
    }

    // Convert hex colors to RGB format for consistency
    List<List<int>> rgbColors = paddedColors.map((hex) {
      final rgb = hexToRgb(hex);
      return [rgb[0], rgb[1], rgb[2]];
    }).toList();

    // Update palettes with selected colors
    final updatedPalettes = PalettesDatabase.updatePalettesWithSelectedColors(rgbColors);
    final palette = preset.paletteId != null ? _getPaletteById(preset.paletteId!, updatedPalettes) : null;
    final paletteColors = palette != null ? (palette['colors'] as List<dynamic>?) ?? [] : [];

    // Determine the number of colors to show and swatch details
    int numColorsToShow;
    List<String> swatchLabels = [];
    List<List<int>> swatchColors = [];
    if ([2, 3, 4, 5].contains(paletteId)) {
      if (paletteId == 2) { // Color 1
        numColorsToShow = 1;
        swatchLabels = ['Fx'];
        swatchColors = [rgbColors[0]];
      } else if (paletteId == 3) { // Colors 1&2
        numColorsToShow = 2;
        swatchLabels = ['Fx', 'Bg'];
        swatchColors = [rgbColors[0], rgbColors[1]];
      } else { // Color Gradient (4), Colors Only (5)
        numColorsToShow = 3;
        swatchLabels = ['Fx', 'Bg', 'Cs'];
        swatchColors = [rgbColors[0], rgbColors[1], rgbColors[2]];
      }
    } else {
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
        return rgbColors[colorIdx];
      });
    }

    // Determine if we should show the palette gradient
    final showPaletteGradient = paletteId != 0 && paletteColors.isNotEmpty;

    // Build the color display widget
    Widget colorDisplay = Container(
      width: 48,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(
          color: preset.isSelected ? Colors.white : Colors.white70,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        gradient: showPaletteGradient
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
      child: !showPaletteGradient
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                numColorsToShow > 3 ? 3 : numColorsToShow,
                (index) {
                  final color = swatchColors[index];
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
    );

    return Card(
      elevation: preset.isSelected ? 8.0 : 2.0,
      color: preset.isSelected ? Colors.blue[700] : const Color(0xFF2D3436),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Color display on the left
              colorDisplay,
              const SizedBox(width: 16),
              // Text content in the middle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: preset.isSelected ? Colors.white : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preset.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: preset.isSelected ? Colors.white70 : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Effect: ${effect['name']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: preset.isSelected ? Colors.white70 : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Icon on the right
              Icon(
                preset.icon,
                size: 40,
                color: preset.isSelected ? Colors.white : Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to convert hex to RGB (copied from api.dart)
  List<int> hexToRgb(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      try {
        final r = int.parse(hex.substring(0, 2), radix: 16);
        final g = int.parse(hex.substring(2, 4), radix: 16);
        final b = int.parse(hex.substring(4, 6), radix: 16);
        return [r, g, b, 0];
      } catch (e) {
        return [255, 255, 255, 0];
      }
    }
    return [255, 255, 255, 0];
  }
}