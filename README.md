🏆 Herramienta para el Desarrollo de Campeonatos Amateur de Tenis – Aplicación Android
📖 Descripción

Aplicación Android desarrollada con Flutter como parte del Trabajo Fin de Grado.

Esta aplicación consume servicios PHP alojados en un servidor local (XAMPP), permitiendo gestionar ligas de tenis amateur desde dispositivo móvil.

⚠️ IMPORTANTE:
La aplicación necesita conexión al servidor local (localhost), por lo que es obligatorio configurar correctamente la IP del equipo anfitrión.

🏗️ Arquitectura

Frontend móvil: Flutter

Backend: PHP

Base de datos: MySQL

Servidor local: XAMPP

Comunicación: HTTP Requests hacia archivos PHP

💻 Requisitos

Android Studio

SDK Android instalado

SDK Flutter instalado

SDK Dart

XAMPP instalado

Base de datos creada en phpMyAdmin

⚙️ INSTALACIÓN COMPLETA
🗄️ 1️⃣ Configurar Base de Datos (OBLIGATORIO)

Antes de ejecutar la app:

Iniciar XAMPP.

Activar Apache y MySQL.

Abrir:

http://localhost/phpmyadmin

Crear base de datos (ejemplo: liga_tenis).
![IMAGEN CON INFORMACIÓN ACERCA DEL ESQUEMA DE LA BASE DE DATOS](https://github.com/alberto535/tenisAPP-android/blob/main/BasesDeDatos.drawio.png?raw=true)

Crear las siguientes tablas según el esquema del diagrama:

administradores

usuarios

ligas

jornada

jornada_partidos

partidos

clasificacion

⚠️ Es imprescindible respetar:

Relaciones

Claves foráneas

Estados

Tipos de datos

📂 2️⃣ Colocar Archivos PHP en XAMPP

Los archivos PHP deben copiarse dentro de:

C:\xampp\htdocs\

Ejemplo:

C:\xampp\htdocs\liga_tenis\
🌐 3️⃣ Configurar IP (PASO CRÍTICO)

Como la app Android NO puede usar localhost, se debe usar la IP local del ordenador.

Obtener IP:

Abrir CMD

Ejecutar:

ipconfig

Copiar la dirección IPv4
Ejemplo:

192.168.1.35
Modificar la IP en el Proyecto Flutter

Buscar en los archivos .dart las URLs que apuntan a:

http://localhost/...

Y reemplazarlas por:

http://TU_IP_LOCAL/liga_tenis/archivo.php

Ejemplo:

❌ Incorrecto:

http://localhost/liga_tenis/login.php

✅ Correcto:

http://192.168.1.35/liga_tenis/login.php

⚠️ Si no se cambia la IP, la app no podrá conectar con el servidor.

📱 4️⃣ Ejecutar Aplicación Android

Abrir Android Studio.

Open Project.

Seleccionar carpeta del proyecto Flutter.

Abrir archivo pubspec.yaml.

Pulsar Pub Get.

Crear dispositivo virtual:

Tools → Device Manager

Ejecutar la app.

🔁 Flujo de Funcionamiento

Usuario se registra.

Administrador lo acepta.

Usuario inicia sesión.

Inserta resultados.

Contrincante acepta.

Administrador genera jornadas y gestiona ligas.

⚠️ Problemas Comunes

❌ Error de conexión
→ Verificar:

Apache activo

MySQL activo

IP correcta

Archivos en htdocs

❌ No conecta desde emulador
→ Comprobar firewall de Windows

🔐 Seguridad

Validación de campos

Estados de partidos (pendiente, activo, procesado)

Validación de jornada activa

Control de roles (admin / usuario)

👨‍🎓 Autor

Alberto Ortiz Arribas
Grado en Ingeniería Informática – Especialidad Software
Universidad de Córdoba
Junio 2025
