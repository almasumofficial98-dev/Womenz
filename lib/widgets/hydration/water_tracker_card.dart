import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/hydration_service.dart';
import '../../theme/app_theme.dart';
import '../interactive_bouncy_card.dart';

class WaterTrackerCard extends StatelessWidget {
  final int currentWaterMl;
  final int goalMl;
  final WaterUnit unit;
  final ValueChanged<int> onAddWater;
  final VoidCallback onResetWater;

  const WaterTrackerCard({
    super.key,
    required this.currentWaterMl,
    this.goalMl = 2500,
    this.unit = WaterUnit.ml,
    required this.onAddWater,
    required this.onResetWater,
  });

  @override
  Widget build(BuildContext context) {
    final progress = HydrationService.calculateProgress(currentWaterMl, goalMl);
    final percentage = (progress * 100).round();
    final currentDisplay = HydrationService.formatWater(currentWaterMl, unit);
    final goalDisplay = HydrationService.formatWater(goalMl, unit);

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
                      color: AppTheme.softBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.water_drop_rounded, color: AppTheme.primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Hydration',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'General Wellness Goal',
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
              IconButton(
                onPressed: onResetWater,
                icon: const Icon(Icons.refresh_rounded, size: 18, color: AppTheme.textSecondary),
                tooltip: 'Reset Today\'s Water',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentDisplay / $goalDisplay',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlue,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppTheme.softBlue,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ),

          const SizedBox(height: 18),

          // Quick Add Buttons
          Row(
            children: [
              Expanded(
                child: BouncyTapCard(
                  onTap: () => onAddWater(250),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.softBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '+ 250 ml',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BouncyTapCard(
                  onTap: () => onAddWater(500),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '+ 500 ml',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Disclaimer
          Text(
            HydrationService.disclaimer,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              color: AppTheme.textMuted,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
