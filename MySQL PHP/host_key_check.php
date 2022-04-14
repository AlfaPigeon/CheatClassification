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


if(isset($_POST["host_key"])){
       //checking if there is POST data

       $host_key = $_POST["host_key"];
       

       $host_key = mysqli_real_escape_string($conn, $host_key);

       $sql = "SELECT * FROM HOST_KEYS WHERE host_key = '$host_key'";
       //building SQL query
       $res = mysqli_query($conn, $sql);
       $numrows = mysqli_num_rows($res);
       $obj = mysqli_fetch_object($res);
       
       if($numrows > 0) {
                $return["success"] = true;
                $return["error"] = false;
                $return["company"] = $obj->company;
        } else {
               $return["error"] = true;
               $return["message"] = 'Invalid Host Key';
        }
           
}

header('Content-Type: application/json');
echo json_encode($return);



?>
