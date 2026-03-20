import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../models/medical_record_model.dart';
import '../../models/prescription_model.dart';
import '../../services/firestore_service.dart';
import 'add_medical_record_screen.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final Appointment appointment;
  const AppointmentDetailsScreen({super.key, required this.appointment});

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  MedicalRecord? record;
  List<Prescription> prescriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicalData();
  }

  Future<void> _loadMedicalData() async {
    if (widget.appointment.status == 'Completed') {
      try {
        final rec = await FirestoreService()
            .getMedicalRecordByAppointmentId(widget.appointment.appointmentId);
        if (rec != null) {
          final meds = await FirestoreService().getPrescriptions(rec.recordId);
          setState(() {
            record = rec;
            prescriptions = meds;
          });
        }
      } catch (e) {
        debugPrint('Error loading medical record: $e');
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = widget.appointment.status == 'Booked'
        ? Colors.blue
        : (widget.appointment.status == 'Completed'
        ? Colors.green
        : Colors.red);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Appointment Details',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Patient Info Card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Patient ID: ${widget.appointment.patientId.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.appointment.status.toUpperCase(),
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Appointment Schedule",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey)),
            const SizedBox(height: 12),

            _buildDetailTile(Icons.calendar_today_rounded, "Date",
                DateFormat('EEEE, dd MMMM yyyy')
                    .format(widget.appointment.appointmentDate)),
            _buildDetailTile(Icons.access_time_rounded, "Time Slot",
                widget.appointment.timeSlot),

            const SizedBox(height: 32),

            // --- Action / Medical Record Section ---
            if (widget.appointment.status == 'Booked')
              Column(
                children: [
                  const Text(
                    "Action Required",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMedicalRecordScreen(
                              appointment: widget.appointment),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment_turned_in_rounded,
                        color: Colors.white),
                    label: const Text('Start Consultation & Record',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.all(18),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                  ),
                ],
              )
            else if (widget.appointment.status == 'Completed')
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : record == null
                  ? const Center(
                  child: Text("No medical record found",
                      style: TextStyle(color: Colors.grey)))
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text("Medical Record",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey)),
                  const SizedBox(height: 12),
                  _buildDetailTile(Icons.healing, "Diagnosis",
                      record!.diagnosis),
                  _buildDetailTile(Icons.bubble_chart, "Symptoms",
                      record!.symptoms),
                  _buildDetailTile(Icons.notes, "Notes",
                      record!.notes),
                  const SizedBox(height: 20),
                  const Text("Prescriptions",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey)),
                  const SizedBox(height: 12),
                  if (prescriptions.isEmpty)
                    const Text("No medicines prescribed",
                        style: TextStyle(color: Colors.grey))
                  else
                    ...prescriptions.map((p) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color:
                              Colors.black.withOpacity(0.02),
                              blurRadius: 5)
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: const Icon(Icons.medication,
                                color: Colors.blue, size: 20)),
                        title: Text(p.medicineName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle:
                        Text("${p.dosage} | ${p.duration}"),
                      ),
                    )),
                  const SizedBox(height: 20),
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green, size: 60),
                        SizedBox(height: 8),
                        Text(
                          "This consultation has been completed.",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // --- FIXED DETAIL TILE METHOD ---
  Widget _buildDetailTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align icon to top
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 16),
          // Expanded ensures the Column doesn't overflow the Row
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  softWrap: true, // Allows wrapping to new lines
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}