import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_model.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  final UserModel doctor;
  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // මුලින්ම පවතින දිනයක් auto-select කිරීමට
    final availableDates = _getAvailableDates();
    if (availableDates.isNotEmpty) {
      _selectedDate = availableDates.first;
    }
  }

  List<DateTime> _getAvailableDates() {
    List<DateTime> dates = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 14; i++) {
      DateTime date = now.add(Duration(days: i));
      String dayName = DateFormat('EEEE').format(date);
      if (widget.doctor.availableDays != null &&
          widget.doctor.availableDays!.contains(dayName)) {
        dates.add(date);
      }
    }
    return dates;
  }

  Future<void> _bookAppointment() async {
    if (_selectedDate == null || _selectedTimeSlot == null) {
      _showSnackBar('Please select both date and time', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUserModel!;
      final appointmentId = const Uuid().v4();

      final appointment = Appointment(
        appointmentId: appointmentId,
        patientId: currentUser.userId,
        doctorId: widget.doctor.userId,
        doctorName: widget.doctor.name,
        doctorCategory: widget.doctor.category ?? 'General Specialist',
        appointmentDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        status: 'Booked',
        createdAt: DateTime.now(),
      );

      await _firestoreService.createAppointment(appointment);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text("Booking Confirmed!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Your appointment with Dr. ${widget.doctor.name} is successfully scheduled."),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to dashboard
                },
                child: const Text("Go to Home"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableDates = _getAvailableDates();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Book Appointment', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Doctor Brief Card ---
            _buildDoctorHeader(),
            const SizedBox(height: 30),

            // --- Date Selection ---
            const Text('Select Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: availableDates.length,
                itemBuilder: (context, index) {
                  final date = availableDates[index];
                  bool isSelected = _selectedDate != null && DateUtils.isSameDay(date, _selectedDate!);
                  return _buildDateItem(date, isSelected);
                },
              ),
            ),

            const SizedBox(height: 30),

            // --- Time Selection ---
            const Text('Select Time Slot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (widget.doctor.timeSlots == null || widget.doctor.timeSlots!.isEmpty)
              _buildEmptySlots()
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.doctor.timeSlots!.map((slot) {
                  bool isSelected = _selectedTimeSlot == slot;
                  return _buildTimeChip(slot, isSelected);
                }).toList(),
              ),

            const SizedBox(height: 40),

            // --- Confirm Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _bookAppointment,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                child: const Text('Confirm Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blue[200],
            child: const Icon(Icons.person, size: 45, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dr. ${widget.doctor.name}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(widget.doctor.category ?? "General Specialist", style: TextStyle(color: Colors.blueGrey[600])),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(widget.doctor.clinicName ?? "Central Clinic", style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(DateTime date, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() { _selectedDate = date; _selectedTimeSlot = null; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 75,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DateFormat('MMM').format(date), style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
            Text(date.day.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
            Text(DateFormat('E').format(date), style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(String slot, bool isSelected) {
    return ChoiceChip(
      label: Text(slot),
      selected: isSelected,
      onSelected: (selected) => setState(() => _selectedTimeSlot = selected ? slot : null),
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildEmptySlots() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 10),
          Text("No time slots available for this day."),
        ],
      ),
    );
  }
}