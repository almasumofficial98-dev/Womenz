import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cycle_model.dart';
import '../services/google_sheets_service.dart';
import '../services/periodic_sync_service.dart';
import '../theme/app_theme.dart';
import '../models/user_profile.dart';
import '../widgets/restore_backup_dialog.dart';
import 'cycle_history_screen.dart';
import 'settings/privacy_security_screen.dart';

class SettingsScreen extends StatefulWidget {
  final UserCycleData cycleData;
  final ValueChanged<UserCycleData> onUpdateCycleData;

  const SettingsScreen({
    super.key,
    required this.cycleData,
    required this.onUpdateCycleData,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController nameController;
  late TextEditingController webhookUrlController;
  late double cycleLengthVal;
  late double periodDurationVal;
  bool isSyncing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.cycleData.userName);
    webhookUrlController = TextEditingController(text: GoogleSheetsService.webhookUrl);
    cycleLengthVal = widget.cycleData.cycleLength.toDouble();
    periodDurationVal = widget.cycleData.periodDuration.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final userId = GoogleSheetsService.userId;
    final daysUntilSync = PeriodicSyncService.daysUntilNextSync;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile & Settings',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(
                  color: Colors.white,
                  radius: 26,
                  shadows: AppTheme.softShadow(opacity: 0.05),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.softPink,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: nameController,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              labelText: 'Your Name',
                              labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                            onChanged: (val) {
                              widget.cycleData.userName = val.isEmpty ? 'User' : val;
                              widget.onUpdateCycleData(widget.cycleData);
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'User ID: $userId',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Local-First + 7-Day Encrypted Sync Card
              Container(
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
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppTheme.softBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.security_rounded, color: AppTheme.primaryBlue, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Local-First & Encrypted Sync',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'AES-256',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Privacy Shield Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded, size: 18, color: AppTheme.primaryPink),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your health data is stored locally in SQLite and encrypted before leaving your phone.',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                color: AppTheme.textPrimary,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 7-Day Sync Status Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '7-Day Auto Cloud Sync',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          PeriodicSyncService.isSyncDue ? 'Sync Due Now' : 'Next in $daysUntilSync days',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: PeriodicSyncService.isSyncDue ? AppTheme.primaryPink : AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Actions Row (Sync Now + Restore Backup)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isSyncing
                                ? null
                                : () async {
                                    setState(() => isSyncing = true);
                                    final success = await PeriodicSyncService.performPeriodicSync(force: true);
                                    setState(() => isSyncing = false);

                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(success ? 'AES-256 Encrypted 7-day backup uploaded!' : 'Sync attempted.'),
                                          backgroundColor: success ? const Color(0xFF0F9D58) : AppTheme.primaryPink,
                                        ),
                                      );
                                    }
                                  },
                            icon: isSyncing
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 16),
                            label: Text(
                              isSyncing ? 'Syncing...' : 'Sync Now',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const RestoreBackupDialog(),
                            );
                          },
                          icon: const Icon(Icons.restore_rounded, size: 16, color: AppTheme.textPrimary),
                          label: Text(
                            'Restore',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.textMuted),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Cycle History Quick Link
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CycleHistoryScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.cardDecoration(
                    color: Colors.white,
                    radius: 24,
                    shadows: AppTheme.softShadow(opacity: 0.04),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppTheme.softPink,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.history_edu_rounded, color: AppTheme.primaryPink, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Manage Cycle History',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Fill past cycle entries & sync to database',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Privacy & Security Controls Link
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivacySecurityScreen(
                        profile: UserProfile(userName: widget.cycleData.userName),
                        onUpdateProfile: (p) {},
                        onDeleteAllData: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All local health records deleted')),
                          );
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.cardDecoration(
                    color: Colors.white,
                    radius: 24,
                    shadows: AppTheme.softShadow(opacity: 0.04),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppTheme.softBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shield_rounded, color: AppTheme.primaryBlue, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Privacy & App Lock',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'PIN Lock, Data Export & Deletion',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Google Sheets Endpoint Configuration Card
              Text(
                'Cloud Backup Endpoint Config',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(
                  color: Colors.white,
                  radius: 26,
                  shadows: AppTheme.softShadow(opacity: 0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Sheet ID: 1lW1-0qdECQZFOl1knroVzJzkmzYLO9A_tV1BIxXbsAE',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F9D58),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: webhookUrlController,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Backup Webhook URL',
                        labelStyle: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (val) {
                        GoogleSheetsService.setWebhookUrl(val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Cycle Parameters Slider Card
              Text(
                'Cycle Parameters',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(
                  color: Colors.white,
                  radius: 26,
                  shadows: AppTheme.softShadow(opacity: 0.05),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Average Cycle Length',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${cycleLengthVal.toInt()} Days',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppTheme.primaryPink,
                        thumbColor: AppTheme.primaryPink,
                        inactiveTrackColor: AppTheme.softPink,
                      ),
                      child: Slider(
                        value: cycleLengthVal,
                        min: 21,
                        max: 35,
                        divisions: 14,
                        onChanged: (val) {
                          setState(() => cycleLengthVal = val);
                          widget.cycleData.cycleLength = val.toInt();
                          widget.onUpdateCycleData(widget.cycleData);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Period Duration',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${periodDurationVal.toInt()} Days',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppTheme.primaryBlue,
                        thumbColor: AppTheme.primaryBlue,
                        inactiveTrackColor: AppTheme.softBlue,
                      ),
                      child: Slider(
                        value: periodDurationVal,
                        min: 3,
                        max: 10,
                        divisions: 7,
                        onChanged: (val) {
                          setState(() => periodDurationVal = val);
                          widget.cycleData.periodDuration = val.toInt();
                          widget.onUpdateCycleData(widget.cycleData);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
