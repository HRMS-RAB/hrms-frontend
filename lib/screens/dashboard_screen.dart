import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  Widget _buildCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HRMS Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              '🎯 Quick Access',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ADMIN / HR
            if (auth.hasRole('ADMIN') || auth.hasRole('HR_ADMIN')) ...[
              _buildCard(
                title: 'Manage Employees',
                icon: Icons.people,
                onTap: () {
                  // TODO: navigate to employee list
                },
              ),
              _buildCard(
                title: 'System Settings',
                icon: Icons.settings,
                onTap: () {
                  // TODO: navigate to settings
                },
              ),
            ],

            // CHANGE PASSWORD – for everyone
            _buildCard(
              title: 'Change Password',
              icon: Icons.password,
              onTap: () {
                Navigator.pushNamed(context, '/change-password');
              },
            ),

            // HR_MANAGER
            if (auth.hasRole('HR_MANAGER'))
              _buildCard(
                title: 'Recruitment',
                icon: Icons.assignment_ind,
                onTap: () {
                  // TODO: recruitment flow
                },
              ),
          ],
        ),
      ),
    );
  }
}











/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  Widget _buildCard(
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HRMS Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text('🎯 Quick Access',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // -------- ADMIN / HR_ADMIN ------------
            if (auth.hasRole('ADMIN') || auth.hasRole('HR_ADMIN')) ...[
              _buildCard(
                  title: 'Manage Employees',
                  icon: Icons.people,
                  onTap: () {
                    // TODO: navigate to employee list
                  }),
              _buildCard(
                  title: 'System Settings',
                  icon: Icons.settings,
                  onTap: () {
                    // TODO: navigate to settings
                  }),
            ],

            // -------- HR_MANAGER -----------------
            if (auth.hasRole('HR_MANAGER'))
              _buildCard(
                  title: 'Recruitment',
                  icon: Icons.assignment_ind,
                  onTap: () {
                    // TODO: navigate to recruitment page
                  }),

            // -------- DEPT_HEAD ------------------
            if (auth.hasRole('DEPT_HEAD'))
              _buildCard(
                  title: 'Team Overview',
                  icon: Icons.group,
                  onTap: () {
                    // TODO: navigate to team dashboard
                  }),

            // -------- EMPLOYEE -------------------
            if (auth.hasRole('EMPLOYEE'))
              _buildCard(
                  title: 'My Profile',
                  icon: Icons.person,
                  onTap: () {
                    // TODO: navigate to profile
                  }),

            // -------- Fall-back ------------------
            if (auth.roles.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(
                  child: Text('No permissions assigned. Contact admin.',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
*/