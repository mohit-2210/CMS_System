import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:cms/globals/auth_service.dart';
import 'package:cms/pages/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:cms/user_role.dart';
import 'package:cms/components/admin_sidebar.dart';
import 'package:cms/components/admin_request_card.dart';

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

  void _showToast(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xff21a345) : Colors.red,
      ),
    );
  }

  Future<void> _handleApprove(String phone, AuthService authService) async {
    authService.approveAdmin(phone);
    _showToast('Admin approved successfully!');
  }

  Future<void> _handleReject(String phone, AuthService authService) async {
    authService.rejectAdmin(phone);
    _showToast('Admin rejected', isSuccess: false);
  }

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
          'Are you sure you want to remove ${name}? They will need to request access again.',
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
      _showToast('Admin removed successfully', isSuccess: false);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final currentUser = authService.currentUser;
        if (currentUser == null || currentUser?.role != UserRole.superAdmin) {
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
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xffeaf1fb),
          appBar: AppBar(
            backgroundColor: const Color(0xff003a78),
            foregroundColor: Colors.white,
            title: Text('Super Admin - ${currentUser?.name}'),
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
              if (authService.pendingAdmins.isNotEmpty) ...[
                Text(
                  'Pending Requests',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xff0a2342),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...authService.pendingAdmins.map(
                  (admin) => AdminRequestCard(
                    admin: admin,
                    onApprove: () => _handleApprove(admin.phone, authService),
                    onReject: () => _handleReject(admin.phone, authService),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (authService.approvedAdmins.isNotEmpty) ...[
                Text(
                  'Approved Admins',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xff0a2342),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...authService.approvedAdmins.map(
                  (admin) => AdminRequestCard(
                    admin: admin,
                    onRemove: () =>
                        _handleRemove(admin.phone, admin.name, authService),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (authService.rejectedAdmins.isNotEmpty) ...[
                Text(
                  'Rejected Requests',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xff0a2342),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...authService.rejectedAdmins.map(
                  (admin) => AdminRequestCard(
                    admin: admin,
                    onRemove: () =>
                        _handleRemove(admin.phone, admin.name, authService),
                  ),
                ),
              ],
              if (authService.allAdmins.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: const Color(0xff607286).withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No admin requests yet',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: const Color(0xff607286)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
