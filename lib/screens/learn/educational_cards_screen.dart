import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EducationalCardsScreen extends StatelessWidget {
  const EducationalCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articles = [
      {
        'title': 'What is PCOS vs PCOD?',
        'source': 'Medical Evidence Review • Sep 2026',
        'summary': 'PCOS (Polycystic Ovary Syndrome) is an endocrine disorder characterized by hormonal imbalance and metabolic factors. PCOD (Polycystic Ovary Disease) primarily involves functional ovarian cyst formation. Both benefit from lifestyle management and medical consultation.'
      },
      {
        'title': 'What Can Cause Missed Periods?',
        'source': 'Endocrinology Clinical Guide • Sep 2026',
        'summary': 'Missed periods (amenorrhea or oligomenorrhea) can result from pregnancy, high stress, significant weight changes, excessive athletic training, thyroid conditions, hyperprolactinemia, hormonal birth control, or PCOS.'
      },
      {
        'title': 'Understanding BMI & Body Metrics',
        'source': 'Health Statistics Review • Sep 2026',
        'summary': 'Body Mass Index (BMI) is a broad statistical screening ratio of weight to height. It does not measure body composition, muscle mass, or metabolic health directly and is never used as a diagnostic test for PCOS.'
      },
      {
        'title': 'Common Blood Tests for Hormonal Health',
        'source': 'Clinical Laboratory Standards • Sep 2026',
        'summary': 'Doctors may evaluate TSH (thyroid), Total & Free Testosterone (androgens), LH/FSH ratio, Fasting Glucose / HbA1c (metabolic health), DHEAS, and Prolactin to understand cycle irregularity.'
      },
      {
        'title': 'What to Expect During a Pelvic Ultrasound',
        'source': 'Gynecology Diagnostic Imaging • Sep 2026',
        'summary': 'A pelvic ultrasound allows a sonographer or doctor to view ovarian morphology, antral follicle count, and endometrial thickness. An ultrasound finding of polycystic ovaries is one of three criteria evaluated by clinicians.'
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Learn & Medical Insights', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
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
              Text('Sourced Medical Knowledge & Educational Guides', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: articles.length,
                  itemBuilder: (context, idx) {
                    final art = articles[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.cardDecoration(color: Colors.white, radius: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: AppTheme.softBlue, shape: BoxShape.circle),
                                child: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryBlue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(art['title']!, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(art['source']!, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          Text(art['summary']!, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppTheme.textPrimary, height: 1.4)),
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
