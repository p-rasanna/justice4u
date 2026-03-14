<?php
$conn = new mysqli("localhost", "root", "", "j4u");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$intern_email = 'virat@gmail.com';
$case_id = 3;
$alid = 17; // dhoni@gmail.com
$assigned_by = 'dhoni@gmail.com';

echo "Attempting manual INSERT into intern_assignments...\n";
$stmt = $conn->prepare("INSERT INTO intern_assignments (intern_email, case_id, alid, assigned_by, status) VALUES (?, ?, ?, ?, 'ACTIVE')");
$stmt->bind_param("siis", $intern_email, $case_id, $alid, $assigned_by);

if ($stmt->execute()) {
    echo "SUCCESS: Manual assignment persisted.\n";
} else {
    echo "ERROR: " . $stmt->error . "\n";
}

$conn->close();
?>