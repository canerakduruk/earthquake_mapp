import 'package:earthquake_mapp/data/models/user_model/user_model.dart';
import 'package:earthquake_mapp/presentation/providers/auth_provider.dart';
import 'package:earthquake_mapp/presentation/providers/user_provider.dart';
import 'package:earthquake_mapp/presentation/widgets/custom_elevated_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'change_password_modal.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  DateTime _birthDate = DateTime(2000, 1, 1);

  bool _isLoading = false;

  void _setLoading(bool value) {
    if (mounted) {
      setState(() {
        _isLoading = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'edit_profile.select_birth_date'.tr(),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _showChangePasswordModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ChangePasswordModal(),
    );
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    _setLoading(true);

    final userViewModel = ref.read(userViewModelProvider.notifier);

    final updatedUser = UserModel(
      id: FirebaseAuth.instance.currentUser!.uid,
      email: ref.read(authViewModelProvider).user?.email ?? '',
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      birthDate: _birthDate,
      createdAt: DateTime.now(),
    );

    try {
      await userViewModel.updateUser(updatedUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('edit_profile.update_success'.tr())),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('edit_profile.error_occurred'.tr(args: [e.toString()])),
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: theme.colorScheme.primary.withOpacity(0.1),
      prefixIconColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
    );

    return ref
        .watch(currentUserStreamProvider)
        .when(
          data: (user) {
            if (user == null) {
              return Scaffold(
                body: Center(child: Text('edit_profile.user_not_found'.tr())),
              );
            }

            // İlk yüklemede controllerları sadece boşsa ata
            if (_firstNameController.text.isEmpty) {
              _firstNameController.text = user.firstName;
            }
            if (_lastNameController.text.isEmpty) {
              _lastNameController.text = user.lastName;
            }
            if (_birthDate == DateTime(2000, 1, 1)) {
              _birthDate = user.birthDate;
            }

            return Scaffold(
              appBar: AppBar(title: Text('edit_profile.title'.tr())),
              body: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          Text(
                            'edit_profile.first_name'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _firstNameController,
                            decoration: inputDecoration.copyWith(
                              prefixIcon: const Icon(Icons.person),
                              hintText: 'edit_profile.enter_first_name'.tr(),
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'edit_profile.first_name_required'.tr()
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'edit_profile.last_name'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: inputDecoration.copyWith(
                              prefixIcon: const Icon(Icons.person_outline),
                              hintText: 'edit_profile.enter_last_name'.tr(),
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'edit_profile.last_name_required'.tr()
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'edit_profile.birth_date'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _selectBirthDate(context),
                            child: InputDecorator(
                              decoration: inputDecoration.copyWith(
                                prefixIcon: const Icon(Icons.cake),
                                hintText: 'edit_profile.select_date'.tr(),
                              ),
                              child: Text(
                                "${_birthDate.day}.${_birthDate.month}.${_birthDate.year}",
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          CustomElevatedButton(
                            onPressed: _onSave,
                            text: 'edit_profile.save'.tr(),
                            backgroundColor: theme.colorScheme.primary,
                            textColor: theme.colorScheme.onPrimary,
                            icon: const FaIcon(
                              FontAwesomeIcons.solidFloppyDisk,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomElevatedButton(
                            text: 'edit_profile.change_password'.tr(),
                            onPressed: _showChangePasswordModal,
                            backgroundColor: theme.colorScheme.secondary,
                            textColor: theme.colorScheme.onSecondary,
                            icon: const FaIcon(FontAwesomeIcons.lock),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(
            body: Center(
              child: Text('edit_profile.error'.tr(args: [e.toString()])),
            ),
          ),
        );
  }
}
