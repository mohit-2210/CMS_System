import 'package:flutter/material.dart';
import 'package:cms/pages/Dashboard/Attendance/service/attendance_service.dart';
import 'expanded_labor_form.dart';

class LaborCard extends StatefulWidget {
  final String laborId;
  final String laborName;
  final String siteName;
  final DateTime selectedDate;
  final Function(Map<String, dynamic>) onSave;

  const LaborCard({
    super.key,
    required this.laborId,
    required this.laborName,
    required this.siteName,
    required this.selectedDate,
    required this.onSave,
  });

  @override
  State<LaborCard> createState() => _LaborCardState();
}

class _LaborCardState extends State<LaborCard> {
  bool _isExpanded = false;
  final TextEditingController _withdrawController = TextEditingController();
  String _paymentMode = 'GPay/UPI';
  String _dayShift = 'Half Day';
  String _nightShift = 'None';
  String? _selectedAdminName;

  // Track existing attendance
  Map<String, dynamic>? _existingAttendance;
  bool _isLoading = true;
  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _loadExistingAttendance();
  }

  @override
  void didUpdateWidget(LaborCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when date changes
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadExistingAttendance();
    }
  }

  Future<void> _loadExistingAttendance() async {
    setState(() {
      _isLoading = true;
    });

    final existing = await _attendanceService.getAttendanceRecord(
      siteName: widget.siteName,
      laborId: widget.laborId,
      date: widget.selectedDate,
    );

    if (mounted) {
      setState(() {
        _existingAttendance = existing;
        _isLoading = false;

        // Pre-populate form with existing data
        if (existing != null) {
          _paymentMode = existing['paymentMode'] ?? 'GPay/UPI';
          _dayShift = existing['dayShift'] ?? 'Half Day';
          _nightShift = existing['nightShift'] ?? 'None';
          _selectedAdminName = existing['adminName'];
          // Don't pre-populate withdraw controller for new withdrawals
        }
      });
    }
  }

  @override
  void dispose() {
    _withdrawController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _save() {
    final data = {
      'laborId': widget.laborId,
      'laborName': widget.laborName,
      'siteName': widget.siteName,
      'dayShift': _dayShift,
      'nightShift': _nightShift,
      'withdrawAmount': _withdrawController.text.trim().isEmpty
          ? null
          : _withdrawController.text.trim(),
      'paymentMode': _paymentMode,
      'adminName': _selectedAdminName,
    };
    widget.onSave(data);
    // Optionally close expansion after save
    setState(() {
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if this is an update (record exists)
    final isUpdate = _existingAttendance != null;
    final backgroundColor = isUpdate
        ? const Color(0xffd4edda) // Light green for updates
        : Colors.white;
    final borderColor = isUpdate ? const Color(0xff21a345) : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: _isExpanded
            ? Border.all(color: const Color(0xff003a78), width: 2)
            : borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isExpanded ? 0.1 : 0.05),
            blurRadius: _isExpanded ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isUpdate
                          ? const Color(0xffc8e6c9)
                          : const Color(0xffeaf1fb),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person,
                      color: isUpdate
                          ? const Color(0xff21a345)
                          : const Color(0xff003a78),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.laborName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0a2342),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.siteName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff607286),
                          ),
                        ),
                        if (isUpdate)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 12,
                                  color: Color(0xff21a345),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Updated',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff21a345),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isUpdate
                        ? const Color(0xff21a345)
                        : const Color(0xff003a78),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            ExpandedLaborForm(
              withdrawController: _withdrawController,
              paymentMode: _paymentMode,
              dayShift: _dayShift,
              nightShift: _nightShift,
              selectedAdminName: _selectedAdminName,
              existingWithdrawalAmount:
                  _existingAttendance?['withdrawAmount'] as int?,
              onPaymentModeChanged: (value) =>
                  setState(() => _paymentMode = value ?? _paymentMode),
              onDayShiftChanged: (value) =>
                  setState(() => _dayShift = value ?? _dayShift),
              onNightShiftChanged: (value) =>
                  setState(() => _nightShift = value ?? _nightShift),
              onAdminNameChanged: (value) =>
                  setState(() => _selectedAdminName = value),
              onSave: _save,
            ),
        ],
      ),
    );
  }
}