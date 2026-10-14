/*
import 'dart:convert';

/// Dedicated Model to track fingerprint scan status (isFingerScanned: 1 or 0) on behalf of userId
class FingerScanStatusModel {
  final String userId;
  final bool isFingerScanned; // 1 = scanned, 0 = not scanned
  final String? scannedAt;

  FingerScanStatusModel({
    required this.userId,
    required this.isFingerScanned,
    this.scannedAt,
  });

  factory FingerScanStatusModel.fromJson(Map<String, dynamic> json) {
    return FingerScanStatusModel(
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      isFingerScanned: json['isFingerScanned'] == 1 ||
          json['isFingerScanned'] == true ||
          json['is_finger_scanned'] == 1 ||
          json['is_finger_scanned'] == true,
      scannedAt: json['scannedAt']?.toString() ?? json['scanned_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'isFingerScanned': isFingerScanned ? 1 : 0,
      'scannedAt': scannedAt ?? DateTime.now().toIso8601String(),
    };
  }

  static FingerScanStatusModel fromRawJson(String str) =>
      FingerScanStatusModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}
*/
import 'dart:convert';

class FingerScanStatusModel {
  String userId;
  bool fingerScanStatus; // 1 = scanned, 0 = not scanned
  String? createdAt;

  FingerScanStatusModel({
    this.userId = '',
    this.fingerScanStatus = false,
    this.createdAt,
  });

  factory FingerScanStatusModel.fromJson(Map<String, dynamic> json) {
    return FingerScanStatusModel(
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      fingerScanStatus: json['fingerScanStatus'] == 1 ||
          json['fingerScanStatus'] == true ||
          json['isFingerScanned'] == 1 ||
          json['isFingerScanned'] == true ||
          json['is_finger_scanned'] == 1 ||
          json['is_finger_scanned'] == true,
      createdAt: json['createdAt']?.toString() ??
          json['scannedAt']?.toString() ??
          json['scanned_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fingerScanStatus': fingerScanStatus ? 1 : 0,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  static FingerScanStatusModel fromRawJson(String str) =>
      FingerScanStatusModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}