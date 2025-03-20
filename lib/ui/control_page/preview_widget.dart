import 'package:flutter/material.dart';
import '../../models/wled_state.dart';

class PreviewWidget extends StatelessWidget {
  final WledState state;

  PreviewWidget({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preview', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 100,
          color: state.primaryColor,
          child: Center(
            child: Text(
              'Effect: ${state.effect}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}