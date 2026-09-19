import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/privacy/secure_storage_service.dart';
import '../../services/local_db_service.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';

class PrivacySecurityScreen extends StatefulWidget {
  final UserProfile profile;
  final ValueChanged<UserProfile> onUpdateProfile;
  final VoidCallback onDeleteAllData;

  const PrivacySecurityScreen({
    super.key,
    required this.profile,
    required this.onUpdateProfile,
    required this.onDeleteAllData,
  });

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final pinCtrl = TextEditingController();
  bool isPinEnabled = false;

  @override
  void initState() {
    super.initState();
    isPinEnabled = widget.profile.isPinEnabled;
  }

  void _showSetPinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Set 4-Digit Security PIN', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('PIN is hashed with SHA-256 before storage and never kept in plain text.', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter 4-digit PIN',
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (pinCtrl.text.length == 4) {
                await SecureStorageService.saveHashedPin(pinCtrl.text);
                setState(() => isPinEnabled = true);
                widget.profile.isPinEnabled = true;
                widget.onUpdateProfile(widget.profile);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hashed PIN App Lock Enabled')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink),
            child: const Text('Enable PIN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Privacy & Local Security', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(color: Colors.white, radius: 24),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Enable Hashed PIN App Lock', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      subtitle: Text('Requires 4-digit PIN to open Womenz app', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textSecondary)),
                      value: isPinEnabled,
                      activeColor: AppTheme.primaryPink,
                      onChanged: (val) async {
                        if (val) {
                          _showSetPinDialog();
                        } else {
                          await SecureStorageService.disablePin();
                          setState(() => isPinEnabled = false);
                          widget.profile.isPinEnabled = false;
                          widget.onUpdateProfile(widget.profile);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Export Data Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(color: Colors.white, radius: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data Export & Backups', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Export full health history in clinician-friendly or portable formats', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.table_chart_rounded, color: AppTheme.primaryBlue),
                      title: const Text('Export Data as CSV (Spreadsheet)', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Copies full FIGO cycle & symptoms log as CSV', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      onTap: () async {
                        final csv = await LocalDbService.exportCsvData();
                        await Clipboard.setData(ClipboardData(text: csv));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('CSV data copied to clipboard! Ready to paste into Excel/Sheets.')),
                          );
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.cloud_download_rounded, color: AppTheme.primaryPurple),
                      title: const Text('Export Full Backup (JSON)', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Complete portable database snapshot', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      onTap: () async {
                        final snapshot = await LocalDbService.exportFullSnapshot();
                        final jsonStr = jsonEncode(snapshot);
                        await Clipboard.setData(ClipboardData(text: jsonStr));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Complete JSON backup copied to clipboard!')),
                          );
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.restore_page_rounded, color: Color(0xFF2E7D32)),
                      title: const Text('Restore from Backup (JSON)', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Restore previously exported Womenz data', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      onTap: () => _showRestoreDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Delete Data Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(color: Colors.white, radius: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Danger Zone', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFFC62828))),
                    const SizedBox(height: 4),
                    Text('Permanently wipe all locally stored health records', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete All Local Data?'),
                              content: const Text('This will permanently delete all cycle, symptom, body, and lab records stored on your phone.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                ElevatedButton(
                                  onPressed: () {
                                    widget.onDeleteAllData();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All local health data cleared.')));
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
                                  child: const Text('Delete Everything'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFC62828)),
                        label: const Text('Clear All Local Data', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, color: Color(0xFFC62828))),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEF5350)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Restore JSON Backup', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paste your exported Womenz JSON backup below to restore your records:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Paste {"profile": ...} here',
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final data = jsonDecode(textCtrl.text) as Map<String, dynamic>;
                final ok = await LocalDbService.importFullSnapshot(data);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? 'Backup successfully restored!' : 'Failed to parse backup format.')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid JSON backup content.')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}
