import 'package:flutter/material.dart';

class AdaptiveCircularProgress extends StatelessWidget {
  const AdaptiveCircularProgress({super.key, this.backgroundColor});
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator.adaptive(
        backgroundColor: backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
      ),
    );
  }
}
