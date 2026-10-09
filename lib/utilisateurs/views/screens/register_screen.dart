import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../repository/auth_repository.dart';
import '../../viewmodels/register_cubit.dart';

class RegisterScreen extends StatelessWidget {
  final AuthRepository? authRepository;

  const RegisterScreen({super.key, this.authRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterCubit>(
      create: (context) => RegisterCubit(
        authRepository ?? AuthRepository(),
      ),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const Color navyColor = Color(0xFF1F3F6E);
  static const Color goldColor = Color(0xFFF0A500);

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final nom = values['nom'] as String;
      final prenom = values['prenom'] as String;
      final email = values['email'] as String;
      final motDePasse = values['motDePasse'] as String;

      context.read<RegisterCubit>().register(
            nom: nom,
            prenom: prenom,
            email: email,
            motDePasse: motDePasse,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            final email = state.user.email;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Compte créé ! Veuillez vérifier votre code OTP.'),
                backgroundColor: navyColor,
              ),
            );
            if (!context.mounted) return;
            context.push('/otp', extra: email);
          } else if (state is RegisterError) {
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
          final isLoading = state is RegisterLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
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
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: navyColor.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                              border: Border.all(color: goldColor, width: 2),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              size: 48,
                              color: navyColor,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Créer un compte',
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
                      'Rejoignez la plateforme Elite Prépa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 32),

                    FormBuilder(
                      key: _formKey,
                      child: Column(
                        children: [
                          FormBuilderTextField(
                            name: 'nom',
                            enabled: !isLoading,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                              label: 'Nom',
                              hint: 'Entrez votre nom',
                              icon: Icons.person_outline,
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'Le nom est obligatoire',
                              ),
                            ]),
                          ),
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: 'prenom',
                            enabled: !isLoading,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                              label: 'Prénom',
                              hint: 'Entrez votre prénom',
                              icon: Icons.person_outline_sharp,
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'Le prénom est obligatoire',
                              ),
                            ]),
                          ),
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: 'email',
                            enabled: !isLoading,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              label: 'Adresse Email',
                              hint: 'exemple@domain.com',
                              icon: Icons.email_outlined,
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'L\'email est obligatoire',
                              ),
                              FormBuilderValidators.email(
                                errorText: 'Veuillez saisir un email valide',
                              ),
                            ]),
                          ),
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: 'motDePasse',
                            enabled: !isLoading,
                            obscureText: _obscurePassword,
                            decoration: _inputDecoration(
                              label: 'Mot de passe',
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
                              hint: 'Répétez votre mot de passe',
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
                                  ?.fields['motDePasse']?.value;
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                                'S\'inscrire',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Déjà un compte ? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go('/login');
                          },
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: goldColor,
                            ),
                          ),
                        ),
                      ],
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
