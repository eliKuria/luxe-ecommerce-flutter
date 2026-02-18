import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/features/auth/presentation/constants/auth_strings.dart';
import 'package:luxe/features/auth/presentation/controllers/auth_controller.dart';
import 'package:luxe/features/auth/presentation/widgets/auth_button.dart';
import 'package:luxe/features/auth/presentation/widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _keepMeSignedIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      
      if (mounted) {
        final state = ref.read(authControllerProvider);
        if (state.hasError) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error.toString()), backgroundColor: AppTheme.errorColor),
          );
        } else {
           context.go('/catalog');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 32),

                  // Header
                  const Text(
                    AuthStrings.welcomeBack,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepOnyx,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AuthStrings.signInSubtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Inputs
                  AuthTextField(
                    label: AuthStrings.emailLabel,
                    controller: _emailController,
                    hintText: AuthStrings.emailPlaceholder,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.secondaryText),
                    validator: (value) {
                      if (value == null || value.isEmpty) return AuthStrings.emailRequired;
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    label: AuthStrings.passwordLabel,
                    controller: _passwordController,
                    isPassword: !_isPasswordVisible,
                    hintText: AuthStrings.passwordPlaceholder,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.secondaryText),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.secondaryText,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return AuthStrings.passwordRequired;
                      return null;
                    },
                  ),
                  
                  // Forgot Password & Keep Signed In
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _keepMeSignedIn,
                          activeColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) {
                            setState(() {
                              _keepMeSignedIn = val ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(AuthStrings.keepMeSignedIn, style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.go('/forgot-password'),
                        child: const Text(
                          AuthStrings.forgotPasswordLink,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Button
                  AuthButton(
                    text: AuthStrings.signInButton,
                    onPressed: _signIn,
                    isLoading: isLoading,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Divider
                  const Row(
                    children: [
                       Expanded(child: Divider()),
                       Padding(
                         padding: EdgeInsets.symmetric(horizontal: 16),
                         child: Text(AuthStrings.orContinueWith, style: TextStyle(color: AppTheme.secondaryText, fontSize: 12, fontWeight: FontWeight.bold)),
                       ),
                       Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Social Login (Mock)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.g_mobiledata, size: 28), // Placeholder for Google Logo
                          label: const Text(AuthStrings.google, style: TextStyle(color: AppTheme.deepOnyx)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppTheme.dividerColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.apple, size: 28),
                          label: const Text(AuthStrings.apple, style: TextStyle(color: AppTheme.deepOnyx)),
                          style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppTheme.dividerColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Text(AuthStrings.dontHaveAccount, style: TextStyle(color: AppTheme.secondaryText)),
                       GestureDetector(
                         onTap: () => context.go('/signup'),
                         child: const Text(
                           AuthStrings.joinTheClub,
                           style: TextStyle(
                             color: AppTheme.primaryColor,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                       ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
