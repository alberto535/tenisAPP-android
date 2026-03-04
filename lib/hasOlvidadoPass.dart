/*
    Autor: Alberto Ortiz Arribas
    Fecha: 08-04-2025
    Resumen: Genera un formulario para introducir el correo y mandar un correo
    para restablecer la contraseña.
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController correoController = TextEditingController();

  Future<void> enviarCorreo() async {
    print("👉 Iniciando enviarCorreo()");
    final url = Uri.parse('http://192.168.252.122/android/hasOlvidadoPass.php');

    try {
      print("📤 Enviando POST a $url con correo: ${correoController.text}");
      final response = await http.post(url, body: {'correo': correoController.text});
      print("📥 Respuesta recibida con statusCode: ${response.statusCode}");
      print("📦 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ JSON decodificado correctamente: $data");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Respuesta desconocida')),
        );
      } else {
        print("❌ Error en la respuesta del servidor");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el correo')),
        );
      }
    } catch (e) {
      print("🔥 Error en enviarCorreo(): $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excepción: $e')),
      );
    }

    print("✅ Finalizó enviarCorreo()");
  }

  @override
  Widget build(BuildContext context) {
    print("🛠️ build() ejecutado");
    return Scaffold(
      appBar: AppBar(title: Text('Olvidé mi contraseña')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: correoController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("🔘 Botón presionado");
                enviarCorreo();
              },
              child: Text('Enviar enlace de recuperación'),
            ),
          ],
        ),
      ),
    );
  }
}
