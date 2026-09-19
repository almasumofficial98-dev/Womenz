import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final now = DateTime.now();
    currentMonth = DateTime(now.year, now.month, 1);
    selectedDay = now.day;
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

  bool _isPeriodDate(DateTime d) {
    final key = d.toString().split(' ')[0];
    final log = widget.cycleData.logs[key];
    if (log != null && log.flow != null && log.flow != 'None') {
      return true;
    }
    if (widget.cycleData.lastPeriodStartDate != null) {
      final diff = d.difference(widget.cycleData.lastPeriodStartDate!).inDays;
      if (diff >= 0 && diff < widget.cycleData.periodDuration) {
        return true;
      }
    }
    return false;
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
                    widget.cycleData.isDiscreetMode ? 'Cycle Calendar' : 'Period & Cycle Calendar',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 22,
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
                        widget.cycleData.isDiscreetMode ? 'Log Past Cycle / Fill History' : 'Log Past Period / Fill History',
                        style: const TextStyle(
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
                        _buildLegendDot(widget.cycleData.isDiscreetMode ? 'Phase' : 'Logged Period', AppTheme.primaryPink),
                        _buildLegendDot(widget.cycleData.isDiscreetMode ? 'Estimated' : 'Estimated Period', AppTheme.softPink),
                        _buildLegendDot('Logged Symptoms', Colors.deepOrange),
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
                                  style: const TextStyle(
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

                        final cellDate = DateTime(currentMonth.year, currentMonth.month, dayNum);
                        final cellDateKey = cellDate.toString().split(' ')[0];
                        final dayLog = widget.cycleData.logs[cellDateKey];

                        final isPeriod = _isPeriodDate(cellDate);
                        final prevIsPeriod = _isPeriodDate(cellDate.subtract(const Duration(days: 1)));
                        final nextIsPeriod = _isPeriodDate(cellDate.add(const Duration(days: 1)));

                        // Estimated next period window based on past cycle length
                        bool isEstimatedPeriod = false;
                        if (widget.cycleData.nextPeriodDate != null && cellDate.isAfter(DateTime.now())) {
                          final nextStart = widget.cycleData.nextPeriodDate!;
                          final diffFromNext = cellDate.difference(nextStart).inDays;
                          if (diffFromNext >= 0 && diffFromNext < widget.cycleData.periodDuration) {
                            isEstimatedPeriod = true;
                          }
                        }

                        Color cellBg = Colors.transparent;
                        Color textColor = AppTheme.textPrimary;
                        Border? border;

                        BorderRadius cellRadius;
                        if (isSelected) {
                          cellBg = AppTheme.primaryPink;
                          textColor = Colors.white;
                          cellRadius = BorderRadius.circular(16);
                        } else if (isPeriod) {
                          cellBg = AppTheme.softPink;
                          textColor = AppTheme.primaryPink;
                          if (prevIsPeriod && nextIsPeriod) {
                            cellRadius = BorderRadius.zero;
                          } else if (!prevIsPeriod && nextIsPeriod) {
                            cellRadius = const BorderRadius.horizontal(left: Radius.circular(16));
                          } else if (prevIsPeriod && !nextIsPeriod) {
                            cellRadius = const BorderRadius.horizontal(right: Radius.circular(16));
                          } else {
                            cellRadius = BorderRadius.circular(16);
                          }
                        } else if (isEstimatedPeriod) {
                          cellBg = const Color(0xFFFFF0F3);
                          textColor = AppTheme.primaryPink;
                          border = Border.all(color: AppTheme.primaryPink.withValues(alpha: 0.4), width: 1.2);
                          cellRadius = BorderRadius.circular(16);
                        } else {
                          cellRadius = BorderRadius.circular(16);
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
                              borderRadius: cellRadius,
                              border: border,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryPink.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$dayNum',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 13,
                                      fontWeight: (isPeriod || isEstimatedPeriod || isSelected)
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                  if (dayLog != null && (dayLog.painScale > 0 || dayLog.tookSupplements))
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : (dayLog.painScale >= 8 ? Colors.red : Colors.deepOrange),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
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

              // Selected Day Details Card
              Builder(
                builder: (context) {
                  final selDate = DateTime(currentMonth.year, currentMonth.month, selectedDay);
                  final selKey = selDate.toString().split(' ')[0];
                  final log = widget.cycleData.logs[selKey];

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.cardDecoration(
                      color: Colors.white,
                      radius: 24,
                      shadows: AppTheme.softShadow(opacity: 0.04),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('EEEE, MMMM d').format(selDate),
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) => SymptomLoggerModal(
                                    initialLog: log ?? DailyLog(date: selDate),
                                    onSave: (newLog) {
                                      widget.onLogAdded(newLog);
                                      setState(() {});
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.softPink,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  log != null ? 'Edit Log' : '+ Log Date',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryPink,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (log == null)
                          const Text(
                            'No symptoms or flow logged for this day.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              if (log.flow != null)
                                _buildDetailPill('Flow: ${log.flow}', AppTheme.primaryPink, AppTheme.softPink),
                              if (log.painScale > 0)
                                _buildDetailPill('Pain: ${log.painScale}/10', Colors.deepOrange, const Color(0xFFFFEBE6)),
                              if (log.mood != null)
                                _buildDetailPill('Mood: ${log.mood}', AppTheme.primaryPurple, AppTheme.softLavender),
                              if (log.medications.isNotEmpty)
                                _buildDetailPill('Meds: ${log.medications.join(", ")}', AppTheme.primaryBlue, AppTheme.softBlue)
                              else if (log.tookSupplements)
                                _buildDetailPill('Medication Logged', AppTheme.primaryBlue, AppTheme.softBlue),
                              if (log.selfCare.isNotEmpty)
                                _buildDetailPill('Care: ${log.selfCare.join(", ")}', const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
                              if (log.cervicalMucus != null)
                                _buildDetailPill('Mucus: ${log.cervicalMucus}', const Color(0xFF5C6BC0), const Color(0xFFEDE7F6)),
                              if (log.bbt != null)
                                _buildDetailPill('BBT: ${log.bbt}°C', const Color(0xFF00897B), const Color(0xFFE0F2F1)),
                              if (log.tookInositol)
                                _buildDetailPill('Inositol Taken', const Color(0xFF8E24AA), const Color(0xFFF3E5F5)),
                            ],
                          ),
                      ],
                    ),
                  );
                },
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
                  border: Border.all(color: AppTheme.primaryPink.withValues(alpha: 0.3)),
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
                            widget.cycleData.hasLoggedData
                                ? (widget.cycleData.isDiscreetMode
                                    ? 'Next cycle estimated around:'
                                    : 'Your next period is estimated around:')
                                : 'Cycle Estimate Status',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.cycleData.hasLoggedData
                                ? (widget.cycleData.isPcosOrIrregular
                                    ? '${DateFormat('MMMM d, yyyy').format(widget.cycleData.nextPeriodDate ?? DateTime.now().add(Duration(days: widget.cycleData.cycleLength)))} (Est. PCOS variance ±7d)'
                                    : DateFormat('MMMM d, yyyy').format(widget.cycleData.nextPeriodDate ?? DateTime.now().add(Duration(days: widget.cycleData.cycleLength))))
                                : 'No history logged yet. Tap + to set period start.',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryPink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Estimated based on logged history • Non-diagnostic pattern projection',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
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

  Widget _buildDetailPill(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
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
