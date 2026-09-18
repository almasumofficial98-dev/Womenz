import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/cycle_record.dart';
import '../../theme/app_theme.dart';

class MenstrualGapTimelineCard extends StatelessWidget {
  final List<CycleRecord> cycleRecords;
  final VoidCallback onLogPeriodTap;
  final VoidCallback onWhyLateTap;

  const MenstrualGapTimelineCard({
    super.key,
    required this.cycleRecords,
    required this.onLogPeriodTap,
    required this.onWhyLateTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeRecords = cycleRecords.where((r) => !r.isDeleted).toList();
    activeRecords.sort((a, b) => b.startDate.compareTo(a.startDate));

    final hasData = activeRecords.isNotEmpty;
    final latestStart = hasData ? activeRecords.first.startDate : null;
    final currentGapDays = hasData ? DateTime.now().difference(latestStart!).inDays : 0;
    final gapMonths = (currentGapDays / 30.44).toStringAsFixed(1);

    final dateFormat = DateFormat('MMM d');

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppTheme.cardDecoration(
        color: Colors.white,
        radius: 28,
        shadows: AppTheme.softShadow(opacity: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppTheme.softPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.timeline_rounded, color: AppTheme.primaryPink, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menstrual Gap Timeline',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Cycle History & Gap Duration',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: onWhyLateTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.help_outline_rounded, size: 14, color: AppTheme.primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Why Late?',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Visual Timeline Chips
          if (!hasData)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppTheme.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No period history logged yet. Tap below to add your first period date.',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Horizontal sequence chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (int i = activeRecords.length - 1; i >= 0; i--) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.softPink,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryPink.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.water_drop_rounded, size: 14, color: AppTheme.primaryPink),
                          const SizedBox(width: 6),
                          Text(
                            dateFormat.format(activeRecords[i].startDate),
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.textMuted),
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Current Gap Counter Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: currentGapDays >= 90 ? const Color(0xFFFFF3E0) : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: currentGapDays >= 90 ? const Color(0xFFFFB74D) : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Gap',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$currentGapDays Days (~$gapMonths months)',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: currentGapDays >= 90 ? const Color(0xFFE65100) : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (currentGapDays >= 90)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE0B2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Delayed Gap',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Log Period CTA
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onLogPeriodTap,
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
              label: Text(
                'Record Period Date',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
