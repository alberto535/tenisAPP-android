/*
    Autor: Alberto Ortiz Arribas
    Fecha: 25-03-2025
    Resumen: Muestra una lista con los partidos en estado pendiente en el
    que el usuario logueado actua como visitante, y tiene la opcion de
    aceptarlo o rechazarlo.
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AceptarPartido extends StatefulWidget {
  @override
  _AceptarPartidoState createState() => _AceptarPartidoState();
}

class _AceptarPartidoState extends State<AceptarPartido> {
  List<dynamic> partidosPendientes = [];
  String nombreUsuario = "Cargando...";
  late Dio dio;

  @override
  void initState() {
    super.initState();
    dio = Dio();
    obtenerUsuario();
  }

  /// Obtiene el usuario desde SharedPreferences
  Future<void> obtenerUsuario() async {
    print("📢 Ejecutando obtenerUsuario()...");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuarioGuardado = prefs.getString('correo');

    if (usuarioGuardado != null && usuarioGuardado.isNotEmpty) {
      print("✅ Usuario encontrado en SharedPreferences: $usuarioGuardado");
      setState(() {
        nombreUsuario = usuarioGuardado;
      });
      cargarPartidos(usuarioGuardado);  // 🔍 Verificamos si esto se ejecuta
    } else {
      print("⚠️ Usuario no encontrado en SharedPreferences");
      setState(() {
        nombreUsuario = 'Usuario no autenticado';
      });
    }
  }

  /// Guarda el usuario en SharedPreferences (útil para iniciar sesión)
  Future<void> guardarUsuario(String correo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('correo', correo);
  }

  /// Carga los partidos pendientes con el usuario como parámetro GET
  Future<void> cargarPartidos(String correo) async {
    print("📢 Ejecutando cargarPartidos() para usuario: $correo");

    try {
      String url = 'http://192.168.252.122/android/get_partidos.php?nombreUsuario=$correo';
      print("🌍 URL solicitada: $url");

      var response = await dio.get(url);

      print("📡 Código de estado HTTP: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Respuesta recibida: ${response.data}");

        var data = response.data;
        if (!data.containsKey('matches')) {
          print("⚠️ Clave 'matches' no encontrada en la respuesta.");
          return;
        }

        setState(() {
          partidosPendientes = data['matches'];
        });

        print("🎾 Partidos cargados: $partidosPendientes");
      } else {
        print("❌ Error HTTP: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Excepción al cargar partidos: $e");
    }
  }

  /// Actualiza el estado de un partido
  Future<void> actualizarEstadoPartido(int id, String accion) async {
    try {
      await dio.post(
        'http://192.168.252.122/android/actualizar_estado_partido.php',
        data: {'id': id.toString(), 'accion': accion},
      );
      cargarPartidos(nombreUsuario); // Recargar partidos después de actualizar
    } catch (e) {
      print("Error actualizando estado del partido: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Aceptar/Rechazar Partido")),
      body: partidosPendientes.isEmpty
          ? Center(child: Text("No hay partidos pendientes"))
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Bienvenido, $nombreUsuario",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: partidosPendientes.length,
              itemBuilder: (context, index) {
                var partido = partidosPendientes[index];
                return Card(
                  child: ListTile(
                    title: Text("${partido['nombre_participantes']} - ${partido['resultado']}"),
                    subtitle: Text("División: ${partido['division']} | Sets: ${partido['sets']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => actualizarEstadoPartido(partido['id'], "aceptar"),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => actualizarEstadoPartido(partido['id'], "rechazar"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
