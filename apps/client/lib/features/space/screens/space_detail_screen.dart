import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/space_provider.dart';

class SpaceDetailScreen extends ConsumerStatefulWidget {
  final String spaceId;

  const SpaceDetailScreen({
    super.key,
    required this.spaceId,
  });

  @override
  ConsumerState<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends ConsumerState<SpaceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(spaceProvider.notifier).getSpaceDetails(widget.spaceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final spaceState = ref.watch(spaceProvider);
    final space = spaceState.currentSpace;

    return Scaffold(
      appBar: AppBar(
        title: Text(space?.name ?? 'Space Details'),
      ),
      body: spaceState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : space == null
              ? const Center(child: Text('Space nicht gefunden'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Space Info Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.space16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.home_outlined, color: AppColors.primary, size: 32),
                                  const SizedBox(width: AppSpacing.space12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          space.name,
                                          style: AppTextStyles.titleLarge,
                                        ),
                                        Text(
                                          'Einladungscode: ${space.inviteCode ?? 'Nicht verfügbar'}',
                                          style: AppTextStyles.labelLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (space.inviteCode != null) ...[
                                const SizedBox(height: AppSpacing.space16),
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.space12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy_outlined, color: AppColors.primary, size: 20),
                                      const SizedBox(width: AppSpacing.space8),
                                      Expanded(
                                        child: Text(
                                          space.inviteCode!,
                                          style: AppTextStyles.bodyLarge.copyWith(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: () {
                                          // TODO: Copy to clipboard
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Code kopiert!')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.space24),
                      
                      // Members Section
                      Text(
                        'Mitglieder',
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.space12),
                      
                      ...space.members.map((member) {
                        final isOwner = member.role == 'owner';
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.space8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isOwner 
                                  ? AppColors.primary.withOpacity(0.2) 
                                  : AppColors.surfaceVariant,
                              child: Text(
                                member.user?.displayName.substring(0, 1).toUpperCase() ?? '?',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: isOwner ? AppColors.primary : AppColors.onSurface,
                                ),
                              ),
                            ),
                            title: Text(
                              member.user?.displayName ?? 'Unbekannt',
                              style: AppTextStyles.titleMedium,
                            ),
                            subtitle: Text(
                              isOwner ? 'Besitzer' : 'Mitglied',
                              style: AppTextStyles.labelMedium,
                            ),
                            trailing: isOwner
                                ? Icon(Icons.star, color: AppColors.primary, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                      
                      const SizedBox(height: AppSpacing.space32),
                      
                      // Danger Zone
                      if (space.ownerUserId == ref.read(spaceProvider).currentSpace?.ownerUserId)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Leave/Delete space
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                            ),
                            child: const Text('Space verlassen'),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}