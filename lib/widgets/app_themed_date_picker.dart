import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'interactive_bouncy_card.dart';

class AppThemedDateRangePicker extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;
  final ValueChanged<DateTimeRange> onSelected;

  const AppThemedDateRangePicker({
    super.key,
    required this.initialStart,
    required this.initialEnd,
    required this.onSelected,
  });

  @override
  State<AppThemedDateRangePicker> createState() => _AppThemedDateRangePickerState();
}

class _AppThemedDateRangePickerState extends State<AppThemedDateRangePicker> {
  late DateTime currentMonth;
  DateTime? startDate;
  DateTime? endDate;

  final List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStart;
    endDate = widget.initialEnd;
    currentMonth = DateTime(startDate!.year, startDate!.month, 1);
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    });
  }

  void _prevMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    });
  }

  void _onDayTapped(DateTime day) {
    setState(() {
      if (startDate == null || (startDate != null && endDate != null)) {
        startDate = day;
        endDate = null;
      } else if (startDate != null && endDate == null) {
        if (day.isBefore(startDate!)) {
          startDate = day;
        } else {
          endDate = day;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final firstWeekday = DateTime(currentMonth.year, currentMonth.month, 1).weekday % 7;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Select Period Dates',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap start date then end date on the app calendar',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Custom App-Themed Month Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.textPrimary),
                ),
                Text(
                  '${monthNames[currentMonth.month - 1]} ${currentMonth.year}',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Days Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((d) => Expanded(
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 10),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + firstWeekday,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday) return const SizedBox();
              final dayNum = index - firstWeekday + 1;
              final dayDate = DateTime(currentMonth.year, currentMonth.month, dayNum);

              final isStart = startDate != null && DateUtils.isSameDay(dayDate, startDate);
              final isEnd = endDate != null && DateUtils.isSameDay(dayDate, endDate);
              final isInRange = startDate != null &&
                  endDate != null &&
                  dayDate.isAfter(startDate!) &&
                  dayDate.isBefore(endDate!);

              Color bg = Colors.transparent;
              Color textCol = AppTheme.textPrimary;

              if (isStart || isEnd) {
                bg = AppTheme.primaryPink;
                textCol = Colors.white;
              } else if (isInRange) {
                bg = AppTheme.softPink;
                textCol = AppTheme.primaryPink;
              }

              return BouncyTapCard(
                onTap: () => _onDayTapped(dayDate),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: (isStart || isEnd)
                        ? [BoxShadow(color: AppTheme.primaryPink.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: (isStart || isEnd || isInRange) ? FontWeight.w800 : FontWeight.w500,
                        color: textCol,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Confirm Selected Range Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (startDate != null)
                  ? () {
                      final finalEnd = endDate ?? startDate!;
                      widget.onSelected(DateTimeRange(start: startDate!, end: finalEnd));
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(
                'Confirm Selected Dates',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
