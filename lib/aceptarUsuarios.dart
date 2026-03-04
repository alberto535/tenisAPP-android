/*
    Autor: Alberto Ortiz Arribas
    Fecha: 28-03-2025
    Resumen: Muestra una lista con los usuarios registrados que NO estan aceptados
    en el sistema y el administrador decide si los acepta o rechaza.
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Usuarios',
      home: UsuariosPendientesPage(),
    );
  }
}

class UsuariosPendientesPage extends StatefulWidget {
  @override
  _UsuariosPendientesPageState createState() => _UsuariosPendientesPageState();
}

class _UsuariosPendientesPageState extends State<UsuariosPendientesPage> {
  List<Map<String, dynamic>> usuariosPendientes = [];
  List<Map<String, dynamic>> usuariosFiltrados = [];
  Map<String, bool> seleccionados = {};
  TextEditingController filtroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarUsuariosPendientes();
    filtroController.addListener(filtrarUsuarios);
  }

  Future<void> cargarUsuariosPendientes() async {
    final url = Uri.parse('http://192.168.252.122/android/aceptarUsuariosPendientes.php');

    print("🔍 Intentando conectar a: $url");

    try {
      final response = await http.get(url);
      print("📡 Código de respuesta: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Datos recibidos: $data");

        setState(() {
          usuariosPendientes = List<Map<String, dynamic>>.from(data['usuarios'] ?? []);
          usuariosFiltrados = List.from(usuariosPendientes);
          seleccionados = {for (var usuario in usuariosPendientes) usuario['correo']: false};
        });
      } else {
        print("❌ Error en la respuesta del servidor: ${response.body}");
        mostrarMensaje('Error al cargar usuarios');
      }
    } catch (e) {
      print("🚨 Error de conexión: $e");
      mostrarMensaje('Error de conexión: $e');
    }
  }


  void filtrarUsuarios() {
    String filtro = filtroController.text.toLowerCase().trim();
    setState(() {
      usuariosFiltrados = usuariosPendientes.where((usuario) {
        return usuario.values
            .whereType<String>() // Solo filtra en valores tipo String
            .any((valor) => valor.toLowerCase().contains(filtro));
      }).toList();
    });
  }

  Future<void> gestionarUsuarios(String accion) async {
    final seleccionadosCorreo = seleccionados.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (seleccionadosCorreo.isEmpty) {
      mostrarMensaje('Seleccione al menos un usuario');
      return;
    }

    final url = Uri.parse('http://192.168.252.122/android/aceptarUsuarios.php');
    try {
      final response = await http.post(url, body: {
        'accion': accion,
        'correos': json.encode(seleccionadosCorreo),
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        mostrarMensaje(data['message'] ?? 'Operación realizada');
        cargarUsuariosPendientes();
      } else {
        mostrarMensaje('Error al gestionar usuarios');
      }
    } catch (e) {
      mostrarMensaje('Error de conexión');
    }
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios Pendientes'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: filtroController,
              decoration: InputDecoration(
                labelText: 'Buscar usuario',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  columns: [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Apellidos')),
                    DataColumn(label: Text('DNI')),
                    DataColumn(label: Text('Teléfono')),
                    DataColumn(label: Text('Correo')),
                    DataColumn(label: Text('Fecha de Nacimiento')),
                    DataColumn(label: Text('Seleccionar')),
                  ],
                  rows: usuariosFiltrados.map((usuario) {
                    return DataRow(cells: [
                      DataCell(Text(usuario['nombre'] ?? '')),
                      DataCell(Text(usuario['apellidos'] ?? '')),
                      DataCell(Text(usuario['dni'] ?? '')),
                      DataCell(Text(usuario['telefono'] ?? '')),
                      DataCell(Text(usuario['correo'] ?? '')),
                      DataCell(Text(usuario['fechanacimiento'] ?? '')),
                      DataCell(
                        Checkbox(
                          value: seleccionados[usuario['correo']] ?? false,
                          onChanged: (bool? value) {
                            setState(() {
                              seleccionados[usuario['correo']] = value ?? false;
                            });
                          },
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => gestionarUsuarios('aceptar'),
                  child: Text('Aceptar'),
                ),
                ElevatedButton(
                  onPressed: () => gestionarUsuarios('rechazar'),
                  child: Text('Rechazar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
