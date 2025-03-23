import 'package:flutter/material.dart';

class PalettesDatabase {
  static const List<Map<String, dynamic>> palettesDatabase = [
    // Standard palettes from WLED documentation (IDs 0-70)
    {
      'id': 0,
      'name': 'Default',
      'description': 'The palette is automatically selected depending on the effect. For most effects, this is the primary color.',
      'colors': ['Primary'],
    },
    {
      'id': 1,
      'name': 'Random Cycle',
      'description': 'The palette changes to a random one every few seconds. Subject to change.',
      'colors': [], // Colors vary randomly
    },
    {
      'id': 2,
      'name': 'Color 1',
      'description': 'A palette consisting only of the primary color.',
      'colors': ['Primary'],
    },
    {
      'id': 3,
      'name': 'Colors 1&2',
      'description': 'Consists of the primary and secondary color.',
      'colors': ['Primary', 'Secondary'],
    },
    {
      'id': 4,
      'name': 'Color Gradient',
      'description': 'A palette which is a mixture of all segment colors.',
      'colors': ['Primary', 'Secondary', 'Tertiary'],
    },
    {
      'id': 5,
      'name': 'Colors Only',
      'description': 'Contains primary, secondary and tertiary colors.',
      'colors': ['Primary', 'Secondary', 'Tertiary'],
    },
    // From ID 6 onwards, exclude the colors field (set to null)
    {
      'id': 6,
      'name': 'Party',
      'description': 'Rainbow without green hues.',
      'colors': null,
    },
    {
      'id': 7,
      'name': 'Cloud',
      'description': 'Gray-blueish colors.',
      'colors': null,
    },
    {
      'id': 8,
      'name': 'Lava',
      'description': 'Dark red, yellow and bright white.',
      'colors': null,
    },
    {
      'id': 9,
      'name': 'Ocean',
      'description': 'Blue, teal and white colors.',
      'colors': null,
    },
    {
      'id': 10,
      'name': 'Forest',
      'description': 'Yellow and green hues.',
      'colors': null,
    },
    {
      'id': 11,
      'name': 'Rainbow',
      'description': 'Every hue.',
      'colors': null,
    },
    {
      'id': 12,
      'name': 'Rainbow Bands',
      'description': 'Rainbow colors with black spots in-between.',
      'colors': null,
    },
    {
      'id': 13,
      'name': 'Sunset',
      'description': 'Dark blue with purple, red and yellow hues.',
      'colors': null,
    },
    {
      'id': 14,
      'name': 'Rivendell',
      'description': 'Desaturated greens.',
      'colors': null,
    },
    {
      'id': 15,
      'name': 'Breeze',
      'description': 'Teal colors with varying brightness.',
      'colors': null,
    },
    {
      'id': 16,
      'name': 'Red & Blue',
      'description': 'Red running on blue.',
      'colors': null,
    },
    {
      'id': 17,
      'name': 'Yellowout',
      'description': 'Yellow, fading out.',
      'colors': null,
    },
    {
      'id': 18,
      'name': 'Analogous',
      'description': 'Red running on blue.',
      'colors': null,
    },
    {
      'id': 19,
      'name': 'Splash',
      'description': 'Vibrant pink and magenta.',
      'colors': null,
    },
    {
      'id': 20,
      'name': 'Pastel',
      'description': 'Different hues with very little saturation.',
      'colors': null,
    },
    {
      'id': 21,
      'name': 'Sunset 2',
      'description': 'Yellow and white running on dim blue.',
      'colors': null,
    },
    {
      'id': 22,
      'name': 'Beach',
      'description': 'Different shades of light blue.',
      'colors': null,
    },
    {
      'id': 23,
      'name': 'Vintage',
      'description': 'Warm white running on very dim red.',
      'colors': null,
    },
    {
      'id': 24,
      'name': 'Departure',
      'description': 'Greens and white fading out.',
      'colors': null,
    },
    {
      'id': 25,
      'name': 'Landscape',
      'description': 'Blue, white and green gradient.',
      'colors': null,
    },
    {
      'id': 26,
      'name': 'Beech',
      'description': 'Teal and yellow gradient fading out.',
      'colors': null,
    },
    {
      'id': 27,
      'name': 'Sherbet',
      'description': 'Bright white, pink and mint colors.',
      'colors': null,
    },
    {
      'id': 28,
      'name': 'Hult',
      'description': 'White, magenta and teal.',
      'colors': null,
    },
    {
      'id': 29,
      'name': 'Hult 64',
      'description': 'Teal and yellow hues.',
      'colors': null,
    },
    {
      'id': 30,
      'name': 'Drywet',
      'description': 'Blue and yellow gradient.',
      'colors': null,
    },
    {
      'id': 31,
      'name': 'Jul',
      'description': 'Pastel green and red.',
      'colors': null,
    },
    {
      'id': 32,
      'name': 'Grintage',
      'description': 'Yellow fading out.',
      'colors': null,
    },
    {
      'id': 33,
      'name': 'Rewhi',
      'description': 'Bright orange on desaturated purple.',
      'colors': null,
    },
    {
      'id': 34,
      'name': 'Tertiary',
      'description': 'Red, green and blue gradient.',
      'colors': null,
    },
    {
      'id': 35,
      'name': 'Fire',
      'description': 'White, yellow and fading red gradient.',
      'colors': null,
    },
    {
      'id': 36,
      'name': 'Icefire',
      'description': 'Same as Fire, but with blue colors.',
      'colors': null,
    },
    {
      'id': 37,
      'name': 'Cyane',
      'description': 'Desaturated pastel colors.',
      'colors': null,
    },
    {
      'id': 38,
      'name': 'Light Pink',
      'description': 'Desaturated purple hues.',
      'colors': null,
    },
    {
      'id': 39,
      'name': 'Autumn',
      'description': 'Three white fields surrounded by yellow and dim red.',
      'colors': null,
    },
    {
      'id': 40,
      'name': 'Magenta',
      'description': 'White with magenta and blue.',
      'colors': null,
    },
    {
      'id': 41,
      'name': 'Magred',
      'description': 'Magenta and red hues.',
      'colors': null,
    },
    {
      'id': 42,
      'name': 'Yelmag',
      'description': 'Magenta and red hues with a yellow.',
      'colors': null,
    },
    {
      'id': 43,
      'name': 'Yelblu',
      'description': 'Blue with a little yellow.',
      'colors': null,
    },
    {
      'id': 44,
      'name': 'Orange & Teal',
      'description': 'An Orange - Gray - Teal gradient.',
      'colors': null,
    },
    {
      'id': 45,
      'name': 'Tiamat',
      'description': 'A bright meteor with blue, teal and magenta hues.',
      'colors': null,
    },
    {
      'id': 46,
      'name': 'April Night',
      'description': 'Dark blue background with colorful snowflakes.',
      'colors': null,
    },
    {
      'id': 47,
      'name': 'Orangery',
      'description': 'Orange and yellow tones.',
      'colors': null,
    },
    {
      'id': 48,
      'name': 'C9',
      'description': 'Christmas lights palette. Red - amber - green - blue.',
      'colors': null,
    },
    {
      'id': 49,
      'name': 'Sakura',
      'description': 'Pink and rose tones.',
      'colors': null,
    },
    {
      'id': 50,
      'name': 'Aurora',
      'description': 'Greens on dark blue.',
      'colors': null,
    },
    {
      'id': 51,
      'name': 'Atlantica',
      'description': 'Greens & Blues of the ocean.',
      'colors': null,
    },
    {
      'id': 52,
      'name': 'C9 2',
      'description': 'C9 plus yellow.',
      'colors': null,
    },
    {
      'id': 53,
      'name': 'C9 New',
      'description': 'C9, but brighter and with a less purple blue.',
      'colors': null,
    },
    {
      'id': 54,
      'name': 'Temperature',
      'description': 'Temperature mapping.',
      'colors': null,
    },
    {
      'id': 55,
      'name': 'Aurora 2',
      'description': 'Aurora with some pinks & blue.',
      'colors': null,
    },
    {
      'id': 56,
      'name': 'Retro Clown',
      'description': 'Yellow to purple gradient.',
      'colors': null,
    },
    {
      'id': 57,
      'name': 'Candy',
      'description': 'Vivid yellows, magenta, salmon and blues.',
      'colors': null,
    },
    {
      'id': 58,
      'name': 'Toxy Reaf',
      'description': 'Vivid aqua to purple gradient.',
      'colors': null,
    },
    {
      'id': 59,
      'name': 'Fairy Reaf',
      'description': 'Bright aqua to purple gradient.',
      'colors': null,
    },
    {
      'id': 60,
      'name': 'Semi Blue',
      'description': 'Dark blues with a bright blue burst.',
      'colors': null,
    },
    {
      'id': 61,
      'name': 'Pink Candy',
      'description': 'White, pinks and purple',
      'colors': null,
    },
    /*{
      'id': 62,
      'name': 'Emerald',
      'description': 'A rich palette of emerald greens and deep teals, inspired by precious gemstones.',
      'colors': null,
    },
    {
      'id': 63,
      'name': 'Sapphire',
      'description': 'A luxurious palette of deep blues and silvers, evoking the sparkle of sapphires.',
      'colors': null,
    },
    {
      'id': 64,
      'name': 'Amethyst',
      'description': 'A regal palette of purples and lavenders, inspired by the amethyst gemstone.',
      'colors': null,
    },
    {
      'id': 65,
      'name': 'Golden',
      'description': 'A luxurious palette of golds and yellows, creating a warm and opulent display.',
      'colors': null,
    },
    {
      'id': 66,
      'name': 'Sunflower',
      'description': 'A bright palette of yellows and greens, inspired by the vibrant colors of sunflowers in a field.',
      'colors': null,
    },
    {
      'id': 67,
      'name': 'Orchid',
      'description': 'A delicate palette of purples, pinks, and whites, evoking the elegance of orchid flowers.',
      'colors': null,
    },
    {
      'id': 68,
      'name': 'Storm',
      'description': 'A dramatic palette of dark grays, blues, and purples, capturing the intensity of a stormy sky.',
      'colors': null,
    },
    {
      'id': 69,
      'name': 'Candy Cane',
      'description': 'A festive palette of red and white stripes, reminiscent of classic candy canes.',
      'colors': null,
    },*/
    {
      'id': 70,
      'name': 'Candy2',
      'description': 'Faded gradient of yellow, salmon and blue',
      'colors': null,
    },
  ];

  static int getPaletteId(String paletteName) {
    final palette = palettesDatabase.firstWhere(
      (p) => p['name'].toString().toLowerCase() == paletteName.toLowerCase(),
      orElse: () => {'id': 0}, // Default to 'Default' (ID 0) if not found
    );
    return palette['id'] as int;
  }
}