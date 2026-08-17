import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/auth_models.dart';
import '../../space/providers/space_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).checkAuthStatus();
      ref.read(spaceProvider.notifier).loadSpaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.watch(authProvider);
    final authState = authNotifier.state;
    final spaceState = ref.watch(spaceProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hallo, ${user.displayName}',
          style: AppTextStyles.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await ref.read(authProvider).logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home Tab
          _buildHomeTab(spaceState, user),
          
          // Spaces Tab
          _buildSpacesTab(spaceState),
          
          // Profile Tab
          _buildProfileTab(user),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Spaces',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(SpaceState spaceState, User user) {
    final spaces = spaceState.spaces;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.today, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.space8),
                      Text(
                        'Heute',
                        style: AppTextStyles.headlineMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.local_fire_department,
                          color: AppColors.calories,
                          label: 'Kalorien',
                          value: '0',
                          unit: 'kcal',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.directions_walk,
                          color: AppColors.protein,
                          label: 'Schritte',
                          value: '0',
                          unit: 'Schritte',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.space24),
          
          // Spaces Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deine Spaces',
                style: AppTextStyles.headlineMedium,
              ),
              TextButton(
                onPressed: () {
                  _showSpaceOptions(context);
                },
                child: const Text('Verwalten'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          
          if (spaces.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space24),
                child: Column(
                  children: [
                    Icon(
                      Icons.group_add_outlined,
                      size: 48,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    Text(
                      'Noch keine Spaces',
                      style: AppTextStyles.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      'Erstelle einen Space oder tritt einem bei',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.push('/space/create'),
                            child: const Text('Erstellen'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push('/space/join'),
                            child: const Text('Beitreten'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            ...spaces.map((space) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.space8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: const Icon(Icons.home, color: AppColors.primary),
                ),
                title: Text(space.name, style: AppTextStyles.titleMedium),
                subtitle: Text(
                  'Code: ${space.inviteCode ?? 'N/A'}',
                  style: AppTextStyles.labelMedium,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/space/${space.id}'),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildSpacesTab(SpaceState spaceState) {
    final spaces = spaceState.spaces;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () => context.push('/space/create'),
            icon: const Icon(Icons.add),
            label: const Text('Neuen Space erstellen'),
          ),
          const SizedBox(height: AppSpacing.space12),
          OutlinedButton.icon(
            onPressed: () => context.push('/space/join'),
            icon: const Icon(Icons.login),
            label: const Text('Space beitreten'),
          ),
          const SizedBox(height: AppSpacing.space24),
          
          if (spaces.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 64,
                    color: AppColors.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    'Keine Spaces vorhanden',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            ...spaces.map((space) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.space8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: const Icon(Icons.home, color: AppColors.primary),
                ),
                title: Text(space.name, style: AppTextStyles.titleMedium),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Code: ${space.inviteCode}',
                      style: AppTextStyles.labelMedium,
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/space/${space.id}'),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildProfileTab(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      user.displayName.substring(0, 1).toUpperCase(),
                      style: AppTextStyles.displayLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    user.displayName,
                    style: AppTextStyles.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    user.email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Profil bearbeiten',
            onTap: () {
              // TODO: Navigate to profile edit
            },
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Benachrichtigungen',
            onTap: () {
              // TODO: Navigate to notifications
            },
          ),
          _buildSettingsTile(
            icon: Icons.palette_outlined,
            title: 'Erscheinungsbild',
            onTap: () {
              // TODO: Navigate to appearance settings
            },
          ),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Abmelden',
            textColor: AppColors.error,
            onTap: () async {
              await ref.read(authProvider).logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.space8),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: AppTextStyles.labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? AppColors.primary),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: textColor,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showSpaceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Space erstellen'),
              onTap: () {
                Navigator.pop(context);
                context.push('/space/create');
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Space beitreten'),
              onTap: () {
                Navigator.pop(context);
                context.push('/space/join');
              },
            ),
          ],
        ),
      ),
    );
  }
}