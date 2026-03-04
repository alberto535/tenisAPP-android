/*
    Autor: Alberto Ortiz Arribas
    Fecha: 21-03-2025
    Resumen: Muestra los resultados de los partidos en la liga del usuario,
    seleccionando la jornada y la division.
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: ResultadosPartidos(),
    debugShowCheckedModeBanner: false,
  ));
}

class ResultadosPartidos extends StatefulWidget {
  @override
  _ResultadosPartidosState createState() => _ResultadosPartidosState();
}

class _ResultadosPartidosState extends State<ResultadosPartidos> {
  String? selectedDivision;
  String? selectedJornada;
  List<String> divisiones = [];
  List<String> jornadas = [];
  List<dynamic> partidos = [];
  String? correoUsuario;

  @override
  void initState() {
    super.initState();
    cargarCorreoUsuario();
  }

  Future<void> cargarCorreoUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    correoUsuario = prefs.getString('correo');

    print("Correo almacenado en SharedPreferences: $correoUsuario");

    if (correoUsuario != null && correoUsuario!.isNotEmpty) {
      fetchDivisionesYJornadas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No hay sesión iniciada")));
    }
  }

  Future<void> fetchDivisionesYJornadas() async {
    if (correoUsuario == null || correoUsuario!.isEmpty) {
      print("Error: El correo del usuario es nulo o vacío.");
      return;
    }

    final url = Uri.parse("http://192.168.252.122/android/get_divisiones_jornadas.php?correo=$correoUsuario");
    print("Llamando a: $url");
    final response = await http.get(url);
    print("Respuesta del servidor: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Respuesta: $data");

      if (data["success"]) {
        setState(() {
          divisiones = List<String>.from(data["divisiones"].map((d) => d.toString()));
          jornadas = List<String>.from(data["jornadas"].map((j) => j.toString()));

          if (divisiones.isNotEmpty) selectedDivision = divisiones.first;
          if (jornadas.isNotEmpty) selectedJornada = jornadas.first;

          if (selectedDivision != null && selectedJornada != null) {
            fetchPartidos();
          }
        });
      }

    } else {
      print("Error HTTP: ${response.statusCode}");
    }

    print("División seleccionada: $selectedDivision");
    print("Jornada seleccionada: $selectedJornada");
  }

  Future<void> fetchPartidos() async {
    final url = Uri.parse("http://192.168.252.122/android/get_partidos_resultados.php?division=$selectedDivision&id_jornada=$selectedJornada&correo=$correoUsuario");
    print("URL para obtener partidos: $url");

    final response = await http.get(url);
    print("Respuesta del servidor en fetchPartidos: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["success"]) {
        setState(() {
          partidos = data["partidos"];
        });
      } else {
        print("⚠️ No se encontraron partidos. Mensaje del servidor: ${data["message"]}");
        setState(() {
          partidos = [];
        });
      }
    } else {
      print("❌ Error HTTP: ${response.statusCode}");
      setState(() {
        partidos = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Resultados de Partidos")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedDivision,
              hint: Text("Seleccionar División"),
              isExpanded: true,
              items: divisiones.map((div) => DropdownMenuItem(value: div, child: Text(div))).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDivision = value;
                  fetchPartidos();
                });
              },
            ),
            DropdownButton<String>(
              value: selectedJornada,
              hint: Text("Seleccionar Jornada"),
              isExpanded: true,
              items: jornadas.map((jornada) => DropdownMenuItem(value: jornada, child: Text("Jornada $jornada"))).toList(),
              onChanged: (value) {
                setState(() {
                  selectedJornada = value;
                  fetchPartidos();
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: partidos.isEmpty
                  ? Center(child: Text("No hay partidos registrados"))
                  : ListView.builder(
                itemCount: partidos.length,
                itemBuilder: (context, index) {
                  final partido = partidos[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text("Participantes: ${partido["nombre_participantes"]}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("División: ${partido["division"]}"),
                          Text("Jornada: ${partido["id_jornada"]}"),
                          Text("Fecha: ${partido["fecha"]}"),
                          Text("Resultado: ${partido["resultado"]}"),
                          if (partido.containsKey("sets"))
                            Text("Sets: ${partido["sets"]}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
