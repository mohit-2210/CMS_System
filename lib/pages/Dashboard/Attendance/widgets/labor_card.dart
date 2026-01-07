import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cms/globals/site_service.dart';
import 'package:cms/components/animated_dropdown.dart';
import 'package:cms/pages/Dashboard/Attendance/service/attendance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        } else {
          // Load sticky defaults if no existing record
          _loadStickyDefaults();
        }
      });
    }
  }

  Future<void> _loadStickyDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      
      setState(() {
        _paymentMode = prefs.getString('last_payment_mode') ?? 'GPay/UPI';
        _dayShift = prefs.getString('last_day_shift') ?? 'Half Day';
        _nightShift = prefs.getString('last_night_shift') ?? 'None';
      });
    } catch (e) {
      debugPrint('Error loading sticky defaults: $e');
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

  // New: Check if we need to show site selector
  bool _shouldShowSiteSelector() {
    // Only show if:
    // 1. It is a past date (not today)
    // 2. AND no existing attendance record found
    // 3. AND labor is either unassigned OR we want to allow override even if assigned (User simplified: "if no attendance record exists")
    // Re-reading request: "Filling Attendance for a Previous Date (No Attendance Exists)... The labour list should show an additional dropdown"
    
    final isPastDate = widget.selectedDate.isBefore(DateTime(
      DateTime.now().year, 
      DateTime.now().month, 
      DateTime.now().day
    ));

    return isPastDate && _existingAttendance == null;
  }

  String? _selectedSiteForPastDate;

  void _showAssignmentRequiredDialog() {
    // Only block if strictly unassigned AND not allowing past date override
    // But for past date flow, we allow selecting site manually if no record exists.
    // So only block if it's TODAY and unassigned.
    
    if (_shouldShowSiteSelector()) return; // Don't block, show selector instead

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
    if (_isUnassigned() && !_shouldShowSiteSelector()) {
      _showAssignmentRequiredDialog();
      return;
    }

    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Future<void> _save() async {
    // If strict mode (past date), site selection is mandatory
    if (_shouldShowSiteSelector() && (_selectedSiteForPastDate == null || _selectedSiteForPastDate!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a site for this attendance record')),
      );
      return;
    }

    String? resolvedSiteId;
    final overrideSiteName = _shouldShowSiteSelector() ? _selectedSiteForPastDate : null;

    if (overrideSiteName != null) {
       final siteService = context.read<SiteService>();
       try {
         final site = siteService.sites.firstWhere((s) => s.siteName == overrideSiteName);
         resolvedSiteId = site.id;
       } catch (e) {
         // Should not happen if data is consistent
         print('Error finding site ID for name: $overrideSiteName');
       }
    }

    final data = {
      'laborId': widget.laborId,
      'laborName': widget.laborName,
      'siteName': overrideSiteName ?? widget.siteName,
      'siteId': resolvedSiteId, // Pass optional siteId
      'dayShift': _dayShift,
      'nightShift': _nightShift,
      'withdrawAmount': _withdrawController.text.trim().isEmpty
          ? null
          : _withdrawController.text.trim(),
      'paymentMode': _paymentMode,
      'adminName': _selectedAdminName,
    };
    
    // UI Feedback: collapse immediately but DON'T turn green yet
    setState(() {
      _isExpanded = false;
      _isLoading = true; // Show loading state
    });

    try {
      // Await the save operation
      await widget.onSave(data);

      // Save sticky defaults
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_payment_mode', _paymentMode);
        await prefs.setString('last_day_shift', _dayShift);
        await prefs.setString('last_night_shift', _nightShift);
      } catch (e) {
        debugPrint('Error saving sticky defaults: $e');
      }

      // Only update UI to success state AFTER successful save
      if (mounted) {
        setState(() {
          _justUpdated = true;
          _isLoading = false;
        });
        
        // Refresh data
        await _loadExistingAttendance();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isExpanded = true; // Re-open on error
        });
        // Error handling matches parent's snackbar usually
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnassigned = _isUnassigned();
    final isUpdate = _existingAttendance != null || _justUpdated;
    
    // Determine colors
    Color backgroundColor = Colors.white;
    Color? borderColor;
    Color iconColor = const Color(0xff003a78);
    Color iconBackgroundColor = const Color(0xffeaf1fb);
    
    if (isUnassigned && !_shouldShowSiteSelector()) {
      backgroundColor = const Color(0xffffebee);
      borderColor = Colors.red;
      iconColor = Colors.red;
      iconBackgroundColor = const Color(0xffffcdd2);
    } else if (isUpdate) {
      backgroundColor = const Color(0xffd4edda);
      borderColor = const Color(0xff21a345);
      iconColor = const Color(0xff21a345);
      iconBackgroundColor = const Color(0xffc8e6c9);
    } else if (_isLoading && !_isExpanded) {
       // Saving state
       backgroundColor = const Color(0xfff5f5f5);
       borderColor = Colors.grey;
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
                    child: _isLoading && !_isExpanded
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          (isUnassigned && !_shouldShowSiteSelector()) ? Icons.warning_amber_rounded : Icons.person,
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
                          _existingAttendance != null 
                              ? (_existingAttendance!['siteName'] ?? widget.siteName)
                              : (isUnassigned && !_shouldShowSiteSelector())
                                  ? 'Not Assigned' 
                                  : (_shouldShowSiteSelector() && _selectedSiteForPastDate != null)
                                      ? 'Site: $_selectedSiteForPastDate'
                                      : (_shouldShowSiteSelector())
                                          ? 'Tap to Select Site'
                                          : widget.siteName,
                          style: TextStyle(
                            fontSize: 14,
                            color: (isUnassigned && !_shouldShowSiteSelector() && _existingAttendance == null) 
                                ? Colors.red 
                                : (_shouldShowSiteSelector() && _selectedSiteForPastDate == null && _existingAttendance == null)
                                    ? Colors.orange.shade700 // Orange for "Action Required"
                                    : const Color(0xff607286),
                            fontWeight: (isUnassigned && !_shouldShowSiteSelector() && _existingAttendance == null) 
                                ? FontWeight.w600 
                                : (_shouldShowSiteSelector() && _selectedSiteForPastDate == null && _existingAttendance == null)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        if (isUnassigned && !_shouldShowSiteSelector())
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
                        if (isUpdate && !(isUnassigned && !_shouldShowSiteSelector()))
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
          if (_isExpanded) ...[
             // Site Selector for Past Dates
             if (_shouldShowSiteSelector())
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text(
                       'SELECT SITE (Past Date Override)',
                       style: TextStyle(
                         fontSize: 12,
                         fontWeight: FontWeight.bold,
                         color: Color(0xff607286),
                         letterSpacing: 0.5,
                       ),
                     ),
                     const SizedBox(height: 8),
                     Consumer<SiteService>(
                        builder: (context, siteService, child) {
                          final sites = siteService.sites;
                          // Filter out empty/invalid site names if any
                          final siteNames = sites.map((s) => s.siteName).where((name) => name.isNotEmpty).toList();
                          
                          if (siteNames.isEmpty) {
                            return const Text('No active sites available', style: TextStyle(color: Colors.red));
                          }
                          
                          return AnimatedDropdown<String>(
                            value: _selectedSiteForPastDate,
                            items: siteNames,
                            hintText: 'Select Site',
                            itemLabelBuilder: (item) => item,
                            onChanged: (value) {
                              setState(() {
                                _selectedSiteForPastDate = value;
                              });
                            },
                          );
                        },
                     ),
                   ],
                 ),
               ),
          
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
          ]
        ],
      ),
    );
  }
}