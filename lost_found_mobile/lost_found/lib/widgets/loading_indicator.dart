import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent background
        Opacity(
          opacity: 0.5,
          child: const ModalBarrier(
            dismissible: false,
            color: Colors.black,
          ),
        ),
        // Centered loading indicator
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
