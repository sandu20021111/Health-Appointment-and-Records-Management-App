class Prescription {
  final String prescriptionId;
  final String recordId;
  final String medicineName;
  final String dosage;
  final String duration;

  Prescription({
    required this.prescriptionId,
    required this.recordId,
    required this.medicineName,
    required this.dosage,
    required this.duration,
  });

  factory Prescription.fromMap(Map<String, dynamic> data) {
    return Prescription(
      prescriptionId: data['prescriptionId'] ?? '',
      recordId: data['recordId'] ?? '',
      medicineName: data['medicineName'] ?? '',
      dosage: data['dosage'] ?? '',
      duration: data['duration'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prescriptionId': prescriptionId,
      'recordId': recordId,
      'medicineName': medicineName,
      'dosage': dosage,
      'duration': duration,
    };
  }
}
