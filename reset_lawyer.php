<?php
$conn = new mysqli("localhost", "root", "", "j4u");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
// Generate hash for '123456' using SHA-256
$password = "123456";
$hash = base64_encode(hash("sha256", $password, true));
echo "Generated Hash: " . $hash . "\n";

$sql = "UPDATE lawyer_reg SET pass='$hash' WHERE email='dhoni@gmail.com'";
if ($conn->query($sql) === TRUE) {
    echo "Record updated successfully";
} else {
    echo "Error updating record: " . $conn->error;
}
$conn->close();
?>