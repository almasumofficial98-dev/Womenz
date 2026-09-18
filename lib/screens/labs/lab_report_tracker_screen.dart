import 'package:flutter/material.dart';
import '../../models/lab_result.dart';
import '../../theme/app_theme.dart';

class LabReportTrackerScreen extends StatefulWidget {
  final List<LabResult> labResults;
  final ValueChanged<LabResult> onAddLabResult;

  const LabReportTrackerScreen({
    super.key,
    required this.labResults,
    required this.onAddLabResult,
  });

  @override
  State<LabReportTrackerScreen> createState() => _LabReportTrackerScreenState();
}

class _LabReportTrackerScreenState extends State<LabReportTrackerScreen> {
  final testNameCtrl = TextEditingController(text: 'TSH');
  final valueCtrl = TextEditingController();
  final unitCtrl = TextEditingController(text: 'mIU/L');
  final refRangeCtrl = TextEditingController(text: '0.4 - 4.0');
  final labNameCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  void _showAddLabModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log Lab Result Report', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('Record exact lab values and reference ranges from your doctor report', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: testNameCtrl.text,
                decoration: InputDecoration(labelText: 'Test Name', filled: true, fillColor: AppTheme.surfaceLight, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                items: ['TSH', 'Total Testosterone', 'Free Testosterone', 'LH', 'FSH', 'HbA1c', 'Fasting Glucose', 'DHEAS', 'Prolactin']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => testNameCtrl.text = val);
                },
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: valueCtrl,
                      decoration: InputDecoration(labelText: 'Value (e.g. 2.8)', filled: true, fillColor: AppTheme.surfaceLight, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: unitCtrl,
                      decoration: InputDecoration(labelText: 'Unit (e.g. mIU/L)', filled: true, fillColor: AppTheme.surfaceLight, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TextField(
                controller: refRangeCtrl,
                decoration: InputDecoration(labelText: 'Lab Reference Range (e.g. 0.4 - 4.0)', filled: true, fillColor: AppTheme.surfaceLight, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: labNameCtrl,
                decoration: InputDecoration(labelText: 'Diagnostic Lab Name (e.g. XYZ Diagnostics)', filled: true, fillColor: AppTheme.surfaceLight, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (valueCtrl.text.isEmpty) return;
                    final newRes = LabResult(
                      id: 'lab_${DateTime.now().millisecondsSinceEpoch}',
                      date: DateTime.now(),
                      testName: testNameCtrl.text,
                      value: valueCtrl.text,
                      unit: unitCtrl.text,
                      referenceRange: refRangeCtrl.text,
                      labName: labNameCtrl.text.isEmpty ? null : labNameCtrl.text,
                      reportDate: DateTime.now(),
                    );
                    widget.onAddLabResult(newRes);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  child: const Text('Save Lab Record', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Lab Report Health Records', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
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
              Text('Blood Panels & Diagnostic Lab Tracker', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 20),

              Expanded(
                child: widget.labResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.folder_open_rounded, size: 48, color: AppTheme.textMuted),
                            const SizedBox(height: 12),
                            Text('No lab reports recorded yet.', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, color: AppTheme.textSecondary)),
                            const SizedBox(height: 4),
                            Text('Tap + below to store your medical lab values.', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textMuted)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: widget.labResults.length,
                        itemBuilder: (context, index) {
                          final lab = widget.labResults[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(18),
                            decoration: AppTheme.cardDecoration(color: Colors.white, radius: 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(lab.testName, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                                    Text(lab.date.toString().split(' ')[0], style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textSecondary)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('Result: ', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: AppTheme.textSecondary)),
                                    Text('${lab.value} ${lab.unit}', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryPink)),
                                  ],
                                ),
                                if (lab.referenceRange != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Reference Range: ${lab.referenceRange}', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, color: AppTheme.textMuted)),
                                ],
                                if (lab.labName != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Diagnostic Lab: ${lab.labName}', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _showAddLabModal,
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  label: const Text('Add Lab Result', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
