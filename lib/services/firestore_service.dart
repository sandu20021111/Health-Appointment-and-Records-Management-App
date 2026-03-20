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
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList());
  }

  Stream<List<UserModel>> getAllDoctorsForAdmin() {
    return _db.collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList());
  }

  // --- Doctor Categories ---
  Stream<List<DoctorCategory>> getDoctorCategories() {
    return _db.collection('doctor_categories')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => DoctorCategory.fromMap(doc.data()))
        .toList());
  }

  // --- Appointments ---
  Future<void> createAppointment(Appointment appointment) async {
    try {
      await _db.collection('appointments')
          .doc(appointment.appointmentId)
          .set(appointment.toMap());
      print("Appointment created successfully!");
    } catch (e) {
      print("Error creating appointment: $e");
      rethrow;
    }
  }

  Stream<List<Appointment>> getAppointmentsForPatient(String patientId) {
    return _db.collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Appointment.fromMap(doc.data()))
        .toList());
  }

  Stream<List<Appointment>> getAppointmentsForDoctor(String doctorId) {
    return _db.collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Appointment.fromMap(doc.data()))
        .toList());
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _db.collection('appointments').doc(appointmentId).delete();
      print('Appointment deleted successfully!');
    } catch (e) {
      print('Error deleting appointment: $e');
      rethrow;
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _db.collection('appointments')
          .doc(appointmentId)
          .update({'status': status});
    } catch (e) {
      print("Error updating appointment status: $e");
      rethrow;
    }
  }

  // --- Medical Records ---
  Future<void> createMedicalRecord(MedicalRecord record) async {
    try {
      await _db.collection('medical_records')
          .doc(record.recordId)
          .set(record.toMap());
    } catch (e) {
      print("Error creating medical record: $e");
      rethrow;
    }
  }

  Future<MedicalRecord?> getMedicalRecordByAppointmentId(String appointmentId) async {
    try {
      final snapshot = await _db.collection('medical_records')
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return MedicalRecord.fromMap(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print("Error fetching medical record: $e");
      return null;
    }
  }

  Stream<List<MedicalRecord>> getMedicalRecordsForPatient(String patientId) {
    return _db.collection('medical_records')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MedicalRecord.fromMap(doc.data()))
        .toList());
  }

  // --- Prescriptions ---
  Future<void> addPrescription(Prescription prescription) async {
    try {
      await _db.collection('prescriptions')
          .doc(prescription.prescriptionId)
          .set(prescription.toMap());
    } catch (e) {
      print("Error adding prescription: $e");
      rethrow;
    }
  }

  Future<List<Prescription>> getPrescriptions(String recordId) async {
    try {
      final snapshot = await _db.collection('prescriptions')
          .where('recordId', isEqualTo: recordId)
          .get();

      return snapshot.docs
          .map((doc) => Prescription.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching prescriptions: $e");
      return [];
    }
  }

  Stream<List<Prescription>> getPrescriptionsForRecord(String recordId) {
    return _db.collection('prescriptions')
        .where('recordId', isEqualTo: recordId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Prescription.fromMap(doc.data()))
        .toList());
  }

  // --- Reports ---
  Future<void> addReport(Report report) async {
    try {
      await _db.collection('reports')
          .doc(report.reportId)
          .set(report.toMap());
    } catch (e) {
      print("Error adding report: $e");
      rethrow;
    }
  }

  Stream<List<Report>> getReportsForRecord(String recordId) {
    return _db.collection('reports')
        .where('recordId', isEqualTo: recordId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Report.fromMap(doc.data()))
        .toList());
  }

  Stream<List<Report>> getReportsForPatient(String patientId) {
    return _db.collection('reports')
        .where('patientId', isEqualTo: patientId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Report.fromMap(doc.data()))
        .toList());
  }

  // --- Admin Analytics ---
  Future<int> getAppointmentsCount() async {
    try {
      final snapshot = await _db.collection('appointments').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print("Error getting appointments count: $e");
      return 0;
    }
  }
}