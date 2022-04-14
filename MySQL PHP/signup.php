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


if(isset($_POST["host_key"]) && isset($_POST["id"]) && isset($_POST["name"]) && isset($_POST["surname"]) && isset($_POST["email"]) && isset($_POST["is_host"])){
       //checking if there is POST data

       $host_key = $_POST["host_key"];
       $id = $_POST["id"];
       $name = $_POST["name"];
       $surname = $_POST["surname"];
       $email = $_POST["email"];
       $is_host = $_POST["is_host"];
       

       $host_key = mysqli_real_escape_string($conn, $host_key);
       $id = mysqli_real_escape_string($conn, $id);
       $name = mysqli_real_escape_string($conn, $name);
       $surname = mysqli_real_escape_string($conn, $surname);
       $email = mysqli_real_escape_string($conn, $email);
       $is_host = mysqli_real_escape_string($conn, $is_host);
       //escape inverted comma query conflict from string

       $sql = "SELECT * FROM HOST_KEYS WHERE host_key = '$host_key'";
       //building SQL query
       $res = mysqli_query($conn, $sql);
       $numrows = mysqli_num_rows($res);
       $obj = mysqli_fetch_object($res);
       
       if($is_host == '1') {
           if($numrows > 0) {
               $addsql = "INSERT INTO USERS(id,name,surname,email,is_host,host_id) VALUES ('$id', '$name', '$surname' , '$email' , '1',
               '$obj->host_id')";
            $res = mysqli_query($conn, $addsql);
            if(!$addsql) {
                $return["error"] = true;
                $return["message"] = 'Query error';
            } else {
                $return["success"] = true;
                $return["company"] = $obj->company;
            }
            $numrows = mysqli_num_rows($res);
            $obj = mysqli_fetch_object($res);
           } else {
               $return["error"] = true;
               $return["message"] = 'Invalid Host Key';
           }
           
       } else {
           $addsql = "INSERT INTO USERS(id,name,surname,email,is_host,host_id) VALUES ('$id', '$name', '$surname' , '$email' , '0', '2')";
            $res = mysqli_query($conn, $addsql);
            $numrows = mysqli_num_rows($res);
            $obj = mysqli_fetch_object($res);
             if(!$addsql) {
                $return["error"] = true;
                $return["message"] = 'Query error';
            } else {
                $return["success"] = true;
                $sql = "SELECT * FROM HOST_KEYS WHERE host_id = '2'";
                $res = mysqli_query($conn, $sql);
                $numrows = mysqli_num_rows($res);
                $obj = mysqli_fetch_object($res);
                $return["company"] = $obj->company;
            }
       }
       
}

header('Content-Type: application/json');
echo json_encode($return);



?>
