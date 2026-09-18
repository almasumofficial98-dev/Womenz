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
  final TextEditingController notesController = TextEditingController();

  final List<Map<String, dynamic>> flowOptions = [
    {'label': 'Light', 'icon': Icons.water_drop_outlined, 'color': Color(0xFFFFB3C1)},
    {'label': 'Medium', 'icon': Icons.water_drop_rounded, 'color': Color(0xFFFF7597)},
    {'label': 'Heavy', 'icon': Icons.opacity_rounded, 'color': Color(0xFFE63946)},
    {'label': 'Spotting', 'icon': Icons.grain_rounded, 'color': Color(0xFFFFC6FF)},
  ];

  final List<Map<String, String>> moodOptions = [
    {'label': 'Happy', 'emoji': '😊'},
    {'label': 'Calm', 'emoji': '😌'},
    {'label': 'Sensitive', 'emoji': '🥺'},
    {'label': 'Energetic', 'emoji': '⚡'},
    {'label': 'Tired', 'emoji': '😴'},
    {'label': 'Anxious', 'emoji': '🌧️'},
  ];

  final List<String> symptomList = [
    'Cramps',
    'Headache',
    'Bloating',
    'Acne',
    'Tender Breasts',
    'Backache',
    'Cravings',
    'Nausea',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialLog != null) {
      selectedFlow = widget.initialLog!.flow ?? 'Medium';
      selectedMood = widget.initialLog!.mood ?? 'Calm';
      selectedSymptoms = List.from(widget.initialLog!.symptoms);
      tookSupplements = widget.initialLog!.tookSupplements;
      notesController.text = widget.initialLog!.notes ?? '';
    } else {
      selectedSymptoms = ['Cramps'];
    }
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log Today\'s Cycle & Symptoms',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Track your health insights',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 1. Flow Intensity Selector
            Text(
              'Period Flow Intensity',
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
                        color: isSelected ? (opt['color'] as Color).withOpacity(0.15) : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? (opt['color'] as Color) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(opt['icon'] as IconData, color: isSelected ? (opt['color'] as Color) : AppTheme.textSecondary, size: 22),
                          const SizedBox(height: 6),
                          Text(
                            opt['label'],
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
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

            // 2. Mood Selector
            Text(
              'How are you feeling today?',
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
                children: moodOptions.map((m) {
                  final isSelected = selectedMood == m['label'];
                  return GestureDetector(
                    onTap: () => setState(() => selectedMood = m['label']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.softPink : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryPink : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(m['emoji']!, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            m['label']!,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
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

            // 3. Physical Symptoms Chips
            Text(
              'Symptoms',
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
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryBlue.withOpacity(0.5) : Colors.transparent,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 4. Supplement / Med Switch Tile
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
                        'Took any supplements / medication?',
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
                    activeColor: AppTheme.primaryPink,
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
                    notes: notesController.text,
                  );
                  widget.onSave(log);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  elevation: 6,
                  shadowColor: AppTheme.primaryPink.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Save Daily Log',
                  style: TextStyle(
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
