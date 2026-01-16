import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecord {
  final String recordId;
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final String diagnosis;
  final String symptoms;
  final String notes;
  final DateTime createdAt;

  MedicalRecord({
    required this.recordId,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.diagnosis,
    required this.symptoms,
    required this.notes,
    required this.createdAt,
  });

  factory MedicalRecord.fromMap(Map<String, dynamic> data) {
    return MedicalRecord(
      recordId: data['recordId'] ?? '',
      appointmentId: data['appointmentId'] ?? '',
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      symptoms: data['symptoms'] ?? '',
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recordId': recordId,
      'appointmentId': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'diagnosis': diagnosis,
      'symptoms': symptoms,
      'notes': notes,
      'createdAt': createdAt,
    };
  }
}
