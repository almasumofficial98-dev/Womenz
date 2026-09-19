import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/cycle_models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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
    final logs = _storage.cycleLogs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body & Cycle Insights'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cycle Regularity Header Card
              _buildRegularityOverviewCard(profile, logs),

              const SizedBox(height: 24),

              // PCOD / PCOS Educational & Care Guide Card
              _buildConditionEducationalCard(profile.healthCondition),

              const SizedBox(height: 24),

              // Cycle Phase Guide
              _buildFourPhasesGuideCard(),

              const SizedBox(height: 24),

              // Cycle History List
              _buildCycleHistoryList(logs),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegularityOverviewCard(UserProfile profile, List<CycleLog> logs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cycle Regularity Overview',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryViolet,
                  ),
                ),
                Icon(
                  profile.healthCondition == HealthCondition.pcodPcos ||
                          profile.healthCondition == HealthCondition.irregular
                      ? Icons.insights
                      : Icons.check_circle_outline,
                  color: AppTheme.accentPurple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _statColumn(
                    'Avg Length',
                    '${profile.avgCycleLength} Days',
                  ),
                ),
                Container(height: 40, width: 1, color: AppTheme.softLavender),
                Expanded(
                  child: _statColumn(
                    'Period Duration',
                    '${profile.avgPeriodLength} Days',
                  ),
                ),
                Container(height: 40, width: 1, color: AppTheme.softLavender),
                Expanded(
                  child: _statColumn(
                    'Variance Range',
                    '±${profile.cycleVariance} Days',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.softLavender,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                logs.length < 2
                    ? 'Log at least 2 consecutive periods to unlock automatic cycle variability calculations.'
                    : 'Your cycle history shows steady logging! Adaptive algorithm is active.',
                style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryViolet,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionEducationalCard(HealthCondition condition) {
    String title;
    String content;
    Color color;

    if (condition == HealthCondition.pcodPcos) {
      title = 'Understanding PCOD & PCOS Care';
      color = AppTheme.pcodTagBg;
      content =
          'Polycystic Ovarian Disease/Syndrome causes hormonal imbalances that may lead to variable cycle lengths, delayed ovulation, or skipped periods.\n\nKey pillars for managing PCOD/PCOS:\n'
          '• Insulin Balance: Eat low-GI foods, pair carbs with protein & fiber.\n'
          '• Hormonal Support: Spearmint tea, inositol, and omega-3s.\n'
          '• Gentle Movement: Strength training and walking beat chronic high-cortisol cardio.\n'
          '• Sleep & Stress: Cortisol directly influences androgen production.';
    } else if (condition == HealthCondition.irregular) {
      title = 'Managing Irregular Cycles';
      color = AppTheme.irregularTagBg;
      content =
          'Irregular cycles vary widely from month to month due to stress, travel, thyroid shifts, or lifestyle changes.\n\nTips for irregular cycle tracking:\n'
          '• Focus on daily symptom signals rather than strict calendar dates.\n'
          '• Monitor cervical mucus & energy shifts for ovulation cues.\n'
          '• Maintain consistent circadian sleep hygiene.';
    } else {
      title = 'Optimizing Your Natural Cycle';
      color = AppTheme.softLavender;
      content =
          'Your menstrual cycle is considered a fifth vital sign! By syncing your diet, exercise, and productivity with your 4 cycle phases, you can reduce PMS, boost energy, and honor your natural rhythm.';
    }

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book, color: AppTheme.primaryViolet),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryViolet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.textDark,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFourPhasesGuideCard() {
    return Card(
      child: ExpansionTile(
        title: Text(
          'Guide to the 4 Cycle Phases',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryViolet,
          ),
        ),
        leading: const Icon(Icons.donut_large, color: AppTheme.accentPurple),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _phaseInfoTile(
                  '1. Menstrual Phase (Day 1-5)',
                  'Estrogen & Progesterone are low. Energy is internal. Focus on rest, warm iron-rich foods, and hydration.',
                  AppTheme.menstrualRed,
                ),
                _phaseInfoTile(
                  '2. Follicular Phase (Day 6-12)',
                  'Estrogen rises as follicles mature. Energy climbs! Great time for workouts, brainstorming, and social events.',
                  AppTheme.follicularGreen,
                ),
                _phaseInfoTile(
                  '3. Ovulation Phase (Day 13-15)',
                  'LH surge triggers egg release. Peak libido, glowing skin, and highest social confidence.',
                  AppTheme.ovulationTeal,
                ),
                _phaseInfoTile(
                  '4. Luteal Phase (Day 16-28)',
                  'Progesterone peaks. Metabolism increases. Focus on complex carbs, magnesium, and calming routines.',
                  AppTheme.lutealAmber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _phaseInfoTile(String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleHistoryList(List<CycleLog> logs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cycle Log History',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryViolet,
                  ),
                ),
                Text(
                  '${logs.length} Entries',
                  style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (logs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'No logged cycles yet (Nil State).',
                    style: GoogleFonts.outfit(color: AppTheme.textMuted),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.menstrualRed.withOpacity(0.15),
                      child: const Icon(Icons.water_drop, color: AppTheme.menstrualRed, size: 20),
                    ),
                    title: Text(
                      DateFormat('MMM d, yyyy').format(log.startDate),
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Flow: ${log.flow.displayName}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                      onPressed: () async {
                        await _storage.deleteCycleLog(log.id);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
