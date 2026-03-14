<?php
$conn = new mysqli("localhost", "root", "", "j4u");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

function dumpData($conn, $table, $limit = 5)
{
    echo "\n--- Data in $table ---\n";
    $result = $conn->query("SELECT * FROM $table LIMIT $limit");
    if ($result) {
        $fields = $result->fetch_fields();
        foreach ($fields as $field) {
            echo $field->name . "\t";
        }
        echo "\n";
        while ($row = $result->fetch_assoc()) {
            foreach ($row as $val) {
                echo $val . "\t";
            }
            echo "\n";
        }
    } else {
        echo "Error: " . $conn->error . "\n";
    }
}

dumpData($conn, "allotlawyer");
dumpData($conn, "casetb");
dumpData($conn, "intern_assignments");
dumpData($conn, "intern");

$conn->close();
?>