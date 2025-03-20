import 'dart:ui';

class WledState {
  final bool on;
  final int brightness;
  final Color primaryColor;
  final Color? secondaryColor;
  final Color? tertiaryColor;
  final String effect;
  final int effectSpeed;
  final int effectIntensity;
  final int paletteIndex; // Added paletteIndex field

  WledState({
    required this.on,
    required this.brightness,
    required this.primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
    required this.effect,
    required this.effectSpeed,
    required this.effectIntensity,
    required this.paletteIndex, // Added to constructor
  });

  factory WledState.fromJson(Map<String, dynamic> json) {
    final effectSpeedRaw = json['seg']?[0]?['sx'] ?? 128;
    final effectIntensityRaw = json['seg']?[0]?['ix'] ?? 128;
    final colArray = json['seg']?[0]?['col'] ?? [];
    final primaryColorList = colArray.isNotEmpty ? colArray[0] : [255, 0, 0];
    final secondaryColorList = colArray.length > 1 ? colArray[1] : null;
    final tertiaryColorList = colArray.length > 2 ? colArray[2] : null;

    return WledState(
      on: json['on'] ?? true,
      brightness: json['bri'] ?? 128,
      primaryColor: Color.fromRGBO(
        primaryColorList[0] ?? 255,
        primaryColorList[1] ?? 0,
        primaryColorList[2] ?? 0,
        1.0,
      ),
      secondaryColor: secondaryColorList != null
          ? Color.fromRGBO(
              secondaryColorList[0] ?? 0,
              secondaryColorList[1] ?? 0,
              secondaryColorList[2] ?? 0,
              1.0,
            )
          : null,
      tertiaryColor: tertiaryColorList != null
          ? Color.fromRGBO(
              tertiaryColorList[0] ?? 0,
              tertiaryColorList[1] ?? 0,
              tertiaryColorList[2] ?? 0,
              1.0,
            )
          : null,
      effect: json['seg']?[0]?['fx']?.toString() ?? '0',
      effectSpeed: effectSpeedRaw is int
          ? effectSpeedRaw
          : int.tryParse(effectSpeedRaw.toString()) ?? 128,
      effectIntensity: effectIntensityRaw is int
          ? effectIntensityRaw
          : int.tryParse(effectIntensityRaw.toString()) ?? 128,
      paletteIndex: json['seg']?[0]?['pal'] ?? 0, // Added paletteIndex parsing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'on': on,
      'bri': brightness,
      'seg': [
        {
          'col': [
            [primaryColor.red, primaryColor.green, primaryColor.blue],
            if (secondaryColor != null)
              [secondaryColor!.red, secondaryColor!.green, secondaryColor!.blue],
            if (tertiaryColor != null)
              [tertiaryColor!.red, tertiaryColor!.green, tertiaryColor!.blue],
          ],
          'fx': int.parse(effect),
          'sx': effectSpeed,
          'ix': effectIntensity,
          'pal': paletteIndex, // Added paletteIndex to JSON
        }
      ],
    };
  }
}