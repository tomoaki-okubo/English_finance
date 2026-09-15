import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'banner_ad_widget.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget child;

  const ResponsiveScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 600;
    
    final location = GoRouterState.of(context).uri.path;
    int activeTabIndex = -1;
    if (location == '/') {
      activeTabIndex = 0;
    } else if (location.startsWith('/chat')) {
      activeTabIndex = 1;
    } else if (location.startsWith('/exercise')) {
      activeTabIndex = 2;
    } else if (location.startsWith('/saved-drills')) {
      activeTabIndex = 3;
    } else if (location.startsWith('/flashcards')) {
      activeTabIndex = 4;
    }

    final selectedIndexForDisplay = activeTabIndex < 0 ? 0 : activeTabIndex;

    void onNavigate(int index) {
      if (index == activeTabIndex) return;
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/chat');
          break;
        case 2:
          context.go('/exercise');
          break;
        case 3:
          context.go('/saved-drills');
          break;
        case 4:
          context.go('/flashcards');
          break;
      }
    }

    if (isWideScreen) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        primary: false,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                            child: NavigationRail(
                              selectedIndex: selectedIndexForDisplay,
                              onDestinationSelected: onNavigate,
                              labelType: NavigationRailLabelType.all,
                              leading: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Icon(Icons.account_balance, color: Theme.of(context).colorScheme.primary, size: 28),
                              ),
                              destinations: const [
                                NavigationRailDestination(
                                  icon: Icon(Icons.dashboard_outlined),
                                  selectedIcon: Icon(Icons.dashboard),
                                  label: Text('Dashboard'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.chat_bubble_outline),
                                  selectedIcon: Icon(Icons.chat_bubble),
                                  label: Text('AI Chat'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.assignment_outlined),
                                  selectedIcon: Icon(Icons.assignment),
                                  label: Text('Drills'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.auto_stories_outlined),
                                  selectedIcon: Icon(Icons.auto_stories),
                                  label: Text('Saved'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.style_outlined),
                                  selectedIcon: Icon(Icons.style),
                                  label: Text('単語カード'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: child,
                  ),
                ],
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          NavigationBar(
            selectedIndex: selectedIndexForDisplay,
            onDestinationSelected: onNavigate,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: 'AI Chat',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: 'Drills',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined),
                selectedIcon: Icon(Icons.auto_stories),
                label: '復習ノート',
              ),
              NavigationDestination(
                icon: Icon(Icons.style_outlined),
                selectedIcon: Icon(Icons.style),
                label: '単語カード',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
