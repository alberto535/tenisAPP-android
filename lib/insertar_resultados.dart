/*
    Autor: Alberto Ortiz Arribas
    Fecha: 23-03-2025
    Resumen: Muestra un formulario para introducir los datos del partido jugado
    y envia a su contrincante para que este los acepte o rechace.
*/

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registrar partido',
      home: RegistrarPartido(),
    );
  }
}

class RegistrarPartido extends StatefulWidget {
  @override
  _RegistrarPartidoState createState() => _RegistrarPartidoState();
}

class _RegistrarPartidoState extends State<RegistrarPartido> {
  TextEditingController setsController = TextEditingController();
  TextEditingController resultadoController = TextEditingController();
  TextEditingController fechaController = TextEditingController();

  String? divisionSeleccionada;
  String? ligaSeleccionada;
  String? participante;
  List<String> divisiones = [];
  List<String> ligas = [];
  List<String> participantes = [];

  // Contrincante
  String? nombreContrincante;
  String? apellidosContrincante;
  String? telefonoContrincante;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    String? correo = prefs.getString('correo');

    if (correo == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No hay sesión iniciada")));
      return;
    }

    var url = Uri.parse('http://192.168.252.122/android/obtenerDatos.php?correo=$correo');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      if (!data.containsKey("error")) {
        setState(() {
          divisiones = [data['division'].toString()];
          ligas = [data['liga'].toString()];
          participantes = [data['nombre_participantes'].toString()];
          divisionSeleccionada = divisiones.first;
          ligaSeleccionada = ligas.first;
          participante = participantes.first;
        });
      }
    }

    // Obtener datos del contrincante
    var urlInfo = Uri.parse('http://192.168.252.122/android/obtenerInfoContrincante.php?correo=$correo');
    var responseInfo = await http.get(urlInfo);
    print('Respuesta del servidor: ${response.body}'); // 👈 IMPORTANTE

    if (responseInfo.statusCode == 200) {
      var data = json.decode(responseInfo.body);
      if (!data.containsKey("error")) {
        setState(() {
          nombreContrincante = data['nombre'].toString();
          apellidosContrincante = data['apellidos'].toString();
          telefonoContrincante = data['telefono'].toString();
        });

      } else {
        print("Error: ${data['error']}");
      }
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        fechaController.text = "${fechaSeleccionada.year}-${fechaSeleccionada.month.toString().padLeft(2, '0')}-${fechaSeleccionada.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> registrarPartido() async {
    if (setsController.text.isEmpty ||
        resultadoController.text.isEmpty ||
        divisionSeleccionada == null ||
        ligaSeleccionada == null ||
        participante == null ||
        fechaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Todos los campos son obligatorios")));
      return;
    }

    print("Datos enviados al servidor: ");
    print('nombre_participantes: $participante');
    print('resultado: ${resultadoController.text}');
    print('sets: ${setsController.text}');
    print('division: $divisionSeleccionada');
    print('liga: $ligaSeleccionada');
    print('fecha: ${fechaController.text}');

    var url = Uri.parse('http://192.168.252.122/android/guardarNotificarPartido.php');
    var response = await http.post(url, body: {
      'nombre_participantes': participante,
      'resultado': resultadoController.text,
      'sets': setsController.text,
      'division': divisionSeleccionada,
      'liga': ligaSeleccionada,
      'fecha': fechaController.text,
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print("Respuesta del servidor: ${response.body}");  // Debugging the response
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));

      // Redirigir o realizar alguna acción adicional
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OtraPagina()));
    } else {
      print("Error en la respuesta: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al registrar el partido")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrar Partido")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField(
              value: participante,
              items: participantes.map((part) {
                return DropdownMenuItem(value: part, child: Text(part));
              }).toList(),
              onChanged: (value) => setState(() => participante = value.toString()),
              decoration: InputDecoration(labelText: "Participante"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: resultadoController,
              decoration: InputDecoration(labelText: "Resultado (Ej: 2-1)"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: setsController,
              decoration: InputDecoration(labelText: "Sets (Ej: 6-4, 4-6, 6-5)"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: fechaController,
              decoration: InputDecoration(
                labelText: "Fecha (YYYY-MM-DD)",
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _seleccionarFecha(context),
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              value: divisionSeleccionada,
              items: divisiones.map((div) {
                return DropdownMenuItem(value: div, child: Text(div));
              }).toList(),
              onChanged: (value) => setState(() => divisionSeleccionada = value.toString()),
              decoration: InputDecoration(labelText: "División"),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              value: ligaSeleccionada,
              items: ligas.map((liga) {
                return DropdownMenuItem(value: liga, child: Text(liga));
              }).toList(),
              onChanged: (value) => setState(() => ligaSeleccionada = value.toString()),
              decoration: InputDecoration(labelText: "Liga"),
            ),
            SizedBox(height: 20),

            // Mostrar info del contrincante
            if (nombreContrincante != null) ...[
              Text("Información del contrincante", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Nombre: $nombreContrincante $apellidosContrincante"),
              Text("Teléfono: $telefonoContrincante"),
              SizedBox(height: 20),
            ],

            ElevatedButton(
              onPressed: registrarPartido,
              child: Text("Registrar Partido"),
            ),
          ],
        ),
      ),
    );
  }
}
