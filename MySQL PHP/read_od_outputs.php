<?php
$servername = "srvc31.turhost.com";
$username = "kemalba2_kemalb";
$password = "Ketoketo1!";
$dbname = "kemalba2_overseer";


// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT * FROM OBJECT_DETECTION_OUTPUTS";
//building SQL query
       
$result = $conn->query($sql);

if ($result->num_rows > 0) {
  $return["success"] = true;
  $count = 0;
  while($row = $result->fetch_assoc()) {
    $return["user_id"][$count] = $row["user_id"];
    $return["percentage"][$count] = $row["percentage"];
    $count = $count + 1;
  }
} else {
  echo "0 results";
}
           

header('Content-Type: application/json');
echo json_encode($return);



?>
