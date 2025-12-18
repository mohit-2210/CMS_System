import 'package:cms/pages/Dashboard/Attendance/service/attendance_service.dart';
import 'package:cms/pages/Dashboard/Attendance/widgets/calendar_strip.dart';
import 'package:cms/pages/Dashboard/Attendance/widgets/labor_card.dart';
import 'package:cms/pages/Dashboard/Attendance/widgets/site_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cms/globals/labor_service.dart';
import 'package:intl/intl.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class DailyAttendanceScreen extends StatefulWidget {
  const DailyAttendanceScreen({super.key});

  @override
  State<DailyAttendanceScreen> createState() => _DailyAttendanceScreenState();
}

@NowaGenerated()
class _DailyAttendanceScreenState extends State<DailyAttendanceScreen> {
  String? _selectedSite; // Default to null (All Sites)
  DateTime _selectedDate = DateTime.now();
  final ScrollController _calendarScrollController = ScrollController();
  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  void _scrollToToday() {
    final today = DateTime.now();
    final daysDifference =
        today.difference(DateTime(today.year, today.month, 1)).inDays;
    final scrollOffset = daysDifference * 80.0;
    if (_calendarScrollController.hasClients) {
      _calendarScrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    super.dispose();
  }

  Future<void> _showFullCalendar() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff003a78),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xff0a2342),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveAttendance({
    required String laborId,
    required String laborName,
    required String siteName,
    required String dayShift,
    required String nightShift,
    required String? withdrawAmount,
    required String paymentMode,
    required String? adminName,
  }) async {
    // Validation
    if (adminName == null || adminName.isEmpty) {
      if (withdrawAmount != null && withdrawAmount.isNotEmpty) {
        _showErrorSnackBar('Please select an admin for payment entry');
        return;
      }
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Site: $siteName'),
            Text('Labour: $laborName',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}'),
            const SizedBox(height: 8),
            Text('Day Shift: $dayShift'),
            Text('Night Shift: $nightShift'),
            if (withdrawAmount != null && withdrawAmount.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('New Withdrawal: ₹$withdrawAmount'),
              Text('Payment Mode: $paymentMode'),
              Text('Admin: $adminName'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff003a78),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final newWithdrawAmount =
            withdrawAmount != null && withdrawAmount.isNotEmpty
                ? int.tryParse(withdrawAmount)
                : null;

        await _attendanceService.createOrUpdateAttendance(
          siteName: siteName,
          laborId: laborId,
          laborName: laborName,
          date: _selectedDate,
          dayShift: dayShift,
          nightShift: nightShift,
          newWithdrawAmount: newWithdrawAmount,
          paymentMode: paymentMode,
          adminName: adminName,
        );

        _showSuccessSnackBar(
          newWithdrawAmount != null && newWithdrawAmount > 0
              ? 'Attendance and payment recorded'
              : 'Attendance recorded successfully',
        );
      } catch (e) {
        _showErrorSnackBar('Failed to save attendance: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
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
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xff21a345),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Daily Attendance'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Site Selector
          SiteSelector(
            selectedSite: _selectedSite,
            onSiteChanged: (value) => setState(() => _selectedSite = value),
          ),
          // Calendar Strip
          CalendarStrip(
            selectedDate: _selectedDate,
            onDateSelected: (date) => setState(() => _selectedDate = date),
            scrollController: _calendarScrollController,
            onFullCalendarPressed: _showFullCalendar,
          ),
          // Labor List Header
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xffeaf1fb),
            child: Row(
              children: [
                const Text(
                  'LABOR LIST',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff607286),
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMMM dd, yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff607286),
                  ),
                ),
              ],
            ),
          ),
          // Labor Cards List
          Expanded(
            child: Consumer<LaborService>(
              builder: (context, laborService, child) {
                // Filter labors based on selected site
                final labors = _selectedSite != null && _selectedSite != 'All Sites'
                    ? laborService.labors
                        .where((labor) => labor.siteName == _selectedSite)
                        .toList()
                    : laborService.labors; // All Sites: show all labors

                if (labors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: const Color(0xff607286).withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedSite != null && _selectedSite != 'All Sites'
                              ? 'No labors found for this site'
                              : 'No labors available',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xff607286),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: labors.length,
                  itemBuilder: (context, index) {
                    final labor = labors[index];
                    return LaborCard(
                      laborId: labor.id,
                      laborName: labor.laborName,
                      siteName: labor.siteName,
                      selectedDate: _selectedDate,
                      onSave: (data) => _saveAttendance(
                        laborId: data['laborId'],
                        laborName: data['laborName'],
                        siteName: data['siteName'],
                        dayShift: data['dayShift'],
                        nightShift: data['nightShift'],
                        withdrawAmount: data['withdrawAmount'],
                        paymentMode: data['paymentMode'],
                        adminName: data['adminName'],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}