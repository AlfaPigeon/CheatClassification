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

$sql = "SELECT * FROM USERS";
//building SQL query
       
$result = $conn->query($sql);

if ($result->num_rows > 0) {
  $return["success"] = true;
  $count = 0;
  while($row = $result->fetch_assoc()) {
    $return["id"][$count] = $row["id"];
    $return["name"][$count] = $row["name"];
    $return["surname"][$count] = $row["surname"];
    $return["email"][$count] = $row["email"];
    $return["is_host"][$count] = $row["is_host"];
    $return["host_id"][$count] = $row["host_id"];
    $count = $count + 1;
  }
} else {
  echo "0 results";
}
           

header('Content-Type: application/json');
echo json_encode($return);



?>
