/*
    Autor: Alberto Ortiz Arribas
    Fecha: 20-03-2025
    Resumen: Muestra y permite editar los datos del usuario autenticado,
    usando SharedPreferences para obtener su correo.
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inicio',
      home: EditProfilePage(),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController fechaNacimientoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final correo = prefs.getString('correo');

    if (correo != null && correo.isNotEmpty) {
      final url = Uri.parse('http://192.168.252.122/android/buscar_usuario_por_correo.php');

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: {"correo": correo},
        );

        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          final data = responseData['data'];
          setState(() {
            nombreController.text = data['nombre'] ?? '';
            apellidosController.text = data['apellidos'] ?? '';
            correoController.text = data['correo'] ?? '';
            fechaNacimientoController.text = data['fecha_nacimiento']?.toString() ?? '';
            telefonoController.text = data['telefono']?.toString() ?? '';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? "Error desconocido")),
          );
        }
      } catch (e) {
        print("Error al procesar la respuesta: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al procesar los datos del servidor")),
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> actualizarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final correo = prefs.getString('correo');

    if (correo == null || correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Correo no disponible")));
      return;
    }

    final url = Uri.parse('http://192.168.252.122/android/actualizar_usuario_por_correo.php');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "correo": correo,
          "nombre": nombreController.text,
          "apellidos": apellidosController.text,
          "fecha_nacimiento": fechaNacimientoController.text,
          "telefono": telefonoController.text,
        },
      );

      final responseData = jsonDecode(response.body);
      final mensaje = responseData['message'] ?? "Error desconocido";

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error de red: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editar Perfil")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: apellidosController,
              decoration: InputDecoration(labelText: "Apellidos"),
            ),
            TextField(
              controller: correoController,
              decoration: InputDecoration(labelText: "Correo"),
              enabled: false, // el correo no debe poder editarse
            ),
            TextField(
              controller: fechaNacimientoController,
              decoration: InputDecoration(labelText: "Fecha de Nacimiento"),
            ),
            TextField(
              controller: telefonoController,
              decoration: InputDecoration(labelText: "Teléfono"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: actualizarUsuario,
              child: Text("Actualizar Usuario"),
            ),
          ],
        ),
      ),
    );
  }
}
