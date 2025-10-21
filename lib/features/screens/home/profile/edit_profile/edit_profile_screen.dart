import 'package:earthquake_mapp/data/models/user_model/user_model.dart';
import 'package:earthquake_mapp/features/providers/user_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      email: "",
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
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: const Color.fromARGB(38, 255, 136, 0),
      prefixIconColor: const Color.fromARGB(255, 133, 93, 66),
      labelStyle: TextStyle(color: Colors.grey[700]),
    );

    final saveButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF8800),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      minimumSize: const Size.fromHeight(48),
    );

    final changePasswordButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFB74D),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      minimumSize: const Size.fromHeight(48),
    );

    // Burada StreamProvider'dan dinliyoruz:
    final userAsync = ref.watch(currentUserStreamProvider);

    return userAsync.when(
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: inputDecoration.copyWith(
                          prefixIcon: const Icon(Icons.person),
                          hintText: 'edit_profile.enter_first_name'.tr(),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'edit_profile.first_name_required'.tr()
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'edit_profile.last_name'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: inputDecoration.copyWith(
                          prefixIcon: const Icon(Icons.person_outline),
                          hintText: 'edit_profile.enter_last_name'.tr(),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'edit_profile.last_name_required'.tr()
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'edit_profile.birth_date'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey[700],
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
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _onSave,
                        style: saveButtonStyle,
                        child: Text('edit_profile.save'.tr()),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showChangePasswordModal,
                        icon: const Icon(Icons.lock_reset),
                        label: Text('edit_profile.change_password'.tr()),
                        style: changePasswordButtonStyle,
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
