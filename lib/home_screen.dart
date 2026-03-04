/*
    Autor: Alberto Ortiz Arribas
    Fecha: 17-03-2025
    Resumen: Muestra el menu de inicio para el usuario.
*/


import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'dart:convert';
import 'package:tfgandroid/login_screen.dart';
import 'package:tfgandroid/edit_profile.dart';
import 'package:tfgandroid/resultados.dart';
import 'package:tfgandroid/insertar_resultados.dart';
import 'package:tfgandroid/aceptar_partido.dart';
import 'package:tfgandroid/clasificacion.dart';

void main() {
  runApp(UserHomeApp());
}

class UserHomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserHomePage(),
    );
  }
}

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  String nombreUsuario = '';
  final Dio dio = Dio();
  final CookieJar cookieJar = CookieJar();

  @override
  void initState() {
    super.initState();
    dio.interceptors.add(CookieManager(cookieJar)); // Habilitar manejo de cookies
    obtenerUsuario();
  }

  Future<void> obtenerUsuario() async {
    var url = 'http://192.168.252.122/android/session_start.php';
    try {
      var response = await dio.get(url);

      if (response.statusCode == 200) {
        var data = response.data;
        if (data.containsKey('usuario')) {
          setState(() {
            nombreUsuario = data['usuario'];
          });
        } else {
          setState(() {
            nombreUsuario = 'Usuario desconocido';
          });
        }
      } else {
        setState(() {
          nombreUsuario = 'Error en el servidor';
        });
      }
    } catch (e) {
      setState(() {
        nombreUsuario = 'Error de conexión';
      });
      print("Error obteniendo usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/tenis2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bienvenido, $nombreUsuario!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text('Selecciona una opción:',
                    style: TextStyle(fontSize: 18, color: Colors.green), textAlign: TextAlign.center),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
                  },
                  child: Text('Ver Perfil'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClasificacionUserPage(),
                      ),
                    );
                  },
                  child: Text('Clasificación'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ResultadosPartidos()));
                  },
                  child: Text('Resultados'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrarPartido()));
                  },
                  child: Text('Insertar resultado'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AceptarPartido(),
                      ),
                    );
                  },
                  child: Text('Aceptar partidos'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text('Cerrar Sesión'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClasificacionPage extends StatefulWidget {
  final String correoUsuario;

  ClasificacionPage({required this.correoUsuario});

  @override
  _ClasificacionPageState createState() => _ClasificacionPageState();
}

class _ClasificacionPageState extends State<ClasificacionPage> {
  List<Map<String, dynamic>> clasificacion = [];

  @override
  void initState() {
    super.initState();
    obtenerClasificacion();
  }

  Future<void> obtenerClasificacion() async {
    final url = Uri.parse('http://192.168.252.122/android/obtener_clasificacion.php');

    try {
      final response = await http.post(url, body: {"correo": widget.correoUsuario});

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data is List) {
          setState(() {
            clasificacion = List<Map<String, dynamic>>.from(data);
          });
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clasificación"), backgroundColor: Colors.green),
      body: clasificacion.isEmpty
          ? Center(child: Text("No hay datos disponibles"))
          : ListView.builder(
        itemCount: clasificacion.length,
        itemBuilder: (context, index) {
          final item = clasificacion[index];
          return ListTile(
            title: Text("${item['nombre']} ${item['apellidos']}"),
            subtitle: Text("Correo: ${item['correo']}"),
            trailing: Text("Puntos: ${item['puntuaje']}"),
          );
        },
      ),
    );
  }
}
