import 'package:flutter/material.dart';
import 'package:luxe/core/utils/error_messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/features/auth/presentation/constants/auth_strings.dart';
import 'package:luxe/features/auth/presentation/controllers/auth_controller.dart';
import 'package:luxe/features/auth/presentation/widgets/auth_button.dart';
import 'package:luxe/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).resetPassword(
            email: _emailController.text.trim(),
          );
      
      if (mounted) {
        final state = ref.read(authControllerProvider);
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(friendlyError(state.error)), backgroundColor: AppTheme.errorColor),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text(AuthStrings.sentResetLinkSuccess), backgroundColor: Colors.green),
          );
          // Optional: Navigate back to login
          context.go('/login');
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepOnyx),
          onPressed: () => context.go('/login'),
        ),
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset, size: 40, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    AuthStrings.forgotPasswordTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepOnyx,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Subtitle
                  const Text(
                    AuthStrings.forgotPasswordSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Input
                  AuthTextField( // We might need to update AuthTextField to support icons if we want to match design perfectly
                    label: AuthStrings.emailLabel,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return AuthStrings.emailRequired;
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Button
                  AuthButton(
                    text: AuthStrings.sendResetLink,
                    onPressed: _resetPassword,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Text(AuthStrings.rememberedPassword, style: TextStyle(color: AppTheme.secondaryText)),
                       GestureDetector(
                         onTap: () => context.go('/login'),
                         child: const Text(
                           AuthStrings.logIn,
                           style: TextStyle(
                             color: AppTheme.primaryColor, // Using Primary Color (Orange)
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
