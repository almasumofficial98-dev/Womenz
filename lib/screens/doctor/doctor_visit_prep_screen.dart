import 'package:flutter/material.dart';
import '../../models/body_measurement.dart';
import '../../models/cycle_record.dart';
import '../../models/lab_result.dart';
import '../../models/symptom_record.dart';
import '../../models/user_profile.dart';
import '../../services/cycle_calculation_service.dart';
import '../../theme/app_theme.dart';

class DoctorVisitPrepScreen extends StatelessWidget {
  final UserProfile profile;
  final List<CycleRecord> cycleRecords;
  final List<SymptomRecord> symptomRecords;
  final BodyMeasurement? latestBody;
  final List<LabResult> labResults;

  const DoctorVisitPrepScreen({
    super.key,
    required this.profile,
    required this.cycleRecords,
    required this.symptomRecords,
    this.latestBody,
    required this.labResults,
  });

  @override
  Widget build(BuildContext context) {
    final currentGap = CycleCalculationService.calculateCurrentGap(cycleRecords);
    final longestGap = CycleCalculationService.calculateLongestGap(cycleRecords);
    final avgCycle = CycleCalculationService.calculateAverageCycleLength(cycleRecords);
    final periods12m = CycleCalculationService.calculatePeriodsLast12Months(cycleRecords);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Prepare for Doctor Visit', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mandatory Clinical Header Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.softBlue,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_information_rounded, color: AppTheme.primaryBlue, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Patient-generated health summary. Not a medical diagnosis.',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 1. Menstrual History Summary
              _buildSectionCard(
                title: 'Menstrual History Summary',
                icon: Icons.calendar_month_rounded,
                iconColor: AppTheme.primaryPink,
                bgColor: AppTheme.softPink,
                children: [
                  _buildDataRow('Last Recorded Period Gap:', '$currentGap Days'),
                  _buildDataRow('Longest Gap (Last 12m):', '$longestGap Days'),
                  _buildDataRow('Average Cycle Length:', '$avgCycle Days'),
                  _buildDataRow('Periods in Last 12 Months:', '$periods12m'),
                  _buildDataRow('Irregular Cycle Mode:', profile.isIrregularCycle ? 'Enabled' : 'Disabled'),
                ],
              ),

              const SizedBox(height: 16),

              // 2. Tracked Symptoms Summary
              _buildSectionCard(
                title: 'Tracked Symptoms & Intensity',
                icon: Icons.sick_rounded,
                iconColor: AppTheme.primaryPink,
                bgColor: AppTheme.softPink,
                children: [
                  if (symptomRecords.isEmpty)
                    Text('No symptoms logged yet', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textSecondary))
                  else ...[
                    for (final s in symptomRecords.take(5))
                      _buildDataRow(
                        s.date.toString().split(' ')[0],
                        'Acne: ${s.acne.name}, Hair: ${s.hirsutism.name}, Pain: ${s.pelvicPain.name}',
                      ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // 3. Body Measurements & BMI
              _buildSectionCard(
                title: 'Body Measurements & BMI',
                icon: Icons.monitor_weight_rounded,
                iconColor: AppTheme.primaryBlue,
                bgColor: AppTheme.softBlue,
                children: [
                  if (latestBody == null)
                    Text('No body measurements logged yet', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textSecondary))
                  else ...[
                    _buildDataRow('Current Weight:', '${latestBody!.weightKg} kg'),
                    _buildDataRow('Height:', '${latestBody!.heightCm} cm'),
                    _buildDataRow('Calculated BMI:', '${latestBody!.bmi} (${latestBody!.bmiClassification})'),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // 4. Questions to Ask Clinician
              _buildSectionCard(
                title: 'Questions to Ask Your Doctor',
                icon: Icons.question_answer_rounded,
                iconColor: AppTheme.primaryBlue,
                bgColor: AppTheme.softBlue,
                children: [
                  _buildBulletQuestion('Could these menstrual cycle gaps or changes have an underlying hormonal cause?'),
                  _buildBulletQuestion('Should I have blood tests performed (e.g. TSH, Total/Free Testosterone, LH, FSH, HbA1c)?'),
                  _buildBulletQuestion('Do I need a pelvic ultrasound to evaluate ovarian morphology?'),
                  _buildBulletQuestion('Could thyroid or prolactin factors be contributing to my symptoms?'),
                ],
              ),

              const SizedBox(height: 24),

              // Export Data Actions Row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exporting Doctor Summary PDF...')),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 18),
                      label: const Text('Export PDF', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exporting CSV / JSON Data...')),
                        );
                      },
                      icon: const Icon(Icons.file_download_rounded, color: AppTheme.primaryBlue, size: 18),
                      label: const Text('Export CSV/JSON', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(color: Colors.white, radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textSecondary)),
          Text(val, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildBulletQuestion(String q) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Expanded(child: Text(q, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textPrimary, height: 1.3))),
        ],
      ),
    );
  }
}
