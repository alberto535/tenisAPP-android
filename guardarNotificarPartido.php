<?php
header('Content-Type: application/json');
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "l&r";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => 'Error de conexión']));
}

// Obtener datos del partido desde Flutter
$nombre_participantes = $_POST['nombre_participantes'] ?? null;
$resultado = $_POST['resultado'] ?? null;
$division = $_POST['division'] ?? null;

if (!$nombre_participantes || !$resultado || !$division) {
    echo json_encode(['success' => false, 'message' => 'Faltan datos']);
    exit;
}

// 1️⃣ Obtener el `id_jornada` activo (sin `fecha_fin`)
$sqlJornada = "SELECT id FROM jornada WHERE fecha_fin IS NULL LIMIT 1";
$resultJornada = $conn->query($sqlJornada);
if ($resultJornada->num_rows == 0) {
    echo json_encode(['success' => false, 'message' => 'No hay jornada activa']);
    exit;
}
$id_jornada = $resultJornada->fetch_assoc()['id'];

// 2️⃣ Obtener el último ID de partidos y sumarle 1
$sqlUltimoId = "SELECT MAX(id) as max_id FROM partidos";
$resultUltimoId = $conn->query($sqlUltimoId);
$ultimoId = $resultUltimoId->fetch_assoc()['max_id'] ?? 0;
$nuevoId = $ultimoId + 1;

// 3️⃣ Insertar el partido en la base de datos
$sqlInsert = "INSERT INTO partidos (id, fecha, resultado, nombre_participantes, division, estado, id_jornada)
              VALUES (?, NOW(), ?, ?, ?, 'pendiente', ?)";

$stmt = $conn->prepare($sqlInsert);
$stmt->bind_param("isssi", $nuevoId, $resultado, $nombre_participantes, $division, $id_jornada);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Partido registrado, esperando aceptación']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error al registrar partido']);
}

$stmt->close();
$conn->close();
?>
