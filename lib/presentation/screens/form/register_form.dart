import 'package:earthquake_mapp/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
          const SnackBar(
            content: Text("Şifreler eşleşmiyor"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Doğum tarihi seçiniz"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ViewModel üzerinden kayıt yap
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
        Navigator.pop(context); // Kayıt başarılı ise modalı kapat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kayıt başarılı! Giriş yapabilirsiniz."),
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
                // Tutamaç
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
        const Text(
          "Kayıt Ol - Adım 1",
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
          validator: (value) => value!.isEmpty ? "E-posta giriniz" : null,
          onSaved: (value) => email = value!,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Şifre",
            prefixIcon: Icon(FontAwesomeIcons.lock),
          ),
          obscureText: true,
          validator: (value) =>
              value!.length < 6 ? "Şifre en az 6 karakter olmalı" : null,
          onSaved: (value) => password = value!,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Şifre Tekrar",
            prefixIcon: Icon(FontAwesomeIcons.lock),
          ),
          obscureText: true,
          validator: (value) =>
              value!.isEmpty ? "Şifre tekrarını giriniz" : null,
          onSaved: (value) => confirmPassword = value!,
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _nextStep, child: const Text("Devam Et")),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Zaten kayıtlı mısın?"),
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
              icon: const Icon(FontAwesomeIcons.rightToBracket),
              label: const Text("Giriş Yap"),
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
        const Text(
          "Kayıt Ol - Adım 2",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Ad",
            prefixIcon: Icon(FontAwesomeIcons.user),
          ),
          validator: (value) => value!.isEmpty ? "Adınızı giriniz" : null,
          onSaved: (value) => firstName = value!,
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Soyad",
            prefixIcon: Icon(FontAwesomeIcons.user),
          ),
          validator: (value) => value!.isEmpty ? "Soyadınızı giriniz" : null,
          onSaved: (value) => lastName = value!,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _birthDateController,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: "Doğum Tarihi",
            prefixIcon: Icon(FontAwesomeIcons.calendarDays),
          ),
          onTap: () => _selectBirthDate(context),
          validator: (_) => birthDate == null ? "Doğum tarihi seçiniz" : null,
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _submit, child: const Text("Kayıt Ol")),
        const SizedBox(height: 10),
      ],
    );
  }
}
