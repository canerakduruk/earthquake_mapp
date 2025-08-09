import 'package:earthquake_mapp/presentation/providers/auth_provider.dart';
import 'package:earthquake_mapp/presentation/screens/auth/login_form.dart';
import 'package:earthquake_mapp/presentation/viewmodels/auth_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
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
  int _step = 1;

  String email = '';
  String password = '';
  String confirmPassword = '';

  String firstName = '';
  String lastName = '';
  DateTime? birthDate;
  final TextEditingController _birthDateController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _step = 2;
      });
    }
  }

  Future<void> _submit() async {
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

      if (birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('register.birth_date_empty'.tr()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await ref
          .read(authViewModelProvider.notifier)
          .signUp(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate!,
          );

      final error = ref.read(authViewModelProvider).error;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('register.register_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'register.select_date'.tr(),
    );
    if (picked != null) {
      setState(() {
        birthDate = picked;
        _birthDateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authViewModelProvider).isLoading;

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
                if (_step == 1) _buildStep1(),
                if (_step == 2) _buildStep2(),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'register.step1_title'.tr(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'register.email_label'.tr(),
            prefixIcon: const Icon(FontAwesomeIcons.envelope),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) =>
              value!.isEmpty ? 'register.email_empty'.tr() : null,
          onSaved: (value) => email = value!,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'register.password_label'.tr(),
            prefixIcon: const Icon(FontAwesomeIcons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          obscureText: !_isPasswordVisible,
          validator: (value) =>
              value!.length < 6 ? 'register.password_length'.tr() : null,
          onSaved: (value) => password = value!,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'register.password_confirm_label'.tr(),
            prefixIcon: const Icon(FontAwesomeIcons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
          ),
          obscureText: !_isConfirmPasswordVisible,
          validator: (value) =>
              value!.isEmpty ? 'register.password_confirm_empty'.tr() : null,
          onSaved: (value) => confirmPassword = value!,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _nextStep,
          child: Text('register.next_button'.tr()),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('register.already_registered'.tr()),
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
                  builder: (_) => const LoginForm(),
                );
              },
              icon: const Icon(FontAwesomeIcons.rightToBracket),
              label: Text('register.login_button'.tr()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'register.step2_title'.tr(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'register.first_name_label'.tr(),
            prefixIcon: const Icon(FontAwesomeIcons.user),
          ),
          validator: (value) =>
              value!.isEmpty ? 'register.first_name_empty'.tr() : null,
          onSaved: (value) => firstName = value!,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'register.last_name_label'.tr(),
            prefixIcon: const Icon(FontAwesomeIcons.user),
          ),
          validator: (value) =>
              value!.isEmpty ? 'register.last_name_empty'.tr() : null,
          onSaved: (value) => lastName = value!,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _birthDateController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'register.birth_date_label'.tr(),
            prefixIcon: const Icon(FontAwesomeIcons.calendarDays),
          ),
          onTap: () => _selectBirthDate(context),
          validator: (_) =>
              birthDate == null ? 'register.birth_date_empty'.tr() : null,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submit,
          child: Text('register.register_button'.tr()),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
