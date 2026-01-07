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
  String? _selectedSite;
  DateTime _selectedDate = DateTime.now();
  DateTime _displayMonth = DateTime.now(); // Track current month being displayed
  final ScrollController _calendarScrollController = ScrollController();
  final AttendanceService _attendanceService = AttendanceService();
  
  // Cache for daily attendance to support strict filtering
  Map<String, Map<String, dynamic>> _dailyAttendanceCache = {};
  bool _isLoadingAttendance = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
      _fetchDailyAttendance();
    });
  }

  Future<void> _fetchDailyAttendance() async {
    if (!mounted) return;
    setState(() => _isLoadingAttendance = true);
    
    final records = await _attendanceService.getAllAttendanceForDate(_selectedDate);
    
    final newMap = <String, Map<String, dynamic>>{};
    for (var record in records) {
      if (record['laborId'] != null) {
        newMap[record['laborId']] = record;
      }
    }
    
    if (mounted) {
      setState(() {
        _dailyAttendanceCache = newMap;
        _isLoadingAttendance = false;
      });
    }
  }

  void _scrollToSelectedDate() {
    // Check if selected date is in the display month
    if (_selectedDate.year == _displayMonth.year && 
        _selectedDate.month == _displayMonth.month) {
      // Calculate scroll offset based on day of month
      final scrollOffset = (_selectedDate.day - 1) * 82.0; // 80 width + 12 margin
      
      if (_calendarScrollController.hasClients) {
        _calendarScrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
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
        _displayMonth = picked; // Update display month when date is picked
      });
      // Scroll to the selected date
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate();
      });
    }
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      // If date is from different month, update display month
      if (date.month != _displayMonth.month || date.year != _displayMonth.year) {
        _displayMonth = date;
      }
    });
    // Ensure the date is scrolled into view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
      _fetchDailyAttendance();
    });
  }

  void _handleMonthChange(int monthOffset) {
    setState(() {
      _displayMonth = DateTime(
        _displayMonth.year,
        _displayMonth.month + monthOffset,
      );
      _calendarScrollController.jumpTo(0);
    });
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
    String? siteId, // Add optional siteId
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
          laborId: laborId,
          laborName: laborName,
          date: _selectedDate,
          dayShift: dayShift,
          nightShift: nightShift,
          newWithdrawAmount: newWithdrawAmount,
          paymentMode: paymentMode,
          adminName: adminName,
          // Pass override info if available (for previous dates)
          siteName: siteName, 
          siteId: siteId,
        );
        
        // Refresh local cache to reflect changes immediately
        await _fetchDailyAttendance();
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
          // Calendar Strip with Month Display
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Column(
              children: [
                // Month/Year Header with Navigation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_displayMonth),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff003a78),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 20),
                            onPressed: () => _handleMonthChange(-1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 20),
                            onPressed: () => _handleMonthChange(1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Calendar Strip
                CalendarStrip(
                  selectedDate: _selectedDate,
                  displayMonth: _displayMonth,
                  onDateSelected: _handleDateSelected,
                  scrollController: _calendarScrollController,
                  onFullCalendarPressed: _showFullCalendar,
                ),
              ],
            ),
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
                // Filter labors based on selected site AND attendance records
                final labors = laborService.labors.where((labor) {
                   // 1. Determine effective site
                   final attendance = _dailyAttendanceCache[labor.id];
                   final effectiveSite = attendance != null 
                      ? (attendance['siteName'] as String?) 
                      : labor.siteName;
                   
                   // 2. Filter
                   if (_selectedSite == null || _selectedSite == 'All Sites') return true;
                   
                   // Strict comparison: if attendance exists, MUST match its siteName
                   // If no attendance, match current assignment
                   return effectiveSite == _selectedSite;
                }).toList();

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
                        siteId: data['siteId'],
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