import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../core/widgets/error_snackbar.dart';
import '../../models/profil_model.dart';
import '../../models/user_model.dart';
import '../../repository/profil_repository.dart';
import '../../viewmodels/auth_cubit.dart';
import '../../viewmodels/profil_cubit.dart';

class ProfilScreen extends StatelessWidget {
  final String userId;
  final ProfilRepository? profilRepository;

  const ProfilScreen({
    super.key,
    required this.userId,
    this.profilRepository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfilCubit>(
      create: (context) => ProfilCubit(
        profilRepository ?? ProfilRepository(),
      )..fetchProfil(userId),
      child: _ProfilView(userId: userId),
    );
  }
}

class _ProfilView extends StatefulWidget {
  final String userId;

  const _ProfilView({required this.userId});

  @override
  State<_ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<_ProfilView> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEditing = false;

  static const Color navyColor = Color(0xFF1F3F6E);
  static const Color goldColor = Color(0xFFF0A500);

  void _saveProfil(ProfilModel currentProfil) {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;

      final updatedProfil = currentProfil.copyWith(
        telephone: values['telephone'] as String?,
        adresse: values['adresse'] as String?,
        bio: values['bio'] as String?,
        photoUrl: values['photoUrl'] as String?,
      );

      context
          .read<ProfilCubit>()
          .updateProfil(widget.userId, updatedProfil)
          .then((_) {
        setState(() {
          _isEditing = false;
        });
      });
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion', style: TextStyle(color: navyColor)),
        content:
            const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: navyColor),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthCubit>().logout();
            },
            child: const Text('Déconnexion',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(color: navyColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit_outlined,
              color: goldColor,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            tooltip: _isEditing ? 'Annuler' : 'Éditer le profil',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () => _handleLogout(context),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: BlocConsumer<ProfilCubit, ProfilState>(
        listener: (context, state) {
          if (state is ProfilError) {
            showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is ProfilLoading) {
            return const Center(
              child: CircularProgressIndicator(color: goldColor),
            );
          }

          if (state is ProfilLoaded) {
            final profil = state.profil;
            final user = profil.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Photo de profil & En-tête
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: navyColor.withValues(alpha: 0.1),
                          backgroundImage: (profil.photoUrl != null &&
                                  profil.photoUrl!.isNotEmpty)
                              ? NetworkImage(profil.photoUrl!)
                              : null,
                          child: (profil.photoUrl == null ||
                                  profil.photoUrl!.isEmpty)
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 64,
                                  color: navyColor,
                                )
                              : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: goldColor,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user != null ? '${user.prenom} ${user.nom}' : 'Utilisateur',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: navyColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Mode affichage / Formulaire édition
                  if (!_isEditing)
                    _buildReadOnlyView(profil, user)
                  else
                    _buildEditableForm(profil),

                  if (_isEditing) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _saveProfil(profil),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'Sauvegarder les modifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navyColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return Center(
            child: ElevatedButton(
              onPressed: () =>
                  context.read<ProfilCubit>().fetchProfil(widget.userId),
              style: ElevatedButton.styleFrom(backgroundColor: navyColor),
              child: const Text('Réessayer',
                  style: TextStyle(color: Colors.white)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadOnlyView(ProfilModel profil, UserModel? user) {
    return Column(
      children: [
        _infoTile(
          icon: Icons.phone_outlined,
          title: 'Téléphone',
          value: profil.telephone ?? 'Non renseigné',
        ),
        const SizedBox(height: 14),
        _infoTile(
          icon: Icons.location_on_outlined,
          title: 'Adresse',
          value: profil.adresse ?? 'Non renseignée',
        ),
        const SizedBox(height: 14),
        _infoTile(
          icon: Icons.info_outline,
          title: 'Bio',
          value: profil.bio ?? 'Aucune biographie rédigée',
        ),
      ],
    );
  }

  Widget _buildEditableForm(ProfilModel profil) {
    return FormBuilder(
      key: _formKey,
      initialValue: {
        'telephone': profil.telephone ?? '',
        'adresse': profil.adresse ?? '',
        'bio': profil.bio ?? '',
        'photoUrl': profil.photoUrl ?? '',
      },
      child: Column(
        children: [
          FormBuilderTextField(
            name: 'telephone',
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              label: 'Numéro de téléphone',
              icon: Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'adresse',
            decoration: _inputDecoration(
              label: 'Adresse',
              icon: Icons.location_on_outlined,
            ),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'bio',
            maxLines: 3,
            decoration: _inputDecoration(
              label: 'Biographie',
              icon: Icons.info_outline,
            ),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'photoUrl',
            decoration: _inputDecoration(
              label: 'URL de la photo de profil',
              icon: Icons.image_outlined,
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.url(
                errorText: 'Veuillez entrer une URL valide',
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: navyColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: navyColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: navyColor, fontSize: 14),
      prefixIcon: Icon(icon, color: navyColor.withValues(alpha: 0.7)),
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
    );
  }
}
