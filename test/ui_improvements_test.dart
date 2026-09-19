import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:womenz/models/cycle_model.dart';
import 'package:womenz/screens/home_screen.dart';
import 'package:womenz/screens/settings_screen.dart';
import 'package:womenz/screens/stats_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Womenz UI Enhancements Widget Tests', () {
    testWidgets('HomeScreen lifestyle tabs switch between Nutrition, Movement, and Mind', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cycleData = UserCycleData(
        lastPeriodStartDate: DateTime.now().subtract(const Duration(days: 3)),
        cycleLength: 28,
        periodDuration: 5,
        currentDay: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreen(
              cycleData: cycleData,
              onLogAdded: (_) {},
              onOpenCalendar: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Default tab: Nutrition
      expect(find.text('🥗 Nutrition'), findsOneWidget);
      expect(find.text('Recommended Nutrition'), findsOneWidget);

      // Tap Movement tab
      await tester.tap(find.text('🏃 Movement'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Movement & Energy Pacing'), findsOneWidget);

      // Tap Mind & Care tab
      await tester.tap(find.text('💡 Mind & Care'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(Icons.lightbulb_outline_rounded), findsWidgets);
    });

    testWidgets('HomeScreen compact logged state shows summary and expands on edit', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final today = DateTime.now();
      final todayKey = today.toString().split(' ')[0];
      final cycleData = UserCycleData(
        lastPeriodStartDate: today.subtract(const Duration(days: 2)),
        cycleLength: 28,
        periodDuration: 5,
        currentDay: 2,
        logs: {
          todayKey: DailyLog(
            date: today,
            flow: 'Medium',
            painScale: 2,
            mood: 'Calm',
            symptoms: ['Cramps'],
            tookInositol: true,
          ),
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreen(
              cycleData: cycleData,
              onLogAdded: (_) {},
              onOpenCalendar: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show Logged indicator and Edit button
      expect(find.text('Logged'), findsOneWidget);
      expect(find.text('Edit Today\'s Check-in'), findsOneWidget);
      expect(find.text('Medium Flow'), findsOneWidget);
      expect(find.text('Inositol Taken'), findsOneWidget);

      // Tap Edit Today's Check-in to expand
      await tester.tap(find.text('Edit Today\'s Check-in'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Now expanded, should show Done button and Save Today's Log
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Save Today\'s Log'), findsOneWidget);
    });

    testWidgets('SettingsScreen allows configuring Reproductive Health Stage & Pregnancy LMP', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cycleData = UserCycleData(
        lastPeriodStartDate: DateTime.now().subtract(const Duration(days: 10)),
        cycleLength: 28,
        periodDuration: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            cycleData: cycleData,
            onUpdateCycleData: (_) {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify health stage options exist
      expect(find.text('Reproductive Health Stage'), findsOneWidget);
      expect(find.text('🌸 Natural Cycle'), findsOneWidget);
      expect(find.text('🌿 PCOS / PCOD'), findsOneWidget);
      expect(find.text('🌅 Perimenopause'), findsOneWidget);
      expect(find.text('🤰 Pregnancy Mode'), findsOneWidget);

      // Tap Pregnancy Mode
      await tester.tap(find.text('🤰 Pregnancy Mode'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(cycleData.isPregnancyPaused, isTrue);
      expect(find.text('Pregnancy Pause Active'), findsOneWidget);
      expect(find.text('Set LMP'), findsOneWidget);
    });

    testWidgets('SettingsScreen allows configuring Contraception method and shows withdrawal bleed context', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cycleData = UserCycleData(
        lastPeriodStartDate: DateTime.now().subtract(const Duration(days: 10)),
        cycleLength: 28,
        periodDuration: 5,
        contraceptionType: ContraceptionType.none,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            cycleData: cycleData,
            onUpdateCycleData: (_) {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Contraception & Birth Control'), findsOneWidget);
      expect(find.text('None (Natural Cycle)'), findsOneWidget);
      expect(find.text('Combined Oral Pill (COC)'), findsOneWidget);

      // Select Combined Oral Pill
      await tester.tap(find.text('Combined Oral Pill (COC)'), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(cycleData.contraceptionType, equals(ContraceptionType.combinedPill));
      expect(find.textContaining('withdrawal bleeding'), findsOneWidget);
    });

    testWidgets('StatsScreen switches to BBT & Ovulation tab and renders chart and mucus stats', (tester) async {
      final cycleData = UserCycleData(
        lastPeriodStartDate: DateTime.now().subtract(const Duration(days: 14)),
        cycleLength: 28,
        periodDuration: 5,
        logs: {
          '2026-09-01': DailyLog(date: DateTime(2026, 9, 1), bbt: 36.3, cervicalMucus: 'Dry'),
          '2026-09-05': DailyLog(date: DateTime(2026, 9, 5), bbt: 36.4, cervicalMucus: 'Sticky'),
          '2026-09-12': DailyLog(date: DateTime(2026, 9, 12), bbt: 36.3, cervicalMucus: 'Egg-White'),
          '2026-09-15': DailyLog(date: DateTime(2026, 9, 15), bbt: 36.8, cervicalMucus: 'Creamy'),
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: StatsScreen(
            cycleData: cycleData,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('BBT & Ovulation'), findsOneWidget);

      // Tap BBT & Ovulation tab
      await tester.tap(find.text('BBT & Ovulation'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Basal Body Temperature (BBT)'), findsOneWidget);
      expect(find.text('Cervical Fluid Patterns'), findsOneWidget);
      expect(find.text('Coverline (~36.6°C)'), findsOneWidget);
      expect(find.text('Egg-White'), findsOneWidget);
      expect(find.text('Creamy'), findsOneWidget);
    });
  });
}
