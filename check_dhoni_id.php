<?php
$conn = new mysqli("localhost", "root", "", "j4u");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$email = 'dhoni@gmail.com';
$result = $conn->query("SELECT lid, name, email FROM lawyer_reg WHERE email = '$email'");
if ($row = $result->fetch_assoc()) {
    echo "LID for $email: " . $row['lid'] . " (Name: " . $row['name'] . ")\n";
} else {
    echo "Lawyer $email not found!\n";
}

$conn->close();
?>