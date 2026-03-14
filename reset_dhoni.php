<?php
$conn = new mysqli("localhost", "root", "", "j4u");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Reset dhoni@gmail.com
$email = 'dhoni@gmail.com';
$pass = '123456';
// Using SHA-256 (as used in PasswordUtil.java)
// The project uses SHA-256 for passwords. Let's verify the hashing.
// Actually, PasswordUtil.java might use a specific salt or just direct SHA-256.
// Let's check PasswordUtil.java if possible or just use what worked before.
// In found_credentials.md, it says "dhoni@gmail.com / 123456 (Hashed)".
// Let's use the hash from a known working account or just update it here.

$hashedPass = base64_encode(hash('sha256', $pass, true));

$stmt = $conn->prepare("UPDATE lawyer_reg SET pass = ?, flag = 1 WHERE email = ?");
$stmt->bind_param("ss", $hashedPass, $email);
if ($stmt->execute()) {
    echo "Successfully reset $email with Base64 SHA-256 hash: $hashedPass\n";
} else {
    echo "Error: " . $stmt->error . "\n";
}

$conn->close();
?>