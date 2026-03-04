/*
    Autor: Alberto Ortiz Arribas
    Fecha: 21-03-2025
    Resumen: Muestra la clasificacion de la liga del usuario que se logueo en el sistema.
*/

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clasificación Usuario',
      home: ClasificacionUserPage(),
    );
  }
}

class ClasificacionUserPage extends StatefulWidget {
  @override
  _ClasificacionPageState createState() => _ClasificacionPageState();
}

class _ClasificacionPageState extends State<ClasificacionUserPage> {
  String? correoUsuario;
  String? liga;
  String? divisionSeleccionada;
  List<String> divisiones = [];
  List<Map<String, dynamic>> clasificacion = [];

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    print("📢 Iniciando cargarDatosUsuario()...");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    correoUsuario = prefs.getString('correo');

    if (correoUsuario != null) {
      print("✅ Correo del usuario obtenido: $correoUsuario");
      obtenerLigaYDivisiones();
    } else {
      print("⚠️ No se encontró un correo en SharedPreferences.");
    }

    print("✅ Finalizando cargarDatosUsuario()");
  }

  Future<void> obtenerLigaYDivisiones() async {
    print("📢 Iniciando obtenerLigaYDivisiones()...");

    final response = await http.post(
      Uri.parse('http://192.168.252.122/android/obtener_liga.php'),
      body: {'correo': correoUsuario},
    );

    print('📡 Respuesta de obtener_liga.php: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.containsKey('error')) {
        print('❌ Error en obtener_liga.php: ${data['error']}');
      } else {
        setState(() {
          liga = data['liga'];
          divisiones = data['divisiones'].map<String>((e) => e.toString()).toList();
          print("✅ Liga obtenida: $liga");
          print("✅ Divisiones obtenidas: $divisiones");

          if (divisiones.isNotEmpty) {
            divisionSeleccionada = divisiones.first;
            obtenerClasificacion();
          }
        });

      }
    } else {
      print('❌ Error en la solicitud a obtener_liga.php, código: ${response.statusCode}');
    }

    print("✅ Finalizando obtenerLigaYDivisiones()");
  }

  Future<void> obtenerClasificacion() async {
    print("📢 Iniciando obtenerClasificacion()...");

    final response = await http.post(
      Uri.parse('http://192.168.252.122/android/obtener_clasificacion.php'),
      body: {'liga': liga, 'division': divisionSeleccionada},
    );

    print('📡 Respuesta de obtener_clasificacion.php: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List) {
        setState(() {
          clasificacion = List<Map<String, dynamic>>.from(data);
        });
        print("✅ Clasificación obtenida correctamente (Lista)");
      } else if (data is Map<String, dynamic> && data.containsKey('clasificacion')) {
        setState(() {
          clasificacion = List<Map<String, dynamic>>.from(data['clasificacion']);
        });
        print("✅ Clasificación obtenida correctamente (Mapa)");
      } else {
        print('⚠️ Formato inesperado en obtener_clasificacion.php');
      }
    } else {
      print('❌ Error en la solicitud, código: ${response.statusCode}');
    }

    print("✅ Finalizando obtenerClasificacion()");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clasificación')),
      body: Column(
        children: [
          if (divisiones.isNotEmpty)
            DropdownButton<String>(
              value: divisionSeleccionada,
              items: divisiones
                  .map((div) => DropdownMenuItem(value: div, child: Text(div)))
                  .toList(),
              onChanged: (newValue) {
                print("📢 Cambio de división a: $newValue");
                setState(() {
                  divisionSeleccionada = newValue;
                  obtenerClasificacion();
                });
              },
            ),
          Expanded(
            child: ListView.builder(
              itemCount: clasificacion.length,
              itemBuilder: (context, index) {
                final jugador = clasificacion[index];
                return ListTile(
                  leading: Text(
                    '${index + 1}', // Muestra la posición del jugador
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  title: Text('${jugador['nombre']} ${jugador['apellidos']}'),
                  subtitle: Text(
                      'Puntos: ${jugador['puntuaje']} | Buch: ${jugador['buch']} | M-Buch: ${jugador['m-buch']}'),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
