import 'package:flutter/material.dart';
import '../models/cycle_model.dart';
import '../theme/app_theme.dart';

class SymptomLoggerModal extends StatefulWidget {
  final DailyLog? initialLog;
  final ValueChanged<DailyLog> onSave;

  const SymptomLoggerModal({
    super.key,
    this.initialLog,
    required this.onSave,
  });

  @override
  State<SymptomLoggerModal> createState() => _SymptomLoggerModalState();
}

class _SymptomLoggerModalState extends State<SymptomLoggerModal> {
  String selectedFlow = 'Medium';
  String selectedMood = 'Calm';
  late List<String> selectedSymptoms;
  bool tookSupplements = false;
  int painLevel = 0;
  String selectedClotSize = 'None';
  String selectedCervicalMucus = 'Creamy';
  final TextEditingController notesController = TextEditingController();

  final List<Map<String, dynamic>> flowOptions = [
    {'label': 'Light', 'icon': Icons.water_drop_outlined, 'color': const Color(0xFFFFB3C1)},
    {'label': 'Medium', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFFFF7597)},
    {'label': 'Heavy', 'icon': Icons.opacity_rounded, 'color': const Color(0xFFE63946)},
    {'label': 'Spotting', 'icon': Icons.grain_rounded, 'color': const Color(0xFFFFC6FF)},
  ];

  final List<Map<String, String>> moodOptions = [
    {'label': 'Happy', 'emoji': '😊'},
    {'label': 'Calm', 'emoji': '😌'},
    {'label': 'Sensitive', 'emoji': '🥺'},
    {'label': 'Energetic', 'emoji': '⚡'},
    {'label': 'Tired', 'emoji': '😴'},
    {'label': 'Anxious', 'emoji': '🌧️'},
    {'label': 'PMDD Mood', 'emoji': '🌩️'},
  ];

  final List<String> symptomList = [
    'Cramps',
    'Headache',
    'Bloating',
    'Acne / Breakout',
    'Tender Breasts',
    'Backache',
    'Cravings',
    'Nausea',
    'Hirsutism / Facial Hair',
    'Hair Thinning',
    'Brain Fog',
    'Insulin Crash / Fatigue',
    'Pelvic Pressure',
  ];

  final List<String> clotOptions = [
    'None',
    'Small (< Dime)',
    'Large (> Quarter)',
  ];

  final List<Map<String, dynamic>> cervicalMucusOptions = [
    {'label': 'Dry / Sticky', 'phase': 'Low Fertility'},
    {'label': 'Creamy', 'phase': 'Transitioning'},
    {'label': 'Watery', 'phase': 'High Fertility'},
    {'label': 'Egg-White / Stretchy', 'phase': 'Peak Ovulation'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialLog != null) {
      selectedFlow = widget.initialLog!.flow ?? 'Medium';
      selectedMood = widget.initialLog!.mood ?? 'Calm';
      selectedSymptoms = List.from(widget.initialLog!.symptoms);
      tookSupplements = widget.initialLog!.tookSupplements;
      painLevel = widget.initialLog!.painScale;
      selectedClotSize = widget.initialLog!.clotSize ?? 'None';
      selectedCervicalMucus = widget.initialLog!.cervicalMucus ?? 'Creamy';
      notesController.text = widget.initialLog!.notes ?? '';
    } else {
      selectedSymptoms = ['Cramps'];
    }
  }

  bool get isUrgentRedFlag {
    return painLevel >= 8 ||
        selectedClotSize == 'Large (> Quarter)' ||
        (selectedFlow == 'Heavy' && selectedSymptoms.contains('Brain Fog'));
  }

  String get painLevelDescription {
    if (painLevel == 0) return 'Pain-Free';
    if (painLevel <= 3) return 'Mild (Noticeable, but routine continues)';
    if (painLevel <= 6) return 'Moderate (Affects focus, needs heat/meds)';
    return 'Severe / Bed-ridden (Incapacitating pain - consult OB-GYN)';
  }

  @override
  Widget build(BuildContext context) {
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Handle Bar
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Health & Cycle Log',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Clinical gynecological symptom tracking',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                ),
              ],
            ),

            // Red Flag Clinical Warning Banner (if triggered)
            if (isUrgentRedFlag) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFF5252), width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Clinical Precaution Notice',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            selectedClotSize == 'Large (> Quarter)'
                                ? 'Passing large blood clots (> quarter size) can indicate menorrhagia or fibroids. If you are soaking pads hourly, please contact your OB-GYN.'
                                : 'Severe pelvic pain (8+/10) is a medical symptom. Please rest, apply warmth, and seek medical attention if pain persists or escalates.',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: Color(0xFF5D101D),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 1. Flow Level
            Text(
              'Flow Level',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: flowOptions.map((opt) {
                final isSelected = selectedFlow == opt['label'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedFlow = opt['label']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? opt['color'] as Color : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: (opt['color'] as Color).withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            opt['icon'] as IconData,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            opt['label'] as String,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 2. Dysmenorrhea Pain Scale Slider (0-10)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cramp & Pelvic Pain Scale (0-10)',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '$painLevel / 10',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: painLevel >= 7
                        ? const Color(0xFFD32F2F)
                        : (painLevel >= 4 ? AppTheme.primaryPeach : AppTheme.primaryPink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              painLevelDescription,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                color: painLevel >= 7 ? const Color(0xFFD32F2F) : AppTheme.textSecondary,
                fontWeight: painLevel >= 7 ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: painLevel >= 7 ? const Color(0xFFD32F2F) : AppTheme.primaryPink,
                thumbColor: painLevel >= 7 ? const Color(0xFFD32F2F) : AppTheme.primaryPink,
                inactiveTrackColor: AppTheme.softPink,
              ),
              child: Slider(
                value: painLevel.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (val) => setState(() => painLevel = val.toInt()),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Menstrual Clot Size
            Text(
              'Blood Clot Size (If Any)',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: clotOptions.map((opt) {
                final isSelected = selectedClotSize == opt;
                return ChoiceChip(
                  label: Text(opt),
                  selected: isSelected,
                  selectedColor: opt.contains('Large') ? const Color(0xFFFFCDD2) : AppTheme.softPink,
                  labelStyle: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: opt.contains('Large') && isSelected
                        ? const Color(0xFFB71C1C)
                        : (isSelected ? AppTheme.primaryPink : AppTheme.textSecondary),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => selectedClotSize = opt);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 4. Cervical Fluid / Mucus (Key for Ovulation & PCOS)
            Text(
              'Cervical Fluid / Mucus Consistency',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Primary biological sign of ovulation (ideal for irregular/PCOS cycles)',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cervicalMucusOptions.map((opt) {
                final label = opt['label'] as String;
                final isSelected = selectedCervicalMucus == label;
                return ChoiceChip(
                  label: Text('$label (${opt['phase']})'),
                  selected: isSelected,
                  selectedColor: AppTheme.softBlue,
                  labelStyle: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => selectedCervicalMucus = label);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 5. Mood & Emotional State
            Text(
              'Mood & Emotional State',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: moodOptions.map((opt) {
                  final isSelected = selectedMood == opt['label'];
                  return GestureDetector(
                    onTap: () => setState(() => selectedMood = opt['label']!),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.softPurple : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(opt['emoji']!, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            opt['label']!,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? AppTheme.primaryPurple : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // 6. Specific Symptoms & PCOS Markers
            Text(
              'Symptoms & Hormonal Markers',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symptomList.map((symptom) {
                final isSelected = selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        selectedSymptoms.add(symptom);
                      } else {
                        selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                  selectedColor: AppTheme.softBlue,
                  checkmarkColor: AppTheme.primaryBlue,
                  backgroundColor: AppTheme.surfaceLight,
                  labelStyle: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.5) : Colors.transparent,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 7. Supplement / Medication Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.softPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.medication_rounded, color: AppTheme.primaryPurple, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Took supplements / medications?',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: tookSupplements,
                    activeThumbColor: AppTheme.primaryPink,
                    onChanged: (val) => setState(() => tookSupplements = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  final log = DailyLog(
                    date: DateTime.now(),
                    flow: selectedFlow,
                    mood: selectedMood,
                    symptoms: selectedSymptoms,
                    tookSupplements: tookSupplements,
                    painScale: painLevel,
                    clotSize: selectedClotSize,
                    cervicalMucus: selectedCervicalMucus,
                    isRedFlagLogged: isUrgentRedFlag,
                    notes: notesController.text,
                  );
                  widget.onSave(log);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUrgentRedFlag ? const Color(0xFFD32F2F) : AppTheme.primaryPink,
                  elevation: 6,
                  shadowColor: AppTheme.primaryPink.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  isUrgentRedFlag ? 'Save Log & Review Safety' : 'Save Daily Log',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
