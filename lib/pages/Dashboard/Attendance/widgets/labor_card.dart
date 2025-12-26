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
  bool _justUpdated = false;
  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _loadExistingAttendance();
  }

  @override
  void didUpdateWidget(LaborCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _justUpdated = false;
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

        if (existing != null) {
          _paymentMode = existing['paymentMode'] ?? 'GPay/UPI';
          _dayShift = existing['dayShift'] ?? 'Half Day';
          _nightShift = existing['nightShift'] ?? 'None';
          _selectedAdminName = existing['adminName'];
        }
      });
    }
  }

  @override
  void dispose() {
    _withdrawController.dispose();
    super.dispose();
  }

  bool _isUnassigned() {
    return widget.siteName.isEmpty || 
           widget.siteName == 'Unassigned' || 
           widget.siteName.toLowerCase() == 'unassigned';
  }

  void _showAssignmentRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Site Assignment Required',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cannot fill attendance for ${widget.laborName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This laborer has not been assigned to any site yet. Please assign them to a site first before marking attendance.',
              style: TextStyle(color: Color(0xff607286)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffeaf1fb),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xff003a78),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Go to Labours → Select laborer → Assign to Site',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xff003a78),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _toggleExpansion() {
    if (_isUnassigned()) {
      _showAssignmentRequiredDialog();
      return;
    }

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
    
    setState(() {
      _justUpdated = true;
      _isExpanded = false;
    });

    widget.onSave(data);

    Future.delayed(const Duration(milliseconds: 500), () {
      _loadExistingAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUnassigned = _isUnassigned();
    final isUpdate = _existingAttendance != null || _justUpdated;
    
    // Determine colors based on status
    final Color backgroundColor;
    final Color? borderColor;
    final Color iconColor;
    final Color iconBackgroundColor;
    
    if (isUnassigned) {
      // Red theme for unassigned
      backgroundColor = const Color(0xffffebee);
      borderColor = Colors.red;
      iconColor = Colors.red;
      iconBackgroundColor = const Color(0xffffcdd2);
    } else if (isUpdate) {
      // Green theme for updated/existing attendance
      backgroundColor = const Color(0xffd4edda);
      borderColor = const Color(0xff21a345);
      iconColor = const Color(0xff21a345);
      iconBackgroundColor = const Color(0xffc8e6c9);
    } else {
      // Default white theme
      backgroundColor = Colors.white;
      borderColor = null;
      iconColor = const Color(0xff003a78);
      iconBackgroundColor = const Color(0xffeaf1fb);
    }

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
                ? Border.all(color: borderColor, width: 1.5)
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
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isUnassigned ? Icons.warning_amber_rounded : Icons.person,
                      color: iconColor,
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
                          isUnassigned ? 'Not Assigned' : widget.siteName,
                          style: TextStyle(
                            fontSize: 14,
                            color: isUnassigned ? Colors.red : const Color(0xff607286),
                            fontWeight: isUnassigned ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (isUnassigned)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 14,
                                  color: Colors.red.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Assign to site first',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isUpdate && !isUnassigned)
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
                    color: iconColor,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded && !isUnassigned)
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