import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/cycle_models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class SymptomTrackerScreen extends StatefulWidget {
  final DateTime date;

  const SymptomTrackerScreen({super.key, required this.date});

  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen> {
  final StorageService _storage = StorageService.instance;

  final List<String> _selectedSymptoms = [];
  final List<String> _selectedMoods = [];
  int _waterGlasses = 4;
  double _sleepHours = 7.0;
  final TextEditingController _notesController = TextEditingController();

  static const List<String> physicalSymptomsList = [
    'Cramps',
    'Headache',
    'Acne',
    'Bloating',
    'Fatigue',
    'Pelvic Pain',
    'Backache',
    'Breast Tenderness',
    'Nausea',
  ];

  static const List<String> pcodPcosSymptomsList = [
    'Sugar Cravings',
    'Hirsutism / Facial Hair',
    'Hair Thinning',
    'Weight Fluctuation',
    'Facial Flushing',
    'Insulin Spike Feeling',
  ];

  static const List<String> moodsList = [
    'Happy',
    'Energetic',
    'Sensitive',
    'Anxious',
    'Irritable',
    'Sad',
    'Calm',
    'Stressed',
  ];

  @override
  void initState() {
    super.initState();
    final existingLog = _storage.getSymptomLogForDate(widget.date);
    if (existingLog != null) {
      _selectedSymptoms.addAll(existingLog.symptoms);
      _selectedMoods.addAll(existingLog.moods);
      _waterGlasses = existingLog.waterGlasses;
      _sleepHours = existingLog.sleepHours;
      _notesController.text = existingLog.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(widget.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Daily Symptoms'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                dateStr,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentPurple,
                ),
              ),
              const SizedBox(height: 20),

              // Physical Symptoms
              _buildSectionHeader('Physical Symptoms'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: physicalSymptomsList.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return FilterChip(
                    label: Text(symptom),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryViolet,
                    backgroundColor: Colors.white,
                    labelStyle: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSymptoms.add(symptom);
                        } else {
                          _selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // PCOD / PCOS Special Markers
              _buildSectionHeader('PCOD / PCOS & Hormonal Markers'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pcodPcosSymptomsList.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return FilterChip(
                    label: Text(symptom),
                    selected: isSelected,
                    selectedColor: AppTheme.lutealAmber,
                    backgroundColor: AppTheme.pcodTagBg,
                    labelStyle: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : AppTheme.pcodTagText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSymptoms.add(symptom);
                        } else {
                          _selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Emotional Moods
              _buildSectionHeader('Mood & Emotions'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: moodsList.map((mood) {
                  final isSelected = _selectedMoods.contains(mood);
                  return FilterChip(
                    label: Text(mood),
                    selected: isSelected,
                    selectedColor: AppTheme.accentPurple,
                    backgroundColor: Colors.white,
                    labelStyle: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedMoods.add(mood);
                        } else {
                          _selectedMoods.remove(mood);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Hydration & Sleep Tracker
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.water_drop, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text('Water Intake:', style: GoogleFonts.outfit(fontSize: 15)),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: _waterGlasses > 0
                                    ? () => setState(() => _waterGlasses--)
                                    : null,
                              ),
                              Text(
                                '$_waterGlasses Glasses',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryViolet,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => setState(() => _waterGlasses++),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bedtime, color: AppTheme.accentPurple),
                              const SizedBox(width: 8),
                              Text('Sleep Hours:', style: GoogleFonts.outfit(fontSize: 15)),
                            ],
                          ),
                          Text(
                            '${_sleepHours.toStringAsFixed(1)} hrs',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryViolet,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _sleepHours,
                        min: 3.0,
                        max: 12.0,
                        divisions: 18,
                        activeColor: AppTheme.accentPurple,
                        onChanged: (val) => setState(() => _sleepHours = val),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Notes
              _buildSectionHeader('Personal Notes'),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add notes about food, exercise, energy levels, or symptoms...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.softLavender),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveSymptomLog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Log'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryViolet,
      ),
    );
  }

  Future<void> _saveSymptomLog() async {
    final log = SymptomLog(
      id: widget.date.millisecondsSinceEpoch.toString(),
      date: widget.date,
      symptoms: _selectedSymptoms,
      moods: _selectedMoods,
      waterGlasses: _waterGlasses,
      sleepHours: _sleepHours,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    await _storage.saveSymptomLog(log);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Symptom log saved successfully!')),
      );
      Navigator.pop(context);
    }
  }
}
