import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/space_provider.dart';

class CreateSpaceScreen extends ConsumerStatefulWidget {
  const CreateSpaceScreen({super.key});

  @override
  ConsumerState<CreateSpaceScreen> createState() => _CreateSpaceScreenState();
}

class _CreateSpaceScreenState extends ConsumerState<CreateSpaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createSpace() async {
    if (!_formKey.currentState!.validate()) return;
    
    await ref.read(spaceProvider.notifier).createSpace(
      name: _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spaceState = ref.watch(spaceProvider);
    
    ref.listen(spaceProvider, (previous, current) {
      if (current.spaces.length > (previous?.spaces.length ?? 0)) {
        // Space created successfully
        context.go('/');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Space erstellen'),
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
                  Icons.group_add_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.space24),
                
                Text(
                  'Neuen Space erstellen',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  'Erstelle einen Space für dich und deine Mitbewohner',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space32),
                
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Space Name',
                    hintText: 'z.B. Unser Haushalt',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte Namen eingeben';
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
                    onPressed: spaceState.isLoading ? null : _createSpace,
                    child: spaceState.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Space erstellen'),
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