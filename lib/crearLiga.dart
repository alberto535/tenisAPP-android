/*
    Autor: Alberto Ortiz Arribas
    Fecha: 30-03-2025
    Resumen: Aparece una lista y un checkbox a la lado de cada usuario que se
    encuentra sin liga, ni division y permite tambien poner un nombre a la liga.
 */
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registrar Liga',
      home: RegistrarLigaPage(),
    );
  }
}

class RegistrarLigaPage extends StatefulWidget {
  @override
  _RegistrarLigaPageState createState() => _RegistrarLigaPageState();
}

class _RegistrarLigaPageState extends State<RegistrarLigaPage> {
  final Dio dio = Dio();
  List<Map<String, dynamic>> usuarios = [];
  Map<String, int> divisionesSeleccionadas = {};
  List<String> seleccionados = [];
  TextEditingController nombreLigaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarUsuariosSinLiga();
  }

  Future<void> cargarUsuariosSinLiga() async {
    final url = "http://192.168.252.122/android/get_users_sin_liga.php";
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['usuarios'] is List) {
          setState(() {
            usuarios = List<Map<String, dynamic>>.from(data['usuarios']);
            for (var usuario in usuarios) {
              divisionesSeleccionadas[usuario['correo']] = 1;
            }
          });
        }
      }
    } catch (e) {
      print("Error al cargar usuarios: $e");
    }
  }

  Future<void> registrarLiga() async {
    final url = "http://192.168.252.122/android/registrar_liga.php";
    final nombreLiga = nombreLigaController.text.trim();

    if (nombreLiga.isEmpty || seleccionados.isEmpty) {
      print("⚠️ Debes ingresar un nombre de liga y seleccionar al menos un usuario.");
      return;
    }

    final dataToSend = {
      "nombre_liga": nombreLiga,
      "usuarios": seleccionados.map((correo) => {
        "correo": correo,
        "division": divisionesSeleccionadas[correo] ?? 1
      }).toList(),
    };

    final jsonString = jsonEncode(dataToSend);
    print("📤 Enviando datos: $jsonString");

    try {
      final response = await dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: dataToSend,
      );

      if (response.data == null) {
        print("🚨 Error: La respuesta del servidor es nula.");
        return;
      }

      print("📡 Código de respuesta: ${response.statusCode}");
      print("📩 Respuesta del servidor: ${response.data}");

      if (response.statusCode == 200) {
        print("✅ Liga registrada con éxito.");
        cargarUsuariosSinLiga();
      } else {
        print("⚠️ Error al registrar la liga: ${response.data}");
      }
    } catch (e) {
      print("🚨 Error al registrar la liga: $e");
      if (e is DioException) {
        print("📜 Respuesta del servidor: ${e.response?.data}");
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Nueva Liga')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nombreLigaController,
              decoration: InputDecoration(
                labelText: 'Nombre de la liga',
                border: OutlineInputBorder(),
              ),
            ),
            Expanded(
              child: usuarios.isEmpty
                  ? Center(child: Text('No hay usuarios disponibles'))
                  : ListView.builder(
                itemCount: usuarios.length,
                itemBuilder: (context, index) {
                  final usuario = usuarios[index];
                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text("${usuario['nombre']} ${usuario['apellidos']}"),
                        subtitle: Text("Correo: ${usuario['correo']}"),
                        value: seleccionados.contains(usuario['correo']),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              seleccionados.add(usuario['correo']);
                            } else {
                              seleccionados.remove(usuario['correo']);
                            }
                          });
                        },
                      ),
                      DropdownButton<int>(
                        value: divisionesSeleccionadas[usuario['correo']],
                        items: [1, 2, 3].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('División $value'),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            divisionesSeleccionadas[usuario['correo']] = newValue!;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: registrarLiga,
              child: Text('Registrar Liga'),
            ),
          ],
        ),
      ),
    );
  }
}
