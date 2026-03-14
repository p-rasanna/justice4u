<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Access Denied - Justice4U</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8ffff;
            color: #333;
            text-align: center;
            padding: 50px;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 80vh;
        }
        .container {
            max-width: 500px;
            background: #fff;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0px 4px 15px rgba(0,0,0,0.1);
        }
        h1 {
            color: #dc3545;
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        p {
            font-size: 1.1em;
            color: #666;
            margin-bottom: 30px;
        }
        a {
            display: inline-block;
            padding: 12px 25px;
            background-color: #0d6efd;
            color: #fff;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            transition: background-color 0.3s;
        }
        a:hover {
            background-color: #0b5ed7;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>403</h1>
        <h2>Access Denied</h2>
        <p>Sorry, you do not have permission to access the requested resource. Please ensure you are logged in with the correct account privileges.</p>
        <a href="Login.html">Return to Login</a>
    </div>
</body>
</html>
