import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/cycle_models.dart';
import '../services/storage_service.dart';
import '../services/cycle_calculator.dart';
import '../theme/app_theme.dart';
import 'symptom_tracker_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storage = StorageService.instance;

  @override
  void initState() {
    super.initState();
    _storage.addListener(_onStorageChanged);
  }

  @override
  void dispose() {
    _storage.removeListener(_onStorageChanged);
    super.dispose();
  }

  void _onStorageChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profile = _storage.profile;
    final cycleLogs = _storage.cycleLogs;

    final calcResult = CycleCalculator.calculate(
      profile: profile,
      cycleLogs: cycleLogs,
    );

    final isNil = _storage.isNilState;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with Logo & Condition Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/womenz_logo.jpg',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 40,
                            height: 40,
                            color: AppTheme.primaryViolet,
                            child: const Icon(Icons.favorite, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Womenz',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryViolet,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, MMM d').format(DateTime.now()),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Condition Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: profile.healthCondition == HealthCondition.pcodPcos
                          ? AppTheme.pcodTagBg
                          : AppTheme.softLavender,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: profile.healthCondition == HealthCondition.pcodPcos
                            ? AppTheme.pcodTagText.withOpacity(0.3)
                            : AppTheme.primaryViolet.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      profile.healthCondition.displayName,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: profile.healthCondition == HealthCondition.pcodPcos
                            ? AppTheme.pcodTagText
                            : AppTheme.primaryViolet,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Interactive Cycle Ring Card
              _buildCycleRingCard(calcResult, isNil),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.water_drop, size: 20),
                      label: const Text('Log Period'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.menstrualRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _showQuickPeriodLogDialog(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_note, size: 20),
                      label: const Text('Log Symptoms'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryViolet,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SymptomTrackerScreen(date: DateTime.now()),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Condition & Phase Tailored Wellness Tips Card
              _buildWellnessTipsCard(profile.healthCondition, calcResult.phase),

              const SizedBox(height: 24),

              // Fertility & Health Indicator Card
              if (!isNil) _buildFertilityIndicatorCard(calcResult, profile),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCycleRingCard(CycleCalculationResult calc, bool isNil) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryViolet,
            AppTheme.accentPurple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryViolet.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Banner Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              calc.conditionBanner,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Ring Graphic
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Track
                SizedBox(
                  width: 190,
                  height: 190,
                  child: CircularProgressIndicator(
                    value: isNil ? 0.0 : calc.cycleProgressRatio,
                    strokeWidth: 14,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isNil ? Colors.white : calc.phase.color,
                    ),
                  ),
                ),
                // Inner Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isNil) ...[
                      const Icon(Icons.favorite_outline, color: Colors.white, size: 42),
                      const SizedBox(height: 8),
                      Text(
                        'NIL DATA',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap "Log Period"\nto start tracking',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'DAY',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '${calc.currentCycleDay}',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: calc.phase.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          calc.phase.nameTitle,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Subtitle / Next Period Countdown
          if (!isNil && calc.nextPeriodStartDate != null) ...[
            if (_storage.profile.healthCondition == HealthCondition.pcodPcos ||
                _storage.profile.healthCondition == HealthCondition.irregular) ...[
              Text(
                'Next Period Expected Window:',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                '${DateFormat('MMM d').format(calc.nextPeriodStartDate!)} - ${DateFormat('MMM d').format(calc.nextPeriodEndDate ?? calc.nextPeriodStartDate!.add(const Duration(days: 7)))}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              Text(
                'Next Period in approx.',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                '${calc.daysUntilNextPeriod} Days (${DateFormat('MMM d').format(calc.nextPeriodStartDate!)})',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildWellnessTipsCard(HealthCondition condition, CyclePhase phase) {
    final tips = CycleCalculator.getTipsForConditionAndPhase(
      condition: condition,
      phase: phase,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppTheme.accentPurple),
                const SizedBox(width: 10),
                Text(
                  'Daily Health & Care Tips',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Expanded(
                        child: Text(
                          tip,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppTheme.textDark,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFertilityIndicatorCard(CycleCalculationResult calc, UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: calc.isFertile ? AppTheme.ovulationTeal.withOpacity(0.15) : AppTheme.softLavender,
                shape: BoxShape.circle,
              ),
              child: Icon(
                calc.isFertile ? Icons.nature_people : Icons.shield_moon_outlined,
                color: calc.isFertile ? AppTheme.ovulationTeal : AppTheme.primaryViolet,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    calc.isFertile ? 'Fertile Window Active' : 'Low Fertility Phase',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.healthCondition == HealthCondition.pcodPcos
                        ? 'Note: In PCOD/PCOS, fertility windows can be variable. Keep tracking symptoms.'
                        : (calc.isFertile
                            ? 'High chance of ovulation during this window.'
                            : 'Standard non-fertile days of cycle.'),
                    style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickPeriodLogDialog(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    FlowIntensity selectedFlow = FlowIntensity.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Log Period Start',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryViolet,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Start Date:', style: GoogleFonts.outfit(fontSize: 15)),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_month, size: 18),
                        label: Text(
                          DateFormat('MMM d, yyyy').format(selectedDate),
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 90)),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Flow Intensity:', style: GoogleFonts.outfit(fontSize: 15)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: FlowIntensity.values.map((flow) {
                      final isSelected = selectedFlow == flow;
                      return ChoiceChip(
                        label: Text(flow.displayName),
                        selected: isSelected,
                        selectedColor: AppTheme.menstrualRed,
                        backgroundColor: AppTheme.softLavender,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textDark,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedFlow = flow);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.menstrualRed,
                    ),
                    onPressed: () async {
                      final newLog = CycleLog(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        startDate: selectedDate,
                        flow: selectedFlow,
                      );
                      await _storage.addCycleLog(newLog);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Save Period Log'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
