import 'package:flutter/material.dart';

import '../../settings.dart' as CFG;

class StyledElevatedButton extends ElevatedButton {
  StyledElevatedButton({
    Key? key,
    required VoidCallback onPressed,
    required Widget child,
  }) : super(
          key: key,
          onPressed: onPressed,
          child: child,
          style: ElevatedButton.styleFrom(
            backgroundColor: CFG.ContrastColor,
            enableFeedback: true,
          ),
        );
}
