// Yeni provider dosyasını import ediyoruz (dosya yolunuzu doğrulayın)
import 'package:earthquake_mapp/features/providers/auth_provider.dart';
import 'package:earthquake_mapp/features/screens/auth/register_form.dart';
import 'package:earthquake_mapp/shared/widgets/button/custom_button.dart';
import 'package:earthquake_mapp/shared/widgets/textfield/custom_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _obscurePassword = true;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ref.read(authProvider.notifier).login(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }

      final User? previousUser = previous?.valueOrNull;
      final User? nextUser = next.valueOrNull;

      if (nextUser != null && previousUser == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('login.login_success'.tr())));
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
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                Text(
                  'login.title'.tr(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  labelText: 'login.email_label'.tr(),
                  prefixIcon: FontAwesomeIcons.envelope,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'login.email_empty'.tr() : null,
                  onSaved: (value) => email = value!,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  labelText: 'login.password_label'.tr(),
                  prefixIcon: FontAwesomeIcons.lock,
                  obscureText: _obscurePassword,
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
                  validator: (value) =>
                      value!.length < 6 ? 'login.password_length'.tr() : null,
                  onSaved: (value) => password = value!,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  onPressed: _submit,
                  iconData: FontAwesomeIcons.rightToBracket,
                  labelText: 'login.login_button'.tr(),
                  isLoading: authState.isLoading,
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('login.no_account'.tr()),
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
                      label: Text('login.register_button'.tr()),
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
