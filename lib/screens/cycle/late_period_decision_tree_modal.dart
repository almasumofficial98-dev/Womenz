import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LatePeriodDecisionTreeModal extends StatelessWidget {
  const LatePeriodDecisionTreeModal({super.key});

  @override
  Widget build(BuildContext context) {
    final factors = [
      {'icon': Icons.pregnant_woman_rounded, 'title': 'Pregnancy Possibility', 'desc': 'Conception or recent sexual activity'},
      {'icon': Icons.psychology_rounded, 'title': 'Recent Major Stress', 'desc': 'Work, emotional, or exam pressure'},
      {'icon': Icons.scale_rounded, 'title': 'Significant Weight Change', 'desc': 'Rapid weight gain or rapid loss'},
      {'icon': Icons.fitness_center_rounded, 'title': 'Intense Physical Exercise', 'desc': 'Strenuous athletic training'},
      {'icon': Icons.child_care_rounded, 'title': 'Breastfeeding', 'desc': 'Postpartum lactation'},
      {'icon': Icons.medication_rounded, 'title': 'New Medications / Birth Control', 'desc': 'Hormonal contraceptives or IUD'},
      {'icon': Icons.medical_services_rounded, 'title': 'Thyroid or Prolactin History', 'desc': 'Hypothyroidism or hyperprolactinemia'},
      {'icon': Icons.analytics_rounded, 'title': 'PCOS / PCOD Indicators', 'desc': 'Oligomenorrhea or hyperandrogenism'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Why Is My Period Late?',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Common physiological factors that affect menstrual cycle timing',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textSecondary),
          ),

          const SizedBox(height: 20),

          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: factors.length,
              itemBuilder: (context, idx) {
                final item = factors[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppTheme.softPink, shape: BoxShape.circle),
                        child: Icon(item['icon'] as IconData, color: AppTheme.primaryPink, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title'] as String, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                            Text(item['desc'] as String, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.softBlue, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppTheme.primaryBlue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Several factors can affect menstrual cycles. If your period has been absent for several months, consider discussing this with a healthcare professional.',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, color: AppTheme.primaryBlue, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
