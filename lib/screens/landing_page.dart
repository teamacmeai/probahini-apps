import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:probahini/providers/tips_provider.dart';
import 'package:probahini/providers/autonomous_coach_provider.dart';
import 'package:probahini/screens/emergency_help.dart';
import 'package:probahini/screens/autonomous_coach_page.dart';
import '../utils/app_localizations.dart';
import '../widgets/settings_bottom_sheet.dart';
import 'chat_page.dart';
import 'package:uuid/uuid.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = const Uuid().v4();
    
    // Initialize autonomous coach
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AutonomousCoachProvider>().initializeCoach(_userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('app_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => SettingsBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 176.0),
                child: Column(
                  children: [
                    _buildHeaderIcon(theme),
                    const SizedBox(height: 40),
                    _buildWelcomeTexts(t, theme),
                    const SizedBox(height: 20),
                    _buildTodaysTipSection(context, t, theme),
                    const SizedBox(height: 60),
                    // _buildFeatureCards(context, t),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _primaryButton(
                      icon: Icons.chat,
                      label: t.translate('start_chat'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatPage()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _primaryButton(
                      icon: Icons.psychology,
                      label: t.translate('autonomous_coach'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AutonomousCoachPage(userId: _userId),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _outlinedButton(
                      icon: Icons.emergency,
                      label: t.translate('emergency_help'),
                      theme: theme,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmergencyHelpScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(ThemeData theme) => Container(
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      color: theme.primaryColor.withAlpha(25),
      shape: BoxShape.circle,
    ),
    child: Icon(Icons.health_and_safety, size: 100, color: theme.primaryColor),
  );

  Widget _buildWelcomeTexts(AppLocalizations t, ThemeData theme) => Column(
    children: [
      Text(
        t.translate('welcome'),
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      Text(
        t.translate('welcome_message'),
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _primaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) => SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    ),
  );

  Widget _outlinedButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) => SizedBox(
    width: double.infinity,
    height: 60,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.canvasColor,
        foregroundColor: theme.primaryColor,
        side: BorderSide(color: theme.primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: theme.primaryColor.withAlpha(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: theme.primaryColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildTodaysTipSection(
    BuildContext context,
    AppLocalizations t,
    ThemeData theme,
  ) {
    return Consumer<TipsProvider>(
      builder: (_, tipsProvider, __) {
        final tip = tipsProvider.todaysTip;
        if (tip == null) return const SizedBox.shrink();

        final isBn = t.locale.languageCode == 'bn';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor.withAlpha(25),
                theme.primaryColor.withAlpha(13),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.primaryColor.withAlpha(50),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    t.translate("todays_health_tip"),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                isBn ? tip.titleBn : tip.titleEn,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isBn ? tip.contentBn : tip.contentEn,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }
}
