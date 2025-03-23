import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../effects_database.dart';

// Helper to convert hex color to RGB array with debugging
List<int> hexToRgb(String hex) {
  hex = hex.replaceAll('#', ''); // Remove # if present
  if (hex.length == 6) {
    try {
      final r = int.parse(hex.substring(0, 2), radix: 16);
      final g = int.parse(hex.substring(2, 4), radix: 16);
      final b = int.parse(hex.substring(4, 6), radix: 16);
      print('Parsed $hex to RGB: [$r, $g, $b]');
      return [r, g, b];
    } catch (e) {
      print('Error parsing hex color "$hex": $e');
      return [255, 255, 255]; // Default to white on error
    }
  }
  print('Invalid hex length for "$hex", expected 6 digits');
  return [255, 255, 255]; // Default to white if invalid
}

// API call to get the state of a WLED device
Future<Map<String, dynamic>> getState(String ip) async {
  try {
    final response = await http.get(Uri.parse('http://$ip/json/state'));
    if (response.statusCode == 200) {
      final state = jsonDecode(response.body) as Map<String, dynamic>;
      return state;
    } else {
      throw Exception('Failed to get state: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to get state: $e');
  }
}

// API call to set the power state of a WLED device
Future<void> setPower(String ip, bool value) async {
  try {
    final response = await http.post(
      Uri.parse('http://$ip/json/state'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'on': value}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to set power: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to set power: $e');
  }
}

// API call to set the brightness of a WLED device
Future<void> setBrightness(String ip, int value) async {
  try {
    final response = await http.post(
      Uri.parse('http://$ip/json/state'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'bri': value}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to set brightness: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to set brightness: $e');
  }
}

// API call to set a preset on a WLED device
Future<void> setPreset(String ip, Map<String, dynamic> settings) async {
  try {
    // Extract settings with defaults
    final effectName = settings['effect'] ?? 'Solid';
    final effectId = EffectsDatabase.getEffectId(effectName);
    final palette = settings['palette'] as int? ?? 0;
    final colors = settings['colors'] as List<dynamic>?; // Expecting a list
    final speed = settings['speed'] as int?;
    final intensity = settings['intensity'] as int?;
    final c1 = settings['custom1'] as int?;
    final c2 = settings['custom2'] as int?;
    final c3 = settings['custom3'] as int?;
    final o1 = settings['option1'] as bool?;
    final o2 = settings['option2'] as bool?;
    final o3 = settings['option3'] as bool?;

    // Log the raw settings
    print('Settings received: $settings');

    // Convert colors to RGB, default to white if none provided
    final colorArray = colors != null && colors.isNotEmpty
        ? colors.map((c) => hexToRgb(c as String)).toList()
        : [[255, 255, 255]]; // Default to white if no colors

    // Log the converted colors
    print('Converted colorArray: $colorArray');

    // Pad or truncate to exactly 3 colors for WLED
    final paddedColors = [
      colorArray.length > 0 ? colorArray[0] : [255, 255, 255],
      colorArray.length > 1 ? colorArray[1] : [0, 0, 0],
      colorArray.length > 2 ? colorArray[2] : [0, 0, 0],
    ];

    // Log the final padded colors
    print('Padded colors: $paddedColors');

    final payload = {
      'seg': [
        {
          'id': 0,
          'start': 0,
          'stop': 9999,
          'on': true,
          'col': paddedColors,
          'fx': effectId,
          'pal': palette,
          if (speed != null) 'sx': speed,
          if (intensity != null) 'ix': intensity,
          if (c1 != null) 'c1': c1,
          if (c2 != null) 'c2': c2,
          if (c3 != null) 'c3': c3,
          if (o1 != null) 'o1': o1,
          if (o2 != null) 'o2': o2,
          if (o3 != null) 'o3': o3,
        }
      ]
    };

    // Log the final payload
    print('Sending payload: ${jsonEncode(payload)}');

    final response = await http.post(
      Uri.parse('http://$ip/json/state'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to set preset: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to set preset: $e');
  }
}

// Helper to extract the first color from the state
Color extractFirstColor(Map<String, dynamic> state) {
  final segments = state['seg'] as List<dynamic>?;
  if (segments != null && segments.isNotEmpty) {
    final segment = segments[0] as Map<String, dynamic>;
    final col = segment['col'] as List<dynamic>?;
    if (col != null && col.isNotEmpty) {
      final firstColor = col[0] as List<dynamic>;
      if (firstColor.length >= 3) {
        return Color.fromRGBO(firstColor[0], firstColor[1], firstColor[2], 1.0);
      }
    }
  }
  return Colors.grey;
}