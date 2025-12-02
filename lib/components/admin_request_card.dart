import 'package:flutter/material.dart';
import 'package:cms/models/user_model.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:cms/admin_status.dart';

@NowaGenerated()
class AdminRequestCard extends StatelessWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const AdminRequestCard({
    super.key,
    required this.admin,
    this.onApprove,
    this.onReject,
    this.onRemove,
  });

  final UserModel admin;

  /// Called when the super admin approves a *pending* admin.
  final VoidCallback? onApprove;

  /// Called when the super admin rejects a *pending* admin.
  final VoidCallback? onReject;

  /// Called when the super admin removes an *approved / rejected* admin.
  final VoidCallback? onRemove;

  String _getStatusText() {
    if (admin.status == AdminStatus.approved) {
      return 'Approved';
    } else {
      if (admin.status == AdminStatus.rejected) {
        return 'Rejected';
      } else {
        return 'Pending';
      }
    }
  }

  Color _getStatusColor() {
    if (admin.status == AdminStatus.approved) {
      return const Color(0xff21a345);
    } else {
      if (admin.status == AdminStatus.rejected) {
        return Colors.red;
      } else {
        return Colors.orange;
      }
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${day}/${month}/${year} ${hour}:${minute}';
  }

  @override
  Widget build(BuildContext context) {
    final isPending = admin.status == AdminStatus.pending;
    final isApproved = admin.status == AdminStatus.approved;
    final isRejected = admin.status == AdminStatus.rejected;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xffeaf1fb),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: Color(0xff003a78)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      admin.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xff0a2342),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      admin.phone,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xff607286),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: Color(0xff607286),
              ),
              const SizedBox(width: 6),
              Text(
                'Created: ${_formatDate(admin.createdAt)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xff607286)),
              ),
            ],
          ),
          if (isPending && (onApprove != null || onReject != null)) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onApprove != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff21a345),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                if (onApprove != null && onReject != null)
                  const SizedBox(width: 12),
                if (onReject != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onReject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
              ],
            ),
          ] else if (!isPending && onRemove != null && (isApproved || isRejected)) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRemove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Remove'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
