// lib/widgets/expanded_labor_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExpandedLaborForm extends StatelessWidget {
  final TextEditingController withdrawController;
  final TextEditingController adminNameController;
  final String paymentMode;
  final String dayShift;
  final String nightShift;
  final ValueChanged<String?> onPaymentModeChanged;
  final ValueChanged<String?> onDayShiftChanged;
  final ValueChanged<String?> onNightShiftChanged;
  final VoidCallback onSave;

  const ExpandedLaborForm({
    super.key,
    required this.withdrawController,
    required this.adminNameController,
    required this.paymentMode,
    required this.dayShift,
    required this.nightShift,
    required this.onPaymentModeChanged,
    required this.onDayShiftChanged,
    required this.onNightShiftChanged,
    required this.onSave,
  });

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
          // Withdraw Amount
          const Text(
            'Withdraw Amount',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff0a2342)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: withdrawController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '500',
              prefixText: '₹ ',
              filled: true,
              fillColor: const Color(0xfff5f5f5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          // Payment Mode
          const Text(
            'Payment Mode',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff0a2342)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: paymentMode,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xfff5f5f5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: ['GPay/UPI', 'Cash', 'PhonePe', 'Paytm', 'BHIM', 'Cheque', 'Other']
                .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                .toList(),
            onChanged: onPaymentModeChanged,
          ),
          const SizedBox(height: 16),
          // Admin Name
          const Text(
            'Admin Name',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff0a2342)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: adminNameController,
            decoration: InputDecoration(
              hintText: 'Supervisor A',
              filled: true,
              fillColor: const Color(0xfff5f5f5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
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
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff0a2342)),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: dayShift,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xfff5f5f5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: ['Full Day', 'Half Day', 'Semi-Half Day', 'Half Day + Half Day']
                          .map((shift) => DropdownMenuItem(value: shift, child: Text(shift, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: onDayShiftChanged,
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
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff0a2342)),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: nightShift,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xfff5f5f5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: ['None', 'Full Night', 'Half Night', 'Half Night + Half Night']
                          .map((shift) => DropdownMenuItem(value: shift, child: Text(shift, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: onNightShiftChanged,
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
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff003a78),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Update Record', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}