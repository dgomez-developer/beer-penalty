import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void navigateTo(BuildContext context, Widget screen) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
      (Route<dynamic> route) => false,
    );
  });
}
