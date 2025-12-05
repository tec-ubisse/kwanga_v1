import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class KwangaSlidableAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  KwangaSlidableAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class KwangaSlidableCard extends StatelessWidget {
  final Widget child;
  final List<KwangaSlidableAction> actions;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final bool showShadow;

  const KwangaSlidableCard({
    super.key,
    required this.child,
    required this.actions,
    this.borderRadius = 16,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(0),
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect( // 🔥 Aplica borda ao Slidable inteiro
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          boxShadow: showShadow
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ]
              : null,
        ),

        child: Slidable(
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: actions.length * 0.25,
            children: actions.map((a) {
              return SlidableAction(
                onPressed: (_) => a.onTap(),
                backgroundColor: a.color,
                foregroundColor: Colors.white,
                icon: a.icon,
                label: a.label,
              );
            }).toList(),
          ),

          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
