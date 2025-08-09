import 'package:earthquake_mapp/core/utils/logger_helper.dart';
import 'package:earthquake_mapp/presentation/providers/auth_provider.dart';
import 'package:earthquake_mapp/presentation/screens/auth/register_form.dart';
import 'package:earthquake_mapp/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _obscurePassword = true; // 👀 Şifre göster/gizle

  void _submit() {
    LoggerHelper.info("Login Form", "signIn çağrılıyor");

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ref.read(authViewModelProvider.notifier).signIn(email, password);
      LoggerHelper.info("Login Form", "Çalıştı");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }

      if (next.user != null && previous?.user == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Başarıyla giriş yapıldı')),
        );
      }
    });

    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 📌 Modal tutamacı
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const Text(
                  "Giriş Yap",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "E-posta",
                    prefixIcon: Icon(FontAwesomeIcons.envelope),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? "E-posta giriniz" : null,
                  onSaved: (value) => email = value!,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Şifre",
                    prefixIcon: const Icon(FontAwesomeIcons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) => value!.length < 6
                      ? "Şifre en az 6 karakter olmalı"
                      : null,
                  onSaved: (value) => password = value!,
                ),
                const SizedBox(height: 20),

                authState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(FontAwesomeIcons.rightToBracket),
                        label: const Text("Giriş Yap"),
                      ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Hesabın yok mu?"),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (_) => const RegisterForm(),
                        );
                      },
                      icon: const Icon(FontAwesomeIcons.userPlus),
                      label: const Text("Kayıt Ol"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
