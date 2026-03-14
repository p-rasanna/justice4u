<?php
$conn = new mysqli("localhost", "root", "", "j4u");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$conn->query("SET FOREIGN_KEY_CHECKS = 0");

// 1. Drop existing tables
$conn->query("DROP TABLE IF EXISTS intern_tasks");
$conn->query("DROP TABLE IF EXISTS intern_assignments");
echo "Dropped intern_tasks and intern_assignments.\n";

// 2. Re-create intern_assignments
$sql1 = "CREATE TABLE intern_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    intern_email VARCHAR(200) NOT NULL,
    case_id INT NOT NULL,
    alid INT NOT NULL,
    assigned_by VARCHAR(200) NOT NULL,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

// 3. Re-create intern_tasks
$sql2 = "CREATE TABLE intern_tasks (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    due_date DATE,
    status VARCHAR(50) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assignment_id) REFERENCES intern_assignments(assignment_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

if ($conn->query($sql1) && $conn->query($sql2)) {
    echo "Re-created tables successfully with correct schema.\n";
} else {
    echo "Error recreating tables: " . $conn->error . "\n";
}

$conn->query("SET FOREIGN_KEY_CHECKS = 1");

$conn->close();
?>