import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/wled_state.dart';
import '../models/effect_metadata.dart';

class WledApiService {
  final String baseUrl;

  WledApiService(this.baseUrl);

  Future<WledState> getState() async {
    final url = '$baseUrl/json/state';
    try {
      final response = await http.get(Uri.parse(url));
      print('getState response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        return WledState.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load state: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching state from $url: $e');
      rethrow;
    }
  }

  Future<void> setState(WledState state) async {
    final url = '$baseUrl/json/state';
    try {
      final payload = state.toJson();
      print('Sending state update to $url: $payload');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update state: ${response.statusCode} - ${response.body}');
      }
      print('State update successful: ${response.body}');
    } catch (e) {
      print('Error updating state to $url: $e');
      rethrow;
    }
  }

  Future<List<EffectMetadata>> getEffects() async {
    final url = '$baseUrl/json';
    try {
      final response = await http.get(Uri.parse(url));
      print('getEffects response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('effects')) {
          final effectNames = List<String>.from(data['effects']);
          return effectNames.asMap().entries.map((entry) {
            final id = entry.key;
            final name = entry.value;
            return EffectMetadata.fallbackForIndex(id, name);
          }).toList();
        } else {
          throw Exception('Effects not found in API response');
        }
      } else {
        throw Exception('Failed to load effects: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching effects from $url: $e');
      rethrow;
    }
  }

  Future<List<String>> getPalettes() async {
    final url = '$baseUrl/json';
    try {
      final response = await http.get(Uri.parse(url));
      print('getPalettes response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('palettes')) {
          return List<String>.from(data['palettes']);
        } else {
          throw Exception('Palettes not found in API response');
        }
      } else {
        throw Exception('Failed to load palettes: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching palettes from $url: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPresets() async {
    final url = '$baseUrl/json';
    try {
      final response = await http.get(Uri.parse(url));
      print('getPresets response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('presets')) {
          return Map<String, dynamic>.from(data['presets']);
        } else {
          throw Exception('Presets not found in API response');
        }
      } else {
        throw Exception('Failed to load presets: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching presets from $url: $e');
      rethrow;
    }
  }

  Future<bool> doesEffectUsePalette(int effectId) async {
    final effects = await getEffects();
    final effect = effects.firstWhere(
      (e) => e.id == effectId,
      orElse: () => EffectMetadata.fallbackForIndex(effectId, 'Unknown'),
    );
    return effect.supportsPalette;
  }
}