import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';

class PurposeWidget extends StatelessWidget {
  final String areaName;
  final String path;
  final String purposeDescription;

  const PurposeWidget({
    super.key,
    required this.areaName,
    required this.path,
    required this.purposeDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: cBlackColor.withAlpha(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Image.asset('assets/icons/$path.png'),
                    Text(
                      areaName,
                      style: tNormal.copyWith(
                        fontSize: areaName.length>8? 9.0 : 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    purposeDescription,
                    style: tNormal,
                    textAlign: TextAlign.justify,
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
