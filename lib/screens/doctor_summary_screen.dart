import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/cycle_model.dart';
import '../services/google_sheets_service.dart';
import '../services/local_db_service.dart';
import '../theme/app_theme.dart';

class DoctorSummaryScreen extends StatefulWidget {
  final UserCycleData cycleData;

  const DoctorSummaryScreen({super.key, required this.cycleData});

  @override
  State<DoctorSummaryScreen> createState() => _DoctorSummaryScreenState();
}

class _DoctorSummaryScreenState extends State<DoctorSummaryScreen> {
  List<Map<String, dynamic>> historyLogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final entries = await LocalDbService.getHistoryEntries();
    if (mounted) {
      setState(() {
        historyLogs = entries;
        isLoading = false;
      });
    }
  }

  int get averageCycleLength => widget.cycleData.cycleLength;
  int get periodDuration => widget.cycleData.periodDuration;

  int get severePainDaysCount {
    int count = 0;
    for (final log in widget.cycleData.logs.values) {
      if (log.painScale >= 8) count++;
    }
    return count;
  }

  int get largeClotDaysCount {
    int count = 0;
    for (final log in widget.cycleData.logs.values) {
      if (log.clotSize == 'Large (> Quarter)') count++;
    }
    return count;
  }

  bool get hasPcosIndicators {
    bool hasHirsutism = false;
    bool hasAcne = false;
    bool hasThinning = false;
    for (final log in widget.cycleData.logs.values) {
      if (log.symptoms.contains('Hirsutism / Facial Hair')) hasHirsutism = true;
      if (log.symptoms.contains('Acne / Breakout')) hasAcne = true;
      if (log.symptoms.contains('Hair Thinning')) hasThinning = true;
    }
    return hasHirsutism || hasAcne || hasThinning;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMMM d, yyyy').format(DateTime.now());
    final cycleLens = historyLogs
        .map((h) => int.tryParse(h['durationDays']?.toString() ?? ''))
        .whereType<int>()
        .toList();
    if (cycleLens.isEmpty && widget.cycleData.cycleLength > 0) {
      cycleLens.add(widget.cycleData.cycleLength);
    }
    final durations = [widget.cycleData.periodDuration];
    final figoReport = FigoReport.evaluate(
      cycleLengths: cycleLens,
      periodDurations: durations,
      recentLogs: widget.cycleData.logs.values.toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('OB-GYN Clinical Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share with Doctor',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Doctor summary report ready to present or print!'),
                  backgroundColor: AppTheme.primaryPink,
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPink))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prominent Non-Diagnostic Clinical Disclaimer
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFF475569), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Non-Diagnostic Clinical Disclaimer: This report summarizes self-reported observations and bleeding timelines recorded in Womenz. It is designed to assist healthcare provider consultations and does not constitute a diagnostic medical opinion.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Clinical Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2C3E50), Color(0xFF4A6572)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PATIENT CYCLE REPORT',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.7),
                                letterSpacing: 1.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'CLINICAL USE',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Patient: ${widget.cycleData.userName}',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Report Date: $dateStr • ID: ${GoogleSheetsService.userId.substring(0, 8)}',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 1: Cycle Parameters & Regularity
                  _buildSectionHeader('1. Menstrual Cycle Regularity & Length'),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _reportMetric('Average Cycle Length', '$averageCycleLength Days'),
                              _reportMetric('Menses Duration', '$periodDuration Days'),
                              _reportMetric('Cycle Variance', averageCycleLength > 35 ? 'Irregular / Oligo' : 'Normal Range'),
                            ],
                          ),
                          const Divider(height: 28),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 18, color: AppTheme.primaryBlue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  averageCycleLength > 35
                                      ? 'Note: Cycle length exceeds 35 days (Oligomenorrhea threshold). May warrant hormonal evaluation (FSH, LH, Prolactin, TSH).'
                                      : 'Cycle length is within standard physiologic window (21 - 35 days).',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Action Bar: Copy Clinical Report & Export CSV
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final reportText = _generateFormattedReport(figoReport);
                            Clipboard.setData(ClipboardData(text: reportText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Full clinical report copied to clipboard! Ready to paste into portal or email.'),
                                backgroundColor: Color(0xFF2C3E50),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_all_rounded, size: 18),
                          label: const Text('Copy Clinical Report'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C3E50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final csv = await LocalDbService.exportCsvData();
                          Clipboard.setData(ClipboardData(text: csv));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Raw CSV data copied to clipboard! Ready to import into spreadsheets.'),
                                backgroundColor: AppTheme.primaryPink,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.table_chart_outlined, size: 18),
                        label: const Text('CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.textPrimary,
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // FIGO Abnormal Uterine Bleeding Evaluation
                  _buildSectionHeader('FIGO Menstrual Pattern Evaluation'),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _statusPill('Frequency', figoReport.frequencyStatus),
                              const SizedBox(width: 8),
                              _statusPill('Regularity', figoReport.regularityStatus),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _statusPill('Duration', figoReport.durationStatus),
                              const SizedBox(width: 8),
                              _statusPill('Volume', figoReport.volumeStatus),
                            ],
                          ),
                          if (figoReport.clinicalObservations.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            const Text(
                              'Clinical Observations:',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            for (final obs in figoReport.clinicalObservations)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(color: AppTheme.primaryPink, fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(
                                        obs,
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pre-Appointment Discussion Prompts
                  _buildSectionHeader('Pre-Appointment Discussion Prompts'),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Questions to consider discussing with your doctor:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          for (final prompt in figoReport.discussionPrompts)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.help_outline_rounded, size: 16, color: AppTheme.primaryPink),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      prompt,
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 2: Dysmenorrhea & Pain Assessment
                  _buildSectionHeader('2. Dysmenorrhea & Severe Pain Assessment (Self-Reported)'),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _reportMetric('Severe Pain Days (8-10/10)', '$severePainDaysCount Days'),
                              _reportMetric('Large Clots (> Quarter)', '$largeClotDaysCount Episodes'),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: severePainDaysCount > 0 ? const Color(0xFFFFF0F1) : AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              severePainDaysCount > 0
                                  ? 'Patient Self-Report Note: Severe pain (score ≥ 8/10) recorded. Consider differential screening for secondary dysmenorrhea (Endometriosis, Adenomyosis, fibroids).'
                                  : 'Dysmenorrhea score managed within mild to moderate range.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: severePainDaysCount > 0 ? FontWeight.w700 : FontWeight.normal,
                                color: severePainDaysCount > 0 ? const Color(0xFFD32F2F) : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 3: Rotterdam PCOS Clinical Indicators
                  _buildSectionHeader('3. Rotterdam PCOS / Hyperandrogenism Indicators'),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _checklistRow('Cycle Length > 35 Days (Ovulatory Dysfunction)', averageCycleLength > 35),
                          _checklistRow('Hirsutism / Excess Facial Hair', _checkSymptom('Hirsutism / Facial Hair')),
                          _checklistRow('Persistent Moderate/Severe Acne', _checkSymptom('Acne / Breakout')),
                          _checklistRow('Androgenic Hair Thinning / Shedding', _checkSymptom('Hair Thinning')),
                          _checklistRow('Insulin Resistance / Fatigue Slumps', _checkSymptom('Insulin Crash / Fatigue')),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 4: Recent Cycle Log Table
                  _buildSectionHeader('4. Logged Menstrual History'),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: historyLogs.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No past cycles recorded in history yet.', style: TextStyle(color: AppTheme.textSecondary)),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: historyLogs.take(6).length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, idx) {
                                final item = historyLogs[idx];
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item['startDate']} - ${item['endDate']}',
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                        ),
                                        Text('Flow: ${item['flowIntensity']}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                    Text(
                                      '${item['durationDays']} Days',
                                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryPink, fontSize: 13),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _reportMetric(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _checklistRow(String label, bool isPresent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            isPresent ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 18,
            color: isPresent ? AppTheme.primaryPink : AppTheme.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isPresent ? FontWeight.w700 : FontWeight.normal,
                color: isPresent ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _checkSymptom(String symptomName) {
    for (final log in widget.cycleData.logs.values) {
      if (log.symptoms.contains(symptomName)) return true;
    }
    return false;
  }

  Widget _statusPill(String title, String value) {
    final bool isAlert = value.contains('Frequent') ||
        value.contains('Infrequent') ||
        value.contains('Irregular') ||
        value.contains('Prolonged') ||
        value.contains('Heavy');

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isAlert ? const Color(0xFFFFF0F1) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAlert ? const Color(0xFFFFCDD2) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isAlert ? const Color(0xFFC62828) : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateFormattedReport(FigoReport figo) {
    final buffer = StringBuffer();
    buffer.writeln('========================================');
    buffer.writeln('WOMENZ CLINICAL CYCLE & BLEEDING REPORT');
    buffer.writeln('========================================');
    buffer.writeln('Patient: ${widget.cycleData.userName}');
    buffer.writeln('Report Date: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}');
    buffer.writeln('Clinical Intent: ${widget.cycleData.userIntent.toUpperCase()}');
    buffer.writeln('Health Profile: ${widget.cycleData.healthCondition.toUpperCase()}');
    buffer.writeln('Contraception: ${widget.cycleData.contraceptionType.displayName}');
    buffer.writeln('');
    buffer.writeln('--- CYCLE METRICS ---');
    buffer.writeln('Typical Cycle Length: ${widget.cycleData.cycleLength} Days');
    buffer.writeln('Typical Period Duration: ${widget.cycleData.periodDuration} Days');
    buffer.writeln('Severe Pain Days (8–10/10): $severePainDaysCount');
    buffer.writeln('Large Clot Episodes: $largeClotDaysCount');
    buffer.writeln('');
    buffer.writeln('--- FIGO AUB EVALUATION ---');
    buffer.writeln('Frequency: ${figo.frequencyStatus}');
    buffer.writeln('Regularity: ${figo.regularityStatus}');
    buffer.writeln('Duration: ${figo.durationStatus}');
    buffer.writeln('Volume: ${figo.volumeStatus}');
    if (figo.clinicalObservations.isNotEmpty) {
      buffer.writeln('Observations:');
      for (final obs in figo.clinicalObservations) {
        buffer.writeln('  - $obs');
      }
    }
    buffer.writeln('');
    buffer.writeln('--- PRE-APPOINTMENT DISCUSSION PROMPTS ---');
    for (final p in figo.discussionPrompts) {
      buffer.writeln('  • $p');
    }
    buffer.writeln('');
    buffer.writeln('--- RECENT RECORDED CYCLES ---');
    for (final item in historyLogs.take(6)) {
      buffer.writeln('${item['startDate']} to ${item['endDate']} (${item['durationDays']} days, Flow: ${item['flowIntensity']})');
    }
    buffer.writeln('========================================');
    buffer.writeln('Note: Self-reported patient log for clinical consultation.');
    return buffer.toString();
  }
}
