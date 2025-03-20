class EffectMetadata {
  final int id;
  final String name;
  final int colorCount; // Number of colors the effect can use (0, 1, 2, or 3)
  final bool supportsPalette; // Whether the effect supports palettes
  final int defaultPalette; // Default palette ID (e.g., 0 for Default, 11 for Rainbow)
  final List<String> sliders; // List of sliders (e.g., ["Speed", "Intensity"])
  final bool overlaySwitch; // Whether the effect supports overlay

  EffectMetadata({
    required this.id,
    required this.name,
    required this.colorCount,
    required this.supportsPalette,
    required this.defaultPalette,
    required this.sliders,
    required this.overlaySwitch,
  });

  // Fallback metadata for specific effects if API doesn't provide it
  static EffectMetadata fallbackForIndex(int id, String name) {
    switch (id) {
      case 0: // Solid
        return EffectMetadata(
          id: id,
          name: "Solid",
          colorCount: 1,
          supportsPalette: false,
          defaultPalette: 0,
          sliders: [],
          overlaySwitch: false,
        );
      case 1: // Blink
        return EffectMetadata(
          id: id,
          name: "Blink",
          colorCount: 2, // Primary and secondary colors for blinking
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"], // As specified by the user
          overlaySwitch: false,
        );
      case 2: // Breathe
        return EffectMetadata(
          id: id,
          name: "Breathe",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 3: // Wipe
        return EffectMetadata(
          id: id,
          name: "Wipe",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 4: // Wipe Random
        return EffectMetadata(
          id: id,
          name: "Wipe Random",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 5: // Random Colors
        return EffectMetadata(
          id: id,
          name: "Random Colors",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 6: // Sweep
        return EffectMetadata(
          id: id,
          name: "Sweep",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 7: // Dynamic
        return EffectMetadata(
          id: id,
          name: "Dynamic",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 8: // Colorloop
        return EffectMetadata(
          id: id,
          name: "Colorloop",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 9: // Rainbow
        return EffectMetadata(
          id: id,
          name: "Rainbow",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 11, // Rainbow palette
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 10: // Scan
        return EffectMetadata(
          id: id,
          name: "Scan",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 11: // Scan Dual
        return EffectMetadata(
          id: id,
          name: "Scan Dual",
          colorCount: 2,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 12: // Fade
        return EffectMetadata(
          id: id,
          name: "Fade",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 13: // Theater
        return EffectMetadata(
          id: id,
          name: "Theater",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 14: // Theater Rainbow
        return EffectMetadata(
          id: id,
          name: "Theater Rainbow",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 11,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 15: // Running
        return EffectMetadata(
          id: id,
          name: "Running",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 16: // Saw
        return EffectMetadata(
          id: id,
          name: "Saw",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 17: // Twinkle
        return EffectMetadata(
          id: id,
          name: "Twinkle",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 18: // Dissolve
        return EffectMetadata(
          id: id,
          name: "Dissolve",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 19: // Dissolve Random
        return EffectMetadata(
          id: id,
          name: "Dissolve Random",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 20: // Sparkle
        return EffectMetadata(
          id: id,
          name: "Sparkle",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 21: // Dark Sparkle
        return EffectMetadata(
          id: id,
          name: "Dark Sparkle",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 22: // Sparkle+
        return EffectMetadata(
          id: id,
          name: "Sparkle+",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 23: // Strobe
        return EffectMetadata(
          id: id,
          name: "Strobe",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 24: // Strobe Rainbow
        return EffectMetadata(
          id: id,
          name: "Strobe Rainbow",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 11,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 25: // Mega Strobe
        return EffectMetadata(
          id: id,
          name: "Mega Strobe",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 26: // Blink Rainbow
        return EffectMetadata(
          id: id,
          name: "Blink Rainbow",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 11,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 27: // Android
        return EffectMetadata(
          id: id,
          name: "Android",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 28: // Chase
        return EffectMetadata(
          id: id,
          name: "Chase",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 29: // Chase Random
        return EffectMetadata(
          id: id,
          name: "Chase Random",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 30: // Chase Rainbow
        return EffectMetadata(
          id: id,
          name: "Chase Rainbow",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 11,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 31: // Chase Flash
        return EffectMetadata(
          id: id,
          name: "Chase Flash",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 32: // Chase Flash Random
        return EffectMetadata(
          id: id,
          name: "Chase Flash Random",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 33: // Chase 2
        return EffectMetadata(
          id: id,
          name: "Chase 2",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 34: // Rainbow Runner
        return EffectMetadata(
          id: id,
          name: "Rainbow Runner",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 11,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 35: // Colorful
        return EffectMetadata(
          id: id,
          name: "Colorful",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 36: // Traffic Light
        return EffectMetadata(
          id: id,
          name: "Traffic Light",
          colorCount: 0,
          supportsPalette: false, // Fixed colors (red, yellow, green)
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 37: // Sweep Random
        return EffectMetadata(
          id: id,
          name: "Sweep Random",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 38: // Running 2
        return EffectMetadata(
          id: id,
          name: "Running 2",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 39: // Red & Blue
        return EffectMetadata(
          id: id,
          name: "Red & Blue",
          colorCount: 0,
          supportsPalette: false, // Fixed colors (red and blue)
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 40: // Stream
        return EffectMetadata(
          id: id,
          name: "Stream",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 41: // Scanner
        return EffectMetadata(
          id: id,
          name: "Scanner",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 42: // Lighthouse
        return EffectMetadata(
          id: id,
          name: "Lighthouse",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 43: // Fireworks 1D
        return EffectMetadata(
          id: id,
          name: "Fireworks 1D",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 11, // Rainbow palette, as per user example
          sliders: ["Gravity", "Firing side"],
          overlaySwitch: true,
        );
      case 44: // Rain
        return EffectMetadata(
          id: id,
          name: "Rain",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 45: // Popcorn
        return EffectMetadata(
          id: id,
          name: "Popcorn",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 46: // Fire Flicker
        return EffectMetadata(
          id: id,
          name: "Fire Flicker",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 47: // Gradient
        return EffectMetadata(
          id: id,
          name: "Gradient",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 48: // Meteor
        return EffectMetadata(
          id: id,
          name: "Meteor",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 49: // Meteor Smooth
        return EffectMetadata(
          id: id,
          name: "Meteor Smooth",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 50: // Fireworks Starburst
        return EffectMetadata(
          id: id,
          name: "Fireworks Starburst",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 11,
          sliders: ["Chance", "Fragments"],
          overlaySwitch: true,
        );
      case 51: // Fireworks 1D Rainbow
        return EffectMetadata(
          id: id,
          name: "Fireworks 1D Rainbow",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 11,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 52: // Sinelon
        return EffectMetadata(
          id: id,
          name: "Sinelon",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 53: // Sinelon Dual
        return EffectMetadata(
          id: id,
          name: "Sinelon Dual",
          colorCount: 2,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 54: // Sinelon Rainbow
        return EffectMetadata(
          id: id,
          name: "Sinelon Rainbow",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 11,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 55: // Ripple
        return EffectMetadata(
          id: id,
          name: "Ripple",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 56: // Ripple Rainbow
        return EffectMetadata(
          id: id,
          name: "Ripple Rainbow",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 11,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 57: // Twinkleup
        return EffectMetadata(
          id: id,
          name: "Twinkleup",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 58: // Twinklecat
        return EffectMetadata(
          id: id,
          name: "Twinklecat",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 59: // Twinklefox
        return EffectMetadata(
          id: id,
          name: "Twinklefox",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 60: // Aurora
        return EffectMetadata(
          id: id,
          name: "Aurora",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 61: // Blends
        return EffectMetadata(
          id: id,
          name: "Blends",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Shift speed", "Blend speed"],
          overlaySwitch: false,
        );
      case 62: // Perlin Move
        return EffectMetadata(
          id: id,
          name: "Perlin Move",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["# of pixels", "Fade rate"],
          overlaySwitch: false,
        );
      case 63: // Wavesins
        return EffectMetadata(
          id: id,
          name: "Wavesins",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity", "Custom1", "Custom2", "Custom3"],
          overlaySwitch: false,
        );
      case 64: // TV Simulator
        return EffectMetadata(
          id: id,
          name: "TV Simulator",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 65: // Lake
        return EffectMetadata(
          id: id,
          name: "Lake",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 66: // Dynamic Smooth
        return EffectMetadata(
          id: id,
          name: "Dynamic Smooth",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 67: // Polar Lights
        return EffectMetadata(
          id: id,
          name: "Polar Lights",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 68: // Merry Christmas
        return EffectMetadata(
          id: id,
          name: "Merry Christmas",
          colorCount: 0,
          supportsPalette: false, // Fixed festive colors
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 69: // Halloween
        return EffectMetadata(
          id: id,
          name: "Halloween",
          colorCount: 0,
          supportsPalette: false, // Fixed Halloween colors
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 70: // Tri Chase
        return EffectMetadata(
          id: id,
          name: "Tri Chase",
          colorCount: 3,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 71: // Tri Wipe
        return EffectMetadata(
          id: id,
          name: "Tri Wipe",
          colorCount: 3,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 72: // Tri Fade
        return EffectMetadata(
          id: id,
          name: "Tri Fade",
          colorCount: 3,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 73: // Lightning
        return EffectMetadata(
          id: id,
          name: "Lightning",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 74: // ICU
        return EffectMetadata(
          id: id,
          name: "ICU",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 75: // Multi Comet
        return EffectMetadata(
          id: id,
          name: "Multi Comet",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 76: // Dual Scanner
        return EffectMetadata(
          id: id,
          name: "Dual Scanner",
          colorCount: 2,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 77: // Stream 2
        return EffectMetadata(
          id: id,
          name: "Stream 2",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 78: // Oscillate
        return EffectMetadata(
          id: id,
          name: "Oscillate",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 79: // Pride 2015
        return EffectMetadata(
          id: id,
          name: "Pride 2015",
          colorCount: 0,
          supportsPalette: false, // Fixed pride colors
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 80: // Juggle
        return EffectMetadata(
          id: id,
          name: "Juggle",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 81: // Palette
        return EffectMetadata(
          id: id,
          name: "Palette",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 82: // Fire 2012
        return EffectMetadata(
          id: id,
          name: "Fire 2012",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 83: // Colorwaves
        return EffectMetadata(
          id: id,
          name: "Colorwaves",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 84: // BPM
        return EffectMetadata(
          id: id,
          name: "BPM",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 85: // Fill Noise
        return EffectMetadata(
          id: id,
          name: "Fill Noise",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 86: // Noise 1
        return EffectMetadata(
          id: id,
          name: "Noise 1",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 87: // Noise 2
        return EffectMetadata(
          id: id,
          name: "Noise 2",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 88: // Noise 3
        return EffectMetadata(
          id: id,
          name: "Noise 3",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 89: // Noise 4
        return EffectMetadata(
          id: id,
          name: "Noise 4",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 90: // Colortwinkle
        return EffectMetadata(
          id: id,
          name: "Colortwinkle",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 91: // Lake 2
        return EffectMetadata(
          id: id,
          name: "Lake 2",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 92: // Meteor 2
        return EffectMetadata(
          id: id,
          name: "Meteor 2",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 93: // Smooth Meteor 2
        return EffectMetadata(
          id: id,
          name: "Smooth Meteor 2",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 94: // Railway
        return EffectMetadata(
          id: id,
          name: "Railway",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 95: // Ripple 2
        return EffectMetadata(
          id: id,
          name: "Ripple 2",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 96: // Twinklefox 2
        return EffectMetadata(
          id: id,
          name: "Twinklefox 2",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 97: // In Out
        return EffectMetadata(
          id: id,
          name: "In Out",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 98: // In In
        return EffectMetadata(
          id: id,
          name: "In In",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 99: // Out Out
        return EffectMetadata(
          id: id,
          name: "Out Out",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 100: // Out In
        return EffectMetadata(
          id: id,
          name: "Out In",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 101: // Circus
        return EffectMetadata(
          id: id,
          name: "Circus",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 102: // Halloween 2
        return EffectMetadata(
          id: id,
          name: "Halloween 2",
          colorCount: 0,
          supportsPalette: false,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 103: // Tri Chase 2
        return EffectMetadata(
          id: id,
          name: "Tri Chase 2",
          colorCount: 3,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 104: // Tri Wipe 2
        return EffectMetadata(
          id: id,
          name: "Tri Wipe 2",
          colorCount: 3,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 105: // Tri Fade 2
        return EffectMetadata(
          id: id,
          name: "Tri Fade 2",
          colorCount: 3,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 106: // Lightning 2
        return EffectMetadata(
          id: id,
          name: "Lightning 2",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: true,
        );
      case 107: // ICU 2
        return EffectMetadata(
          id: id,
          name: "ICU 2",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 108: // Multi Comet 2
        return EffectMetadata(
          id: id,
          name: "Multi Comet 2",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 109: // Dual Scanner 2
        return EffectMetadata(
          id: id,
          name: "Dual Scanner 2",
          colorCount: 2,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 110: // Stream 2 (duplicate)
        return EffectMetadata(
          id: id,
          name: "Stream 2 (2)",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 111: // Oscillate 2
        return EffectMetadata(
          id: id,
          name: "Oscillate 2",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 112: // Pride 2015 2
        return EffectMetadata(
          id: id,
          name: "Pride 2015 2",
          colorCount: 0,
          supportsPalette: false,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 113: // Juggle 2
        return EffectMetadata(
          id: id,
          name: "Juggle 2",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 114: // Palette 2
        return EffectMetadata(
          id: id,
          name: "Palette 2",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 115: // Fire 2012 2
        return EffectMetadata(
          id: id,
          name: "Fire 2012 2",
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
      case 116: // Colorwaves 2
        return EffectMetadata(
          id: id,
          name: "Colorwaves 2",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      case 117: // BPM 2
        return EffectMetadata(
          id: id,
          name: "BPM 2",
          colorCount: 0,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed"],
          overlaySwitch: false,
        );
      default:
        // Default to 1 color, palette supported, with Speed and Intensity sliders
        return EffectMetadata(
          id: id,
          name: name,
          colorCount: 1,
          supportsPalette: true,
          defaultPalette: 0,
          sliders: ["Speed", "Intensity"],
          overlaySwitch: false,
        );
    }
  }
}