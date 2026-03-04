/*
    Autor: Alberto Ortiz Arribas
    Fecha: 31-03-2025
    Resumen: Muestra las ligas que tengan fecha de finalizacion y se les pueden
    hacer dos cosas: consultar la clasificacion o consultar los resultados.
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tfgandroid/resultados_admin.dart';
import 'package:tfgandroid/clasificacion-admin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ligas Finalizadas',
      home: LigasPage(),
    );
  }
}

class LigasPage extends StatefulWidget {
  @override
  _LigasPageState createState() => _LigasPageState();
}

class _LigasPageState extends State<LigasPage> {
  List<Map<String, dynamic>> ligas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    obtenerLigas();
  }

  Future<void> obtenerLigas() async {
    final url = Uri.parse('http://192.168.252.122/android/get_ligas.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ligas = List<Map<String, dynamic>>.from(data['ligas']);
        });
      } else {
        mostrarMensaje('Error al cargar las ligas');
      }
    } catch (e) {
      mostrarMensaje('Error de conexión');
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ligas Finalizadas')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: cargando
            ? Center(child: CircularProgressIndicator())
            : ligas.isEmpty
            ? Center(child: Text('No hay ligas pasadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
            : ListView(
          children: ligas.map((liga) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text(liga['nombre'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Creada: ${liga['fecha_creacion']} - Finalizada: ${liga['fecha_finalizacion']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultadosAdminPage(liga['nombre']),
                          ),
                        );
                      },
                      child: Text('Resultados'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClasificacionAdminPage(liga['nombre']),
                          ),
                        );
                      },
                      child: Text('Clasificación'),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
