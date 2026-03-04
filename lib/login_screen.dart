/*
    Autor: Alberto Ortiz Arribas
    Fecha: 16-03-2025
    Resumen: Guarda en con shared preferences algunos datos acerca del usuario que se loguea,
    y muestra un formulario para introducir correo y contraseña para iniciar sesion.
*/


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'home.dart';
import 'home_screen.dart';
import 'hasOlvidadoPass.dart';
import 'registro.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iniciar sesión',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Dio dio = Dio();
  final CookieJar cookieJar = CookieJar();

  LoginPage() {
    dio.interceptors.add(CookieManager(cookieJar)); // Habilitar manejo de cookies
  }

  void iniciarSesion(BuildContext context) async {
    final url = 'http://192.168.252.122/android/login.php';

    try {
      final response = await dio.post(
        url,
        options: Options(headers: {"Content-Type": "application/x-www-form-urlencoded"}),
        data: {
          "correo": correoController.text,
          "contraseña": passwordController.text,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        bool success = responseData['success'] ?? false;
        if (success) {
          String role = responseData['role'] ?? 'user';
          String correo = correoController.text; // Guardar el correo ingresado

          // Guardar el correo en SharedPreferences
          await guardarCorreo(correo);

          // Extraer cookies correctamente
          List<Cookie> cookies = response.headers['set-cookie']
              ?.map((cookie) => Cookie.fromSetCookieValue(cookie))
              ?.toList() ?? [];

          await cookieJar.saveFromResponse(Uri.parse(url), cookies);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => role == 'admin' ? HomePage() : UserHomePage(),
            ),
          );
        } else {
          mostrarMensajeError(context, responseData['message'] ?? "Error desconocido");
        }
      } else {
        mostrarMensajeError(context, "Error en el servidor: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al iniciar sesión: $e");
      mostrarMensajeError(context, "Error de conexión: $e");
    }
  }


  void mostrarMensajeError(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> guardarCorreo(String correo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('correo', correo);
    print("Correo guardado: $correo"); // 👀 Verifica si se guarda
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/tenis.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.white.withOpacity(0.8),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: correoController,
                          decoration: InputDecoration(labelText: 'Correo'),
                        ),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(labelText: 'Contraseña'),
                          obscureText: true,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => iniciarSesion(context),
                          child: Text('Iniciar Sesión'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                            );
                          },
                          child: Text('¿Has olvidado la contraseña?'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegistroPage()),
                            );
                          },
                          child: Text('Registrarse'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
