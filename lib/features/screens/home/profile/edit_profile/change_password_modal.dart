import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // eklendi

class ChangePasswordModal extends StatefulWidget {
  const ChangePasswordModal({super.key});

  @override
  State<ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // Şifre göster/gizle için değişkenler
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;



  Future<void> _changePassword() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      setState(() {
        _errorMessage = tr(
          'change_password.please_fill_all_fields',
        ); // Lokalize edildi
        _isLoading = false;
      });
      return;
    }

    if (newPass != confirmPass) {
      setState(() {
        _errorMessage = tr(
          'change_password.passwords_do_not_match',
        ); // Lokalize edildi
        _isLoading = false;
      });
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = tr('change_password.user_not_found'); // Lokalize edildi
        _isLoading = false;
      });
      return;
    }

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPass,
      );
      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(newPass);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('change_password.password_changed_successfully')),
        ), // Lokalize edildi
      );
      Navigator.of(context).pop();

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = tr(
          'change_password.error_occurred',
          args: [e.toString()],
        ); // Lokalize edildi
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
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

    final changePasswordButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFB74D),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      minimumSize: const Size.fromHeight(48),
    );

    if (_isLoading) {
      return SizedBox(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(color: Colors.orange[700]),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
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
            Text(
              tr('change_password.title'), // Lokalize edildi
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _oldPasswordController,
              decoration: inputDecoration.copyWith(
                labelText: tr(
                  'change_password.old_password',
                ), // Lokalize edildi
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOldPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureOldPassword = !_obscureOldPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureOldPassword,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPasswordController,
              decoration: inputDecoration.copyWith(
                labelText: tr(
                  'change_password.new_password',
                ), // Lokalize edildi
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureNewPassword,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: inputDecoration.copyWith(
                labelText: tr(
                  'change_password.confirm_new_password',
                ), // Lokalize edildi
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword, // Lokalize edildi
              style: changePasswordButtonStyle,
              child: Text(tr('change_password.change_password_button')),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
