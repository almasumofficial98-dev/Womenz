import 'package:flutter/material.dart';
import '../../core/privacy/secure_storage_service.dart';
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
                      leading: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryPink),
                      title: Text('Export Doctor Summary (PDF)', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w700)),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating PDF Report...'))),
                    ),
                    ListTile(
                      leading: const Icon(Icons.table_chart_rounded, color: AppTheme.primaryBlue),
                      title: Text('Export Personal Health Records (CSV / JSON)', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w700)),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting CSV & JSON...'))),
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
}
