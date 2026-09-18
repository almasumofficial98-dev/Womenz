import 'package:flutter/material.dart';
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
import 'symptom_logger_modal.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;
  final UserCycleData cycleData = UserCycleData(userName: 'User');

  @override
  void initState() {
    super.initState();
    _initAppServices();
  }

  Future<void> _initAppServices() async {
    // Initialize Local SQLite DB, Encryption Service & 7-Day Sync Engine
    await LocalDbService.database;
    await EncryptionService.init();
    await GoogleSheetsService.init();
    await PeriodicSyncService.init();

    // Trigger 7-Day periodic sync if due
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SymptomLoggerModal(
        onSave: (log) {
          setState(() {
            cycleData.logs[log.date.toString()] = log;
          });
          LocalDbService.saveDailyLog(log);
          PeriodicSyncService.performPeriodicSync(force: false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Log saved locally to SQLite database!'),
              backgroundColor: AppTheme.primaryPink,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        },
      ),
    );
  }
}
