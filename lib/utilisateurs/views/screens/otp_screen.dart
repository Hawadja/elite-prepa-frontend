import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../repository/auth_repository.dart';
import '../../viewmodels/otp_cubit.dart';

class OtpScreen extends StatelessWidget {
  final String email;
  final AuthRepository? authRepository;

  const OtpScreen({
    super.key,
    required this.email,
    this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OtpCubit>(
      create: (context) => OtpCubit(
        authRepository ?? AuthRepository(),
      ),
      child: _OtpView(email: email),
    );
  }
}

class _OtpView extends StatefulWidget {
  final String email;

  const _OtpView({required this.email});

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  final _formKey = GlobalKey<FormBuilderState>();
  Timer? _timer;
  int _secondsRemaining = 60;

  static const Color navyColor = Color(0xFF1F3F6E);
  static const Color goldColor = Color(0xFFF0A500);

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _secondsRemaining = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resendCode() {
    if (_secondsRemaining > 0) return;
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Un nouveau code OTP a été envoyé à votre adresse email.'),
        backgroundColor: navyColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final code = values['otp'] as String;

      context.read<OtpCubit>().verifyOtp(widget.email, code);
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
      body: BlocConsumer<OtpCubit, OtpState>(
        listener: (context, state) {
          if (state is OtpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vérification réussie ! Bienvenue sur Elite Prépa.'),
                backgroundColor: navyColor,
              ),
            );
            if (!context.mounted) return;
            context.go('/home');
          } else if (state is OtpError) {
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
          final isLoading = state is OtpLoading;

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
                              Icons.mark_email_read_outlined,
                              size: 56,
                              color: navyColor,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Vérification OTP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: navyColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.email.isNotEmpty
                          ? 'Saisissez le code à 6 chiffres envoyé à\n${widget.email}'
                          : 'Saisissez le code à 6 chiffres envoyé par email',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 36),

                    FormBuilder(
                      key: _formKey,
                      child: FormBuilderTextField(
                        name: 'otp',
                        enabled: !isLoading,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 14,
                          color: navyColor,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: InputDecoration(
                          hintText: '000000',
                          hintStyle: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 14,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: goldColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Colors.redAccent, width: 1.5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Colors.redAccent, width: 2),
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Le code OTP est obligatoire',
                          ),
                          FormBuilderValidators.numeric(
                            errorText:
                                'Le code doit contenir uniquement des chiffres',
                          ),
                          FormBuilderValidators.minLength(
                            6,
                            errorText: 'Le code doit contenir 6 chiffres',
                          ),
                          FormBuilderValidators.maxLength(
                            6,
                            errorText: 'Le code doit contenir 6 chiffres',
                          ),
                        ]),
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
                                'Valider le code',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    Center(
                      child: TextButton(
                        onPressed: (_secondsRemaining > 0 || isLoading)
                            ? null
                            : _resendCode,
                        child: Text(
                          _secondsRemaining > 0
                              ? 'Renvoyer le code dans ${_secondsRemaining}s'
                              : 'Renvoyer le code OTP',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _secondsRemaining > 0
                                ? Colors.grey.shade500
                                : goldColor,
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
}
