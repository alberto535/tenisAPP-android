/*
    Autor: Alberto Ortiz Arribas
    Fecha: 03-04-2025
    Resumen: Muestra una lista con los resultados de la liga seleccionada,
     y tienes la posibilidad de seleccionar jornada y division.
 */
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultadosAdminPage extends StatefulWidget {
  final String liga;
  ResultadosAdminPage(this.liga);

  @override
  _ResultadosAdminPageState createState() => _ResultadosAdminPageState();
}

class _ResultadosAdminPageState extends State<ResultadosAdminPage> {
  List<Map<String, dynamic>> resultados = [];
  List<Map<String, dynamic>> resultadosFiltrados = [];
  List<String> divisiones = [];
  List<String> jornadas = [];
  String? divisionSeleccionada;
  String? jornadaSeleccionada;

  @override
  void initState() {
    super.initState();
    obtenerResultados();
  }

  Future<void> obtenerResultados() async {
    final url = Uri.parse('http://192.168.252.122/android/get_resultados.php?liga=${widget.liga}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          resultados = List<Map<String, dynamic>>.from(data['partidos']);
          resultadosFiltrados = List.from(resultados);
          _extraerFiltros();
        });
      } else {
        mostrarMensaje('Error al cargar los resultados');
      }
    } catch (e) {
      mostrarMensaje('Error de conexión');
    }
  }

  void _extraerFiltros() {
    Set<String> divisionesSet = {};
    Set<String> jornadasSet = {};

    for (var partido in resultados) {
      divisionesSet.add(partido['division'].toString());
      jornadasSet.add(partido['id_jornada'].toString());
    }

    setState(() {
      divisiones = divisionesSet.toList();
      jornadas = jornadasSet.toList();
    });
  }

  void _filtrarResultados() {
    setState(() {
      resultadosFiltrados = resultados.where((partido) {
        final coincideDivision = divisionSeleccionada == null || partido['division'].toString() == divisionSeleccionada;
        final coincideJornada = jornadaSeleccionada == null || partido['id_jornada'].toString() == jornadaSeleccionada;
        return coincideDivision && coincideJornada;
      }).toList();
    });
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resultados - ${widget.liga}')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    hint: Text('Seleccionar División'),
                    value: divisionSeleccionada,
                    isExpanded: true,
                    items: divisiones.map((div) {
                      return DropdownMenuItem(value: div, child: Text(div));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        divisionSeleccionada = value;
                        _filtrarResultados();
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    hint: Text('Seleccionar Jornada'),
                    value: jornadaSeleccionada,
                    isExpanded: true,
                    items: jornadas.map((jornada) {
                      return DropdownMenuItem(value: jornada, child: Text(jornada));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        jornadaSeleccionada = value;
                        _filtrarResultados();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: resultadosFiltrados.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20.0,
                  columns: [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('Resultado')),
                    DataColumn(label: Text('Sets')),
                    DataColumn(label: Text('Jugadores')),
                    DataColumn(label: Text('División')),
                    DataColumn(label: Text('Jornada')),
                    DataColumn(label: Text('Liga')),
                  ],
                  rows: resultadosFiltrados.map((partido) {
                    return DataRow(
                      cells: [
                        DataCell(Text(partido['id'].toString())),
                        DataCell(Text(partido['fecha'])),
                        DataCell(Text(partido['resultado'])),
                        DataCell(Text(partido['sets'])),
                        DataCell(Text(partido['nombre_participantes'])),
                        DataCell(Text(partido['division'].toString())),
                        DataCell(Text(partido['id_jornada'].toString())),
                        DataCell(Text(partido['liga'])),
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
