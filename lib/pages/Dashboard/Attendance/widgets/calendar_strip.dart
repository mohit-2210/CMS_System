import 'package:flutter/material.dart';
import 'date_card.dart';

class CalendarStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final ScrollController scrollController;
  final VoidCallback onFullCalendarPressed;

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.scrollController,
    required this.onFullCalendarPressed,
  });

  List<DateTime> _generateCalendarDates() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    List<DateTime> dates = [];
    for (int i = 0; i < lastDay.day; i++) {
      dates.add(firstDay.add(Duration(days: i)));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _generateCalendarDates()
                  .map((date) => DateCard(
                        date: date,
                        isSelected: date.year == selectedDate.year &&
                            date.month == selectedDate.month &&
                            date.day == selectedDate.day,
                        onTap: () => onDateSelected(date),
                      ))
                  .toList(),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.calendar_month, color: Color(0xff003a78)),
              onPressed: onFullCalendarPressed,
              tooltip: 'Full View',
            ),
          ),
        ],
      ),
    );
  }
}