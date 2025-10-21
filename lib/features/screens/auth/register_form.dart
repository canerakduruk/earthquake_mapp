// Yeni provider dosyasını import edin
import 'package:earthquake_mapp/features/providers/auth_provider.dart';
import 'package:earthquake_mapp/features/screens/auth/login_form.dart';
import 'package:earthquake_mapp/shared/widgets/button/custom_button.dart';
import 'package:earthquake_mapp/shared/widgets/textfield/custom_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String confirmPassword = '';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('register.password_mismatch'.tr()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ref.read(authProvider.notifier).register(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      if (next is AsyncError) {
        // Hata mesajını göstermeden önce context'in hala geçerli olup olmadığını kontrol et
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      final User? previousUser = previous?.valueOrNull;
      final User? nextUser = next.valueOrNull;

      if (nextUser != null && previousUser == null) {
        // Pop ve SnackBar göstermeden önce context'in hala geçerli olup olmadığını kontrol et
        if (mounted) {
          Navigator.pop(context); // Modal'ı kapat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('register.register_success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        }
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
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  'register.title'.tr(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // --- TextFormField yerine CustomTextField ---
                CustomTextField(
                  labelText: 'register.email_label'.tr(),
                  prefixIcon: FontAwesomeIcons.envelope,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'register.email_empty'.tr() : null,
                  onSaved: (value) => email = value!,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  labelText: 'register.password_label'.tr(),
                  prefixIcon: FontAwesomeIcons.lock,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) => value!.length < 6
                      ? 'register.password_length'.tr()
                      : null,
                  onSaved: (value) => password = value!,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  labelText: 'register.password_confirm_label'.tr(),
                  prefixIcon: FontAwesomeIcons.lock,
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'register.password_confirm_empty'.tr();
                    }
                    return null; // Karşılaştırma _submit içinde yapılıyor
                  },
                  onSaved: (value) => confirmPassword = value!,
                ),

                // --- Bitti ---
                const SizedBox(height: 20),

                // --- ElevatedButton yerine CustomButton ---
                CustomButton(
                  onPressed: _submit,
                  iconData: FontAwesomeIcons.userPlus,
                  // İkonu değiştirebilirsiniz
                  labelText: 'register.register_button'.tr(),
                  isLoading: authState.isLoading,
                ),

                // --- Bitti ---
                const SizedBox(height: 10), // Aralık ekledim

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('register.already_registered'.tr()),
                    TextButton.icon(
                      onPressed: () {
                        // Önce mevcut modal'ı kapat
                        Navigator.pop(context);
                        // Sonra login formunu aç
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          // RegisterForm yerine LoginForm'u çağır
                          builder: (_) => const LoginForm(),
                        );
                      },
                      // Iconu değiştirebilirsiniz
                      icon: const Icon(
                        FontAwesomeIcons.rightToBracket,
                        size: 16,
                      ),
                      label: Text('register.login_button'.tr()),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Altına biraz daha boşluk
              ],
            ),
          ),
        ),
      ],
    );
  }
}
