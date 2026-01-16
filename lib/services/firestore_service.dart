import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/medical_record_model.dart';
import '../models/prescription_model.dart';
import '../models/report_model.dart';
import '../models/doctor_category_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Users ---
  Future<void> updateUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.userId).update(user.toMap());
    } catch (e) {
      print("Error updating user: $e");
      rethrow;
    }
  }

  Stream<List<UserModel>> getDoctors() {
    return _db.collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('approved', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Stream<List<UserModel>> getAllDoctorsForAdmin() {
    return _db.collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // --- Doctor Categories ---
  Stream<List<DoctorCategory>> getDoctorCategories() {
    return _db.collection('doctor_categories')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => DoctorCategory.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // --- Appointments ---
  Future<void> createAppointment(Appointment appointment) async {
    try {
      await _db.collection('appointments')
          .doc(appointment.appointmentId)
          .set(appointment.toMap());
      print("Appointment Created in DB!");
    } catch (e) {
      print("Error creating appointment: $e");
      rethrow;
    }
  }

  // වැදගත්: මෙම query එක වැඩ කිරීමට Firestore Index එකක් අවශ්‍ය වේ.
  Stream<List<Appointment>> getAppointmentsForPatient(String patientId) {
    return _db.collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // වැදගත්: මෙම query එක වැඩ කිරීමට Firestore Index එකක් අවශ්‍ය වේ.
  Stream<List<Appointment>> getAppointmentsForDoctor(String doctorId) {
    return _db.collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _db.collection('appointments').doc(appointmentId).update({'status': status});
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  // --- Medical Records ---
  Future<void> createMedicalRecord(MedicalRecord record) async {
    await _db.collection('medical_records').doc(record.recordId).set(record.toMap());
  }

  Stream<List<MedicalRecord>> getMedicalRecordsForPatient(String patientId) {
    return _db.collection('medical_records')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MedicalRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // --- Prescriptions ---
  Future<void> addPrescription(Prescription prescription) async {
    await _db.collection('prescriptions').doc(prescription.prescriptionId).set(prescription.toMap());
  }

  Stream<List<Prescription>> getPrescriptionsForRecord(String recordId) {
    return _db.collection('prescriptions')
        .where('recordId', isEqualTo: recordId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Prescription.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // --- Reports ---
  Future<void> addReport(Report report) async {
    await _db.collection('reports').doc(report.reportId).set(report.toMap());
  }

  Stream<List<Report>> getReportsForRecord(String recordId) {
    return _db.collection('reports')
        .where('recordId', isEqualTo: recordId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Report.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Stream<List<Report>> getReportsForPatient(String patientId) {
    return _db.collection('reports')
        .where('patientId', isEqualTo: patientId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Report.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // --- Admin Analytics ---
  Future<int> getAppointmentsCount() async {
    try {
      final snapshot = await _db.collection('appointments').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print("Error getting count: $e");
      return 0;
    }
  }
}