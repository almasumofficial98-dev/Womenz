import 'package:flutter/material.dart';
import '../models/cycle_model.dart';
import '../theme/app_theme.dart';
import '../widgets/interactive_bouncy_card.dart';
import 'symptom_logger_modal.dart';
import 'cycle_history_screen.dart';

class CalendarScreen extends StatefulWidget {
  final UserCycleData cycleData;
  final ValueChanged<DailyLog> onLogAdded;

  const CalendarScreen({
    super.key,
    required this.cycleData,
    required this.onLogAdded,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime currentMonth;
  late int selectedDay;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(2026, 9, 1);
    selectedDay = DateTime.now().day;
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

  final List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final firstWeekday = DateTime(currentMonth.year, currentMonth.month, 1).weekday % 7;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Navigation Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cycle Calendar',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  BouncyTapCard(
                    onTap: () => _showLogModal(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppTheme.softPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded, color: AppTheme.primaryPink, size: 22),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Month Selector Header Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: AppTheme.cardDecoration(
                  color: Colors.white,
                  radius: 24,
                  shadows: AppTheme.softShadow(opacity: 0.04),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _prevMonth,
                      icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.textPrimary, size: 28),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryPink, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${monthNames[currentMonth.month - 1]} ${currentMonth.year}',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.textPrimary, size: 28),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Log Past Period / Fill History Action Banner Button with Bouncy Micro-Interaction
              BouncyTapCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CycleHistoryScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF7597), Color(0xFFFF94A8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPink.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_edu_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Log Past Period / Fill History',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Calendar Grid Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(
                  color: Colors.white,
                  radius: 28,
                  shadows: AppTheme.softShadow(opacity: 0.05),
                ),
                child: Column(
                  children: [
                    // Legend Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendDot('Period', AppTheme.primaryPink),
                        _buildLegendDot('Predicted', AppTheme.softPink),
                        _buildLegendDot('Fertile Window', AppTheme.primaryBlue),
                        _buildLegendDot('Ovulation', AppTheme.primaryPurple),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Days of Week Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                          .map((day) => Expanded(
                                child: Text(
                                  day,
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

                    const SizedBox(height: 12),

                    // Days Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: daysInMonth + firstWeekday,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 6,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        if (index < firstWeekday) {
                          return const SizedBox();
                        }
                        final dayNum = index - firstWeekday + 1;
                        final isSelected = (dayNum == selectedDay);

                        final isPeriod = widget.cycleData.hasLoggedData && (dayNum >= 1 && dayNum <= 5);
                        final isFertile = widget.cycleData.hasLoggedData && (dayNum >= 12 && dayNum <= 16);
                        final isOvulation = widget.cycleData.hasLoggedData && (dayNum == 14);

                        Color cellBg = Colors.transparent;
                        Color textColor = AppTheme.textPrimary;
                        Border? border;

                        if (isPeriod) {
                          cellBg = AppTheme.softPink;
                          textColor = AppTheme.primaryPink;
                        } else if (isFertile) {
                          cellBg = AppTheme.softBlue;
                          textColor = AppTheme.primaryBlue;
                        }

                        if (isSelected) {
                          cellBg = AppTheme.primaryPink;
                          textColor = Colors.white;
                        }

                        if (isOvulation && !isSelected) {
                          border = Border.all(color: AppTheme.primaryPurple, width: 2);
                        }

                        return BouncyTapCard(
                          onTap: () {
                            setState(() {
                              selectedDay = dayNum;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: cellBg,
                              borderRadius: BorderRadius.circular(16),
                              border: border,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryPink.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '$dayNum',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  fontWeight: (isPeriod || isFertile || isSelected)
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Prediction Summary Callout Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFEEF2), Color(0xFFFFF7F9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primaryPink.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cycleData.hasLoggedData ? 'Your next period is predicted to start on:' : 'Cycle Prediction Status',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.cycleData.hasLoggedData ? 'October 12, 2026' : 'No history logged yet. Fill history to see predictions.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showLogModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SymptomLoggerModal(
        onSave: (log) {
          widget.onLogAdded(log);
        },
      ),
    );
  }
}
