// api.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nsd/nsd.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Helper to convert Color object to RGB array
List<int> colorToRgb(Color color) {
  try {
    final rgb = [color.red, color.green, color.blue, 0];
    print('Converted color ${color.value.toRadixString(16)} to RGB: $rgb');
    return rgb;
  } catch (e) {
    print('Error converting color: $e');
    return [255, 255, 255, 0];
  }
}

// Helper to convert hex string to RGB array
List<int> hexToRgb(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) {
    try {
      final r = int.parse(hex.substring(0, 2), radix: 16);
      final g = int.parse(hex.substring(2, 4), radix: 16);
      final b = int.parse(hex.substring(4, 6), radix: 16);
      print('Parsed hex $hex to RGB: [$r, $g, $b, 0]');
      return [r, g, b, 0];
    } catch (e) {
      print('Error parsing hex color "$hex": $e');
      return [255, 255, 255, 0];
    }
  }
  print('Invalid hex length for "$hex", expected 6 digits');
  return [255, 255, 255, 0];
}

// Discover WLED devices using mDNS (not supported on web)
Future<List<Map<String, String>>> discoverWledDevices() async {
  if (kIsWeb) {
    // Web platform doesn't support mDNS discovery
    print('mDNS discovery is not supported on web platform');
    return [];
  }

  try {
    // Start mDNS discovery for WLED services (WLED typically uses "_wled._tcp")
    final discovery = await startDiscovery('_wled._tcp');
    final List<Map<String, String>> discoveredDevices = [];

    // Listen for discovered services for 5 seconds
    final streamSubscription = discovery.stream.listen((service) async {
      final addresses = service.addresses;
      final port = service.port;
      final name = service.name ?? 'Unknown WLED Device';

      if (addresses != null && addresses.isNotEmpty && port != null) {
        final address = addresses.first;
        print('Found WLED device: ${address.address}:$port');
        discoveredDevices.add({
          'name': name,
          'ip': address.address,
          'port': port.toString(),
        });
      }
    });

    // Stop discovery after 5 seconds
    await Future.delayed(Duration(seconds: 5));
    await streamSubscription.cancel();
    await stopDiscovery(discovery);

    return discoveredDevices;
  } catch (e) {
    print('Error discovering WLED devices: $e');
    return [];
  }
}

extension on Discovery {
  get stream => null;
}

// Get WLED device state
Future<Map<String, dynamic>> getState(String ip) async {
  try {
    final response = await http.get(Uri.parse('http://$ip/json/state'));
    if (response.statusCode == 200) {
      final state = jsonDecode(response.body) as Map<String, dynamic>;
      print('Retrieved state: $state');
      return state;
    } else {
      throw Exception('Failed to get state: ${response.statusCode}');
    }
  } catch (e) {
    print('Error getting state: $e');
    throw Exception('Failed to get state: $e');
  }
}

// Set power state
Future<void> setPower(String ip, bool value) async {
  try {
    final payload = {'on': value};
    final response = await http.post(
      Uri.parse('http://$ip/json/state'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to set power: ${response.statusCode}');
    }
    print('Power set to $value');
  } catch (e) {
    print('Error setting power: $e');
    throw Exception('Failed to set power: $e');
  }
}

// Set brightness
Future<void> setBrightness(String ip, int value) async {
  if (value < 0 || value > 255) {
    throw Exception('Brightness must be between 0 and 255');
  }
  try {
    final payload = {'bri': value};
    final response = await http.post(
      Uri.parse('http://$ip/json/state'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to set brightness: ${response.statusCode}');
    }
    print('Brightness set to $value');
  } catch (e) {
    print('Error setting brightness: $e');
    throw Exception('Failed to set brightness: $e');
  }
}

// Set custom preset with multiple segments
Future<void> setPreset(String ip, Map<String, dynamic> settings) async {
  try {
    // Handle both custom pattern and preset database cases
    final segments = settings['seg'] as List<dynamic>? ?? [];
    final effectId = settings['effect'] as int?;
    final colors = settings['colors'] as List<dynamic>?;
    final palette = settings['palette'] as int?;
    final speed = settings['speed'] as int?;
    final intensity = settings['intensity'] as int?;
    final c1 = settings['custom1'] as int?;
    final c2 = settings['custom2'] as int?;
    final c3 = settings['custom3'] as int?;
    final o1 = settings['option1'] as bool?;
    final o2 = settings['option2'] as bool?;
    final o3 = settings['option3'] as bool?;

    const maxSegments = 16;
    final activeSegments = segments.isNotEmpty ? segments.length : (colors != null ? 1 : 0);

    final allSegments = List<Map<String, dynamic>>.generate(maxSegments, (index) {
      if (segments.isNotEmpty && index < segments.length) {
        final seg = segments[index] as Map<String, dynamic>;
        return {
          'id': seg['id'] ?? index,
          'start': seg['start'] ?? 0,
          'stop': seg['stop'] ?? 1000,
          'grp': seg['grp'] ?? 1,
          'spc': seg['spc'] ?? 0,
          'of': seg['of'] ?? 0,
          'on': seg['on'] ?? true,
          'bri': seg['bri'] ?? 255,
          'col': seg['col'] ?? [[255, 255, 255, 0]],
          'fx': seg['fx'] ?? 0,
          'sx': seg['sx'] ?? 128,
          'ix': seg['ix'] ?? 128,
          'pal': seg['pal'] ?? 0,
          'sel': seg['sel'] ?? (index == 0),
          'rev': seg['rev'] ?? false,
          'mi': seg['mi'] ?? false,
        };
      } else if (index == 0 && colors != null && effectId != null) {
        // For preset database entries, create one segment
        return {
          'id': 0,
          'start': 0,
          'stop': 1000,
          'grp': 1,
          'spc': 0,
          'of': 0,
          'on': true,
          'bri': 255,
          'col': colors.map((color) => hexToRgb(color.toString())).toList(),
          'fx': effectId,
          'sx': speed ?? 128,
          'ix': intensity ?? 128,
          'pal': palette ?? 0,
          'c1': c1 ?? 128,
          'c2': c2 ?? 128,
          'c3': c3 ?? 16,
          'sel': true,
          'rev': false,
          'mi': false,
          'o1': o1 ?? false,
          'o2': o2 ?? false,
          'o3': o3 ?? false,
        };
      } else {
        return {'stop': 0}; // Terminate unused segments
      }
    });

    final payload = {
      'on': settings['on'] ?? true,
      'bri': settings['bri'] ?? 150,
      'mainseg': settings['mainseg'] ?? 0,
      'seg': allSegments,
      'transition': settings['transition'] ?? 7,
    };

    print('Sending preset payload: ${jsonEncode(payload)}');
    
    final response = await http.post(
      Uri.parse('http://$ip/json/state'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to set preset: ${response.statusCode} - ${response.body}');
    }
    print('Preset applied successfully: ${response.body}');
  } catch (e) {
    print('Error in setPreset: $e');
    throw Exception('Failed to set preset: $e');
  }
}

// Save a preset to WLED (create or overwrite)
Future<void> savePreset(String ip, int presetId, String name, Map<String, dynamic> settings) async {
  try {
    final segments = settings['seg'] as List<dynamic>? ?? [];
    final effectId = settings['effect'] as int?;
    final colors = settings['colors'] as List<dynamic>?;
    final palette = settings['palette'] as int?;
    final speed = settings['speed'] as int?;
    final intensity = settings['intensity'] as int?;
    final c1 = settings['custom1'] as int?;
    final c2 = settings['custom2'] as int?;
    final c3 = settings['custom3'] as int?;
    final o1 = settings['option1'] as bool?;
    final o2 = settings['option2'] as bool?;
    final o3 = settings['option3'] as bool?;

    const maxSegments = 16;
    final activeSegments = segments.isNotEmpty ? segments.length : (colors != null ? 1 : 0);

    final allSegments = List<Map<String, dynamic>>.generate(maxSegments, (index) {
      if (segments.isNotEmpty && index < segments.length) {
        final seg = segments[index] as Map<String, dynamic>;
        return {
          'id': seg['id'] ?? index,
          'start': seg['start'] ?? 0,
          'stop': seg['stop'] ?? 1000,
          'grp': seg['grp'] ?? 1,
          'spc': seg['spc'] ?? 0,
          'of': seg['of'] ?? 0,
          'on': seg['on'] ?? true,
          'bri': seg['bri'] ?? 255,
          'col': seg['col'] ?? [[255, 255, 255, 0]],
          'fx': seg['fx'] ?? 0,
          'sx': seg['sx'] ?? 128,
          'ix': seg['ix'] ?? 128,
          'pal': seg['pal'] ?? 0,
          'sel': seg['sel'] ?? (index == 0),
          'rev': seg['rev'] ?? false,
          'mi': seg['mi'] ?? false,
        };
      } else if (index == 0 && colors != null && effectId != null) {
        return {
          'id': 0,
          'start': 0,
          'stop': 1000,
          'grp': 1,
          'spc': 0,
          'of': 0,
          'on': true,
          'bri': 255,
          'col': colors.map((color) => hexToRgb(color.toString())).toList(),
          'fx': effectId,
          'sx': speed ?? 128,
          'ix': intensity ?? 128,
          'pal': palette ?? 0,
          'c1': c1 ?? 128,
          'c2': c2 ?? 128,
          'c3': c3 ?? 16,
          'sel': true,
          'rev': false,
          'mi': false,
          'o1': o1 ?? false,
          'o2': o2 ?? false,
          'o3': o3 ?? false,
        };
      } else {
        return {'stop': 0}; // Terminate unused segments
      }
    });

    final payload = {
      'on': settings['on'] ?? true,
      'bri': settings['bri'] ?? 150,
      'mainseg': settings['mainseg'] ?? 0,
      'seg': allSegments,
      'transition': settings['transition'] ?? 7,
      'psave': presetId,
      'n': name,
      'ib': true,
      'sb': true,
    };

    print('Saving preset $presetId: ${jsonEncode(payload)}');
    
    final response = await http.post(
      Uri.parse('http://$ip/json/state'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save preset $presetId: ${response.statusCode} - ${response.body}');
    }
    print('Preset $presetId saved successfully: ${response.body}');
  } catch (e) {
    print('Error in savePreset: $e');
    throw Exception('Failed to save preset: $e');
  }
}

// Set a timer on WLED
Future<void> setTimer(String ip, int slot, Map<String, dynamic> timerSettings) async {
  try {
    final payload = {
      'timer': {
        '$slot': timerSettings,
      },
    };

    print('Setting timer for slot $slot: ${jsonEncode(payload)}');
    
    final response = await http.post(
      Uri.parse('http://$ip/json'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to set timer for slot $slot: ${response.statusCode} - ${response.body}');
    }
    print('Timer for slot $slot set successfully: ${response.body}');
  } catch (e) {
    print('Error in setTimer: $e');
    throw Exception('Failed to set timer: $e');
  }
}

// Disable a timer on WLED
Future<void> disableTimer(String ip, int slot) async {
  try {
    final payload = {
      'timer': {
        '$slot': {
          'enabled': false,
        },
      },
    };

    print('Disabling timer for slot $slot: ${jsonEncode(payload)}');
    
    final response = await http.post(
      Uri.parse('http://$ip/json'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to disable timer for slot $slot: ${response.statusCode} - ${response.body}');
    }
    print('Timer for slot $slot disabled successfully: ${response.body}');
  } catch (e) {
    print('Error in disableTimer: $e');
    throw Exception('Failed to disable timer: $e');
  }
}

// Create preset from colors and effect with dynamic segments (for custom pattern screen only)
Map<String, dynamic> createPresetFromColors(List<Color> colors, int effectId, {int ledCount = 1000}) {
  try {
    final numSegments = colors.length;
    final spacing = numSegments > 1 ? (numSegments - 1) : 0;
    
    final segments = colors.asMap().entries.map((entry) {
      final index = entry.key;
      final color = entry.value;
      return {
        'id': index,
        'start': 0,
        'stop': ledCount,
        'grp': 1,
        'spc': spacing,
        'of': index,
        'on': true,
        'bri': 255,
        'col': [
          colorToRgb(color),
          [0, 0, 0, 0], // Second color black
          [0, 0, 0, 0], // Third color black
        ],
        'fx': effectId,
        'sx': 128,
        'ix': 128,
        'pal': 0,
      };
    }).toList();

    return {
      'bri': 150,
      'mainseg': 0,
      'on': true,
      'seg': segments,
      'transition': 7,
    };
  } catch (e) {
    print('Error creating preset: $e');
    rethrow;
  }
}

// Extract first color from state
Color extractFirstColor(Map<String, dynamic> state) {
  try {
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
  } catch (e) {
    print('Error extracting first color: $e');
    return Colors.grey;
  }
}