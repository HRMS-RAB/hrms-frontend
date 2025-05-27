import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  Widget _buildCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HRMS Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          const Text(
            '🎯 Quick Access',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          if (auth.hasRole('ADMIN') || auth.hasRole('HR_MANAGER'))
            _buildCard('Manage Employees', Icons.people, () {
              // Navigate to employee list screen
            }),

          if (auth.hasRole('ADMIN'))
            _buildCard('System Settings', Icons.settings, () {
              // Navigate to admin settings
            }),

          if (auth.hasRole('EMPLOYEE'))
            _buildCard('My Profile', Icons.person, () {
              // Navigate to personal profile page
            }),

          if (auth.hasRole('HR_MANAGER'))
            _buildCard('Recruitment', Icons.assignment_ind, () {
              // Navigate to recruitment page
            }),

          if (auth.roles.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(
                child: Text(
                  'No permissions assigned. Contact admin.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
