import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.watch(authProvider);
    final authState = authNotifier.state;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.space48),
              
              // Logo / Brand
              Icon(
                Icons.favorite_rounded,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.space24),
              
              Text(
                'Willkommen zurück',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Melde dich an, um deinen Ernährungsplan zu sehen',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space48),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-Mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Passwort',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.space24),
              
              // Error Message
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space12),
                  margin: const EdgeInsets.only(bottom: AppSpacing.space16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                  ),
                  child: Text(
                    authState.error!,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                  ),
                ),
              
              // Loading Indicator
              if (authState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.space16),
                    child: CircularProgressIndicator(),
                  ),
                ),
              
              // Login Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: authState.isLoading 
                    ? null 
                    : () {
                        if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bitte E-Mail und Passwort eingeben')),
                          );
                          return;
                        }
                        
                        // NUR Login ausführen — Navigation macht der Router!
                        authNotifier.login(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                        );
                      },
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Anmelden'),
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              
              // Quick Test Button
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: authState.isLoading 
                    ? null 
                    : () {
                        // NUR Registrierung ausführen — Navigation macht der Router!
                        authNotifier.register(
                          email: 'test@test.com',
                          password: '123456',
                          displayName: 'Test User',
                        );
                      },
                  child: const Text('Schnell-Test: Account erstellen'),
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              
              // Clear Data Button
              TextButton(
                onPressed: () async {
                  await authNotifier.clearAllData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alle Daten gelöscht')),
                    );
                  }
                },
                child: const Text('Alle Daten löschen', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: AppSpacing.space16),
              
              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Noch kein Konto? ',
                    style: AppTextStyles.bodyMedium,
                  ),
                  TextButton(
                    onPressed: authState.isLoading 
                      ? null 
                      : () => context.push('/register'),
                    child: const Text('Registrieren'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}