import 'package:flutter/material.dart';
import '../models/body_measurement.dart';
import '../models/cycle_model.dart';
import '../models/cycle_record.dart';
import '../models/lab_result.dart';
import '../models/symptom_record.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/cycle_ring_painter.dart';
import '../widgets/interactive_bouncy_card.dart';
import '../widgets/cycle/menstrual_gap_timeline_card.dart';
import '../widgets/body/body_measurement_card.dart';
import '../widgets/hydration/water_tracker_card.dart';
import 'screening/pcos_screening_wizard.dart';
import 'doctor/doctor_visit_prep_screen.dart';
import 'labs/lab_report_tracker_screen.dart';
import 'cycle/late_period_decision_tree_modal.dart';
import 'screening/red_flags_urgent_care_screen.dart';
import 'learn/educational_cards_screen.dart';
import 'symptom_logger_modal.dart';

class HomeScreen extends StatefulWidget {
  final UserCycleData cycleData;
  final ValueChanged<DailyLog> onLogAdded;
  final VoidCallback onOpenCalendar;

  const HomeScreen({
    super.key,
    required this.cycleData,
    required this.onLogAdded,
    required this.onOpenCalendar,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime selectedDate;
  double currentWeightKg = 60.0;
  double currentHeightCm = 160.0;
  int waterIntakeMl = 0;
  final UserProfile userProfile = UserProfile();
  final List<CycleRecord> cycleRecords = [];
  final List<SymptomRecord> symptomRecords = [];
  final List<LabResult> labResults = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final phase = widget.cycleData.currentPhase;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // User Avatar with soft glow border
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.softPink,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPink.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.cycleData.userName,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Header Action Buttons
                  Row(
                    children: [
                      BouncyTapCard(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No new notifications'),
                              backgroundColor: AppTheme.primaryBlue,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.softShadow(opacity: 0.05),
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: AppTheme.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Horizontal Date Ribbon (Week Selector)
              _buildHorizontalDateRibbon(),

              const SizedBox(height: 20),

              // 3. Status Summary Pill Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: AppTheme.cardDecoration(
                  color: Colors.white,
                  radius: 24,
                  shadows: AppTheme.softShadow(opacity: 0.06),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildStatusColumn(
                        'Next cycle in',
                        widget.cycleData.daysUntilNextCycleText,
                        AppTheme.primaryPink,
                      ),
                    ),
                    Container(height: 36, width: 1, color: AppTheme.surfaceLight),
                    Expanded(
                      child: _buildStatusColumn(
                        'Pregnancy chance',
                        phase.pregnancyChance,
                        AppTheme.primaryBlue,
                      ),
                    ),
                    Container(height: 36, width: 1, color: AppTheme.surfaceLight),
                    Expanded(
                      child: _buildStatusColumn(
                        'Current Phase',
                        phase.displayName.replaceAll(' Phase', ''),
                        AppTheme.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Main Interactive Cycle Ring Widget
              CycleRingWidget(
                currentDay: widget.cycleData.currentDay,
                totalDays: widget.cycleData.cycleLength,
                periodDays: widget.cycleData.periodDuration,
                currentPhase: phase,
                hasData: widget.cycleData.hasLoggedData,
                onTap: () {
                  _showLogModal(context);
                },
              ),

              const SizedBox(height: 24),

              // 5. Quick Logging Cards Grid (Mood, Cramps, Drugs) with Bouncy Touch
              Row(
                children: [
                  Expanded(
                    child: BouncyTapCard(
                      onTap: () => _showLogModal(context),
                      child: _buildQuickLogTile(
                        title: 'Mood',
                        subtitle: 'How are you feeling?',
                        emoji: '😊',
                        bgColor: const Color(0xFFFFF7EA),
                        borderColor: const Color(0xFFFFD180),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BouncyTapCard(
                      onTap: () => _showLogModal(context),
                      child: _buildQuickLogTile(
                        title: 'Cramps',
                        subtitle: 'Any Symptoms?',
                        emoji: '🌸',
                        bgColor: const Color(0xFFFFEFF2),
                        borderColor: const Color(0xFFFFB2C1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BouncyTapCard(
                      onTap: () => _showLogModal(context),
                      child: _buildQuickLogTile(
                        title: 'Drugs',
                        subtitle: 'Supplements?',
                        emoji: '💊',
                        bgColor: const Color(0xFFF0F5FF),
                        borderColor: const Color(0xFFA6C4FF),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 6. Daily Insights Banner Card
              BouncyTapCard(
                onTap: () => _showLogModal(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        phase.accentGradientStart.withOpacity(0.9),
                        phase.accentGradientEnd.withOpacity(0.95),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: phase.primaryColor.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Insights • ${phase.displayName}',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              phase.description,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.92),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 5. Menstrual Gap Timeline Card
              MenstrualGapTimelineCard(
                cycleRecords: cycleRecords,
                onLogPeriodTap: widget.onOpenCalendar,
                onWhyLateTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const LatePeriodDecisionTreeModal(),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 6. Body Measurements & Independent BMI Card
              BodyMeasurementCard(
                currentWeightKg: currentWeightKg,
                currentHeightCm: currentHeightCm,
                weightUnit: userProfile.preferredWeightUnit,
                heightUnit: userProfile.preferredHeightUnit,
                onWeightChanged: (w) => setState(() => currentWeightKg = w),
                onHeightChanged: (h) => setState(() => currentHeightCm = h),
              ),

              const SizedBox(height: 20),

              // 7. Daily Hydration Water Tracker Card
              WaterTrackerCard(
                currentWaterMl: waterIntakeMl,
                goalMl: 2500,
                unit: userProfile.preferredWaterUnit,
                onAddWater: (delta) => setState(() => waterIntakeMl = (waterIntakeMl + delta).clamp(0, 10000)),
                onResetWater: () => setState(() => waterIntakeMl = 0),
              ),

              const SizedBox(height: 20),

              // 8. Health Quick Action Tiles Grid (PCOS Screening, Doctor Prep, Lab Tracker, Urgent Care)
              Row(
                children: [
                  Expanded(
                    child: BouncyTapCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PcosScreeningWizard(
                              onOpenDoctorPrep: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoctorVisitPrepScreen(
                                      profile: userProfile,
                                      cycleRecords: cycleRecords,
                                      symptomRecords: symptomRecords,
                                      latestBody: BodyMeasurement(
                                        id: 'b1',
                                        date: DateTime.now(),
                                        weightKg: currentWeightKg,
                                        heightCm: currentHeightCm,
                                      ),
                                      labResults: labResults,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: _buildQuickLogTile(
                        title: 'PCOS Screening',
                        subtitle: 'Educational Wizard',
                        emoji: '🌸',
                        bgColor: AppTheme.softPink,
                        borderColor: AppTheme.primaryPink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BouncyTapCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorVisitPrepScreen(
                              profile: userProfile,
                              cycleRecords: cycleRecords,
                              symptomRecords: symptomRecords,
                              latestBody: BodyMeasurement(
                                id: 'b1',
                                date: DateTime.now(),
                                weightKg: currentWeightKg,
                                heightCm: currentHeightCm,
                              ),
                              labResults: labResults,
                            ),
                          ),
                        );
                      },
                      child: _buildQuickLogTile(
                        title: 'Doctor Visit Prep',
                        subtitle: 'Export & Summary',
                        emoji: '🩺',
                        bgColor: AppTheme.softBlue,
                        borderColor: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: BouncyTapCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LabReportTrackerScreen(
                              labResults: labResults,
                              onAddLabResult: (res) => setState(() => labResults.insert(0, res)),
                            ),
                          ),
                        );
                      },
                      child: _buildQuickLogTile(
                        title: 'Lab Tracker',
                        subtitle: 'TSH, Testosterone, HbA1c',
                        emoji: '🧪',
                        bgColor: const Color(0xFFF3E5F5),
                        borderColor: const Color(0xFFAB47BC),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BouncyTapCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RedFlagsUrgentCareScreen()),
                        );
                      },
                      child: _buildQuickLogTile(
                        title: 'Urgent Care',
                        subtitle: 'Emergency Advice',
                        emoji: '🚨',
                        bgColor: const Color(0xFFFFEBEE),
                        borderColor: const Color(0xFFEF5350),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Educational Learn Topics Banner
              BouncyTapCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EducationalCardsScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: AppTheme.primaryBlue, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Learn & Medical Articles',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Sourced articles on PCOS, BMI, & cycle causes',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalDateRibbon() {
    final now = DateTime.now();
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = now.add(Duration(days: index - 3));
          final isSelected = date.day == selectedDate.day;

          final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
          final dayName = weekDays[date.weekday % 7];

          return BouncyTapCard(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryPink : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryPink.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : AppTheme.softShadow(opacity: 0.04),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white.withOpacity(0.85) : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}'.padLeft(2, '0'),
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusColumn(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLogTile({
    required String title,
    required String subtitle,
    required String emoji,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor.withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Daily symptom log saved successfully!'),
              backgroundColor: AppTheme.primaryPink,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        },
      ),
    );
  }
}
