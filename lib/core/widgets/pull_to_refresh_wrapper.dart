import 'package:flutter/material.dart';

class PullToRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? backgroundColor;

  const PullToRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Theme.of(context).primaryColor,
      backgroundColor: backgroundColor ?? Colors.white,
      child: child,
    );
  }
}

