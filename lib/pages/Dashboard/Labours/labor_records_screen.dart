import 'package:cms/models/labor_model.dart';
import 'package:cms/pages/Dashboard/Labours/add_labor_screen.dart';
import 'package:cms/pages/Dashboard/Labours/widgets/assign_labor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cms/globals/labor_service.dart';
import 'package:cms/globals/site_service.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:intl/intl.dart';

@NowaGenerated()
class LaborRecordsScreen extends StatefulWidget {
  const LaborRecordsScreen({super.key});

  @override
  State<LaborRecordsScreen> createState() => _LaborRecordsScreenState();
}

@NowaGenerated()
class _LaborRecordsScreenState extends State<LaborRecordsScreen> {
  final Set<String> _selectedLaborIds = {};
  bool _isSelectionMode = false;

  void _toggleSelection(String laborId) {
    setState(() {
      if (_selectedLaborIds.contains(laborId)) {
        _selectedLaborIds.remove(laborId);
      } else {
        _selectedLaborIds.add(laborId);
      }
      _isSelectionMode = _selectedLaborIds.isNotEmpty;
    });
  }

  void _enterSelectionMode(String laborId) {
    setState(() {
      _isSelectionMode = true;
      _selectedLaborIds.add(laborId);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedLaborIds.clear();
      _isSelectionMode = false;
    });
  }

  // Get labor summary counts
  Map<String, int> _getLaborCounts(List<dynamic> labors) {
    final total = labors.length;
    final assigned = labors.where((l) => l.siteName != null && l.siteName.isNotEmpty && l.siteName != 'Unassigned').length;
    final unassigned = total - assigned;
    
    return {
      'total': total,
      'assigned': assigned,
      'unassigned': unassigned,
    };
  }

  // Check if labor is already assigned
  bool _isLaborAssigned(String siteName) {
    return siteName != null && siteName.isNotEmpty && siteName != 'Unassigned';
  }

  Future<void> _handleDelete(BuildContext context) async {
    if (_selectedLaborIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Are you sure?'),
          ],
        ),
        content: Text(
          'This action cannot be undone. You are about to permanently delete ${_selectedLaborIds.length} selected labor(s).',
          style: const TextStyle(color: Color(0xff607286)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff607286),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final laborService = context.read<LaborService>();
      final success = await laborService.deleteLabors(_selectedLaborIds.toList());

      if (context.mounted) {
        _clearSelection();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text('Labors deleted successfully'),
                ],
              ),
              backgroundColor: const Color(0xff22a340),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete labors'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  Future<void> _showAssignmentDialog({
    required List<String> laborIds,
    required List<LaborModel> labors,
    bool isEdit = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AssignLaborDialog(
        selectedLaborIds: laborIds,
        labors: labors,
        isEdit: isEdit,
      ),
    );

    // Clear selection after dialog closes if assignment was successful
    if (result == true && !isEdit) {
      _clearSelection();
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe7eff6),
      appBar: AppBar(
        backgroundColor: const Color(0xff093e86),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isSelectionMode) {
              _clearSelection();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Add Labour to Site'),
        centerTitle: false,
      ),
      body: Consumer2<LaborService, SiteService>(
        builder: (context, laborService, siteService, child) {
          final labors = laborService.labors;
          final counts = _getLaborCounts(labors);

          if (laborService.isLoading && labors.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Dashboard Summary Section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xff093e86),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${counts['total']}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.white30,
                    ),
                    Column(
                      children: [
                        Text(
                          '${counts['assigned']}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'ASSIGNED',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.white30,
                    ),
                    Column(
                      children: [
                        Text(
                          '${counts['unassigned']}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'UNASSIGNED',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Labour List
              Expanded(
                child: labors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: const Color(0xff607286)
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No labours added yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: const Color(0xff607286),
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: labors.length,
                        itemBuilder: (context, index) {
                          final labor = labors[index];
                          final isSelected =
                              _selectedLaborIds.contains(labor.id);
                          final isAssigned =
                              _isLaborAssigned(labor.siteName);

                          return GestureDetector(
                            onTap: () {
                              if (isAssigned) {
                                // Open edit dialog for assigned labor
                                _showAssignmentDialog(
                                  laborIds: [labor.id],
                                  labors: [labor],
                                  isEdit: true,
                                );
                              } else {
                                _toggleSelection(labor.id);
                              }
                            },
                            onLongPress: isAssigned
                                ? null
                                : () => _enterSelectionMode(labor.id),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isAssigned
                                    ? const Color(0xfff0f0f0)
                                    : isSelected
                                        ? const Color(0xffe8f5e9)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: isAssigned
                                    ? Border.all(
                                        color: const Color(0xffe0e0e0),
                                      )
                                    : isSelected
                                        ? Border.all(
                                            color:
                                                const Color(0xff4caf50),
                                            width: 2,
                                          )
                                        : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.05,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Checkbox
                                  if (!isAssigned) ...[
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? null
                                            : Border.all(
                                                color: const Color(
                                                  0xffc4c4c4,
                                                ),
                                                width: 2,
                                              ),
                                        color: isSelected
                                            ? const Color(0xff4caf50)
                                            : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                  ] else ...[
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xff4caf50),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  // Labour Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          labor.laborName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isAssigned
                                                ? const Color(0xffb0b0b0)
                                                : const Color(0xff0a2342),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          labor.work,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isAssigned
                                                ? const Color(0xffc0c0c0)
                                                : const Color(0xff607286),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          labor.siteName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isAssigned
                                                ? const Color(0xffc0c0c0)
                                                : const Color(0xff607286),
                                          ),
                                        ),
                                        if (isAssigned)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6,
                                            ),
                                            child: Text(
                                              'Already Assigned to ${labor.siteName}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xffb0b0b0),
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Salary
                                  Text(
                                    _formatCurrency(labor.salary),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isAssigned
                                          ? const Color(0xffb0b0b0)
                                          : const Color(0xff093e86),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Bottom Action Buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Assign to Site Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectedLaborIds.isEmpty
                            ? null
                            : () {
                                _showAssignmentDialog(
                                  laborIds: _selectedLaborIds.toList(),
                                  labors: labors
                                      .where((l) => _selectedLaborIds
                                          .contains(l.id))
                                      .toList(),
                                  isEdit: false,
                                );
                              },
                        icon: const Icon(Icons.assignment),
                        label: const Text('Assign to Site'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _selectedLaborIds.isEmpty
                                  ? Colors.grey
                                  : const Color(0xff093e86),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Add New Labor Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddLaborScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add New Labor'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff093e86),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Color(0xff093e86),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}