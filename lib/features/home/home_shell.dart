import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../path/path_screen.dart';
import '../profile/profile_screen.dart';
import '../vault/vault_screen.dart';

/// Bottom-nav shell. Uses an [IndexedStack] so each tab keeps its scroll
/// position across switches.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.canvas,
      body: IndexedStack(
        index: _index,
        children: const [PathScreen(), VaultScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.hairline)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: c.surface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: c.emberDim,
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.hardware_outlined, color: c.inkMuted),
              selectedIcon: Icon(Icons.hardware, color: c.ember),
              label: 'Path',
            ),
            NavigationDestination(
              icon: Icon(Icons.layers_outlined, color: c.inkMuted),
              selectedIcon: Icon(Icons.layers, color: c.ember),
              label: 'Vault',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: c.inkMuted),
              selectedIcon: Icon(Icons.person, color: c.ember),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
