import 'package:flutter/material.dart';
import '../models/cycle_model.dart';
import '../theme/app_theme.dart';
import '../widgets/cycle_donut_chart.dart';
import '../widgets/weight_timeline_painter.dart';
import 'doctor_report_modal.dart';

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
  int selectedTab = 0; // 0 = Cycle Stats, 1 = Weight Tracker

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
                    'Health & Statistics',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.softShadow(opacity: 0.05),
                    ),
                    child: const Icon(Icons.more_vert_rounded, color: AppTheme.textPrimary, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Segmented Tab Switcher (Cycle Breakdown vs Weight & Body)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedTab == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: selectedTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Cycle Overview',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                              color: selectedTab == 0 ? AppTheme.textPrimary : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedTab == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: selectedTab == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Weight & Body',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                              color: selectedTab == 1 ? AppTheme.textPrimary : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tab 0: Cycle Donut Chart & Phase Lengths
              if (selectedTab == 0) ...[
                CycleDonutChartWidget(
                  totalDays: widget.cycleData.cycleLength,
                  status: 'Regular Cycle',
                ),
                const SizedBox(height: 20),
                _buildPhaseSummaryCards(),
              ],

              // Tab 1: Weight & Body Timeline Widget
              if (selectedTab == 1) ...[
                const WeightTimelineWidget(),
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
                        color: const Color(0xFFFF8BA5).withOpacity(0.35),
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
                            Text(
                              'Report for your Doctor',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Share your mood symptoms flow and more with your doctors!',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
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
                          size: 22,
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

  Widget _buildPhaseSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSmallStatTile(
                'Period Length',
                '5 Days',
                'Regular • Normal flow',
                Icons.water_drop_rounded,
                AppTheme.primaryPink,
                AppTheme.softPink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallStatTile(
                'Cycle Variation',
                '± 1 Day',
                'High regularity',
                Icons.auto_graph_rounded,
                AppTheme.primaryBlue,
                AppTheme.softBlue,
              ),
            ),
          ],
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
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDoctorReportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DoctorReportModal(),
    );
  }
}
