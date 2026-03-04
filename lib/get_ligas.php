<?php
/*
    Autor: Alberto Ortiz Arribas
    Fecha: 31-03-2025
    Resumen: Extrae informacion de la tabla ligas, las ligas con fecha de finalizacion.
 */

header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

$conn = new mysqli("localhost", "root", "", "l&r");

if ($conn->connect_error) {
    die(json_encode(["error" => "Conexión fallida: " . $conn->connect_error]));
}

// Consulta para obtener ligas finalizadas
$query = "SELECT nombre, fecha_creacion, fecha_finalizacion
          FROM ligas
          WHERE fecha_finalizacion IS NOT NULL AND fecha_finalizacion <> '0000-00-00'
          ORDER BY fecha_finalizacion DESC";

$result = $conn->query($query);

$ligas = [];
while ($row = $result->fetch_assoc()) {
    $ligas[] = $row;
}

echo json_encode(["ligas" => $ligas]);

$conn->close();
?>
