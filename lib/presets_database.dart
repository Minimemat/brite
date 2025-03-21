import 'package:flutter/material.dart';
import 'effects_database.dart';
import 'palettes_database.dart';

class Preset {
  final String name;
  final String description;
  final IconData icon;
  final List<String> categories; // Multiple categories
  final String effectName; // Reference to WLEDEffect name
  final String? color; // Hex color (optional if palette is used)
  final int? paletteId; // Reference to WLEDPalette ID (optional)
  bool isSelected;

  Preset({
    required this.name,
    required this.description,
    required this.icon,
    required this.categories,
    required this.effectName,
    this.color,
    this.paletteId,
    this.isSelected = false,
  });

  Map<String, dynamic> toSettings() {
    return {
      'effect': effectName,
      if (color != null) 'color': color,
      if (paletteId != null) 'palette': paletteId,
    };
  }

  String getEffect() {
    final effect = EffectsDatabase.getEffectByName(effectName);
    return effect?.name ?? 'Unknown';
  }

  String getColorsOrPalette() {
    if (color != null) return '#$color';
    if (paletteId != null) {
      final palette = PalettesDatabase.getPaletteById(paletteId!);
      return 'Palette: ${palette?.name ?? 'Unknown'}';
    }
    return 'No Palette';
  }
}

class PresetDatabase {
  static final List<Preset> _presets = [
    // Test Presets
    Preset(
      name: 'Solid Red',
      description: 'A solid red color across all LEDs.',
      icon: Icons.lightbulb,
      categories: ['Test'],
      effectName: 'Solid',
      color: 'FF0000',
    ),
    Preset(
      name: 'Fading Blue',
      description: 'A fading blue effect that transitions smoothly.',
      icon: Icons.waves,
      categories: ['Test'],
      effectName: 'Fade',
      color: '0000FF',
    ),
    Preset(
      name: 'Twinkling Stars',
      description: 'White twinkling lights on a black background.',
      icon: Icons.star,
      categories: ['Test'],
      effectName: 'Twinkle',
      color: 'FFFFFF',
    ),
    Preset(
      name: 'Rainbow Cycle',
      description: 'A rainbow effect cycling through all colors.',
      icon: Icons.color_lens,
      categories: ['Test'],
      effectName: 'Rainbow',
      paletteId: 11, // Rainbow palette
    ),
    Preset(
      name: 'Fire Simulation',
      description: 'A fire effect with red and yellow flickering.',
      icon: Icons.local_fire_department,
      categories: ['Test'],
      effectName: 'Fire Flicker',
      color: 'FF4500',
    ),

    // Holidays (Canada 2026)
    Preset(
      name: 'New Year’s Day',
      description: 'A bright white glow to start the year.',
      icon: Icons.celebration,
      categories: ['Holidays'],
      effectName: 'Solid',
      color: 'FFFFFF',
    ),
    Preset(
      name: 'Good Friday',
      description: 'A solemn purple tone for reflection.',
      icon: Icons.church,
      categories: ['Holidays'],
      effectName: 'Solid',
      color: '800080',
    ),
    Preset(
      name: 'Easter Monday',
      description: 'Soft pastel colors for spring.',
      icon: Icons.egg,
      categories: ['Holidays'],
      effectName: 'Fade',
      paletteId: 20, // Pastel palette
    ),
    Preset(
      name: 'Victoria Day',
      description: 'Royal purple and gold celebration.',
      icon: Icons.crop,
      categories: ['Holidays'],
      effectName: 'Blink',
      color: 'FFD700',
    ),
    Preset(
      name: 'Canada Day',
      description: 'Red and white for national pride.',
      icon: Icons.flag,
      categories: ['Holidays'],
      effectName: 'Solid',
      color: 'FF0000',
    ),
    Preset(
      name: 'Labour Day',
      description: 'A hardworking blue and white theme.',
      icon: Icons.work,
      categories: ['Holidays'],
      effectName: 'Solid',
      color: '0000FF',
    ),
    Preset(
      name: 'National Day for Truth and Reconciliation',
      description: 'Orange to honor Indigenous communities.',
      icon: Icons.handshake,
      categories: ['Holidays'],
      effectName: 'Solid',
      color: 'FFA500',
    ),
    Preset(
      name: 'Thanksgiving Day',
      description: 'Warm autumn tones for gratitude.',
      icon: Icons.local_florist,
      categories: ['Holidays'],
      effectName: 'Fade',
      paletteId: 39, // Autumn palette
    ),
    Preset(
      name: 'Remembrance Day',
      description: 'Red poppies and a solemn tone.',
      icon: Icons.local_florist,
      categories: ['Holidays'],
      effectName: 'Solid',
      color: 'FF0000',
    ),
    Preset(
      name: 'Christmas Day',
      description: 'Festive red, green, and white lights.',
      icon: Icons.star,
      categories: ['Holidays'],
      effectName: 'Twinkle',
      paletteId: 48, // C9 palette (Christmas lights)
    ),
    Preset(
      name: 'Boxing Day',
      description: 'Cool blue for post-Christmas relaxation.',
      icon: Icons.card_giftcard,
      categories: ['Holidays'],
      effectName: 'Solid',
      color: '00BFFF',
    ),

    // Accents
    Preset(
      name: 'Sunset Glow',
      description: 'A warm orange glow mimicking a sunset.',
      icon: Icons.wb_sunny,
      categories: ['Accents'],
      effectName: 'Fade',
      paletteId: 13, // Sunset palette
    ),
    Preset(
      name: 'Ocean Breeze',
      description: 'Cool blue tones like a refreshing ocean wave.',
      icon: Icons.waves,
      categories: ['Accents'],
      effectName: 'Wave',
      paletteId: 9, // Ocean palette
    ),
    Preset(
      name: 'Forest Canopy',
      description: 'Deep green shades for a natural forest feel.',
      icon: Icons.park,
      categories: ['Accents'],
      effectName: 'Solid',
      paletteId: 10, // Forest palette
    ),

    // Sports
    Preset(
      name: 'Hockey Night',
      description: 'Icy blue and white for a hockey game vibe.',
      icon: Icons.sports_hockey,
      categories: ['Sports'],
      effectName: 'Blink',
      color: 'ADD8E6',
    ),
    Preset(
      name: 'Soccer Fever',
      description: 'Green field with black and white accents.',
      icon: Icons.sports_soccer,
      categories: ['Sports'],
      effectName: 'Solid',
      color: '008000',
    ),
    Preset(
      name: 'Olympic Spirit',
      description: 'Colors of the Olympic rings for global unity.',
      icon: Icons.sports,
      categories: ['Sports', 'Events'],
      effectName: 'Rainbow',
      paletteId: 11, // Rainbow palette
    ),

    // Events
    Preset(
      name: 'Fire Spark',
      description: 'Fiery red and yellow flickering like a flame.',
      icon: Icons.local_fire_department,
      categories: ['Events'],
      effectName: 'Fire Flicker',
      paletteId: 35, // Fire palette
    ),
    Preset(
      name: 'Starry Night',
      description: 'Twinkling white lights on a dark blue background.',
      icon: Icons.nights_stay,
      categories: ['Events'],
      effectName: 'Twinkle',
      color: '00008B',
    ),
    Preset(
      name: 'Festival Lights',
      description: 'Colorful lights for a festive celebration.',
      icon: Icons.celebration,
      categories: ['Events'],
      effectName: 'Rainbow',
      paletteId: 6, // Party palette
    ),
  ];

  static List<Preset> getPresets() => _presets;

  static List<Preset> getPresetsByCategory(String category) {
    if (category == 'All') return _presets;
    return _presets.where((preset) => preset.categories.contains(category)).toList();
  }
}