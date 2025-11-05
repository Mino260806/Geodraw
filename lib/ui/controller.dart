import 'package:flutter/material.dart';

extension EditingStripe on TextEditingController {
  String get stripped => text.trim();
}