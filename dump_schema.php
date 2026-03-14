<?php
$conn = new mysqli("localhost", "root", "", "j4u");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

function dumpTable($conn, $table)
{
    echo "\n--- Structure of $table ---\n";
    $result = $conn->query("DESCRIBE $table");
    if ($result) {
        while ($row = $result->fetch_assoc()) {
            echo $row["Field"] . " (" . $row["Type"] . ")\n";
        }
    } else {
        echo "Error: " . $conn->error . "\n";
    }
}

dumpTable($conn, "lawyer_reg");
dumpTable($conn, "intern");
dumpTable($conn, "intern_tasks");
dumpTable($conn, "intern_assignments");
dumpTable($conn, "cust_reg");
dumpTable($conn, "casetb");
dumpTable($conn, "allotlawyer");
dumpTable($conn, "case_documents");

$conn->close();
?>