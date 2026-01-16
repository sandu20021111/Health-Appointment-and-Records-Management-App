import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _categoryController = TextEditingController();

  String? _gender;
  String _role = 'patient';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _clinicNameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // Helper decoration to keep code clean
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
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

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final userModel = UserModel(
        userId: '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _role,
        gender: _role == 'patient' ? _gender : null,
        age: _role == 'patient' ? int.tryParse(_ageController.text) : null,
        category: _role == 'doctor' ? _categoryController.text.trim() : null,
        clinicName: _role == 'doctor' ? _clinicNameController.text.trim() : null,
        availableDays: _role == 'doctor' ? [] : null,
        timeSlots: _role == 'doctor' ? [] : null,
        approved: _role == 'doctor' ? false : null,
        createdAt: DateTime.now(),
      );

      String? error = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        userModel: userModel,
      );

      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      } else {
        if (mounted) {
          await authProvider.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account created! Please login."), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: Colors.blue[50], // Soft background
      appBar: AppBar(
        title: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Join our health network today",
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 30),

              // Role Switcher
              _buildRoleToggle(),
              const SizedBox(height: 25),

              // Common Fields
              _buildTextField(_nameController, "Full Name", Icons.person_outline),
              _buildTextField(_emailController, "Email Address", Icons.email_outlined, type: TextInputType.emailAddress),
              _buildTextField(_passwordController, "Password", Icons.lock_outline, obscure: true),
              _buildTextField(_phoneController, "Phone Number", Icons.phone_android_outlined, type: TextInputType.phone),

              // Patient Specific
              if (_role == 'patient') ...[
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: _inputStyle("Gender", Icons.wc_outlined),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => _gender = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(_ageController, "Age", Icons.cake_outlined, type: TextInputType.number),
              ],

              // Doctor Specific
              if (_role == 'doctor') ...[
                _buildTextField(_categoryController, "Specialization (e.g. Dentist)", Icons.medical_services_outlined),
                _buildTextField(_clinicNameController, "Clinic/Hospital Name", Icons.local_hospital_outlined),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                  ),
                  child: const Text('REGISTER NOW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          _roleButton('patient', "Patient", Icons.person),
          _roleButton('doctor', "Doctor", Icons.medication),
        ],
      ),
    );
  }

  Widget _roleButton(String r, String label, IconData icon) {
    bool isSelected = _role == r;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        decoration: _inputStyle(label, icon),
        validator: (v) => v!.isEmpty ? 'Required' : null,
      ),
    );
  }
}