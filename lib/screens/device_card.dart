import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/device.dart';
import 'custom_pattern_screen.dart'; // Import the CustomPatternScreen

class DeviceCard extends StatelessWidget {
  final Device device;
  final Function(bool) onTogglePower;
  final Function(double) onUpdateBrightness;
  final Function(double) onSetBrightness;
  final VoidCallback onOpenWebView;
  final VoidCallback? onOpenPresets;
  final VoidCallback? onOpenCustom; // New callback for the Custom button

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTogglePower,
    required this.onUpdateBrightness,
    required this.onSetBrightness,
    required this.onOpenWebView,
    this.onOpenPresets,
    this.onOpenCustom, // Add the new parameter
  });

  // Helper to determine if a color is light or dark based on luminance
  bool _isLightColor(Color color) {
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5;
  }

  // Helper to determine if a color is close to white or black
  bool _isCloseToWhite(Color color) {
    return color.red > 240 && color.green > 240 && color.blue > 240;
  }

  bool _isCloseToBlack(Color color) {
    return color.red < 20 && color.green < 20 && color.blue < 20;
  }

  // Helper to generate shades of a color
  Color _darkenColor(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color _lightenColor(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  // Mix a color with another to create a tint
  Color _mixColors(Color color1, Color color2, double weight) {
    final r = (color1.red * weight + color2.red * (1 - weight)).round();
    final g = (color1.green * weight + color2.green * (1 - weight)).round();
    final b = (color1.blue * weight + color2.blue * (1 - weight)).round();
    return Color.fromRGBO(r, g, b, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    // Adjust colors close to white or black
    Color baseColor = device.isSynced
        ? (device.backgroundColor ?? Theme.of(context).cardColor)
        : const Color(0xFF2A2A2A);
    print('Device ${device.name} baseColor: $baseColor'); // Debug log

    final isCloseToWhite = _isCloseToWhite(baseColor);
    final isCloseToBlack = _isCloseToBlack(baseColor);
    Color adjustedBaseColor;

    // Adjust base color for white/black
    if (isCloseToWhite) {
      adjustedBaseColor = Colors.grey[200]!; // Light grey for near-white
    } else if (isCloseToBlack) {
      adjustedBaseColor = Colors.grey[850]!; // Dark grey for near-black
    } else {
      adjustedBaseColor = baseColor;
    }

    // Create a gradient with a tint of the selected color
    final selectedColor = device.isSynced ? (device.backgroundColor ?? Colors.grey) : Colors.grey[600]!;
    print('Device ${device.name} selectedColor: $selectedColor'); // Debug log
    final gradientColors = [
      _mixColors(adjustedBaseColor, selectedColor, 0.8).withOpacity(0.5),
      _mixColors(adjustedBaseColor, selectedColor, 0.6).withOpacity(0.3),
    ];

    final isLight = _isLightColor(adjustedBaseColor);
    final textColor = isLight ? Colors.black : Colors.white;

    // UI element colors
    final activeColor = device.isSynced
        ? (isCloseToWhite
            ? _darkenColor(selectedColor, 0.3) // Darker shade for white
            : isCloseToBlack
                ? _lightenColor(selectedColor, 0.2) // Lighter shade for black
                : isLight
                    ? _darkenColor(selectedColor, 0.3)
                    : _lightenColor(selectedColor, 0.2))
        : Colors.grey;
    final thumbColor = device.isSynced
        ? (isCloseToWhite
            ? _darkenColor(selectedColor, 0.4)
            : isCloseToBlack
                ? _lightenColor(selectedColor, 0.3)
                : _darkenColor(activeColor, 0.2))
        : Colors.grey[600];
    final buttonColor = device.isSynced
        ? (isCloseToWhite
            ? _darkenColor(selectedColor, 0.2)
            : isCloseToBlack
                ? _lightenColor(selectedColor, 0.1)
                : _lightenColor(selectedColor, 0.2))
        : Colors.grey[800];
    final buttonTextColor = _isLightColor(buttonColor!) ? Colors.black : Colors.white;
    final switchColor = device.isSynced
        ? (isCloseToWhite
            ? _darkenColor(selectedColor, 0.2)
            : isCloseToBlack
                ? _lightenColor(selectedColor, 0.2)
                : _lightenColor(selectedColor, 0.2))
        : Colors.grey;

    return Card(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: CustomPaint(
        painter: device.isOn && device.isSynced
            ? DottedBorderPainter(color: selectedColor)
            : null,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: device.isSynced ? textColor : Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                device.ip,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: device.isSynced ? textColor.withOpacity(0.7) : Colors.grey[400],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                device.isSynced ? Icons.wifi : Icons.wifi_off,
                                size: 18,
                                color: device.isSynced ? Colors.green : Colors.red,
                              ),
                              if (!device.isSynced) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '(Offline)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: device.isOn,
                      onChanged: device.isSynced ? (value) => onTogglePower(value) : null,
                      activeColor: thumbColor,
                      activeTrackColor: switchColor,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[600],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
                    activeTrackColor: activeColor,
                    inactiveTrackColor: device.isSynced ? _darkenColor(adjustedBaseColor, 0.3) : Colors.grey[300],
                    thumbColor: thumbColor,
                    overlayColor: activeColor.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: device.brightness,
                    min: 0,
                    max: 255,
                    label: device.brightness.round().toString(),
                    onChanged: device.isSynced ? (value) => onUpdateBrightness(value) : null,
                    onChangeEnd: device.isSynced ? (value) => onSetBrightness(value) : null,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: device.isSynced
                            ? () {
                                onOpenWebView!();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: buttonTextColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Open Device WebView'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: device.isSynced && onOpenPresets != null
                            ? () {
                                onOpenPresets!();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: buttonTextColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Presets'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: device.isSynced && onOpenCustom != null
                            ? () {
                                onOpenCustom!();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: buttonTextColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Custom'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for dotted border with light-spreading effect
class DottedBorderPainter extends CustomPainter {
  final Color color;

  DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

    const double dotLength = 8.0;
    const double spaceLength = 6.0;
    const double cornerRadius = 12.0;

    // Create a rounded rectangle path
    final path = Path();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(cornerRadius));

    // Calculate the total perimeter of the rounded rectangle
    final perimeter = 2 * (size.width + size.height - 4 * cornerRadius) + 2 * math.pi * cornerRadius;
    final segmentLength = dotLength + spaceLength;
    final numSegments = (perimeter / segmentLength).floor();

    // Draw the dotted border with glow
    double distance = 0.0;
    for (int i = 0; i < numSegments; i++) {
      final startT = distance / perimeter;
      final endT = (distance + dotLength) / perimeter;

      final startPoint = _getPointOnRRect(rrect, startT);
      final endPoint = _getPointOnRRect(rrect, endT);

      // Draw glow first
      canvas.drawLine(startPoint, endPoint, glowPaint);
      // Draw the dot
      canvas.drawLine(startPoint, endPoint, paint);

      distance += segmentLength;
    }
  }

  // Helper to get a point on the rounded rectangle at a given t (0 to 1)
  Offset _getPointOnRRect(RRect rrect, double t) {
    final width = rrect.width;
    final height = rrect.height;
    final cornerRadius = rrect.tlRadiusX;
    final straightLength = 2 * (width + height - 4 * cornerRadius);
    final cornerLength = 2 * math.pi * cornerRadius;
    final perimeter = straightLength + cornerLength;

    double distance = t * perimeter;

    // Top straight segment
    if (distance < width - 2 * cornerRadius) {
      return Offset(rrect.left + cornerRadius + distance, rrect.top);
    }
    distance -= width - 2 * cornerRadius;

    // Top-right corner
    if (distance < cornerLength / 4) {
      final angle = math.pi / 2 * (1 - distance / (cornerLength / 4));
      return Offset(
        rrect.right - cornerRadius + cornerRadius * math.cos(angle),
        rrect.top + cornerRadius - cornerRadius * math.sin(angle),
      );
    }
    distance -= cornerLength / 4;

    // Right straight segment
    if (distance < height - 2 * cornerRadius) {
      return Offset(rrect.right, rrect.top + cornerRadius + distance);
    }
    distance -= height - 2 * cornerRadius;

    // Bottom-right corner
    if (distance < cornerLength / 4) {
      final angle = math.pi / 2 * (distance / (cornerLength / 4));
      return Offset(
        rrect.right - cornerRadius + cornerRadius * math.cos(angle),
        rrect.bottom - cornerRadius + cornerRadius * math.sin(angle),
      );
    }
    distance -= cornerLength / 4;

    // Bottom straight segment
    if (distance < width - 2 * cornerRadius) {
      return Offset(rrect.right - cornerRadius - distance, rrect.bottom);
    }
    distance -= width - 2 * cornerRadius;

    // Bottom-left corner
    if (distance < cornerLength / 4) {
      final angle = math.pi / 2 * (1 - distance / (cornerLength / 4));
      return Offset(
        rrect.left + cornerRadius - cornerRadius * math.cos(angle),
        rrect.bottom - cornerRadius + cornerRadius * math.sin(angle),
      );
    }
    distance -= cornerLength / 4;

    // Left straight segment
    if (distance < height - 2 * cornerRadius) {
      return Offset(rrect.left, rrect.bottom - cornerRadius - distance);
    }
    distance -= height - 2 * cornerRadius;

    // Top-left corner
    final angle = math.pi / 2 * (distance / (cornerLength / 4));
    return Offset(
      rrect.left + cornerRadius - cornerRadius * math.cos(angle),
      rrect.top + cornerRadius - cornerRadius * math.sin(angle),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}