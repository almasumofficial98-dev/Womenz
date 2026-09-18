import 'package:flutter/material.dart';
import '../../models/screening_result.dart';
import '../../models/ultrasound_info.dart';
import '../../services/health_screening_engine.dart';
import '../../theme/app_theme.dart';

class PcosScreeningWizard extends StatefulWidget {
  final VoidCallback onOpenDoctorPrep;

  const PcosScreeningWizard({super.key, required this.onOpenDoctorPrep});

  @override
  State<PcosScreeningWizard> createState() => _PcosScreeningWizardState();
}

class _PcosScreeningWizardState extends State<PcosScreeningWizard> {
  int currentStep = 0;

  // Step 1: Pregnancy Gate
  String pregnancyStatus = 'unknown'; // 'unknown', 'notPossible', 'possible', 'confirmed'

  // Step 2: Cycle Irregularity & Gap
  bool hasIrregularPeriods = false;
  int longestGapDays = 28;

  // Step 3: Androgenic & Metabolic Symptoms
  bool hasAcne = false;
  bool hasHirsutism = false;
  bool hasHairThinning = false;
  bool hasWeightFluctuations = false;
  bool hasFamilyPCOS = false;
  bool hasFamilyDiabetes = false;

  // Step 4: Ultrasound Information
  UltrasoundSource ultrasoundSource = UltrasoundSource.notAvailable;

  PcosScreeningResult? finalResult;

  void _runEvaluation() {
    final input = PcosScreeningInput(
      longestPeriodGapDays: longestGapDays,
      hasIrregularPeriods: hasIrregularPeriods,
      hasAcne: hasAcne,
      hasHirsutism: hasHirsutism,
      hasHairThinning: hasHairThinning,
      hasWeightFluctuations: hasWeightFluctuations,
      hasFamilyPCOS: hasFamilyPCOS,
      hasFamilyDiabetes: hasFamilyDiabetes,
      pregnancyStatus: pregnancyStatus,
      ultrasoundSource: ultrasoundSource,
    );

    setState(() {
      finalResult = HealthScreeningEngine.evaluate(input);
      currentStep = 4; // Result step
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('PCOS Educational Screening', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
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
            children: [
              // Progress Bar
              Row(
                children: List.generate(
                  5,
                  (index) => Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: index <= currentStep ? AppTheme.primaryPink : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildStepContent(),
                ),
              ),

              if (currentStep < 4) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentStep == 0 && (pregnancyStatus == 'possible' || pregnancyStatus == 'confirmed')) {
                        _runEvaluation(); // Trigger pregnancy gate result immediately
                      } else if (currentStep < 3) {
                        setState(() => currentStep++);
                      } else {
                        _runEvaluation();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      currentStep == 3 ? 'Complete Screening' : 'Next Step',
                      style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildPregnancyGateStep();
      case 1:
        return _buildCycleGapStep();
      case 2:
        return _buildSymptomsStep();
      case 3:
        return _buildUltrasoundStep();
      case 4:
        return _buildResultStep();
      default:
        return Container();
    }
  }

  Widget _buildPregnancyGateStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Pregnancy Possibility Check', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Text('Before evaluating menstrual gap patterns, we check for potential pregnancy.', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(color: Colors.white, radius: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Is there any possibility you could be pregnant?', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              _buildChoiceChip('notPossible', 'No / Not Possible', pregnancyStatus, (val) => setState(() => pregnancyStatus = val)),
              _buildChoiceChip('possible', 'Yes, Possible', pregnancyStatus, (val) => setState(() => pregnancyStatus = val)),
              _buildChoiceChip('confirmed', 'Confirmed Pregnant', pregnancyStatus, (val) => setState(() => pregnancyStatus = val)),
              _buildChoiceChip('unknown', 'Prefer Not to Say / Not Sure', pregnancyStatus, (val) => setState(() => pregnancyStatus = val)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCycleGapStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Menstrual Irregularity & Gaps', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Text('Select your typical gap between periods.', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(color: Colors.white, radius: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: Text('Do you frequently experience irregular periods?', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                value: hasIrregularPeriods,
                activeColor: AppTheme.primaryPink,
                onChanged: (val) => setState(() => hasIrregularPeriods = val),
              ),
              const Divider(height: 24),
              Text('Longest Period Gap in Last 12 Months:', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              _buildRadioChoice(28, 'Regular (21-35 days)', longestGapDays, (val) => setState(() => longestGapDays = val)),
              _buildRadioChoice(45, '> 35 Days Gap', longestGapDays, (val) => setState(() => longestGapDays = val)),
              _buildRadioChoice(90, '90+ Days (3 Months)', longestGapDays, (val) => setState(() => longestGapDays = val)),
              _buildRadioChoice(180, '180+ Days (6 Months)', longestGapDays, (val) => setState(() => longestGapDays = val)),
              _buildRadioChoice(240, '240+ Days (8 Months)', longestGapDays, (val) => setState(() => longestGapDays = val)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Androgenic & Metabolic Symptoms', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Text('Select physical or hormonal indicators you experience.', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(color: Colors.white, radius: 24),
          child: Column(
            children: [
              CheckboxListTile(
                title: Text('Persistent or severe acne (chin/jawline)', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w600)),
                value: hasAcne,
                activeColor: AppTheme.primaryPink,
                onChanged: (val) => setState(() => hasAcne = val ?? false),
              ),
              CheckboxListTile(
                title: Text('Excess facial or body hair growth (Hirsutism)', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w600)),
                value: hasHirsutism,
                activeColor: AppTheme.primaryPink,
                onChanged: (val) => setState(() => hasHirsutism = val ?? false),
              ),
              CheckboxListTile(
                title: Text('Scalp hair thinning or male-pattern hair loss', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w600)),
                value: hasHairThinning,
                activeColor: AppTheme.primaryPink,
                onChanged: (val) => setState(() => hasHairThinning = val ?? false),
              ),
              CheckboxListTile(
                title: Text('Unexplained weight gain or difficulty managing weight', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w600)),
                value: hasWeightFluctuations,
                activeColor: AppTheme.primaryPink,
                onChanged: (val) => setState(() => hasWeightFluctuations = val ?? false),
              ),
              CheckboxListTile(
                title: Text('Family history of PCOS or Type 2 Diabetes', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w600)),
                value: hasFamilyPCOS,
                activeColor: AppTheme.primaryPink,
                onChanged: (val) => setState(() => hasFamilyPCOS = val ?? false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUltrasoundStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 4: Ultrasound Findings', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Text('Do you have previous pelvic ultrasound information?', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(color: Colors.white, radius: 24),
          child: Column(
            children: [
              _buildUltrasoundChoice(UltrasoundSource.notAvailable, 'No ultrasound performed or not available'),
              _buildUltrasoundChoice(UltrasoundSource.userReportedHistory, 'User-reported previous polycystic ovary finding'),
              _buildUltrasoundChoice(UltrasoundSource.clinicianConfirmedReport, 'Clinician-confirmed medical ultrasound report'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultStep() {
    if (finalResult == null) return Container();
    final res = finalResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Screening Summary', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text('Screening Version ${res.screeningVersion} • Date: ${res.screeningDate.toString().split(" ")[0]}', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: AppTheme.cardDecoration(color: Colors.white, radius: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: AppTheme.softPink, shape: BoxShape.circle),
                    child: const Icon(Icons.analytics_rounded, color: AppTheme.primaryPink, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      res.outcome.title,
                      style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(res.clinicalGuidance, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppTheme.textPrimary, height: 1.4)),
              
              if (res.domainsWithIndicators.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text('Domains with Indicators:', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                for (final d in res.domainsWithIndicators)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppTheme.primaryPink),
                        const SizedBox(width: 8),
                        Text(d, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              widget.onOpenDoctorPrep();
            },
            icon: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 18),
            label: const Text('Prepare for Doctor Visit', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String val, String label, String currentVal, ValueChanged<String> onSelect) {
    final selected = val == currentVal;
    return GestureDetector(
      onTap: () => onSelect(val),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.softPink : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppTheme.primaryPink : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? AppTheme.primaryPink : AppTheme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioChoice(int val, String label, int currentVal, ValueChanged<int> onSelect) {
    final selected = val == currentVal;
    return GestureDetector(
      onTap: () => onSelect(val),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.softPink : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? AppTheme.primaryPink : AppTheme.textSecondary, size: 18),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildUltrasoundChoice(UltrasoundSource val, String label) {
    final selected = val == ultrasoundSource;
    return GestureDetector(
      onTap: () => setState(() => ultrasoundSource = val),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.softBlue : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppTheme.primaryBlue : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? AppTheme.primaryBlue : AppTheme.textSecondary, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppTheme.textPrimary))),
          ],
        ),
      ),
    );
  }
}
