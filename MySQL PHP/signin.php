<?php
$servername = "localhost";
$username = "root";
$password = "kebohso1";
$dbname = "arsos_db";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
header('Content-Type: application/json');
echo json_encode($return);



?>
