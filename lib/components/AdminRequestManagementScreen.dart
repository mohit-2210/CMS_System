import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:provider/provider.dart';
import 'package:cms/globals/auth_service.dart';
import 'package:cms/admin_status.dart';
import 'package:cms/components/admin_request_card.dart';

@NowaGenerated()
class AdminRequestManagementScreen extends StatelessWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const AdminRequestManagementScreen({super.key});

  Future<void> _handleApprove(
    BuildContext context,
    String phone,
    AuthService authService,
  ) async {
    try {
      authService.approveAdmin(phone);
      if (context.mounted) {
        _showSnackBar(
          context,
          'Admin approved successfully!',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          'Failed to approve admin: $e',
          isSuccess: false,
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
        _showSnackBar(
          context,
          'Admin request rejected',
          isSuccess: false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          'Failed to reject admin: $e',
          isSuccess: false,
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
          _showSnackBar(
            context,
            'Admin removed successfully',
            isSuccess: false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showSnackBar(
            context,
            'Failed to remove admin: $e',
            isSuccess: false,
          );
        }
      }
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    required bool isSuccess,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xff21a345) : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: const Color(0xff607286).withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'No Admin Requests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xff0a2342),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Admin requests will appear here when users register',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xff607286),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeaf1fb),
      appBar: AppBar(
        backgroundColor: const Color(0xff003a78),
        foregroundColor: Colors.white,
        title: const Text('Admin Requests'),
        elevation: 0,
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final pendingAdmins = authService.pendingAdmins;
          final approvedAdmins = authService.approvedAdmins;
          final rejectedAdmins = authService.rejectedAdmins;
          final allAdmins = authService.allAdmins;

          if (allAdmins.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 32),
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
                const SizedBox(height: 32),
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
                    // No buttons for rejected admins as per requirements
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}