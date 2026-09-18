import 'package:flutter/material.dart';
import '../../services/red_flag_service.dart';
import '../../theme/app_theme.dart';

class RedFlagsUrgentCareScreen extends StatelessWidget {
  const RedFlagsUrgentCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final urgentSymptoms = [
      'Severe pelvic or lower abdominal pain (sudden or intense)',
      'Fainting, severe dizziness, or loss of consciousness',
      'Extremely heavy menstrual bleeding (soaking multiple pads per hour for consecutive hours)',
      'New severe headaches accompanied by vision changes',
      'Abdominal pain or vaginal bleeding during suspected or confirmed pregnancy',
      'High fever accompanied by pelvic pain or unusual vaginal discharge',
      'Vaginal bleeding occurring after menopause',
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('When to Seek Urgent Care', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFEF5350)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828), size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        RedFlagService.urgentCareAdvice,
                        style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFC62828), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text('Urgent Symptoms Requiring Prompt Medical Assessment:', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 14),

              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: urgentSymptoms.length,
                  itemBuilder: (context, idx) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.cardDecoration(color: Colors.white, radius: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.local_hospital_rounded, color: Color(0xFFE53935), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              urgentSymptoms[idx],
                              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppTheme.textPrimary, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
