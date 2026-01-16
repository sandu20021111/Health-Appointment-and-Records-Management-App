import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'utils/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/patient/patient_dashboard.dart';
import 'screens/doctor/doctor_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

void main() async {
  // Flutter engine initialize kirima
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseInitialized = false;
  String? errorMessage;

  try {
    // 1. Firebase apps list eka empty nam pamanak initialize karanna
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    isFirebaseInitialized = true;
    print("Firebase Successfully Initialized!");
  } catch (e) {
    // 2. Duplicate app error ekak awoth eka ignore karala app eka run karanna
    if (e.toString().contains('duplicate-app')) {
      isFirebaseInitialized = true;
      print("Firebase already initialized, skipping...");
    } else {
      print("Firebase initialization error: $e");
      isFirebaseInitialized = false;
      errorMessage = e.toString();
    }
  }

  runApp(
      isFirebaseInitialized
          ? const MyApp()
          : FirebaseErrorApp(errorMessage: errorMessage)
  );
}

class FirebaseErrorApp extends StatelessWidget {
  final String? errorMessage;
  const FirebaseErrorApp({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Firebase Configuration Error',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'If this persists, please restart your app using Hot Restart.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Detailed Error Log:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      errorMessage ?? 'Unknown error occurred.',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => main(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Community Health App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Initial loading state eka
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // User login wela nathnam Login Screen
    if (!authProvider.isLoggedIn) {
      return const LoginScreen();
    }

    // User ge data Firestore eken load wenakan balan inna kalla
    final user = authProvider.currentUserModel;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Loading User Profile..."),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => authProvider.logout(),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      );
    }

    // Role-based Routing (Mehi role eka 'admin' nam AdminDashboard load wei)
    switch (user.role) {
      case 'admin':
        return const AdminDashboard();
      case 'doctor':
        return const DoctorDashboard();
      case 'patient':
        return const PatientDashboard();
      default:
        return const PatientDashboard();
    }
  }
}