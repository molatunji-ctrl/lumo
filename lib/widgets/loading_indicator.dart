import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const LoadingIndicator({
    super.key,
    this.size = 24.0,
    this.color = AppColors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class ConnectingLoader extends StatelessWidget {
  final String message;

  const ConnectingLoader({
    super.key,
    this.message = 'Connecting To Lumo...',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            border: Border.all(color: AppColors.darkCardBorder),
            borderRadius: BorderRadius.circular(19),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LoadingIndicator(size: 24, color: AppColors.green),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
