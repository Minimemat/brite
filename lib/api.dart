import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../effects_database.dart';

// Helper to convert hex color to RGB array
List<int> hexToRgb(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) {
    final r = int.parse(hex.substring(0, 2), radix: 16);
    final g = int.parse(hex.substring(2, 4), radix: 16);
    final b = int.parse(hex.substring(4, 6), radix: 16);
    return [r, g, b];
  }
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
    final color = settings['color'] != null ? hexToRgb(settings['color']) : [255, 255, 255];
    final effectName = settings['effect'] ?? 'Solid';
    final effectId = EffectsDatabase.getEffectId(effectName); // Convert effect name to ID
    final palette = settings['palette'] ?? 0;

    final payload = {
      'seg': [
        {
          'id': 0,
          'start': 0,
          'stop': 9999,
          'on': true,
          'col': [color],
          'fx': effectId, // Use the effect ID
          'pal': palette,
        }
      ]
    };

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