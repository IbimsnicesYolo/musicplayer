import 'package:flutter/material.dart';

import '../../settings.dart';

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
            backgroundColor: ContrastColor,
            enableFeedback: true,
          ),
        );
}
