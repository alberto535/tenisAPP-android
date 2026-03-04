import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordPage extends StatefulWidget {
  final String token;

  ResetPasswordPage({required this.token});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController passwordController = TextEditingController();

  Future<void> resetPassword() async {
    final url = Uri.parse('http://192.168.252.122/android/recuperarPass.php');
    final response = await http.post(url, body: {
      'token': widget.token,
      'password': passwordController.text,
    });

    if (response.statusCode == 200) {
      final data = response.body;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restablecer contraseña')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Restablecer contraseña')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Nueva contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetPassword,
              child: Text('Restablecer contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}
