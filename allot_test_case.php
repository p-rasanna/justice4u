<?php
$conn = new mysqli("localhost", "root", "", "j4u");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Ensure dhoni@gmail.com has at least one case assigned in allotlawyer
// We'll take case ID 3 (Aviraj Hakke) from casetb and assign it to dhoni@gmail.com in allotlawyer

$lawyerEmail = 'dhoni@gmail.com';
$caseId = 3;

// Delete existing if any (to be clean)
$conn->query("DELETE FROM allotlawyer WHERE cid = $caseId");

// Insert from casetb
$result = $conn->query("SELECT * FROM casetb WHERE cid = $caseId");
if ($row = $result->fetch_assoc()) {
    $stmt = $conn->prepare("INSERT INTO allotlawyer (cid, name, title, des, curdate, courttype, city, mop, tid, amt, cname, lname) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("isssssssssss", $row['cid'], $row['name'], $row['title'], $row['des'], $row['curdate'], $row['courttype'], $row['city'], $row['mop'], $row['tid'], $row['amt'], $row['cname'], $lawyerEmail);
    if ($stmt->execute()) {
        echo "Successfully assigned case $caseId to $lawyerEmail in allotlawyer\n";
    } else {
        echo "Error: " . $stmt->error . "\n";
    }
} else {
    echo "Case $caseId not found in casetb\n";
}

$conn->close();
?>