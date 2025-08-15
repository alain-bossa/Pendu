import 'package:flutter/material.dart';
import 'package:pendu/utilities/constants.dart';

class WordButton extends StatelessWidget {
  const WordButton({
    super.key,
    required this.buttonTitle,
    this.onPress,
    this.color = kWordButtonColor, // Add a color parameter with a default value
  });

  final VoidCallback? onPress;
  final String buttonTitle;
  final Color color; // Declare the color variable

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 3.0,
        backgroundColor: color, // Use the color variable here
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(4.0),
      ),
      onPressed: onPress,
      child: Text(
        buttonTitle,
        textAlign: TextAlign.center,
        style: kWordButtonTextStyle,
      ),
    );
  }
}