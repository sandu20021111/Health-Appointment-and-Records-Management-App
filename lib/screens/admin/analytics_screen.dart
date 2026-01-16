import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/appointment_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildNoDataState();
          }

          final appointments = snapshot.data!.docs
              .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          // 1. Logic for Pie Chart
          int booked = appointments.where((a) => a.status == 'Booked').length;
          int completed = appointments.where((a) => a.status == 'Completed').length;
          int cancelled = appointments.where((a) => a.status == 'Cancelled').length;

          // 2. Logic for Bar Chart
          Map<String, int> doctorCounts = {};
          for (var a in appointments) {
            doctorCounts[a.doctorName] = (doctorCounts[a.doctorName] ?? 0) + 1;
          }
          var sortedDoctors = doctorCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          if (sortedDoctors.length > 5) sortedDoctors = sortedDoctors.sublist(0, 5);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader("System Insights", "Real-time overview of hospital activity"),
                const SizedBox(height: 20),

                // --- Pie Chart Card ---
                _buildChartCard(
                  title: 'Appointment Distribution',
                  child: Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              _sectionData(booked.toDouble(), 'Booked', Colors.blue),
                              _sectionData(completed.toDouble(), 'Completed', Colors.green),
                              _sectionData(cancelled.toDouble(), 'Cancelled', Colors.red),
                            ],
                            centerSpaceRadius: 45,
                            sectionsSpace: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLegend(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- Bar Chart Card ---
                _buildChartCard(
                  title: 'Top Performing Doctors',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Based on number of appointments",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 25),
                      SizedBox(
                        height: 250,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (sortedDoctors.isEmpty ? 5 : sortedDoctors.first.value).toDouble() + 1,
                            titlesData: _buildBarTitles(sortedDoctors),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: sortedDoctors.asMap().entries.map((e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value.value.toDouble(),
                                    color: Colors.blue.shade300,
                                    width: 18,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UI Construction Helper Widgets ---

  Widget _buildHeader(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(sub, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
      ],
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 30),
          child,
        ],
      ),
    );
  }

  PieChartSectionData _sectionData(double value, String title, Color color) {
    return PieChartSectionData(
      value: value,
      title: value > 0 ? '${value.toInt()}' : '',
      radius: 50,
      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      color: color,
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem("Booked", Colors.blue),
        _legendItem("Done", Colors.green),
        _legendItem("Cancelled", Colors.red),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  FlTitlesData _buildBarTitles(List<MapEntry<String, int>> sortedDoctors) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (double value, TitleMeta meta) {
            int index = value.toInt();
            if (index < sortedDoctors.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  sortedDoctors[index].key.split(' ').first,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No analytical data found yet", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}