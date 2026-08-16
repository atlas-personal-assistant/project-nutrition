import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/space_provider.dart';

class JoinSpaceScreen extends ConsumerStatefulWidget {
  const JoinSpaceScreen({super.key});

  @override
  ConsumerState<JoinSpaceScreen> createState() => _JoinSpaceScreenState();
}

class _JoinSpaceScreenState extends ConsumerState<JoinSpaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinSpace() async {
    if (!_formKey.currentState!.validate()) return;
    
    await ref.read(spaceProvider.notifier).joinSpace(
      inviteCode: _codeController.text.trim().toUpperCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spaceState = ref.watch(spaceProvider);
    
    ref.listen(spaceProvider, (previous, current) {
      if (current.spaces.length > (previous?.spaces.length ?? 0)) {
        context.go('/');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Space beitreten'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.meeting_room_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.space24),
                
                Text(
                  'Space beitreten',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  'Gib den Einladungscode ein, den du erhalten hast',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space32),
                
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Einladungscode',
                    hintText: 'z.B. ABC12345',
                    prefixIcon: Icon(Icons.vpn_key_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte Code eingeben';
                    }
                    if (value.length < 6) {
                      return 'Code muss mindestens 6 Zeichen haben';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.space8),
                
                if (spaceState.error != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.small),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: AppSpacing.space8),
                        Expanded(
                          child: Text(
                            spaceState.error!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const Spacer(),
                
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: spaceState.isLoading ? null : _joinSpace,
                    child: spaceState.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Beitreten'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}