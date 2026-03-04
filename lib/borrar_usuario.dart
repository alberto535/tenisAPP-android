/*
    Autor: Alberto Ortiz Arribas
    Fecha: 26-03-2025
    Resumen: Muestra una lista con los usuarios registrados en el sistema,
    y un checkbox para seleccionarlos y eliminarlos de las bases de datos.
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
      home: UsuarioPage(),
    );
  }
}

class UsuarioPage extends StatefulWidget {
  @override
  _UsuarioPageState createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  List<Map<String, dynamic>> usuarios = [];
  List<Map<String, dynamic>> usuariosFiltrados = [];
  Map<String, bool> seleccionados = {};
  bool todosSeleccionados = false; // Estado de selección global
  TextEditingController filtroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
    filtroController.addListener(_filtrarUsuarios);
  }

  Future<void> cargarUsuarios() async {
    final url = Uri.parse('http://192.168.252.122/android/get_users.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          usuarios = List<Map<String, dynamic>>.from(data['usuarios']);
          usuariosFiltrados = List.from(usuarios);
          seleccionados = {for (var usuario in usuarios) usuario['correo']: false};
          todosSeleccionados = false; // Reiniciar el estado global
        });
      } else {
        _mostrarMensaje('Error al cargar usuarios');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión');
    }
  }

  void _filtrarUsuarios() {
    String query = filtroController.text.toLowerCase().trim();
    setState(() {
      usuariosFiltrados = usuarios.where((usuario) {
        return usuario.entries.any((entry) {
          final valor = entry.value?.toString().toLowerCase() ?? '';
          return valor.contains(query);
        });
      }).toList();
    });
  }

  void _seleccionarTodos() {
    setState(() {
      todosSeleccionados = !todosSeleccionados;
      for (var usuario in usuariosFiltrados) {
        seleccionados[usuario['correo']] = todosSeleccionados;
      }
    });
  }

  Future<void> eliminarUsuariosSeleccionados() async {
    final url = Uri.parse('http://192.168.252.122/android/delete_user.php');
    final correosSeleccionados = seleccionados.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (correosSeleccionados.isEmpty) {
      _mostrarMensaje('No se seleccionaron usuarios para eliminar');
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'correos': correosSeleccionados}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _mostrarMensaje(data['message'] ?? 'Usuarios eliminados');
        cargarUsuarios(); // Recargar la tabla después de la eliminación
      } else {
        _mostrarMensaje('Error al eliminar usuarios');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión');
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Usuarios')),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _seleccionarTodos,
                  child: Text(todosSeleccionados ? 'Deseleccionar Todos' : 'Seleccionar Todos'),
                ),
                ElevatedButton(
                  onPressed: eliminarUsuariosSeleccionados,
                  child: Text('Eliminar Seleccionados'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: usuariosFiltrados.isEmpty
                  ? Center(child: Text('No se encontraron usuarios'))
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20.0,
                  columns: [
                    DataColumn(label: Text('Seleccionar')),
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Apellidos')),
                    DataColumn(label: Text('Teléfono')),
                    DataColumn(label: Text('DNI')),
                    DataColumn(label: Text('Nacimiento')),
                    DataColumn(label: Text('Correo')),
                  ],
                  rows: usuariosFiltrados.map((usuario) {
                    return DataRow(
                      cells: [
                        DataCell(Checkbox(
                          value: seleccionados[usuario['correo']] ?? false,
                          onChanged: (bool? value) {
                            setState(() {
                              seleccionados[usuario['correo']] = value ?? false;
                            });
                          },
                        )),
                        DataCell(Text(usuario['nombre'] ?? '')),
                        DataCell(Text(usuario['apellidos'] ?? '')),
                        DataCell(Text(usuario['telefono'] ?? '')),
                        DataCell(Text(usuario['dni'] ?? '')),
                        DataCell(Text(usuario['fechanacimiento'] ?? '')),
                        DataCell(Text(usuario['correo'] ?? '')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
