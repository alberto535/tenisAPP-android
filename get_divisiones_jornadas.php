<?php
header('Content-Type: application/json');
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$conn = new mysqli('localhost', 'root', '', 'l&r');

if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Error de conexión"]);
    exit;
}

// Obtener divisiones
$divisiones = [];
$res = $conn->query("SELECT DISTINCT division FROM partidos ORDER BY division");
while ($row = $res->fetch_assoc()) {
    $divisiones[] = $row['division'];
}

// Obtener jornadas
$jornadas = [];
$res = $conn->query("SELECT DISTINCT id_jornada FROM partidos ORDER BY id_jornada");
while ($row = $res->fetch_assoc()) {
    $jornadas[] = $row['id_jornada'];
}

echo json_encode(["success" => true, "divisiones" => $divisiones, "jornadas" => $jornadas]);

$conn->close();
?>
