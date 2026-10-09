import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../repository/auth_repository.dart';
import '../../viewmodels/password_reset_cubit.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String? token;
  final AuthRepository? authRepository;

  const ResetPasswordScreen({
    super.key,
    this.token,
    this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PasswordResetCubit>(
      create: (context) => PasswordResetCubit(
        authRepository ?? AuthRepository(),
      ),
      child: _ResetPasswordView(token: token),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  final String? token;

  const _ResetPasswordView({this.token});

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const Color navyColor = Color(0xFF1F3F6E);
  static const Color goldColor = Color(0xFFF0A500);

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final token = (widget.token != null && widget.token!.isNotEmpty)
          ? widget.token!
          : (values['token'] as String? ?? '');
      final nouveauMotDePasse = values['nouveauMotDePasse'] as String;

      context
          .read<PasswordResetCubit>()
          .resetPassword(token, nouveauMotDePasse);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showTokenField = widget.token == null || widget.token!.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: navyColor),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: BlocConsumer<PasswordResetCubit, PasswordResetState>(
        listener: (context, state) {
          if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mot de passe réinitialisé avec succès !'),
                backgroundColor: navyColor,
              ),
            );
            if (!context.mounted) return;
            context.go('/login');
          } else if (state is PasswordResetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PasswordResetLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/elite-prepa-icon.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: navyColor.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                              border: Border.all(color: goldColor, width: 2),
                            ),
                            child: const Icon(
                              Icons.vpn_key_outlined,
                              size: 56,
                              color: navyColor,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Nouveau mot de passe',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: navyColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Veuillez saisir votre nouveau mot de passe',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 36),

                    FormBuilder(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (showTokenField) ...[
                            FormBuilderTextField(
                              name: 'token',
                              enabled: !isLoading,
                              decoration: _inputDecoration(
                                label: 'Token de réinitialisation',
                                hint: 'Entrez le code/token reçu',
                                icon: Icons.key_outlined,
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(
                                  errorText: 'Le token est obligatoire',
                                ),
                              ]),
                            ),
                            const SizedBox(height: 16),
                          ],
                          FormBuilderTextField(
                            name: 'nouveauMotDePasse',
                            enabled: !isLoading,
                            obscureText: _obscurePassword,
                            decoration: _inputDecoration(
                              label: 'Nouveau mot de passe',
                              hint: '8 caractères minimum',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: navyColor.withValues(alpha: 0.7),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'Le mot de passe est obligatoire',
                              ),
                              FormBuilderValidators.minLength(
                                8,
                                errorText:
                                    'Le mot de passe doit contenir au moins 8 caractères',
                              ),
                            ]),
                          ),
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: 'confirmation',
                            enabled: !isLoading,
                            obscureText: _obscureConfirmPassword,
                            decoration: _inputDecoration(
                              label: 'Confirmation du mot de passe',
                              hint: 'Répétez le nouveau mot de passe',
                              icon: Icons.lock_clock_outlined,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: navyColor.withValues(alpha: 0.7),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La confirmation est obligatoire';
                              }
                              final password = _formKey.currentState
                                  ?.fields['nouveauMotDePasse']?.value;
                              if (value != password) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navyColor,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: goldColor,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Réinitialiser le mot de passe',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: navyColor, fontSize: 14),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIcon: Icon(icon, color: navyColor.withValues(alpha: 0.7)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: goldColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}
