import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment_model.dart';

class PatientAppointmentsScreen extends StatelessWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUserModel;
    final FirestoreService firestoreService = FirestoreService();

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<List<Appointment>>(
        stream: firestoreService.getAppointmentsForPatient(user.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final appointments = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return _buildAppointmentCard(context, appointment, firestoreService);
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment, FirestoreService firestoreService) {
    final dateStr = DateFormat('EEE, d MMM yyyy').format(appointment.appointmentDate);

    // Status අනුව වර්ණ තෝරාගැනීම
    Color statusColor;
    IconData statusIcon;
    switch (appointment.status) {
      case 'Booked':
        statusColor = Colors.blue;
        statusIcon = Icons.calendar_today_rounded;
        break;
      case 'Completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // වම් පැත්තේ පාට තීරුව
              Container(width: 6, color: statusColor),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dr. ${appointment.doctorName}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              appointment.status,
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.doctorCategory,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 16, color: Colors.blue[400]),
                          const SizedBox(width: 6),
                          Text('$dateStr | ${appointment.timeSlot}',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),

                      // Cancel Button - 'Booked' නම් පමණක් පෙන්වයි
                      if (appointment.status == 'Booked') ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _showCancelDialog(context, appointment, firestoreService),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Cancel Appointment'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Appointment appointment, FirestoreService firestoreService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Cancel Appointment?'),
        content: const Text('Are you sure you want to cancel this appointment with the doctor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, keep it'),
          ),
          ElevatedButton(
            onPressed: () async {
              await firestoreService.updateAppointmentStatus(appointment.appointmentId, 'Cancelled');
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
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
          Icon(Icons.event_busy_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No appointments scheduled',
            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}