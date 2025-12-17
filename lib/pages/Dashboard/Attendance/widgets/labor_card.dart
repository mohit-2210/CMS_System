// lib/widgets/labor_card.dart
import 'package:flutter/material.dart';
import 'expanded_labor_form.dart';

class LaborCard extends StatefulWidget {
  final String laborId;
  final String laborName;
  final String siteName;
  final Function(Map<String, dynamic>) onSave;

  const LaborCard({
    super.key,
    required this.laborId,
    required this.laborName,
    required this.siteName,
    required this.onSave,
  });

  @override
  State<LaborCard> createState() => _LaborCardState();
}

class _LaborCardState extends State<LaborCard> {
  bool _isExpanded = false;
  final TextEditingController _withdrawController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();
  String _paymentMode = 'GPay/UPI';
  String _dayShift = 'Half Day';
  String _nightShift = 'None';

  @override
  void dispose() {
    _withdrawController.dispose();
    _adminNameController.dispose();
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
      'withdrawAmount': _withdrawController.text.trim(),
      'paymentMode': _paymentMode,
      'adminName': _adminNameController.text.trim().isEmpty ? null : _adminNameController.text.trim(),
    };
    widget.onSave(data);
    // Optionally close expansion after save
    setState(() {
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: _isExpanded ? Border.all(color: const Color(0xff003a78), width: 2) : null,
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
                      color: const Color(0xffeaf1fb),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xff003a78),
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
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xff003a78),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            ExpandedLaborForm(
              withdrawController: _withdrawController,
              adminNameController: _adminNameController,
              paymentMode: _paymentMode,
              dayShift: _dayShift,
              nightShift: _nightShift,
              onPaymentModeChanged: (value) => setState(() => _paymentMode = value ?? _paymentMode),
              onDayShiftChanged: (value) => setState(() => _dayShift = value ?? _dayShift),
              onNightShiftChanged: (value) => setState(() => _nightShift = value ?? _nightShift),
              onSave: _save,
            ),
        ],
      ),
    );
  }
}