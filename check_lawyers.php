<?php
$conn = new mysqli("localhost", "root", "", "j4u");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
$sql = "SELECT email, name, pass FROM lawyer_reg WHERE email='dhoni@gmail.com'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        echo "Email: " . $row["email"] . " - Name: " . $row["name"] . " - Pass: " . $row["pass"] . "\n";
    }
} else {
    echo "0 results";
}
$conn->close();
?>