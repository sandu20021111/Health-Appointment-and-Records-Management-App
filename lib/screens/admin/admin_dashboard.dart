import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import 'analytics_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDoctorApprovalScreen(),
    const AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
              onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined),
              activeIcon: Icon(Icons.verified_user),
              label: 'Approvals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: 'Analytics',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}

class AdminDoctorApprovalScreen extends StatelessWidget {
  const AdminDoctorApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return StreamBuilder<List<UserModel>>(
      stream: firestoreService.getAllDoctorsForAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final doctors = snapshot.data ?? [];
        final pendingDoctors = doctors.where((d) => d.approved == false).toList();
        final approvedDoctors = doctors.where((d) => d.approved == true).toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Quick Stats Row
            Row(
              children: [
                _buildStatCard("Pending", pendingDoctors.length.toString(), Colors.orange),
                const SizedBox(width: 15),
                _buildStatCard("Total Doctors", doctors.length.toString(), Colors.blue),
              ],
            ),
            const SizedBox(height: 30),

            // Pending Approvals Section
            _buildSectionTitle("Pending Approvals", pendingDoctors.length),
            const SizedBox(height: 12),
            if (pendingDoctors.isEmpty)
              _buildEmptyPlaceholder("No pending approvals")
            else
              ...pendingDoctors.map((doc) => _buildApprovalCard(doc, firestoreService)),

            const SizedBox(height: 30),

            // Already Approved Section
            _buildSectionTitle("Approved Specialists", approvedDoctors.length),
            const SizedBox(height: 12),
            if (approvedDoctors.isEmpty)
              _buildEmptyPlaceholder("No approved doctors yet")
            else
              ...approvedDoctors.map((doc) => _buildDoctorTile(doc)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalCard(UserModel doc, FirestoreService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange[50],
            child: Text(doc.name[0], style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${doc.category} • ${doc.clinicName}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Approval Logic
              final updatedDoc = UserModel(
                userId: doc.userId, name: doc.name, email: doc.email,
                phone: doc.phone, role: doc.role, category: doc.category,
                clinicName: doc.clinicName, availableDays: doc.availableDays,
                timeSlots: doc.timeSlots, approved: true, createdAt: doc.createdAt,
              );
              await service.updateUser(updatedDoc);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Approve"),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorTile(UserModel doc) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green, size: 20),
        title: Text(doc.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: Text(doc.category ?? 'General', style: const TextStyle(fontSize: 12)),
        dense: true,
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
          child: Text(count.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildEmptyPlaceholder(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.grey))),
    );
  }
}