import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../services/google_sheets_service.dart';
import '../services/local_db_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_themed_date_picker.dart';

class CycleHistoryEntry {
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final String flowIntensity;
  final String notes;
  bool isSynced;

  CycleHistoryEntry({
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.flowIntensity,
    required this.notes,
    this.isSynced = false,
  });
}

class CycleHistoryScreen extends StatefulWidget {
  const CycleHistoryScreen({super.key});

  @override
  State<CycleHistoryScreen> createState() => _CycleHistoryScreenState();
}

class _CycleHistoryScreenState extends State<CycleHistoryScreen> {
  final List<CycleHistoryEntry> historyList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    final localEntries = await LocalDbService.getHistoryEntries();
    final List<CycleHistoryEntry> list = [];
    for (final row in localEntries) {
      final sStr = row['startDate']?.toString();
      final eStr = row['endDate']?.toString();
      if (sStr != null && eStr != null) {
        final sDate = DateTime.tryParse(sStr);
        final eDate = DateTime.tryParse(eStr);
        if (sDate != null && eDate != null) {
          list.add(CycleHistoryEntry(
            startDate: sDate,
            endDate: eDate,
            durationDays: (row['durationDays'] as int?) ?? (eDate.difference(sDate).inDays + 1),
            flowIntensity: row['flowIntensity']?.toString() ?? 'Medium',
            notes: row['notes']?.toString() ?? '',
            isSynced: (row['isSynced'] as int?) == 1,
          ));
        }
      }
    }
    if (mounted) {
      setState(() {
        historyList.clear();
        historyList.addAll(list);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Cycle History',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddHistoryDialog(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.softPink,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AppTheme.primaryPink),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C92F8), Color(0xFF8CA8FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C92F8).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_upload_rounded, color: AppTheme.primaryBlue, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Synced to Supabase Cloud',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'User ID: ${GoogleSheetsService.userId}',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Past Cycle Log Entries',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              if (historyList.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: AppTheme.cardDecoration(
                    color: Colors.white,
                    radius: 24,
                    shadows: AppTheme.softShadow(opacity: 0.03),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppTheme.softPink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.history_rounded, color: AppTheme.primaryPink, size: 32),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No Past History Logged Yet',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap "Log Past Period Entry" below to add your past cycle records.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                  final entry = historyList[index];
                  final dateFormat = DateFormat('MMM dd, yyyy');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.cardDecoration(
                      color: Colors.white,
                      radius: 24,
                      shadows: AppTheme.softShadow(opacity: 0.04),
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
                                  decoration: const BoxDecoration(
                                    color: AppTheme.softPink,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.water_drop_rounded, color: AppTheme.primaryPink, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${entry.durationDays} Days Period',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: entry.isSynced ? AppTheme.softBlue : AppTheme.softPeach,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    entry.isSynced ? Icons.check_circle_rounded : Icons.sync_rounded,
                                    size: 12,
                                    color: entry.isSynced ? AppTheme.primaryBlue : AppTheme.primaryPeach,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    entry.isSynced ? 'Synced' : 'Pending',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: entry.isSynced ? AppTheme.primaryBlue : AppTheme.primaryPeach,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          '${dateFormat.format(entry.startDate)} - ${dateFormat.format(entry.endDate)}',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),

                        if (entry.notes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            entry.notes,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],

              const SizedBox(height: 20),

              // Add History Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddHistoryDialog(context),
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text(
                    'Log Past Period Entry',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    elevation: 4,
                    shadowColor: AppTheme.primaryPink.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddHistoryDialog(BuildContext context) {
    DateTime selectedStart = DateTime.now().subtract(const Duration(days: 28));
    DateTime selectedEnd = DateTime.now().subtract(const Duration(days: 23));
    String flow = 'Medium';
    final TextEditingController notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final dateFormat = DateFormat('MMM dd, yyyy');
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Past Period History',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Record past dates to improve cycle predictions & sync to Supabase',
                  style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: AppTheme.textSecondary),
                ),

                const SizedBox(height: 20),

                // App-Themed Date Picker Rows
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AppThemedDateRangePicker(
                              initialStart: selectedStart,
                              initialEnd: selectedEnd,
                              onSelected: (range) {
                                setModalState(() {
                                  selectedStart = range.start;
                                  selectedEnd = range.end;
                                });
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(18)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Date', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, color: AppTheme.textSecondary)),
                              const SizedBox(height: 4),
                              Text(dateFormat.format(selectedStart), style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryPink)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AppThemedDateRangePicker(
                              initialStart: selectedStart,
                              initialEnd: selectedEnd,
                              onSelected: (range) {
                                setModalState(() {
                                  selectedStart = range.start;
                                  selectedEnd = range.end;
                                });
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(18)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Date', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, color: AppTheme.textSecondary)),
                              const SizedBox(height: 4),
                              Text(dateFormat.format(selectedEnd), style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Notes input
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    hintText: 'Notes (e.g. Mild cramps, travel)',
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final duration = selectedEnd.difference(selectedStart).inDays + 1;
                      final id = const Uuid().v4();
                      final startStr = DateFormat('yyyy-MM-dd').format(selectedStart);
                      final endStr = DateFormat('yyyy-MM-dd').format(selectedEnd);

                      final entry = CycleHistoryEntry(
                        startDate: selectedStart,
                        endDate: selectedEnd,
                        durationDays: duration,
                        flowIntensity: flow,
                        notes: notesCtrl.text,
                        isSynced: false,
                      );

                      setState(() {
                        historyList.insert(0, entry);
                      });

                      Navigator.pop(context);

                      await LocalDbService.saveHistoryEntry(
                        id: id,
                        startDate: startStr,
                        endDate: endStr,
                        durationDays: duration,
                        flowIntensity: flow,
                        notes: notesCtrl.text.isEmpty ? 'Past Record' : notesCtrl.text,
                      );

                      // Sync to Supabase Database
                      final synced = await GoogleSheetsService.syncHistoryEntry(
                        startDate: startStr,
                        endDate: endStr,
                        durationDays: duration,
                        flowIntensity: flow,
                        notes: notesCtrl.text.isEmpty ? 'Past Record' : notesCtrl.text,
                      );

                      if (synced) {
                        setState(() => entry.isSynced = true);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('History logged & synced to Supabase!'), backgroundColor: AppTheme.primaryPink),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Save & Sync to Supabase', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
