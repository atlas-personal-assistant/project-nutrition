import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    await ref.read(authProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    // Listen for auth success
    ref.listen(authProvider, (previous, current) {
      if (current.user != null && previous?.user == null) {
        context.go('/');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Form(
            key: _formKey,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte E-Mail eingeben';
                    }
                    if (!value.contains('@')) {
                      return 'Bitte gültige E-Mail eingeben';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.space16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Passwort',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword 
                            ? Icons.visibility_outlined 
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte Passwort eingeben';
                    }
                    if (value.length < 6) {
                      return 'Passwort muss mindestens 6 Zeichen haben';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.space8),
                
                // Error Message
                if (authState.error != null)
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
                            authState.error!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: AppSpacing.space24),
                
                // Login Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
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
                      onPressed: () => context.push('/register'),
                      child: const Text('Registrieren'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}