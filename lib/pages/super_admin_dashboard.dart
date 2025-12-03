import 'package:cms/components/AdminRequestManagementScreen.dart';
import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:cms/globals/auth_service.dart';
import 'package:cms/pages/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:cms/user_role.dart';
import 'package:cms/components/admin_sidebar.dart';

@NowaGenerated()
class SuperAdminDashboard extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() {
    return _SuperAdminDashboardState();
  }
}

@NowaGenerated()
class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _handleRemove(
    String phone,
    String name,
    AuthService authService,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Admin'),
        content: Text(
          'Are you sure you want to remove $name? They will need to request access again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await authService.removeAdmin(phone);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin removed successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final authService = AuthService.of(context);
      await authService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xff0a2342),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xff607286),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final currentUser = authService.currentUser;
        if (currentUser == null || currentUser.role != UserRole.superAdmin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final pendingCount = authService.pendingAdmins.length;
        final approvedCount = authService.approvedAdmins.length;
        final rejectedCount = authService.rejectedAdmins.length;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xffeaf1fb),
          appBar: AppBar(
            backgroundColor: const Color(0xff003a78),
            foregroundColor: Colors.white,
            title: Text('Super Admin - ${currentUser.name}'),
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _handleLogout,
              ),
            ],
          ),
          drawer: AdminSidebar(onRemove: _handleRemove),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Admin Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xff0a2342),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage admin requests and permissions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xff607286),
                    ),
              ),
              const SizedBox(height: 24),
              _buildDashboardCard(
                title: 'Approve Requests',
                subtitle: 'Review and manage all admin requests',
                icon: Icons.assignment_turned_in,
                color: const Color(0xff003a78),
                count: pendingCount + approvedCount + rejectedCount,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AdminRequestManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDashboardCard(
                      title: 'Pending',
                      subtitle: 'Awaiting review',
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                      count: pendingCount,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AdminRequestManagementScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDashboardCard(
                      title: 'Approved',
                      subtitle: 'Active admins',
                      icon: Icons.check_circle,
                      color: const Color(0xff21a345),
                      count: approvedCount,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AdminRequestManagementScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDashboardCard(
                title: 'Rejected',
                subtitle: 'Declined requests',
                icon: Icons.cancel,
                color: Colors.red,
                count: rejectedCount,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AdminRequestManagementScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}