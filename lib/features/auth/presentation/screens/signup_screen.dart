import 'package:flutter/material.dart';
import 'package:luxe/core/utils/error_messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/features/auth/presentation/constants/auth_strings.dart';
import 'package:luxe/features/auth/presentation/controllers/auth_controller.dart';
import 'package:luxe/features/auth/presentation/widgets/auth_button.dart';
import 'package:luxe/features/auth/presentation/widgets/auth_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
          );
      
      if (mounted) {
        final state = ref.read(authControllerProvider);
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(friendlyError(state.error)), backgroundColor: AppTheme.errorColor),
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
                   // Logo + Brand
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        AuthStrings.shopNow,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                     ],
                   ),
                   const SizedBox(height: 40),

                  // Header
                  const Text(
                    AuthStrings.createAccount,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepOnyx,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AuthStrings.signUpSubtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Inputs
                  AuthTextField(
                    label: AuthStrings.fullNameLabel,
                    controller: _nameController,
                    hintText: AuthStrings.fullNamePlaceholder,
                    prefixIcon: const Icon(Icons.person_outline, color: AppTheme.secondaryText),
                    validator: (value) {
                      if (value == null || value.isEmpty) return AuthStrings.nameRequired;
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
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
                    hintText: AuthStrings.createPasswordPlaceholder,
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
                      if (value.length < 8) return AuthStrings.passwordMinLength;
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AuthStrings.passwordMinLength, style: TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                  ),

                  const SizedBox(height: 32),

                  // Button
                  AuthButton(
                    text: AuthStrings.createAccountButton,
                    onPressed: _signUp,
                    isLoading: isLoading,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Divider
                  const Row(
                    children: [
                       Expanded(child: Divider()),
                       Padding(
                         padding: EdgeInsets.symmetric(horizontal: 16),
                         child: Text(AuthStrings.or, style: TextStyle(color: AppTheme.secondaryText, fontSize: 12, fontWeight: FontWeight.bold)),
                       ),
                       Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),

                   // Social Login (Mock)
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata, size: 28), // Placeholder
                    label: const Text(AuthStrings.signUpWithGoogle, style: TextStyle(color: AppTheme.deepOnyx)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppTheme.dividerColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Text(AuthStrings.alreadyHaveAccount, style: TextStyle(color: AppTheme.secondaryText)),
                       GestureDetector(
                         onTap: () => context.go('/login'),
                         child: const Text(
                           AuthStrings.logIn,
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
