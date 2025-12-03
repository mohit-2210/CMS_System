import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:provider/provider.dart';
import 'package:cms/globals/auth_service.dart';
import 'package:cms/pages/login_screen.dart';
import 'package:cms/admin_status.dart';
import 'package:cms/user_role.dart';
import 'package:cms/components/admin_request_card.dart';

@NowaGenerated()
class AdminDashboard extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

@NowaGenerated()
class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _handleApprove(
    BuildContext context,
    String phone,
    AuthService authService,
  ) async {
    try {
      authService.approveAdmin(phone);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin approved successfully!'),
            backgroundColor: Color(0xff21a345),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve admin: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    String phone,
    AuthService authService,
  ) async {
    try {
      authService.rejectAdmin(phone);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin request rejected'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject admin: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleRemove(
    BuildContext context,
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
      try {
        await authService.removeAdmin(phone);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin removed successfully'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove admin: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xff0a2342),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xff003a78).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Color(0xff003a78),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperAdminDrawer(AuthService authService) {
    final pendingAdmins = authService.pendingAdmins;
    final approvedAdmins = authService.approvedAdmins;
    final rejectedAdmins = authService.rejectedAdmins;
    final allAdmins = authService.allAdmins;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Color(0xff003a78)),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Admin Management',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${allAdmins.length} Total Admins',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: allAdmins.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: const Color(0xff607286).withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No admin requests yet',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: const Color(0xff607286)),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      // Pending Requests Section
                      if (pendingAdmins.isNotEmpty) ...[
                        _buildSectionHeader(
                          context,
                          'Pending Requests',
                          pendingAdmins.length,
                        ),
                        ...pendingAdmins.map(
                          (admin) => AdminRequestCard(
                            admin: admin,
                            onApprove: () => _handleApprove(
                              context,
                              admin.phone,
                              authService,
                            ),
                            onReject: () => _handleReject(
                              context,
                              admin.phone,
                              authService,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Approved Admins Section
                      if (approvedAdmins.isNotEmpty) ...[
                        _buildSectionHeader(
                          context,
                          'Approved Admins',
                          approvedAdmins.length,
                        ),
                        ...approvedAdmins.map(
                          (admin) => AdminRequestCard(
                            admin: admin,
                            onRemove: () => _handleRemove(
                              context,
                              admin.phone,
                              admin.name,
                              authService,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Rejected Requests Section
                      if (rejectedAdmins.isNotEmpty) ...[
                        _buildSectionHeader(
                          context,
                          'Rejected Requests',
                          rejectedAdmins.length,
                        ),
                        ...rejectedAdmins.map(
                          (admin) => AdminRequestCard(
                            admin: admin,
                            onRemove: () => _handleRemove(
                              context,
                              admin.phone,
                              admin.name,
                              authService,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: const Color(0xff003a78),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xff003a78),
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xff607286),
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final currentUser = authService.currentUser;
        if (currentUser == null) {
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

        final isRejected = currentUser.status == AdminStatus.rejected;
        final isSuperAdmin = currentUser.role == UserRole.superAdmin;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xffeaf1fb),
          appBar: AppBar(
            backgroundColor: const Color(0xff003a78),
            foregroundColor: Colors.white,
            title: Text(
              isSuperAdmin
                  ? 'Super Admin - ${currentUser.name}'
                  : 'Admin Dashboard - ${currentUser.name}',
            ),
            // Show menu icon ONLY for Super Admin
            leading: isSuperAdmin
                ? IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  )
                : null,
            automaticallyImplyLeading: isSuperAdmin,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
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
                  if (confirmed == true && context.mounted) {
                    await authService.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ],
          ),
          // Show drawer ONLY for Super Admin
          drawer: isSuperAdmin ? _buildSuperAdminDrawer(authService) : null,
          body: Column(
            children: [
              if (isRejected)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.red,
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your access request has been rejected by Super Admin. Limited access only.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildDashboardCard(
                        context,
                        icon: Icons.business,
                        title: 'Sites',
                        subtitle: 'Manage all project sites',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Sites feature coming soon')),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.people,
                        title: 'Labours',
                        subtitle: 'View and edit labour profiles',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Labours feature coming soon')),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Daily Attendance',
                        subtitle: 'Track and log attendance',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Attendance feature coming soon')),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.account_balance_wallet,
                        title: 'Labour Salary',
                        subtitle: 'Process and manage salaries',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Salary feature coming soon')),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.receipt_long,
                        title: 'Site-wise Expense',
                        subtitle: 'Record extra site expenses',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Expense feature coming soon')),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.bar_chart,
                        title: 'Admin Paid Money',
                        subtitle: 'Generate and view reports',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Reports feature coming soon')),
                          );
                        },
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