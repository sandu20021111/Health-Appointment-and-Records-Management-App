import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/medical_record_model.dart';
import '../../models/prescription_model.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUserModel;
    final FirestoreService firestoreService = FirestoreService();

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<List<MedicalRecord>>(
        stream: firestoreService.getMedicalRecordsForPatient(user.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final records = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildHistoryCard(context, record, firestoreService);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, MedicalRecord record, FirestoreService firestoreService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.medication_liquid_rounded, color: Colors.blue),
          ),
          title: Text(
            record.diagnosis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            DateFormat('dd MMM yyyy').format(record.createdAt),
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  _buildSectionTitle(Icons.description_outlined, 'Symptoms & Notes'),
                  Text(record.symptoms, style: const TextStyle(fontSize: 14)),
                  if (record.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(record.notes, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic)),
                  ],
                  const SizedBox(height: 20),

                  // Prescriptions Section
                  _buildSectionTitle(Icons.list_alt_rounded, 'Prescriptions'),
                  StreamBuilder<List<Prescription>>(
                    stream: firestoreService.getPrescriptionsForRecord(record.recordId),
                    builder: (context, pSnapshot) {
                      if (pSnapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      }
                      if (!pSnapshot.hasData || pSnapshot.data!.isEmpty) {
                        return const Text('No prescriptions added', style: TextStyle(color: Colors.grey, fontSize: 13));
                      }
                      return Column(
                        children: pSnapshot.data!.map((p) => _buildPrescriptionItem(p)).toList(),
                      );
                    },
                  ),
                  // Medical Reports කොටස මෙතැනින් ඉවත් කරන ලදී.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildPrescriptionItem(Prescription p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.medicineName, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${p.dosage} | ${p.duration}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No medical history found', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}