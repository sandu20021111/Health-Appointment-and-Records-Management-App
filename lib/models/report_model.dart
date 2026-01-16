import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String reportId;
  final String recordId;
  final String patientId;
    final String reportName;
  final String fileUrl;
  final DateTime uploadedAt;

  Report({
    required this.reportId,
    required this.recordId,
    required this.patientId,
    required this.reportName,
    required this.fileUrl,
    required this.uploadedAt,
  });

  factory Report.fromMap(Map<String, dynamic> data) {
    return Report(
      reportId: data['reportId'] ?? '',
      recordId: data['recordId'] ?? '',
      patientId: data['patientId'] ?? '',
      reportName: data['reportName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'recordId': recordId,
      'patientId': patientId,
      'reportName': reportName,
      'fileUrl': fileUrl,
      'uploadedAt': uploadedAt,
    };
  }
}
