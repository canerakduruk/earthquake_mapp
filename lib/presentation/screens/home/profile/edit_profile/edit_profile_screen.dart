import 'package:earthquake_mapp/data/models/user_model/user_model.dart';
import 'package:earthquake_mapp/presentation/providers/auth_provider.dart';
import 'package:earthquake_mapp/presentation/providers/user_provider.dart';
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
      helpText: 'Doğum Tarihini Seçin',
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
        const SnackBar(content: Text('Profil başarıyla güncellendi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
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
          return const Scaffold(
            body: Center(child: Text('Kullanıcı bulunamadı')),
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
          appBar: AppBar(title: const Text('Bilgileri Düzenle')),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const Text(
                        'Ad',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: inputDecoration.copyWith(
                          prefixIcon: const Icon(Icons.person),
                          hintText: 'Adınızı girin',
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Ad boş olamaz'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Soyad',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: inputDecoration.copyWith(
                          prefixIcon: const Icon(Icons.person_outline),
                          hintText: 'Soyadınızı girin',
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Soyad boş olamaz'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Doğum Tarihi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _selectBirthDate(context),
                        child: InputDecorator(
                          decoration: inputDecoration.copyWith(
                            prefixIcon: const Icon(Icons.cake),
                            hintText: 'Tarih seçin',
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
                        child: const Text('Kaydet'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showChangePasswordModal,
                        icon: const Icon(Icons.lock_reset),
                        label: const Text('Şifre Değiştir'),
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
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
    );
  }
}
