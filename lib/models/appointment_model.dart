import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorCategory;
  final DateTime appointmentDate;
  final String timeSlot;
  final String status; // 'Booked', 'Cancelled', 'Completed'
  final DateTime createdAt;

  // Optional medical record fields
  final String? diagnosis;
  final String? symptoms;
  final String? notes;

  Appointment({
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorCategory,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    required this.createdAt,
    this.diagnosis,
    this.symptoms,
    this.notes,
  });

  factory Appointment.fromMap(Map<String, dynamic> data) {
    return Appointment(
      appointmentId: data['appointmentId'] ?? '',
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorCategory: data['doctorCategory'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      status: data['status'] ?? 'Booked',
      createdAt: (data['createdAt'] as Timestamp).toDate(),

      // Optional medical record fields
      diagnosis: data['diagnosis'],
      symptoms: data['symptoms'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorCategory': doctorCategory,
      'appointmentDate': appointmentDate,
      'timeSlot': timeSlot,
      'status': status,
      'createdAt': createdAt,
      'diagnosis': diagnosis,
      'symptoms': symptoms,
      'notes': notes,
    };
  }
}