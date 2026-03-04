/*
    Autor: Alberto Ortiz Arribas
    Fecha: 17-03-2025
    Resumen: Muestra el menu de para gestionar las ligas para el administrador.
*/

import 'package:flutter/material.dart';
import 'package:tfgandroid/home.dart';
import 'package:tfgandroid/crearLiga.dart';
import 'package:tfgandroid/consultar_ligas_pasadas.dart';
import 'package:tfgandroid/administrar-ligas-activas.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Ligas',
      home: GestionLigasPage(),
    );
  }
}
class GestionLigasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/tenis3.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Gestión de Ligas",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegistrarLigaPage()),
                      );
                    },
                    child: Text('Crear liga') ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LigasPage()),
                      );
                    },
                    child: Text('Consultar Ligas Pasadas') ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LigasActivasPage()),
                  );
                },
                child: Text('Administrar Ligas Activas') ),
                SizedBox(height: 20),
                // Aquí se eliminó el Text(responseText)
                ElevatedButton(
                    onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    );
                },
                child: Text('Volver atrás'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}