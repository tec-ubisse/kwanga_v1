import 'package:flutter/material.dart';

class CustomSwitchTile extends StatefulWidget {
  const CustomSwitchTile({super.key});

  @override
  State<CustomSwitchTile> createState() => _CustomSwitchTileState();
}

class _CustomSwitchTileState extends State<CustomSwitchTile> {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(value: false, onChanged: (_){});
  }
}
