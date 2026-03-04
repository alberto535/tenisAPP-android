/*
    Autor: Alberto Ortiz Arribas
    Fecha: 06-04-2025
    Resumen: Muestra una lista de todos los partidos con estado igual a aceptado,
    y tiene la opcion de acabar la jornada actual.
 */
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JornadaActualPage extends StatefulWidget {
  final String liga;
  JornadaActualPage({required this.liga});

  @override
  _JornadaActualPageState createState() => _JornadaActualPageState();
}

class _JornadaActualPageState extends State<JornadaActualPage> {
  List<dynamic> partidos = [];

  @override
  void initState() {
    super.initState();
    _obtenerPartidos(); // Llamamos a la función de obtener partidos al inicio
  }

  Future<void> _obtenerPartidos() async {
    // Usamos el nombre de la liga actual en la URL
    final url = 'http://192.168.252.122/android/obtenerPartidosAceptados.php?liga=${widget.liga}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          partidos = data['matches']; // Asumimos que la respuesta tiene la estructura { 'matches': [ .. ] }
        });
      } else {
        // Si la respuesta es diferente a 200, muestra el error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener los partidos')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar al servidor')),
      );
    }
  }

  Future<void> _finalizarJornada() async {
    final url = 'http://192.168.252.122/android/acabar_jornada.php?liga=${widget.liga}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Todos los partidos aceptados han sido finalizados')),
        );
        _obtenerPartidos(); // Actualizar la lista después de finalizar los partidos
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al finalizar los partidos (status: ${response.statusCode})')),
        );
      }
    } catch (e) {
      print('Error en la petición: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar al servidor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jornada Actual - ${widget.liga}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Lista de partidos
            Expanded(
              child: ListView.builder(
                itemCount: partidos.length,
                itemBuilder: (context, index) {
                  final partido = partidos[index];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(partido['nombre_participantes']),
                      subtitle: Text('Resultado: ${partido['resultado']}'),
                    ),
                  );
                },
              ),
            ),
            // Botón para finalizar jornada
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: _finalizarJornada,
                child: Text('Finalizar Jornada'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Tamaño completo de ancho
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
