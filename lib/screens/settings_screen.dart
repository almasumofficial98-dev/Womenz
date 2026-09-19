import 'package:flutter/material.dart';
import '../models/cycle_model.dart';
import '../services/google_sheets_service.dart';
import '../services/periodic_sync_service.dart';
import '../theme/app_theme.dart';
import '../models/user_profile.dart';
import '../services/local_db_service.dart';
import '../widgets/restore_backup_dialog.dart';
import 'cycle_history_screen.dart';
import 'settings/privacy_security_screen.dart';
import 'doctor_summary_screen.dart';

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
                                    final messenger = ScaffoldMessenger.of(context);
                                    setState(() => isSyncing = true);
                                    final success = await PeriodicSyncService.performPeriodicSync(force: true);
                                    setState(() => isSyncing = false);

                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(success ? 'AES-256 Encrypted 7-day backup uploaded!' : 'Sync attempted.'),
                                        backgroundColor: success ? const Color(0xFF0F9D58) : AppTheme.primaryPink,
                                      ),
                                    );
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

              const SizedBox(height: 14),

              // Discreet Privacy Mode Switch Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: AppTheme.cardDecoration(
                  color: Colors.white,
                  radius: 24,
                  shadows: AppTheme.softShadow(opacity: 0.04),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.cycleData.isDiscreetMode ? AppTheme.softPink : AppTheme.surfaceLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.cycleData.isDiscreetMode ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: widget.cycleData.isDiscreetMode ? AppTheme.primaryPink : AppTheme.textPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Discreet Privacy Mode',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Mask sensitive labels (period, fertility) for safe public viewing',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      activeTrackColor: AppTheme.softPink,
                      activeThumbColor: AppTheme.primaryPink,
                      value: widget.cycleData.isDiscreetMode,
                      onChanged: (val) {
                        setState(() {
                          widget.cycleData.isDiscreetMode = val;
                        });
                        widget.onUpdateCycleData(widget.cycleData);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Cycle Health Focus / Goal Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(
                  color: Colors.white,
                  radius: 24,
                  shadows: AppTheme.softShadow(opacity: 0.04),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppTheme.softLavender,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.tune_rounded, color: AppTheme.primaryPurple, size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cycle Health Focus',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Personalize predictions for your condition',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildGoalChip('Track & Wellness', 'track', 'regular'),
                        _buildGoalChip('PCOS / Irregular', 'pcos', 'pcod'),
                        _buildGoalChip('Conception (TTC)', 'ttc', 'regular'),
                        _buildGoalChip('Endometriosis Care', 'track', 'endometriosis'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Reproductive Health Stage Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(
                  color: Colors.white,
                  radius: 24,
                  shadows: AppTheme.softShadow(opacity: 0.04),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF0F3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite_rounded, color: AppTheme.primaryPink, size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reproductive Health Stage',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Adapts predictions and advice to your life stage',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildHealthStageChip('🌸 Natural Cycle', 'reproductive', false),
                        _buildHealthStageChip('🌿 PCOS / PCOD', 'pcod', false),
                        _buildHealthStageChip('🌅 Perimenopause', 'perimenopause', false),
                        _buildHealthStageChip('🤰 Pregnancy Mode', 'pregnancy', true),
                      ],
                    ),
                    if (widget.cycleData.isPregnancyPaused) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDCFCE7)),
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
                                    const Text(
                                      'Pregnancy Pause Active',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF166534),
                                      ),
                                    ),
                                    Text(
                                      widget.cycleData.pregnancyWeeks != null
                                          ? 'Estimated Week ${widget.cycleData.pregnancyWeeks} Gestation'
                                          : 'Tap to record LMP / Conception date',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF15803D)),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: _pickPregnancyLmpDate,
                                  icon: const Icon(Icons.edit_calendar_rounded, size: 16, color: Color(0xFF166534)),
                                  label: const Text(
                                    'Set LMP',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Menstrual countdowns are paused. All prior logs are safely preserved.',
                              style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Contraception & Birth Control Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(
                  color: Colors.white,
                  radius: 24,
                  shadows: AppTheme.softShadow(opacity: 0.04),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.medication_liquid_rounded, color: Color(0xFF4F46E5), size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contraception & Birth Control',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Adjusts cycle analysis for hormonal suppression',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ContraceptionType.values.map((type) {
                        final isSelected = widget.cycleData.contraceptionType == type;
                        return ChoiceChip(
                          label: Text(type.displayName),
                          selected: isSelected,
                          selectedColor: const Color(0xFF4F46E5),
                          backgroundColor: AppTheme.surfaceLight,
                          labelStyle: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                widget.cycleData.contraceptionType = type;
                              });
                              LocalDbService.saveUserProfile(widget.cycleData);
                              widget.onUpdateCycleData(widget.cycleData);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    if (widget.cycleData.contraceptionType.isHormonalSuppression) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'With hormonal suppression (pill/patch/ring), bleeding during the hormone-free interval is withdrawal bleeding, not physiological ovulatory menstruation.',
                                style: TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // OB-GYN Doctor Clinical Summary Link Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorSummaryScreen(cycleData: widget.cycleData),
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
                              child: const Icon(Icons.medical_services_rounded, color: AppTheme.primaryBlue, size: 22),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'OB-GYN Clinical Report',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Rotterdam PCOS checklist, pain audit & export',
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

              // Supabase Cloud Database Configuration Card
              Text(
                'Supabase Cloud Database Config',
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cloud_done_rounded, color: Color(0xFF2E7D32), size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Supabase Project: vvzwixqkzuypzymqlpvv',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Endpoint: https://vvzwixqkzuypzymqlpvv.supabase.co',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Active Tables: profiles, cycle_logs, symptom_logs',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryPurple,
                      ),
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

  Widget _buildGoalChip(String label, String intent, String condition) {
    final isSelected = widget.cycleData.userIntent == intent &&
        widget.cycleData.healthCondition == condition;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryPurple,
      backgroundColor: AppTheme.surfaceLight,
      labelStyle: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppTheme.textPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            widget.cycleData.userIntent = intent;
            widget.cycleData.healthCondition = condition;
          });
          widget.onUpdateCycleData(widget.cycleData);
        }
      },
    );
  }

  Widget _buildHealthStageChip(String label, String stage, bool isPregnancy) {
    final isSelected = isPregnancy
        ? widget.cycleData.isPregnancyPaused
        : (!widget.cycleData.isPregnancyPaused && widget.cycleData.healthStage == stage);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryPink,
      backgroundColor: AppTheme.surfaceLight,
      labelStyle: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppTheme.textPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            if (isPregnancy) {
              widget.cycleData.isPregnancyPaused = true;
              widget.cycleData.healthStage = 'pregnancy';
              widget.cycleData.pregnancyStartDate ??= DateTime.now().subtract(const Duration(days: 42));
            } else {
              widget.cycleData.isPregnancyPaused = false;
              widget.cycleData.healthStage = stage;
              if (stage == 'pcod') {
                widget.cycleData.healthCondition = 'pcod';
                widget.cycleData.userIntent = 'pcos';
              } else {
                widget.cycleData.healthCondition = 'regular';
              }
            }
          });
          LocalDbService.saveUserProfile(widget.cycleData);
          widget.onUpdateCycleData(widget.cycleData);
        }
      },
    );
  }

  Future<void> _pickPregnancyLmpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.cycleData.pregnancyStartDate ?? DateTime.now().subtract(const Duration(days: 42)),
      firstDate: DateTime.now().subtract(const Duration(days: 300)),
      lastDate: DateTime.now(),
      helpText: 'Select Last Menstrual Period (LMP) Date',
    );
    if (picked != null) {
      setState(() {
        widget.cycleData.pregnancyStartDate = picked;
      });
      LocalDbService.saveUserProfile(widget.cycleData);
      widget.onUpdateCycleData(widget.cycleData);
    }
  }
}

