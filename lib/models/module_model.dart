import 'package:flutter/foundation.dart';
class ModuleModel {
  final String id;
  final String moduleName;

  ModuleModel({
    required this.id,
    required this.moduleName,
  });

  /// ✅ Factory constructor with safe parsing
  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: safeParse<String>(json['id'], 'id') ?? '',
      moduleName: safeParse<String>(json['module_name'], 'module_name') ?? '',
    );
  }

  /// ✅ Universal Safe Parse Method
  static T? safeParse<T>(dynamic value, String fieldName) {
    if (value == null) return null;

    try {
      if (value is T) return value;

      if (T == int) {
        if (value is double) return value.toInt() as T;
        if (value is String) return int.tryParse(value) as T?;
        if (value is num) return value.toInt() as T;
      }

      if (T == double) {
        if (value is String) return double.tryParse(value) as T?;
        if (value is int) return value.toDouble() as T;
        if (value is num) return value.toDouble() as T;
      }

      if (T == bool) {
        final v = value.toString().toLowerCase();
        if (v == 'true') return true as T;
        if (v == 'false') return false as T;
      }

      if (T == String) return value.toString() as T;
    } catch (e) {
      debugPrint('[safeParse] ▲ Field "$fieldName": $e');
    }

    debugPrint(
        '[safeParse] ✕ Type mismatch in "$fieldName": expected $T, got ${value.runtimeType}');
    return null;
  }
}
