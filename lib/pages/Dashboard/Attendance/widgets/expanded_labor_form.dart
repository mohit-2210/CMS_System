import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cms/pages/Dashboard/Attendance/service/attendance_service.dart';

class ExpandedLaborForm extends StatefulWidget {
  final TextEditingController withdrawController;
  final String paymentMode;
  final String dayShift;
  final String nightShift;
  final String? selectedAdminName;
  final int? existingWithdrawalAmount;
  final ValueChanged<String?> onPaymentModeChanged;
  final ValueChanged<String?> onDayShiftChanged;
  final ValueChanged<String?> onNightShiftChanged;
  final ValueChanged<String?> onAdminNameChanged;
  final VoidCallback onSave;

  const ExpandedLaborForm({
    super.key,
    required this.withdrawController,
    required this.paymentMode,
    required this.dayShift,
    required this.nightShift,
    required this.selectedAdminName,
    required this.existingWithdrawalAmount,
    required this.onPaymentModeChanged,
    required this.onDayShiftChanged,
    required this.onNightShiftChanged,
    required this.onAdminNameChanged,
    required this.onSave,
  });

  @override
  State<ExpandedLaborForm> createState() => _ExpandedLaborFormState();
}

class _ExpandedLaborFormState extends State<ExpandedLaborForm> {
  late Future<List<String>> _adminsFuture;
  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _adminsFuture = _attendanceService.getApprovedAdminsAndSuperAdmins();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xffe0e0e0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Existing Withdrawal Amount Display
          if (widget.existingWithdrawalAmount != null &&
              widget.existingWithdrawalAmount! > 0)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xffd4edda),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xff21a345), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xff21a345),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Withdrawal (Cumulative)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff21a345),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${widget.existingWithdrawalAmount}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff21a345),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Withdraw Amount
          const Text(
            'New Withdrawal Amount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff0a2342),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.withdrawController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '500',
              hintStyle: const TextStyle(color: Color(0xffa0a0a0)),
              prefixText: '₹ ',
              filled: true,
              fillColor: const Color(0xfff5f5f5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          // Payment Mode
          const Text(
            'Payment Mode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff0a2342),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: widget.paymentMode,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xfff5f5f5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: ['GPay/UPI', 'Cash', 'PhonePe', 'Paytm', 'BHIM', 'Cheque', 'Other']
                .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                .toList(),
            onChanged: widget.onPaymentModeChanged,
          ),
          const SizedBox(height: 16),
          // Admin Name Dropdown (NEW)
          const Text(
            'Admin Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff0a2342),
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<String>>(
            future: _adminsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xfff5f5f5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xff003a78),
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: const Text(
                    'Error loading admins',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                );
              }

              final admins = snapshot.data ?? [];

              if (admins.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: const Text(
                    'No approved admins found',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                );
              }

              return DropdownButtonFormField<String>(
                // initialValue: widget.selectedAdminName != null &&
                //         admins.contains(widget.selectedAdminName)
                //     ? widget.selectedAdminName
                //     : null,
                hint: const Text('Select an admin'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xfff5f5f5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: admins
                    .map((admin) =>
                        DropdownMenuItem(value: admin, child: Text(admin)))
                    .toList(),
                onChanged: widget.onAdminNameChanged,
              );
            },
          ),
          const SizedBox(height: 16),
          // Day and Night Shift Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Day Shift',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff0a2342),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: widget.dayShift,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xfff5f5f5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: ['None', 'Full Day', 'Half Day', 'Semi-Half Day']
                          .map((shift) => DropdownMenuItem(
                              value: shift,
                              child: Text(
                                shift,
                                style: const TextStyle(fontSize: 13),
                              )))
                          .toList(),
                      onChanged: widget.onDayShiftChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Night Shift',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff0a2342),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: widget.nightShift,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xfff5f5f5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: ['None', 'Full Night', 'Half Night', 'Semi-Half Night']
                          .map((shift) => DropdownMenuItem(
                              value: shift,
                              child: Text(
                                shift,
                                style: const TextStyle(fontSize: 13),
                              )))
                          .toList(),
                      onChanged: widget.onNightShiftChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Update Record Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff003a78),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Update Record',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}