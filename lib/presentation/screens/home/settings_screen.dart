import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionTitle("Genel"),
          _buildTile(FontAwesomeIcons.moon, "Tema", "Açık / Koyu Mod"),
          _buildTile(FontAwesomeIcons.language, "Dil", "Uygulama Dili"),

          const SizedBox(height: 24),
          _buildSectionTitle("Bildirimler"),
          _buildTile(FontAwesomeIcons.bell, "Uygulama Bildirimleri"),
          _buildTile(FontAwesomeIcons.envelope, "E-posta Bildirimleri"),
          _buildTile(FontAwesomeIcons.clock, "Sessiz Saatler"),

          const SizedBox(height: 24),
          _buildSectionTitle("Yardım ve Destek"),
          _buildTile(FontAwesomeIcons.commentDots, "Geri Bildirim Gönder"),
          _buildTile(FontAwesomeIcons.circleQuestion, "SSS"),
          _buildTile(FontAwesomeIcons.headset, "Destek ile İletişim"),

          const SizedBox(height: 24),
          _buildSectionTitle("Hakkında"),
          _buildTile(FontAwesomeIcons.circleInfo, "Uygulama Sürümü", "v1.0.0"),
          _buildTile(FontAwesomeIcons.userShield, "Gizlilik Politikası"),
          _buildTile(FontAwesomeIcons.fileContract, "Kullanım Şartları"),
          _buildTile(FontAwesomeIcons.codeBranch, "Açık Kaynak Lisansları"),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, [String? subtitle]) {
    return ListTile(
      leading: FaIcon(icon, size: 20),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
