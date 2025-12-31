import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cms/models/labor_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class SiteWiseSalaryDetailsScreen extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const SiteWiseSalaryDetailsScreen({
    super.key,
    required this.siteName,
    required this.fromDate,
    required this.toDate,
  });

  final String siteName;
  final DateTime fromDate;
  final DateTime toDate;

  @override
  State<SiteWiseSalaryDetailsScreen> createState() =>
      _SiteWiseSalaryDetailsScreenState();
}

@NowaGenerated()
class _SiteWiseSalaryDetailsScreenState
    extends State<SiteWiseSalaryDetailsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _salaryData = [];
  double _totalPayableSalary = 0;

  @override
  void initState() {
    super.initState();
    _fetchAndCalculateSalary();
  }

  Future<void> _fetchAndCalculateSalary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final laborsSnapshot = await FirebaseFirestore.instance
          .collection('labors')
          .where('siteName', isEqualTo: widget.siteName)
          .get();

      final labors = laborsSnapshot.docs
          .map((doc) => LaborModel.fromJson(doc.data()))
          .toList();

      List<Map<String, dynamic>> calculatedData = [];
      double totalPayable = 0;
      final random = Random();

      for (var labor in labors) {
        // Mock Attendance Logic
        int totalDays = widget.toDate.difference(widget.fromDate).inDays + 1;
        int presentDays = 0;
        int halfDays = 0;

        // Simple mock: Randomly assign full/half days ensuring it doesn't exceed totalDays
        // This is just for demo visualization as requested
        presentDays = random.nextInt(totalDays + 1); 
        // halfDays = random.nextInt(totalDays - presentDays + 1); // Remaining days could be half

        // Let's make it a bit more realistic for the screenshot demo
        // e.g. 80-90% attendance
        if (totalDays > 5) {
           presentDays = (totalDays * 0.8).toInt() + random.nextInt((totalDays * 0.1).toInt() + 1);
           int remaining = totalDays - presentDays;
           if (remaining > 0) {
             halfDays = random.nextInt(remaining + 1);
           }
        }
        
        double dailySalary = labor.salary;
        double totalSalary =
            (presentDays * dailySalary) + (halfDays * dailySalary * 0.5);

        totalPayable += totalSalary;

        calculatedData.add({
          'labourName': labor.laborName,
          'work': labor.work, // Added for subtitle (e.g. Mason)
          'rate': dailySalary,
          'fullDays': presentDays,
          'halfDays': halfDays,
          'totalSalary': totalSalary,
        });
      }

      setState(() {
        _salaryData = calculatedData;
        _totalPayableSalary = totalPayable;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching salary data: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text(
          'Salary Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff0a2342),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Premium Header Card
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff0a2342), Color(0xff003a78)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff003a78).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.business,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PROJECT SITE',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 11,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.siteName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(
                                color: Colors.white24,
                                height: 1,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.date_range,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DURATION',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 11,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${dateFormat.format(widget.fromDate)} - ${dateFormat.format(widget.toDate)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Table Header / List Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
                    children: [
                      Text(
                        'LABOUR LIST',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_salaryData.length} Workers',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // List Data - Cards
                Expanded(
                  child: _salaryData.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off_outlined,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('No Labors found for this site',
                                  style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: _salaryData.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _salaryData[index];
                            return _buildLabourSalaryCard(context, index, item);
                          },
                        ),
                ),

                // Footer Total
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'TOTAL PAYABLE',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'For selected duration',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹${NumberFormat('#,##0').format(_totalPayableSalary)}',
                          style: const TextStyle(
                            color: Color(0xff003a78),
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
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

  Widget _buildLabourSalaryCard(
      BuildContext context, int index, Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xffeaf1fb),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: Color(0xff003a78),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['labourName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xff0a2342),
                      ),
                    ),
                    Text(
                      item['work'] ?? 'Worker',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${NumberFormat('#,##0').format(item['totalSalary'])}',
                    style: const TextStyle(
                      color: Color(0xff003a78),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xffe8f5e9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '@ ₹${item['rate'].toInt()}/day',
                      style: const TextStyle(
                        color: Color(0xff2e7d32),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xfff5f7fa),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttendanceStat(
                  label: 'Full Days',
                  value: '${item['fullDays']}',
                  color: const Color(0xff1565c0),
                ),
                Container(width: 1, height: 24, color: Colors.grey[300]),
                _buildAttendanceStat(
                  label: 'Half Days',
                  value: '${item['halfDays']}',
                  color: const Color(0xffef6c00),
                ),
                Container(width: 1, height: 24, color: Colors.grey[300]),
                _buildAttendanceStat(
                  label: 'Total Days',
                  value: '${item['fullDays'] + (item['halfDays'] * 0.5)}',
                  color: const Color(0xff2e7d32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(
      {required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
