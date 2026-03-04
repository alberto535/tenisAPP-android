/*
    Autor: Alberto Ortiz Arribas
    Fecha: 17-03-2025
    Resumen: Muestra el menu de inicio para el administrador.
*/


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tfgandroid/aceptarUsuarios.dart';
import 'package:tfgandroid/h_administrar_ligas.dart';
import 'package:tfgandroid/borrar_usuario.dart';
import 'package:tfgandroid/login_screen.dart'; // Importar pantalla de login

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inicio',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String responseText = "Pulse para ejecutar código PHP";

  Future<void> ejecutarPHP() async {
    final url = Uri.parse("http://192.168.252.122/android/rellenarTablaClasificacion.php");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          responseText = "Respuesta del servidor: ${response.body}";
        });
      } else {
        setState(() {
          responseText = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        responseText = "Error de conexión: $e";
      });
    }
  }

  void cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Redirigir a login
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página de Inicio'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: cerrarSesion, // Botón para cerrar sesión
            tooltip: "Cerrar sesión",
          ),
        ],
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/tenis2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Contenido principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UsuariosPendientesPage()),
                    );
                  },
                  child: Text('Aceptar Usuarios'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GestionLigasPage()),
                    );
                  },
                  child: Text('Administrar ligas'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UsuarioPage()),
                    );
                  },
                  child: Text('Borrar usuarios'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
