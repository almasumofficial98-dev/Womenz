import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/cycle_model.dart';
import '../services/encryption_service.dart';
import '../services/google_sheets_service.dart';
import '../services/local_db_service.dart';
import '../services/periodic_sync_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'pin_lock_screen.dart';
import '../core/privacy/secure_storage_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;
  final UserCycleData cycleData = UserCycleData(userName: 'User');
  bool isAppLocked = false;
  bool isPinCheckDone = false;

  @override
  void initState() {
    super.initState();
    _checkPinLock();
    _initAppServices();
  }

  Future<void> _checkPinLock() async {
    final pinEnabled = await SecureStorageService.isPinEnabled();
    if (mounted) {
      setState(() {
        isAppLocked = pinEnabled;
        isPinCheckDone = true;
      });
    }
  }

  Future<void> _initAppServices() async {
    // Initialize Local SQLite DB, Encryption Service, Supabase & 7-Day Sync Engine
    await LocalDbService.database;
    await EncryptionService.init();
    await GoogleSheetsService.init();
    await PeriodicSyncService.init();

    // Fill and populate data from Supabase Cloud
    try {
      final remoteDailyLogs = await GoogleSheetsService.fetchDailyLogs();
      for (final item in remoteDailyLogs) {
        final dateStr = item['log_date']?.toString();
        if (dateStr != null) {
          final date = DateTime.tryParse(dateStr);
          if (date != null) {
            final log = DailyLog(
              date: date,
              flow: item['flow']?.toString() ?? 'Medium',
              mood: (item['moods'] is List && (item['moods'] as List).isNotEmpty)
                  ? item['moods'][0].toString()
                  : 'Calm',
              symptoms: item['symptoms'] is List ? List<String>.from(item['symptoms']) : [],
              notes: item['notes']?.toString(),
            );
            cycleData.logs[date.toString()] = log;
            await LocalDbService.saveDailyLog(log);
          }
        }
      }

      final remoteHistory = await GoogleSheetsService.fetchHistoryEntries();
      for (final item in remoteHistory) {
        final startStr = item['start_date']?.toString();
        if (startStr != null) {
          final sDate = DateTime.tryParse(startStr);
          if (sDate != null) {
            if (cycleData.lastPeriodStartDate == null || sDate.isAfter(cycleData.lastPeriodStartDate!)) {
              cycleData.lastPeriodStartDate = sDate;
              cycleData.currentDay = DateTime.now().difference(sDate).inDays + 1;
            }
          }
        }
      }
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Supabase initial pull notice: $e');
    }

    // Trigger periodic sync if due
    PeriodicSyncService.performPeriodicSync(force: false);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        cycleData: cycleData,
        onLogAdded: (log) {
          setState(() {
            cycleData.logs[log.date.toString()] = log;
          });
          LocalDbService.saveDailyLog(log);
          PeriodicSyncService.performPeriodicSync(force: false);
        },
        onOpenCalendar: () {
          setState(() {
            currentIndex = 1;
          });
        },
      ),
      CalendarScreen(
        cycleData: cycleData,
        onLogAdded: (log) {
          setState(() {
            cycleData.logs[log.date.toString()] = log;
          });
          LocalDbService.saveDailyLog(log);
          PeriodicSyncService.performPeriodicSync(force: false);
        },
      ),
      StatsScreen(
        cycleData: cycleData,
      ),
      SettingsScreen(
        cycleData: cycleData,
        onUpdateCycleData: (newData) {
          setState(() {});
          LocalDbService.saveUserProfile(newData);
        },
      ),
    ];

    if (isAppLocked) {
      return PinLockScreen(
        onUnlocked: () {
          setState(() => isAppLocked = false);
        },
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      // Custom Floating Soft Neumorphic Pill Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF90A4AE).withOpacity(0.12),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Home'),
            _buildNavItem(1, Icons.calendar_month_rounded, 'Calendar'),
            
            // Central Floating '+' Quick Log Button
            GestureDetector(
              onTap: () => _showQuickLogModal(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7597), Color(0xFFFF94A8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPink.withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),

            _buildNavItem(2, Icons.bar_chart_rounded, 'Stats'),
            _buildNavItem(3, Icons.person_rounded, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.softPink : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryPink : AppTheme.textMuted,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryPink,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showQuickLogModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                cycleData.isDiscreetMode ? 'Quick Cycle Action' : 'Menstrual Health Actions',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Log how you feel right now or add past cycle dates',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Option 1: Log Today's Menstrual Health
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _showTodayLogSheet(context);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.softPink,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryPink.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryPink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Log Today\'s Symptoms (Present)',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Flow, spotting, pain level (0-10), mood & medication',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primaryPink, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Option 2: Log Past Period (Start & End Date ONLY)
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _showPastPeriodSheet(context);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.softPurple,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.history_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Log Past Period (Old Records)',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Start date & end date only (no daily questions)',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primaryPurple, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showTodayLogSheet(BuildContext context) {
    String todayFlow = 'Medium';
    int todayPain = 0;
    String todayMood = 'Calm';
    String todayMed = 'None';
    List<String> selSymptoms = ['Cramps'];
    List<String> selSelfCare = ['Heating Pad'];

    final flowOptions = ['None', 'Spotting', 'Light', 'Medium', 'Heavy'];
    final moodOptions = ['Calm', 'Happy', 'Energetic', 'Sensitive', 'Anxious', 'Tired'];
    final medOptions = [
      'None',
      'Ibuprofen / NSAID',
      'Acetaminophen / Paracetamol',
      'Hormonal Birth Control',
      'Tranexamic Acid',
      'Iron Supplement',
    ];
    final selfCareOptions = [
      'Heating Pad',
      'Rest / Sleep',
      'Hot Bath',
      'Gentle Walk / Yoga',
      'Herbal Tea',
      'Hydration',
    ];
    final symptomOptions = [
      'Cramps',
      'Bloating',
      'Headache',
      'Fatigue',
      'Breast Tenderness',
      'Acne',
      'Lower Back Pain',
      'Nausea',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.textMuted.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      cycleData.isDiscreetMode ? 'Care & Symptoms Log' : 'Today\'s Menstrual Log',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Present day entry • Quick 5-second check-in', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),

                    // Flow / Spotting
                    const Text('Flow & Bleeding', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: flowOptions.map((f) {
                        final isSel = todayFlow == f;
                        return ChoiceChip(
                          label: Text(f),
                          selected: isSel,
                          selectedColor: AppTheme.primaryPink,
                          backgroundColor: AppTheme.surfaceLight,
                          labelStyle: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? Colors.white : AppTheme.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          onSelected: (val) {
                            if (val) setSheetState(() => todayFlow = f);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Pain Level (0 to 10)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pain Level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        Text(
                          todayPain == 0
                              ? '0 - None'
                              : todayPain <= 3
                                  ? '$todayPain - Mild'
                                  : todayPain <= 7
                                      ? '$todayPain - Moderate'
                                      : '$todayPain - Severe',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: todayPain >= 8 ? Colors.red : AppTheme.primaryPink,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: todayPain >= 8 ? Colors.red : AppTheme.primaryPink,
                        thumbColor: todayPain >= 8 ? Colors.red : AppTheme.primaryPink,
                        inactiveTrackColor: AppTheme.softPink,
                      ),
                      child: Slider(
                        value: todayPain.toDouble(),
                        min: 0,
                        max: 10,
                        divisions: 10,
                        onChanged: (val) => setSheetState(() => todayPain = val.toInt()),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Symptoms
                    const Text('Symptoms', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: symptomOptions.map((sym) {
                        final isSel = selSymptoms.contains(sym);
                        return FilterChip(
                          label: Text(sym),
                          selected: isSel,
                          selectedColor: AppTheme.softPink,
                          checkmarkColor: AppTheme.primaryPink,
                          backgroundColor: AppTheme.surfaceLight,
                          labelStyle: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? AppTheme.primaryPink : AppTheme.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          onSelected: (val) {
                            setSheetState(() {
                              if (val) {
                                selSymptoms.add(sym);
                              } else {
                                selSymptoms.remove(sym);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    // Mood
                    const Text('Mood', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: moodOptions.map((m) {
                        final isSel = todayMood == m;
                        return ChoiceChip(
                          label: Text(m),
                          selected: isSel,
                          selectedColor: AppTheme.primaryPurple,
                          backgroundColor: AppTheme.surfaceLight,
                          labelStyle: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? Colors.white : AppTheme.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          onSelected: (val) {
                            if (val) setSheetState(() => todayMood = m);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Medication
                    const Text('Medication Taken', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: medOptions.map((med) {
                        final isSel = todayMed == med;
                        return ChoiceChip(
                          label: Text(med),
                          selected: isSel,
                          selectedColor: AppTheme.primaryBlue,
                          backgroundColor: AppTheme.surfaceLight,
                          labelStyle: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? Colors.white : AppTheme.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          onSelected: (val) {
                            if (val) setSheetState(() => todayMed = med);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Self-Care
                    const Text('Self-Care & Comfort', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selfCareOptions.map((sc) {
                        final isSel = selSelfCare.contains(sc);
                        return FilterChip(
                          label: Text(sc),
                          selected: isSel,
                          selectedColor: const Color(0xFFE8F5E9),
                          checkmarkColor: const Color(0xFF2E7D32),
                          backgroundColor: AppTheme.surfaceLight,
                          labelStyle: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? const Color(0xFF2E7D32) : AppTheme.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          onSelected: (val) {
                            setSheetState(() {
                              if (val) {
                                selSelfCare.add(sc);
                              } else {
                                selSelfCare.remove(sc);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final now = DateTime.now();
                          final log = DailyLog(
                            date: now,
                            flow: todayFlow == 'None' ? null : todayFlow,
                            mood: todayMood,
                            symptoms: selSymptoms,
                            medications: todayMed != 'None' ? [todayMed] : [],
                            selfCare: selSelfCare,
                            painScale: todayPain,
                            tookSupplements: todayMed != 'None',
                            notes: todayMed != 'None' ? 'Medication: $todayMed' : null,
                          );

                          setState(() {
                            cycleData.logs[log.date.toString()] = log;
                          });
                          LocalDbService.saveDailyLog(log);
                          PeriodicSyncService.performPeriodicSync(force: false);
                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Today\'s log saved!'),
                              backgroundColor: AppTheme.primaryPink,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPink,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Save Today\'s Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPastPeriodSheet(BuildContext context) {
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
                      color: AppTheme.softPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.history_edu_rounded, color: AppTheme.primaryPurple, size: 22),
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date (First Day)', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MMM dd, yyyy').format(startDate),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryPink),
                              ),
                            ],
                          ),
                          const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryPink, size: 18),
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
                      );
                      if (p != null) {
                        setDialogState(() => endDate = p);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Date (Last Day)', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MMM dd, yyyy').format(endDate),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryPurple),
                              ),
                            ],
                          ),
                          const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryPurple, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Computed Duration Pill
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.softPink,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Total Period Duration: $duration Days',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryPink),
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
                    final startStr = DateFormat('yyyy-MM-dd').format(startDate);
                    final endStr = DateFormat('yyyy-MM-dd').format(endDate);
                    final id = const Uuid().v4();

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Past period ($startStr to $endStr) saved & synced to Supabase!'),
                        backgroundColor: AppTheme.primaryPink,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    );
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
}
