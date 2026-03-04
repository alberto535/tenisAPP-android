import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'borrar_usuario.dart';
import 'registro.dart';
import 'crearLiga.dart';
import 'aceptarUsuarios.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text('Bienvenido!'),
      ),
    );
  }
}
