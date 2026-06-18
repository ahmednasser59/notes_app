import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';

class FeedbackHelper {
  static void showSuccess(BuildContext context, String message) {
    ElegantNotification.success(
      width: 360,
      position: Alignment.topRight,
      animation: AnimationType.fromRight,
      title: const Text(
        'Success',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      description: Text(
        message,
        style: const TextStyle(color: Colors.white70),
      ),
      background: const Color(0xff1e1e24),
      toastDuration: const Duration(seconds: 3),
    ).show(context);
  }

  static void showInfo(BuildContext context, String message) {
    ElegantNotification.info(
      width: 360,
      position: Alignment.topRight,
      animation: AnimationType.fromRight,
      title: const Text(
        'Info',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      description: Text(
        message,
        style: const TextStyle(color: Colors.white70),
      ),
      background: const Color(0xff1e1e24),
      toastDuration: const Duration(seconds: 3),
    ).show(context);
  }

  static void showError(BuildContext context, String message) {
    ElegantNotification.error(
      width: 360,
      position: Alignment.topRight,
      animation: AnimationType.fromRight,
      title: const Text(
        'Error',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      description: Text(
        message,
        style: const TextStyle(color: Colors.white70),
      ),
      background: const Color(0xff1e1e24),
      toastDuration: const Duration(seconds: 3),
    ).show(context);
  }
}
