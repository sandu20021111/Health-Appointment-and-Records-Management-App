import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String role; // 'patient', 'doctor', 'admin'
  final String? gender; // patient only
  final int? age; // patient only
  final String? category; // doctor only
  final String? clinicName; // doctor only
  final List<String>? availableDays; // doctor only
  final List<String>? timeSlots; // doctor only
  final bool? approved; // doctor only
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.gender,
    this.age,
    this.category,
    this.clinicName,
    this.availableDays,
    this.timeSlots,
    this.approved,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'patient',
      gender: data['gender'],
      age: data['age'],
      category: data['category'],
      clinicName: data['clinicName'],
      availableDays:
          data['availableDays'] != null
              ? List<String>.from(data['availableDays'])
              : null,
      timeSlots:
          data['timeSlots'] != null
              ? List<String>.from(data['timeSlots'])
              : null,
      approved: data['approved'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'gender': gender,
      'age': age,
      'category': category,
      'clinicName': clinicName,
      'availableDays': availableDays,
      'timeSlots': timeSlots,
      'approved': approved,
      'createdAt': createdAt,
    };
  }
}
