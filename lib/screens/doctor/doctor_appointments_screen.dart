import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment_model.dart';
import 'appointment_details_screen.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUserModel;
    final FirestoreService firestoreService = FirestoreService();

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<List<Appointment>>(
        stream: firestoreService.getAppointmentsForDoctor(user.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final appointments = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
    Color statusColor;
    switch (appointment.status) {
      case 'Booked': statusColor = Colors.blue; break;
      case 'Completed': statusColor = Colors.green; break;
      case 'Cancelled': statusColor = Colors.red; break;
      default: statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AppointmentDetailsScreen(appointment: appointment)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Date Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(DateFormat('d').format(appointment.appointmentDate),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  Text(DateFormat('MMM').format(appointment.appointmentDate),
                      style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor)),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Appointment Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Patient: ${appointment.patientId.substring(0, 8).toUpperCase()}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(appointment.timeSlot, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(appointment.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(width: 8),

            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Appointment'),
                    content: const Text('Are you sure you want to delete this appointment?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    await firestoreService.deleteAppointment(appointment.appointmentId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Appointment deleted'), backgroundColor: Colors.redAccent),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting appointment: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_today_outlined, size: 70, color: Colors.grey[300]),
        const SizedBox(height: 16),
        const Text("No appointments found", style: TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    ),
  );
}