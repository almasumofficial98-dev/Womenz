import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/cycle_model.dart';
import '../services/google_sheets_service.dart';
import '../services/local_db_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cycle_ring_painter.dart';
import '../widgets/interactive_bouncy_card.dart';
import 'doctor_summary_screen.dart';
import 'screening/red_flags_urgent_care_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserCycleData cycleData;
  final ValueChanged<DailyLog> onLogAdded;
  final VoidCallback onOpenCalendar;

  const HomeScreen({
    super.key,
    required this.cycleData,
    required this.onLogAdded,
    required this.onOpenCalendar,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> pastPeriods = [];
  bool isLoadingPastPeriods = true;

  String todayFlow = 'None'; // 'None', 'Spotting', 'Light', 'Medium', 'Heavy'
  int todayPain = 0; // 0 to 10
  String todayMood = 'Calm';
  String todayMedication = 'None';
  List<String> todaySymptoms = [];
  List<String> selectedSelfCare = [];
  bool dismissedBleedingAlert = false;
  String todayMucus = 'None';
  double? todayBbt;
  bool tookInositolToday = false;

  int lifestyleTab = 0; // 0: Nutrition, 1: Movement, 2: Mind & Care
  bool isTodayLogExpanded = false;

  bool get _hasLoggedToday {
    return todayFlow != 'None' ||
        todayPain > 0 ||
        todaySymptoms.isNotEmpty ||
        todayMucus != 'None' ||
        todayBbt != null ||
        tookInositolToday;
  }

  final List<String> cervicalMucusOptions = ['None', 'Dry', 'Sticky', 'Creamy', 'Egg-White'];
  final List<String> flowOptions = ['None', 'Spotting', 'Light', 'Medium', 'Heavy'];
  final List<Map<String, String>> moodOptions = [
    {'label': 'Calm', 'emoji': '😌'},
    {'label': 'Happy', 'emoji': '🌸'},
    {'label': 'Energetic', 'emoji': '⚡'},
    {'label': 'Sensitive', 'emoji': '🥺'},
    {'label': 'Anxious', 'emoji': '🌧️'},
    {'label': 'Tired', 'emoji': '😴'},
  ];
  final List<String> symptomOptions = [
    'Cramps',
    'Bloating',
    'Headache',
    'Fatigue',
    'Breast Tenderness',
    'Acne',
    'Lower Back Pain',
    'Nausea',
  ];
  final List<String> medicationOptions = [
    'None',
    'Ibuprofen / NSAID',
    'Acetaminophen / Paracetamol',
    'Hormonal Birth Control',
    'Tranexamic Acid',
    'Iron Supplement',
  ];
  final List<String> selfCareOptions = [
    'Heating Pad',
    'Rest / Sleep',
    'Hot Bath',
    'Gentle Walk / Yoga',
    'Herbal Tea',
    'Hydration',
  ];

  @override
  void initState() {
    super.initState();
    _loadPastPeriods();
    _initTodayValues();
  }

  void _initTodayValues() {
    final todayKey = DateTime.now().toString().split(' ')[0];
    for (final entry in widget.cycleData.logs.entries) {
      if (entry.key.startsWith(todayKey)) {
        final log = entry.value;
        todayFlow = log.flow ?? 'None';
        todayPain = log.painScale;
        todayMood = log.mood ?? 'Calm';
        todaySymptoms = List.from(log.symptoms);
        todayMedication = log.medications.isNotEmpty ? log.medications.first : 'None';
        selectedSelfCare = List.from(log.selfCare);
        todayMucus = log.cervicalMucus ?? 'None';
        todayBbt = log.bbt;
        tookInositolToday = log.tookInositol;
        break;
      }
    }
    isTodayLogExpanded = !_hasLoggedToday;
  }

  Future<void> _loadPastPeriods() async {
    final entries = await LocalDbService.getHistoryEntries();
    if (mounted) {
      setState(() {
        pastPeriods = entries;
        isLoadingPastPeriods = false;
      });
    }
  }

  // 1. Log First Day of Period (Present / Recent)
  Future<void> _logFirstDayOfPeriod() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      helpText: 'Select First Day of Period',
    );
    if (picked != null) {
      setState(() {
        widget.cycleData.lastPeriodStartDate = picked;
        widget.cycleData.isPeriodOngoing = true;
        widget.cycleData.currentDay = DateTime.now().difference(picked).inDays + 1;
        todayFlow = 'Medium';
      });

      final log = DailyLog(
        date: picked,
        flow: 'Medium',
        mood: todayMood,
        painScale: todayPain,
        symptoms: todaySymptoms,
        medications: todayMedication != 'None' ? [todayMedication] : [],
        selfCare: selectedSelfCare,
      );
      widget.onLogAdded(log);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Period marked active starting ${DateFormat('MMM d, yyyy').format(picked)}!'),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }

  // Edit Period Start Date
  Future<void> _editPeriodStartDate() async {
    final initialDate = widget.cycleData.lastPeriodStartDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      helpText: 'Edit First Day of Period',
    );
    if (picked != null) {
      setState(() {
        widget.cycleData.lastPeriodStartDate = picked;
        widget.cycleData.currentDay = DateTime.now().difference(picked).inDays + 1;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Period start date updated to ${DateFormat('MMM d, yyyy').format(picked)}'),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }

  // 2. Log Last Day of Period (Ends current period, calculates duration)
  Future<void> _logLastDayOfPeriod() async {
    final defaultStart = widget.cycleData.lastPeriodStartDate ??
        DateTime.now().subtract(const Duration(days: 4));
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: defaultStart,
      lastDate: DateTime.now(),
      helpText: 'Select Last Day of Period',
    );
    if (picked != null) {
      final duration = picked.difference(defaultStart).inDays + 1;
      final id = const Uuid().v4();
      final startStr = DateFormat('yyyy-MM-dd').format(defaultStart);
      final endStr = DateFormat('yyyy-MM-dd').format(picked);

      await LocalDbService.saveHistoryEntry(
        id: id,
        startDate: startStr,
        endDate: endStr,
        durationDays: duration,
        flowIntensity: todayFlow != 'None' ? todayFlow : 'Medium',
        notes: 'Logged from Home',
      );

      // Sync to Supabase
      GoogleSheetsService.syncHistoryEntry(
        startDate: startStr,
        endDate: endStr,
        durationDays: duration,
        flowIntensity: todayFlow != 'None' ? todayFlow : 'Medium',
        notes: 'Logged from Home',
      );

      setState(() {
        widget.cycleData.isPeriodOngoing = false;
        todayFlow = 'None';
      });
      await _loadPastPeriods();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Period marked ended: $duration days logged!'),
            backgroundColor: AppTheme.primaryPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }

  // 3. Save Today's Log (Flow, Spotting, Pain, Mood, Medication, Self-Care)
  void _saveTodayLog() {
    final now = DateTime.now();
    final log = DailyLog(
      date: now,
      flow: todayFlow == 'None' ? null : todayFlow,
      mood: todayMood,
      symptoms: todaySymptoms,
      medications: todayMedication != 'None' ? [todayMedication] : [],
      selfCare: selectedSelfCare,
      painScale: todayPain,
      tookSupplements: todayMedication != 'None' || tookInositolToday,
      cervicalMucus: todayMucus != 'None' ? todayMucus : null,
      bbt: todayBbt,
      tookInositol: tookInositolToday,
      notes: todayMedication != 'None' ? 'Medication: $todayMedication' : null,
    );
    widget.onLogAdded(log);
    setState(() {
      isTodayLogExpanded = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Today\'s menstrual log saved!'),
        backgroundColor: AppTheme.primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildLifestyleTabButton(int index, String label) {
    final isSelected = lifestyleTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => lifestyleTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPill(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  // Delete past history entry
  Future<void> _deleteHistoryEntry(String id) async {
    await LocalDbService.deleteHistoryEntry(id);
    await _loadPastPeriods();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Past cycle entry deleted.'),
          backgroundColor: AppTheme.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  // 4. Add Old Record (Starting Date & End Date ONLY)
  void _showAddPastPeriodDialog() {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 35));
    DateTime endDate = DateTime.now().subtract(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final duration = endDate.difference(startDate).inDays + 1;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.softPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.history_edu_rounded, color: AppTheme.primaryPink, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Log Past Period',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Only the start date and end date are needed for past cycles:',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 18),

                  // Start Date Picker Tile
                  InkWell(
                    onTap: () async {
                      final p = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        helpText: 'Select First Day of Period',
                      );
                      if (p != null) {
                        setDialogState(() {
                          startDate = p;
                          if (endDate.isBefore(startDate)) {
                            endDate = startDate.add(const Duration(days: 4));
                          }
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('First Day (Start Date)', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MMMM d, yyyy').format(startDate),
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryPink),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // End Date Picker Tile
                  InkWell(
                    onTap: () async {
                      final p = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: startDate,
                        lastDate: DateTime.now(),
                        helpText: 'Select Last Day of Period',
                      );
                      if (p != null) {
                        setDialogState(() {
                          endDate = p;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Last Day (End Date)', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MMMM d, yyyy').format(endDate),
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryBlue),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.softPink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Period Duration: $duration Days',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: AppTheme.primaryPink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final id = const Uuid().v4();
                    final startStr = DateFormat('yyyy-MM-dd').format(startDate);
                    final endStr = DateFormat('yyyy-MM-dd').format(endDate);

                    await LocalDbService.saveHistoryEntry(
                      id: id,
                      startDate: startStr,
                      endDate: endStr,
                      durationDays: duration,
                      flowIntensity: 'Medium',
                      notes: 'Past Record',
                    );

                    GoogleSheetsService.syncHistoryEntry(
                      startDate: startStr,
                      endDate: endStr,
                      durationDays: duration,
                      flowIntensity: 'Medium',
                      notes: 'Past Record',
                    );

                    Navigator.pop(ctx);
                    await _loadPastPeriods();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Past period ($startStr to $endStr) saved & synced to Supabase!'),
                          backgroundColor: AppTheme.primaryPink,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final phase = widget.cycleData.currentPhase;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.softPink,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPink.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Good Morning,',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.cycleData.userName,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Discreet Mode Quick-Toggle
                  BouncyTapCard(
                    onTap: () {
                      setState(() {
                        widget.cycleData.isDiscreetMode = !widget.cycleData.isDiscreetMode;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.cycleData.isDiscreetMode
                                ? 'Discreet Mode ON • Sensitive labels masked'
                                : 'Discreet Mode OFF',
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppTheme.primaryPurple,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.cycleData.isDiscreetMode ? AppTheme.softPink : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.softShadow(opacity: 0.05),
                      ),
                      child: Icon(
                        widget.cycleData.isDiscreetMode ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: widget.cycleData.isDiscreetMode ? AppTheme.primaryPink : AppTheme.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Clinical Red Flag Notice (If acute pelvic pain or large clots)
              if (widget.cycleData.hasRecentRedFlags && !widget.cycleData.hasExtendedBleeding) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEF5350), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.cycleData.redFlagReason,
                          style: const TextStyle(fontSize: 12, color: Color(0xFFB71C1C), fontWeight: FontWeight.w600),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RedFlagsUrgentCareScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Review', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],

              // ACOG Extended Bleeding Duration Banner (> 7 Days)
              if (widget.cycleData.hasExtendedBleeding && !dismissedBleedingAlert) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFFE65100), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Bleeding Duration Notice (Day ${widget.cycleData.activePeriodDay})',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFE65100)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your bleeding has continued longer than 7 days (ACOG alert threshold). If this is unusual for you, consider speaking with a healthcare professional.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF5D4037), height: 1.35),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() => dismissedBleedingAlert = true);
                            },
                            child: const Text('Continue Logging', style: TextStyle(color: Color(0xFFE65100), fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DoctorSummaryScreen(cycleData: widget.cycleData)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE65100),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Review Bleeding', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // 2. Status Summary Pill Card (Cycle countdown, Next estimated period date, Phase)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: AppTheme.cardDecoration(
                  color: Colors.white,
                  radius: 22,
                  shadows: AppTheme.softShadow(opacity: 0.05),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildStatusColumn(
                        'Next cycle in',
                        widget.cycleData.daysUntilNextCycleText,
                        AppTheme.primaryPink,
                      ),
                    ),
                    Container(height: 32, width: 1, color: AppTheme.surfaceLight),
                    Expanded(
                      child: _buildStatusColumn(
                        widget.cycleData.isDiscreetMode ? 'Schedule' : 'Estimated Period',
                        widget.cycleData.estimatedNextPeriodText,
                        AppTheme.primaryBlue,
                      ),
                    ),
                    Container(height: 32, width: 1, color: AppTheme.surfaceLight),
                    Expanded(
                      child: _buildStatusColumn(
                        widget.cycleData.isDiscreetMode ? 'Status' : 'Current Phase',
                        widget.cycleData.currentPhasePillText,
                        AppTheme.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Interactive Cycle Ring Hero Widget
              CycleRingWidget(
                currentDay: widget.cycleData.currentDay,
                totalDays: widget.cycleData.cycleLength,
                periodDays: widget.cycleData.periodDuration,
                currentPhase: phase,
                hasData: widget.cycleData.hasLoggedData,
                subtitle: widget.cycleData.centerRingSubtitle,
                onTap: widget.onOpenCalendar,
              ),

              const SizedBox(height: 18),

              // 4. Dynamic Menstruation Controller (Off-Period vs On-Period States)
              Builder(
                builder: (context) {
                  final bool isPeriodActive = widget.cycleData.isPeriodActive;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPeriodActive
                            ? [const Color(0xFFFFF0F3), const Color(0xFFFDE8EC)]
                            : [const Color(0xFFF9FAFB), const Color(0xFFF3F4F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isPeriodActive
                            ? AppTheme.primaryPink.withValues(alpha: 0.4)
                            : AppTheme.surfaceLight,
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isPeriodActive ? AppTheme.primaryPink : Colors.black).withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isPeriodActive ? AppTheme.primaryPink : AppTheme.textMuted,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.cycleData.isDiscreetMode ? Icons.loop_rounded : Icons.water_drop_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  widget.cycleData.isDiscreetMode ? 'Cycle Controller' : 'Menstruation Tracker',
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isPeriodActive ? AppTheme.primaryPink : AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.cycleData.isDiscreetMode
                                    ? (isPeriodActive ? 'Phase Active • Day ${widget.cycleData.activePeriodDay}' : 'Resting')
                                    : (isPeriodActive ? 'Period Active • Day ${widget.cycleData.activePeriodDay}' : 'Off Period'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isPeriodActive ? Colors.white : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // State-dependent content
                        if (isPeriodActive) ...[
                          Row(
                            children: [
                              Text(
                                'Started on: ${DateFormat('MMMM d, yyyy').format(widget.cycleData.lastPeriodStartDate!)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _editPeriodStartDate,
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primaryPink,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _logLastDayOfPeriod,
                              icon: const Icon(Icons.stop_circle_rounded, color: Colors.white, size: 20),
                              label: Text(
                                widget.cycleData.isDiscreetMode ? 'Mark Cycle Ended' : 'Mark Period Ended (Last Day)',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryPurple,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Center(
                            child: Text(
                              'Tap when your bleeding finishes to record duration in history',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ),
                        ] else ...[
                          Text(
                            widget.cycleData.lastPeriodStartDate != null
                                ? 'Last period started: ${DateFormat('MMMM d, yyyy').format(widget.cycleData.lastPeriodStartDate!)}'
                                : 'No period active right now. Tap below when bleeding starts.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _logFirstDayOfPeriod,
                              icon: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 20),
                              label: Text(
                                widget.cycleData.isDiscreetMode ? 'Log Cycle Started' : 'Log Period Started (First Day)',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryPink,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Center(
                            child: Text(
                              'Tap on the day your period bleeding begins',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Contraception / Pill Daily Quick Tracker
              if (widget.cycleData.contraceptionType != ContraceptionType.none) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: AppTheme.softShadow(opacity: 0.04),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: widget.cycleData.isPillTakenToday
                              ? const Color(0xFFE8F5E9)
                              : AppTheme.softPink,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.medication_rounded,
                          size: 20,
                          color: widget.cycleData.isPillTakenToday
                              ? const Color(0xFF2E7D32)
                              : AppTheme.primaryPink,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.cycleData.contraceptionType.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              widget.cycleData.isPillTakenToday
                                  ? 'Dose logged for today'
                                  : 'Daily dose pending',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: widget.cycleData.isPillTakenToday
                                    ? const Color(0xFF2E7D32)
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: widget.cycleData.isPillTakenToday,
                        activeThumbColor: AppTheme.primaryPink,
                        onChanged: (val) {
                          setState(() {
                            widget.cycleData.isPillTakenToday = val;
                          });
                          LocalDbService.saveUserProfile(widget.cycleData);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Phase Lifestyle, Nutrition & Workout Guidance
              Builder(
                builder: (context) {
                  final guide = PhaseLifestyleGuide.getForPhase(widget.cycleData.currentPhase);
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.softShadow(opacity: 0.05),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.cycleData.currentPhase.primaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.spa_outlined,
                                color: widget.cycleData.currentPhase.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${guide.phaseName} Lifestyle Focus',
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    guide.energyInsight,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 3-Tab Segment Selector
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              _buildLifestyleTabButton(0, '🥗 Nutrition'),
                              _buildLifestyleTabButton(1, '🏃 Movement'),
                              _buildLifestyleTabButton(2, '💡 Mind & Care'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Tab Content
                        if (lifestyleTab == 0) ...[
                          const Text(
                            'Recommended Nutrition',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          for (final item in guide.nutritionFocus)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: AppTheme.primaryPink, fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: Text(item, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3)),
                                  ),
                                ],
                              ),
                            ),
                        ] else if (lifestyleTab == 1) ...[
                          const Text(
                            'Movement & Energy Pacing',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          for (final item in guide.movementAdvice)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: Color(0xFF7C8FFD), fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: Text(item, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3)),
                                  ),
                                ],
                              ),
                            ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7F9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFFE4EB)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppTheme.primaryPink),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    guide.selfCareTip,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.35),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              // 5. TODAY'S MENSTRUAL LOG (Ultra-Fast Daily Logging with Smart Compact Mode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(
                  color: Colors.white,
                  radius: 26,
                  shadows: AppTheme.softShadow(opacity: 0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.cycleData.isDiscreetMode ? 'Today\'s Care Log' : 'Today\'s Menstrual Log',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (_hasLoggedToday) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF2E7D32)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Logged',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            if (_hasLoggedToday && isTodayLogExpanded)
                              GestureDetector(
                                onTap: () => setState(() => isTodayLogExpanded = false),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Done',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryPink),
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                DateFormat('EEE, MMM d').format(DateTime.now()),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (_hasLoggedToday && !isTodayLogExpanded) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (todayFlow != 'None')
                            _buildSummaryPill('$todayFlow Flow', const Color(0xFFFF7597), const Color(0xFFFFF0F3)),
                          _buildSummaryPill(
                            todayPain == 0 ? 'Pain-Free (0/10)' : 'Pain: $todayPain/10',
                            todayPain >= 7 ? Colors.red : AppTheme.primaryPink,
                            AppTheme.surfaceLight,
                          ),
                          _buildSummaryPill(
                            todayMood,
                            AppTheme.primaryPurple,
                            const Color(0xFFF3E8FF),
                          ),
                          if (todayMucus != 'None')
                            _buildSummaryPill('$todayMucus Fluid', const Color(0xFF7C8FFD), const Color(0xFFEEF2FF)),
                          if (todayBbt != null)
                            _buildSummaryPill('${todayBbt!.toStringAsFixed(1)}°C BBT', const Color(0xFFFF9E6D), const Color(0xFFFFF4ED)),
                          if (tookInositolToday)
                            _buildSummaryPill('Inositol Taken', const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
                          for (final sym in todaySymptoms.take(2))
                            _buildSummaryPill(sym, AppTheme.textSecondary, AppTheme.surfaceLight),
                          if (todaySymptoms.length > 2)
                            _buildSummaryPill('+${todaySymptoms.length - 2} more', AppTheme.textSecondary, AppTheme.surfaceLight),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => isTodayLogExpanded = true),
                          icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.primaryPink),
                          label: const Text(
                            'Edit Today\'s Check-in',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryPink,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFFD5E0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),

                      // A. Flow & Spotting
                      Text(
                        widget.cycleData.isDiscreetMode ? 'Intensity & Level' : 'Flow & Spotting',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: flowOptions.map((flow) {
                          final isSelected = todayFlow == flow;
                          return ChoiceChip(
                            label: Text(flow),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryPink,
                            backgroundColor: AppTheme.surfaceLight,
                            labelStyle: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppTheme.textPrimary,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            onSelected: (val) {
                              if (val) setState(() => todayFlow = flow);
                            },
                          );
                        }).toList(),
                      ),
                      if (todayFlow == 'Spotting') ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9E6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFD54F)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: Color(0xFFF57F17), size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Intermenstrual spotting can occur for various hormonal or cervical reasons. Track if recurring.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF5D4037)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      // B. Pain Level (0 to 10 - Continuum)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.cycleData.isDiscreetMode ? 'Discomfort Scale' : 'Pain Level',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                          ),
                          Text(
                            todayPain == 0
                                ? '0 - None'
                                : todayPain <= 3
                                    ? '$todayPain - Mild Pain'
                                    : todayPain <= 7
                                        ? '$todayPain - Moderate Pain'
                                        : '$todayPain - Severe Pain',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: todayPain >= 8 ? Colors.red : (todayPain >= 4 ? Colors.deepOrange : AppTheme.primaryPink),
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: todayPain >= 8 ? Colors.red : (todayPain >= 4 ? Colors.deepOrange : AppTheme.primaryPink),
                          thumbColor: todayPain >= 8 ? Colors.red : (todayPain >= 4 ? Colors.deepOrange : AppTheme.primaryPink),
                          inactiveTrackColor: AppTheme.softPink,
                        ),
                        child: Slider(
                          value: todayPain.toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          onChanged: (val) {
                            setState(() => todayPain = val.toInt());
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // C. Symptoms Multi-Select
                      const Text('Symptoms', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: symptomOptions.map((sym) {
                          final isSelected = todaySymptoms.contains(sym);
                          return FilterChip(
                            label: Text(sym),
                            selected: isSelected,
                            selectedColor: AppTheme.softPink,
                            checkmarkColor: AppTheme.primaryPink,
                            backgroundColor: AppTheme.surfaceLight,
                            labelStyle: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppTheme.primaryPink : AppTheme.textPrimary,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  todaySymptoms.add(sym);
                                } else {
                                  todaySymptoms.remove(sym);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // D. Mood Selection
                      const Text('Mood', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: moodOptions.map((mood) {
                          final isSelected = todayMood == mood['label'];
                          return ChoiceChip(
                            label: Text('${mood['emoji']} ${mood['label']}'),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryPurple,
                            backgroundColor: AppTheme.surfaceLight,
                            labelStyle: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppTheme.textPrimary,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            onSelected: (val) {
                              if (val) setState(() => todayMood = mood['label']!);
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // E. Medication (Separated from Self-Care)
                      const Text('Medications Taken', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: medicationOptions.map((med) {
                          final isSelected = todayMedication == med;
                          return ChoiceChip(
                            label: Text(med),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryBlue,
                            backgroundColor: AppTheme.surfaceLight,
                            labelStyle: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppTheme.textPrimary,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            onSelected: (val) {
                              if (val) setState(() => todayMedication = med);
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // F. Non-Pharmacological Self-Care
                      const Text('Self-Care & Comfort Measures', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selfCareOptions.map((sc) {
                          final isSelected = selectedSelfCare.contains(sc);
                          return FilterChip(
                            label: Text(sc),
                            selected: isSelected,
                            selectedColor: const Color(0xFFE8F5E9),
                            checkmarkColor: const Color(0xFF2E7D32),
                            backgroundColor: AppTheme.surfaceLight,
                            labelStyle: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF2E7D32) : AppTheme.textPrimary,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  selectedSelfCare.add(sc);
                                } else {
                                  selectedSelfCare.remove(sc);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // G. Cervical Mucus & Sympto-Thermal Observation
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Cervical Mucus & Fluid', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: cervicalMucusOptions.map((mucus) {
                                    final isSelected = todayMucus == mucus;
                                    return ChoiceChip(
                                      label: Text(mucus),
                                      selected: isSelected,
                                      selectedColor: const Color(0xFF7C8FFD),
                                      backgroundColor: AppTheme.surfaceLight,
                                      labelStyle: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                                      ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      onSelected: (val) {
                                        if (val) setState(() => todayMucus = mucus);
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 90,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('BBT (°C)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: todayBbt != null ? todayBbt!.toStringAsFixed(1) : '',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  decoration: InputDecoration(
                                    hintText: '36.6',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onChanged: (val) {
                                    final p = double.tryParse(val.trim());
                                    todayBbt = p;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // H. Metabolic & PCOS Support
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PCOS Metabolic Care (Inositol)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                              Text('Myo-inositol / D-chiro supplement', style: TextStyle(fontSize: 10.5, color: AppTheme.textSecondary)),
                            ],
                          ),
                          Switch.adaptive(
                            value: tookInositolToday,
                            activeThumbColor: AppTheme.primaryPink,
                            onChanged: (val) => setState(() => tookInositolToday = val),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Save Today Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveTodayLog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPink,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            'Save Today\'s Log',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 6. PAST PERIODS (Old Records - Start Date & End Date Only)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(
                  color: Colors.white,
                  radius: 26,
                  shadows: AppTheme.softShadow(opacity: 0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.cycleData.isDiscreetMode ? 'Past Cycle History' : 'Past Periods History',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.cycleData.isDiscreetMode
                                  ? 'Start and end date only for past records'
                                  : 'Only start & end date required for past cycles',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _showAddPastPeriodDialog,
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.softPink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_rounded, color: AppTheme.primaryPink, size: 20),
                          ),
                          tooltip: 'Add Past Period',
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Pattern Summary Pill
                    Builder(
                      builder: (context) {
                        int totalBleed = 0;
                        for (final p in pastPeriods) {
                          totalBleed += int.tryParse(p['durationDays']?.toString() ?? '') ?? 5;
                        }
                        final double avgBleed = pastPeriods.isNotEmpty
                            ? totalBleed / pastPeriods.length
                            : widget.cycleData.periodDuration.toDouble();

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.insights_rounded, size: 14, color: AppTheme.primaryPink),
                              const SizedBox(width: 6),
                              Text(
                                'Cycle Avg: ${widget.cycleData.cycleLength}d • Menses Avg: ${avgBleed.toStringAsFixed(1)}d',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    if (isLoadingPastPeriods)
                      const Center(child: CircularProgressIndicator(color: AppTheme.primaryPink))
                    else if (pastPeriods.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: AppTheme.textSecondary, size: 28),
                            const SizedBox(height: 6),
                            const Text(
                              'No past period records logged yet',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Tap "+ Log Past Period" to quickly add past start and end dates.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: _showAddPastPeriodDialog,
                              icon: const Icon(Icons.add_rounded, size: 16, color: AppTheme.primaryPink),
                              label: const Text('Add Past Period', style: TextStyle(color: AppTheme.primaryPink, fontSize: 12, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.primaryPink),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pastPeriods.length.clamp(0, 5),
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final p = pastPeriods[index];
                          final id = p['id']?.toString() ?? '';
                          final start = p['startDate']?.toString() ?? '--';
                          final end = p['endDate']?.toString() ?? '--';
                          final days = p['durationDays']?.toString() ?? '5';

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryPink, size: 18),
                                    const SizedBox(width: 10),
                                    Text(
                                      '$start  →  $end',
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.softPink,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$days days',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primaryPink,
                                        ),
                                      ),
                                    ),
                                    if (id.isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textMuted, size: 18),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Delete record',
                                        onPressed: () => _deleteHistoryEntry(id),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 12),

                    // Quick button to add past period
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showAddPastPeriodDialog,
                        icon: const Icon(Icons.add_rounded, color: AppTheme.primaryPink, size: 18),
                        label: Text(
                          widget.cycleData.isDiscreetMode
                              ? '+ Log Past Cycle (Start & End Date Only)'
                              : '+ Log Past Period (Start & End Date Only)',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryPink, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 7. Clinical Report & Details Footer Link
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorSummaryScreen(cycleData: widget.cycleData)),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.softBlue,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.medical_services_rounded, color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'View Doctor Clinical Summary & Cycle Analysis',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryBlue),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusColumn(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
