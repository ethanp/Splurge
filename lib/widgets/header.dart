import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:splurge/global/style.dart';

class Header extends StatelessWidget {
  const Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.4, sigmaY: 4),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.brown, Colors.brown.withOpacity(.4)],
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              // The below performs: `this.height = child.height * 2`
              heightFactor: 2,
              child: Text(title, style: titleStyle),
            ),
          ),
        ),
      ),
    );
  }
}
