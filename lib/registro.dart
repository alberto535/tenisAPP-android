/*
    Autor: Alberto Ortiz Arribas
    Fecha: 16-03-2025
    Resumen: Muestra un formulario para el registro de nuevos usuarios a nuestro sistema,
    tiene una serie de comprobantes para la contraseña.
*/

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registrar',
      home: RegistroPage(),
    );
  }
}

class RegistroPage extends StatefulWidget {
  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final dniController = TextEditingController();
  final fechaNacimientoController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();
  final confirmarContrasenaController = TextEditingController();

  String? validarContrasena(String? value) {
    final regex = RegExp(r'^(?=.*[!@#$%^&*(),.?":{}|<>])');
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa una contraseña';
    } else if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    } else if (!regex.hasMatch(value)) {
      return 'La contraseña debe incluir al menos un carácter especial (!, @, #, etc.)';
    }
    return null;
  }

  Future<void> registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      if (contrasenaController.text != confirmarContrasenaController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }

      final url = Uri.parse('http://192.168.252.122/android/registrar.php');
      final response = await http.post(url, body: {
        'nombre': nombreController.text,
        'apellidos': apellidosController.text,
        'dni': dniController.text,
        'fecha_nacimiento': fechaNacimientoController.text,
        'telefono': telefonoController.text,
        'correo': correoController.text,
        'contraseña': contrasenaController.text,
        'confirm_password': confirmarContrasenaController.text,
      });
      print("🔍 Respuesta del servidor cruda: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['message'] == 'Registro exitoso') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuario registrado exitosamente')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar el usuario')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Usuario')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, ingresa tu nombre'
                    : null,
              ),
              TextFormField(
                controller: apellidosController,
                decoration: InputDecoration(labelText: 'Apellidos'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, ingresa tus apellidos'
                    : null,
              ),
              TextFormField(
                controller: dniController,
                decoration: InputDecoration(labelText: 'DNI'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, ingresa tu DNI'
                    : null,
              ),
              TextFormField(
                controller: fechaNacimientoController,
                decoration: InputDecoration(labelText: 'Fecha de Nacimiento'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, ingresa tu fecha de nacimiento'
                    : null,
              ),
              TextFormField(
                controller: telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, ingresa tu teléfono'
                    : null,
              ),
              TextFormField(
                controller: correoController,
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
                validator: (value) => value == null || !value.contains('@')
                    ? 'Por favor, ingresa un correo válido'
                    : null,
              ),
              TextFormField(
                controller: contrasenaController,
                decoration: InputDecoration(labelText: 'Contraseña con caracteres como: @\$!%*?&'
                ),
                obscureText: true,
                validator: validarContrasena,
              ),
              TextFormField(
                controller: confirmarContrasenaController,
                decoration: InputDecoration(labelText: 'Confirmar Contraseña'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, confirma tu contraseña'
                    : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: registrarUsuario,
                child: Text('Registrar'),
              ),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text('Acceder al login'),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
