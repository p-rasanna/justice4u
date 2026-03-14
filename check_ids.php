<?php
$conn = new mysqli("localhost", "root", "", "j4u");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

function dumpTable($conn, $table)
{
    echo "\n--- Data in $table ---\n";
    $result = $conn->query("SELECT * FROM $table");
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
    }
}

dumpTable($conn, "lawyer_reg");
dumpTable($conn, "intern_assignments");

$conn->close();
?>