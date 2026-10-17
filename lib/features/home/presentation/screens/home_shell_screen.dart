import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/features/challenges/presentation/screens/challenges_screen.dart';
import 'package:yeetcoach/features/chat/presentation/screens/chat_inbox_screen.dart';
import '../controllers/home_shell_controller.dart';
import 'all_clients_screen.dart';
import 'coach_dashboard_screen.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// /home: the four main tabs behind a persistent bottom bar. IndexedStack keeps
/// each tab's scroll position and state while switching.
class HomeShellScreen extends GetView<HomeShellController> {
  const HomeShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final onHome = controller.currentTab.value == HomeTab.home;
      return PopScope(
        canPop: onHome,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          controller.selectTab(HomeTab.home);
        },
        child: Scaffold(
          body: IndexedStack(
            index: controller.currentTab.value.index,
            children: const [
              CoachDashboardScreen(),
              AllClientsScreen(),
              ChatInboxScreen(showBackButton: false),
              ChallengesScreen(),
            ],
          ),
          bottomNavigationBar: const _HomeNavigationBar(),
        ),
      );
    });
  }
}

class _HomeNavigationBar extends GetView<HomeShellController> {
  const _HomeNavigationBar();

  @override
  Widget build(BuildContext context) {
    Color colorFor(Set<WidgetState> states) =>
        states.contains(WidgetState.selected) ? AppColors.primary : AppColors.subtle;

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      position: DecorationPosition.foreground,
      child: NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(color: colorFor(states))),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => _textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: colorFor(states),
          ),
        ),
      ),
      child: Obx(() => NavigationBar(
            selectedIndex: controller.currentTab.value.index,
            onDestinationSelected: (index) => controller.selectTab(HomeTab.values[index]),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Clients',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: 'Chats',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events),
                label: 'Challenges',
              ),
            ],
          )),
      ),
    );
  }
}
