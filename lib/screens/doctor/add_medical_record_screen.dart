import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/appointment_model.dart';
import '../../models/medical_record_model.dart';
import '../../models/prescription_model.dart';
import '../../services/firestore_service.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final Appointment appointment;
  const AddMedicalRecordScreen({super.key, required this.appointment});

  @override
  State<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();

  final List<Prescription> _prescriptions = [];
  bool _isLoading = false;

  // --- UI Helper: Input Decoration ---
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }

  void _addPrescriptionDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.medication, color: Colors.blue),
            SizedBox(width: 10),
            Text('Add Medicine'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: _buildInputDecoration('Medicine Name', Icons.drive_file_rename_outline),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dosageController,
              decoration: _buildInputDecoration('Dosage (e.g. 1-0-1)', Icons.timer_outlined),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationController,
              decoration: _buildInputDecoration('Duration (e.g. 5 days)', Icons.calendar_today),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _prescriptions.add(Prescription(
                    prescriptionId: const Uuid().v4(),
                    recordId: '',
                    medicineName: nameController.text,
                    dosage: dosageController.text,
                    duration: durationController.text,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final recordId = const Uuid().v4();

        final record = MedicalRecord(
          recordId: recordId,
          appointmentId: widget.appointment.appointmentId,
          patientId: widget.appointment.patientId,
          doctorId: widget.appointment.doctorId,
          diagnosis: _diagnosisController.text,
          symptoms: _symptomsController.text,
          notes: _notesController.text,
          createdAt: DateTime.now(),
        );
        await FirestoreService().createMedicalRecord(record);

        for (var p in _prescriptions) {
          final pToSave = Prescription(
            prescriptionId: p.prescriptionId,
            recordId: recordId,
            medicineName: p.medicineName,
            dosage: p.dosage,
            duration: p.duration,
          );
          await FirestoreService().addPrescription(pToSave);
        }

        await FirestoreService().updateAppointmentStatus(widget.appointment.appointmentId, 'Completed');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medical Record Finalized'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add Medical Record'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Diagnosis & Symptoms Section ---
              _buildSectionTitle("Diagnosis Information"),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diagnosisController,
                decoration: _buildInputDecoration('Diagnosis / Disease Name', Icons.healing),
                validator: (v) => v!.isEmpty ? 'Please enter diagnosis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _symptomsController,
                maxLines: 2,
                decoration: _buildInputDecoration('Symptoms Observed', Icons.bubble_chart_outlined),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: _buildInputDecoration('Additional Doctor Notes', Icons.note_alt_outlined),
              ),

              const SizedBox(height: 30),

              // --- Prescriptions Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle("Prescriptions"),
                  ElevatedButton.icon(
                    onPressed: _addPrescriptionDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add Medicine"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade700,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_prescriptions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("No medicines added yet.", style: TextStyle(color: Colors.grey.shade400)),
                  ),
                )
              else
                ..._prescriptions.map((p) => _buildPrescriptionTile(p)),

              const SizedBox(height: 50),

              // --- Final Save Button ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'FINAL SAVE & COMPLETE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.blueGrey),
    );
  }

  Widget _buildPrescriptionTile(Prescription p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.medication, color: Colors.blue, size: 20)),
        title: Text(p.medicineName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${p.dosage} | ${p.duration}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => setState(() => _prescriptions.remove(p)),
        ),
      ),
    );
  }
}