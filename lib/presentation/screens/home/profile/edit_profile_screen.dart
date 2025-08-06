import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  DateTime? _birthDate;

  // Şifre alanları için controllerlar
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000, 1, 1),
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
      isScrollControlled: true, // Klavyeye göre yükseklik ayarı için
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // klavye boşluğu
            top: 20,
            left: 20,
            right: 20,
          ),
          child: _buildChangePasswordForm(),
        );
      },
    );
  }

  Widget _buildChangePasswordForm() {
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

    final changePasswordButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFB74D),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      minimumSize: const Size.fromHeight(48),
    );

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Text(
              'Şifre Değiştir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _oldPasswordController,
              decoration: inputDecoration.copyWith(
                labelText: 'Eski Şifre',
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPasswordController,
              decoration: inputDecoration.copyWith(
                labelText: 'Yeni Şifre',
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: inputDecoration.copyWith(
                labelText: 'Yeni Şifre (Tekrar)',
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final oldPass = _oldPasswordController.text;
                final newPass = _newPasswordController.text;
                final confirmPass = _confirmPasswordController.text;

                if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen tüm alanları doldurun'),
                    ),
                  );
                  return;
                }
                if (newPass != confirmPass) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yeni şifreler eşleşmiyor')),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Şifre başarıyla değiştirildi')),
                );

                Navigator.of(context).pop();

                _oldPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();
              },
              child: const Text('Şifreyi Değiştir'),
              style: changePasswordButtonStyle,
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();
      String birthDateStr = _birthDate != null
          ? "${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}"
          : 'Seçilmedi';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profil kaydedildi:\nAd: $firstName\nSoyad: $lastName\nDoğum Tarihi: $birthDateStr',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

    return Scaffold(
      appBar: AppBar(title: const Text('Bilgileri Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      labelText: null,
                      hintText: 'Adınızı girin',
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Ad boş olamaz'
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      labelText: null,
                      hintText: 'Soyadınızı girin',
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Soyad boş olamaz'
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        labelText: null,
                        hintText: 'Tarih girin',
                      ),
                      child: Text(
                        _birthDate == null
                            ? 'Tarih seçin'
                            : "${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}",
                        style: TextStyle(
                          color: _birthDate == null
                              ? Colors.grey.shade600
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
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
    );
  }
}
