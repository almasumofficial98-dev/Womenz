import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cycle_models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  HealthCondition _selectedCondition = HealthCondition.regular;
  int _avgCycleLength = 28;
  int _avgPeriodLength = 5;
  DateTime? _firstPeriodDate;

  @override
  Widget build(BuildContext me) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // App Logo Branding
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryViolet.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/images/womenz_logo.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppTheme.primaryViolet,
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Womenz',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryViolet,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Personalized menstrual health tracking tailored for every woman — regular, irregular, PCOD/PCOS, and beyond.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: AppTheme.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Step 1: Health Profile / Condition
              _buildSectionHeader('1. Your Health Profile'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: HealthCondition.values.map((condition) {
                  final isSelected = _selectedCondition == condition;
                  return ChoiceChip(
                    label: Text(condition.displayName),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryViolet,
                    backgroundColor: Colors.white,
                    labelStyle: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : AppTheme.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryViolet : AppTheme.softLavender,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCondition = condition;
                          if (condition == HealthCondition.pcodPcos ||
                              condition == HealthCondition.irregular) {
                            _avgCycleLength = 32; // Default starting assumption for PCOD/irregular
                          }
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Step 2: Cycle Parameters
              _buildSectionHeader('2. Typical Cycle Parameters'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Average Cycle Length:', style: GoogleFonts.outfit(fontSize: 15)),
                          Text('$_avgCycleLength Days',
                              style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryViolet)),
                        ],
                      ),
                      Slider(
                        value: _avgCycleLength.toDouble(),
                        min: 20,
                        max: 60,
                        divisions: 40,
                        activeColor: AppTheme.primaryViolet,
                        onChanged: (val) {
                          setState(() {
                            _avgCycleLength = val.toInt();
                          });
                        },
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Average Period Duration:', style: GoogleFonts.outfit(fontSize: 15)),
                          Text('$_avgPeriodLength Days',
                              style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryViolet)),
                        ],
                      ),
                      Slider(
                        value: _avgPeriodLength.toDouble(),
                        min: 2,
                        max: 12,
                        divisions: 10,
                        activeColor: AppTheme.accentPurple,
                        onChanged: (val) {
                          setState(() {
                            _avgPeriodLength = val.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Step 3: Last Period (Optional for Nil Start)
              _buildSectionHeader('3. Last Period Start Date (Optional)'),
              const SizedBox(height: 8),
              Text(
                'You can select your last period date now, or start completely fresh with NIL data and log whenever you are ready.',
                style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, color: AppTheme.primaryViolet),
                label: Text(
                  _firstPeriodDate != null
                      ? 'Selected: ${_firstPeriodDate!.day}/${_firstPeriodDate!.month}/${_firstPeriodDate!.year}'
                      : 'Tap to pick last period start date',
                  style: GoogleFonts.outfit(
                    color: AppTheme.primaryViolet,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: AppTheme.primaryViolet, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 120)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _firstPeriodDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 36),

              // Complete Setup Button
              ElevatedButton(
                onPressed: _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Start Womenz Journey'),
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
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryViolet,
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final storage = StorageService.instance;
    final profile = UserProfile(
      healthCondition: _selectedCondition,
      avgCycleLength: _avgCycleLength,
      avgPeriodLength: _avgPeriodLength,
      cycleVariance: _selectedCondition == HealthCondition.pcodPcos ||
              _selectedCondition == HealthCondition.irregular
          ? 5
          : 2,
      lastPeriodStart: _firstPeriodDate,
      isOnboarded: true,
    );

    await storage.saveProfile(profile);

    if (_firstPeriodDate != null) {
      await storage.addCycleLog(
        CycleLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          startDate: _firstPeriodDate!,
          flow: FlowIntensity.medium,
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }
}
