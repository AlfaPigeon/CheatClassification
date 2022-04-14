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


if(isset($_POST["id"]) && isset($_POST["percentage"])){
       //checking if there is POST data

       $id = $_POST["id"];
       $percentage = $_POST["percentage"];
       

       $id = mysqli_real_escape_string($conn, $id);
       $percentage = mysqli_real_escape_string($conn, $percentage);

       $sql = "SELECT * FROM OBJECT_DETECTION_OUTPUTS WHERE user_id = '$id'";
       //building SQL query
       $res = mysqli_query($conn, $sql);
       $numrows = mysqli_num_rows($res);
       $obj = mysqli_fetch_object($res);
       
       echo "hey";
       
       if($numrows > 0) { //UPDATE THE ROW
            
            
            $update_query = "UPDATE OBJECT_DETECTION_OUTPUTS SET percentage = '$percentage' WHERE user_id = '$id'";
            $res = mysqli_query($conn, $update_query);
            $return["success"] = true;
            $return["error"] = false;
        
           
       } else { //CREATE ROW
            echo "else";
            $insert_query = "INSERT INTO OBJECT_DETECTION_OUTPUTS(user_id,percentage) VALUES('$id','$percentage')";
            if(!$insert_query) {
                $return["error"] = true;
                $return["message"] = 'Query error';
            } else {
                $return["success"] = true;
                $return["error"] = 'false';
            }
            $res = mysqli_query($conn, $insert_query);    

        }
           
}

header('Content-Type: application/json');
echo json_encode($return);



?>
