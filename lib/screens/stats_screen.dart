import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/cycle_model.dart';
import '../theme/app_theme.dart';
import '../widgets/cycle_donut_chart.dart';
import 'doctor_summary_screen.dart';

class StatsScreen extends StatefulWidget {
  final UserCycleData cycleData;

  const StatsScreen({
    super.key,
    required this.cycleData,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int selectedTab = 0; // 0 = Cycle Trends, 1 = Symptoms & Pain

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.cycleData.isDiscreetMode ? 'Cycle Trends & Health' : 'Menstrual Health & Stats',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => _showDoctorReportModal(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.softPink,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.medical_services_rounded, color: AppTheme.primaryPink, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Doctor Export',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Segmented Tab Switcher (Cycle Trends vs Symptoms & Pain vs BBT & Ovulation)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    _buildTabSwitcherItem(0, 'Cycle Trends'),
                    _buildTabSwitcherItem(1, 'Symptoms & Pain'),
                    _buildTabSwitcherItem(2, 'BBT & Ovulation'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tab 0: Cycle Donut Chart & Phase Breakdown
              if (selectedTab == 0) ...[
                CycleDonutChartWidget(
                  totalDays: widget.cycleData.cycleLength,
                  status: widget.cycleData.isPcosOrIrregular ? 'PCOS / Irregular' : 'Regular Cycle',
                ),
                const SizedBox(height: 20),
                _buildCycleSummaryCards(),
              ],

              // Tab 1: Symptoms & Pain Distribution
              if (selectedTab == 1) ...[
                _buildSymptomsAndPainSection(),
              ],

              // Tab 2: BBT Spline & Sympto-Thermal Ovulation
              if (selectedTab == 2) ...[
                _buildBbtAndOvulationSection(),
              ],

              const SizedBox(height: 24),

              // "Report for your Doctor" Gradient Banner Card
              GestureDetector(
                onTap: () => _showDoctorReportModal(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8BA5), Color(0xFFFFC2D1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8BA5).withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Clinical Summary for OB-GYN',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Includes menstrual timeline, cramp severity, flow intensity, and red flags.',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppTheme.primaryPink,
                          size: 20,
                        ),
                      ),
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

  Widget _buildCycleSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSmallStatTile(
                'Period Duration',
                '${widget.cycleData.periodDuration} Days',
                'Average bleeding length',
                Icons.water_drop_rounded,
                AppTheme.primaryPink,
                AppTheme.softPink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallStatTile(
                'Cycle Length',
                '${widget.cycleData.cycleLength} Days',
                widget.cycleData.isPcosOrIrregular ? 'PCOS variance ±7d' : 'High regularity ±1d',
                Icons.auto_graph_rounded,
                AppTheme.primaryBlue,
                AppTheme.softBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSmallStatTile(
                'Typical Range',
                '${widget.cycleData.cycleLength - 2} - ${widget.cycleData.cycleLength + 3} Days',
                'Physiologic baseline range',
                Icons.timeline_rounded,
                AppTheme.primaryPurple,
                AppTheme.softPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallStatTile(
                'Next Expected',
                widget.cycleData.daysUntilNextCycleText,
                widget.cycleData.isDiscreetMode ? 'Phase countdown' : 'Estimated next period',
                Icons.event_available_rounded,
                AppTheme.follicularGreen,
                const Color(0xFFE8F8F2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSymptomsAndPainSection() {
    int totalLoggedDays = widget.cycleData.logs.length;
    int painFreeDays = 0;
    int mildPainDays = 0;
    int moderatePainDays = 0;
    int severePainDays = 0;
    int medsTakenDays = 0;
    int selfCareDays = 0;

    for (final log in widget.cycleData.logs.values) {
      if (log.painScale == 0) {
        painFreeDays++;
      } else if (log.painScale <= 3) {
        mildPainDays++;
      } else if (log.painScale <= 7) {
        moderatePainDays++;
      } else {
        severePainDays++;
      }
      if (log.medications.isNotEmpty || log.tookSupplements) medsTakenDays++;
      if (log.selfCare.isNotEmpty) selfCareDays++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(
            color: Colors.white,
            radius: 24,
            shadows: AppTheme.softShadow(opacity: 0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Menstrual Pain Analysis',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.softPink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$totalLoggedDays days tracked',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPainProgressBar('Pain-Free (0/10)', painFreeDays, totalLoggedDays, AppTheme.follicularGreen),
              const SizedBox(height: 10),
              _buildPainProgressBar('Mild Pain (1-3/10)', mildPainDays, totalLoggedDays, AppTheme.primaryBlue),
              const SizedBox(height: 10),
              _buildPainProgressBar('Moderate Pain (4-7/10)', moderatePainDays, totalLoggedDays, AppTheme.primaryPeach),
              const SizedBox(height: 10),
              _buildPainProgressBar('Severe Pain (8-10/10)', severePainDays, totalLoggedDays, Colors.red),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Care & Relief Card (Separated Medications vs Non-Pharm Self-Care)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.cardDecoration(
            color: Colors.white,
            radius: 22,
            shadows: AppTheme.softShadow(opacity: 0.04),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppTheme.softBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medication_rounded, color: AppTheme.primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Medication Logged',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$medsTakenDays days recorded with medication / pain relief.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.spa_rounded, color: Color(0xFF2E7D32), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Self-Care & Comfort Measures',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$selfCareDays days with heating pad, rest, tea, or gentle movement.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
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
      ],
    );
  }

  Widget _buildPainProgressBar(String label, int count, int total, Color color) {
    final double pct = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            Text('$count days (${(pct * 100).toInt()}%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: AppTheme.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatTile(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(
        color: Colors.white,
        radius: 22,
        shadows: AppTheme.softShadow(opacity: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcherItem(int index, String label) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBbtAndOvulationSection() {
    final bbtEntries = widget.cycleData.logs.values
        .where((l) => l.bbt != null && l.bbt! >= 35.5 && l.bbt! <= 38.0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final isDemoData = bbtEntries.isEmpty;

    final List<FlSpot> spots = isDemoData
        ? const [
            FlSpot(1, 36.35),
            FlSpot(4, 36.40),
            FlSpot(8, 36.30),
            FlSpot(12, 36.38),
            FlSpot(14, 36.25), // Pre-ovulatory dip
            FlSpot(16, 36.65), // Thermal shift rise
            FlSpot(19, 36.80), // Sustained luteal plateau
            FlSpot(23, 36.85),
            FlSpot(27, 36.75),
          ]
        : bbtEntries.asMap().entries.map((e) {
            return FlSpot((e.key + 1).toDouble(), e.value.bbt!);
          }).toList();

    // Cervical mucus distribution
    int dryCount = 0;
    int stickyCount = 0;
    int creamyCount = 0;
    int eggWhiteCount = 0;

    for (final l in widget.cycleData.logs.values) {
      final m = l.cervicalMucus;
      if (m == 'Dry') dryCount++;
      if (m == 'Sticky') stickyCount++;
      if (m == 'Creamy') creamyCount++;
      if (m == 'Egg-White') eggWhiteCount++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BBT Temperature Curve Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(
            color: Colors.white,
            radius: 24,
            shadows: AppTheme.softShadow(opacity: 0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basal Body Temperature (BBT)',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Retrospective ovulatory thermal shift',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDemoData ? const Color(0xFFFFF0F3) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isDemoData ? 'Sample Curve' : '${bbtEntries.length} logged',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isDemoData ? AppTheme.primaryPink : const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // FlChart LineChart
              SizedBox(
                height: 190,
                child: LineChart(
                  LineChartData(
                    minY: 36.0,
                    maxY: 37.2,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: AppTheme.primaryPink,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                            radius: 3.5,
                            color: Colors.white,
                            strokeWidth: 2.5,
                            strokeColor: AppTheme.primaryPink,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primaryPink.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 38,
                          getTitlesWidget: (val, meta) {
                            if (val == 36.0 || val == 36.4 || val == 36.8 || val == 37.2) {
                              return Text(
                                '${val.toStringAsFixed(1)}°',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 3,
                          getTitlesWidget: (val, meta) => Text(
                            'D${val.toInt()}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                          ),
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 0.2,
                      getDrawingHorizontalLine: (val) {
                        if ((val - 36.6).abs() < 0.05) {
                          return const FlLine(color: Color(0xFF7C8FFD), strokeWidth: 1.5, dashArray: [6, 4]);
                        }
                        return const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1);
                      },
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Legend Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 12, height: 3, color: AppTheme.primaryPink),
                  const SizedBox(width: 6),
                  const Text('BBT Temperature', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  const SizedBox(width: 16),
                  Container(width: 14, height: 2, color: const Color(0xFF7C8FFD)),
                  const SizedBox(width: 6),
                  const Text('Coverline (~36.6°C)', style: TextStyle(fontSize: 11, color: Color(0xFF7C8FFD), fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Cervical Mucus / Fertile Fluid Observation Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(
            color: Colors.white,
            radius: 24,
            shadows: AppTheme.softShadow(opacity: 0.04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.water_drop_rounded, color: Color(0xFF7C8FFD), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cervical Fluid Patterns',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Estrogen peak indicator in fertile window',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildMucusBadge('Egg-White', eggWhiteCount, const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
                  const SizedBox(width: 8),
                  _buildMucusBadge('Creamy', creamyCount, const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
                  const SizedBox(width: 8),
                  _buildMucusBadge('Sticky', stickyCount, const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                  const SizedBox(width: 8),
                  _buildMucusBadge('Dry', dryCount, const Color(0xFF64748B), const Color(0xFFF1F5F9)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Clinical Explainer Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppTheme.primaryPink),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Clinical Note: Basal Body Temperature confirms ovulation retroactively via progesterone secretion from the corpus luteum (causing a 0.2°C - 0.5°C rise). It is not an advance predictor. Combined with cervical fluid, it provides reliable retrospective ovulatory tracking.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMucusBadge(String label, int count, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDoctorReportModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorSummaryScreen(cycleData: widget.cycleData),
      ),
    );
  }
}
